"""Records Buddy's lines in the Kokoro voice bf_emma (Apache 2.0 licence).

Reads the JSON list from tool/export_voice_lines_test.dart and writes one
AAC clip per sentence to assets/voice/. Finished clips are skipped, so it can
be stopped and started again. Needs: kokoro, soundfile, numpy, ffmpeg.

    python tool/record_voice.py lines.json
"""
import json
import os
import subprocess
import sys
import tempfile
import time

import numpy as np
import soundfile as sf
import torch
from kokoro import KPipeline

VOICE = 'bf_emma'
SPEED = 1.0  # Natural pace sounds least robotic. The app's slider changes it.
RATE = 24000
TAIL = 0.22  # A short rest after each sentence.
BITRATE = '32k'
OUT = os.path.join('assets', 'voice')


def main():
    lines = json.load(open(sys.argv[1], encoding='utf-8'))
    os.makedirs(OUT, exist_ok=True)
    todo = [x for x in lines
            if not os.path.exists(os.path.join(OUT, x['name'] + '.m4a'))]
    print(len(lines), 'sentences,', len(todo), 'to record', flush=True)
    # Leave a core free, so the computer stays usable.
    torch.set_num_threads(max(1, (os.cpu_count() or 2) - 1))
    pipeline = KPipeline(lang_code='b')
    wav = os.path.join(tempfile.gettempdir(), 'buddy_voice.wav')
    start = time.time()
    for i, line in enumerate(todo, 1):
        chunks = [c.audio.numpy() for c in
                  pipeline(line['text'], voice=VOICE, speed=SPEED)]
        if not chunks:
            print('EMPTY', line['text'], flush=True)
            continue
        audio = np.concatenate(chunks + [np.zeros(int(TAIL * RATE))])
        sf.write(wav, audio, RATE)
        out = os.path.join(OUT, line['name'] + '.m4a')
        partial = os.path.join(tempfile.gettempdir(), 'buddy_clip.m4a')
        encode = ['-ar', str(RATE), '-ac', '1', '-c:a', 'aac', '-b:a', BITRATE,
                  '-movflags', '+faststart', partial]
        ffmpeg = ['ffmpeg', '-y', '-loglevel', 'quiet', '-i', wav]
        even = subprocess.run(
            ffmpeg + ['-af', 'loudnorm=I=-18:TP=-1.5:LRA=11'] + encode)
        if even.returncode != 0:
            # Loudness evening fails on very short clips.
            subprocess.run(ffmpeg + encode, check=True)
        os.replace(partial, out)
        if i % 50 == 0 or i == len(todo):
            spent = time.time() - start
            left = spent / i * (len(todo) - i)
            print(f'{i}/{len(todo)} done, about {left / 3600:.1f} hours left',
                  flush=True)
    print('FINISHED', flush=True)


if __name__ == '__main__':
    main()
