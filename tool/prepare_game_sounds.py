"""Turns the What's That Sound? recordings into the app's short clips.

The recordings are CC0, from BigSoundBank; docs/SOUNDS.md lists each one.

Usage: python -I tool/prepare_game_sounds.py <folder of originals> <res/raw>
The folder holds one mp3 per sound, named by the BigSoundBank number. Needs
mpv on the PATH, to decode them.

Each clip is the loudest stretch of its recording, at most four seconds, with
soft fades and an even volume, as 22 kHz mono WAV.
"""

import array
import math
import pathlib
import subprocess
import sys
import wave

RATE = 22050
LENGTH = 4 * RATE
FADE = RATE // 20
PEAK = 26000
LIMIT = 32000
LOUDNESS = 4000
MAX_BOOST = 3

SOUNDS = {
    'rooster': '0283',
    'cow': '2383',
    'sheep': '2343',
    'dog': '2955',
    'cat': '1890',
    'frog': '0997',
    'bee': '1000',
    'thunder': '3113',
    'rain': '1290',
    'sea': '0266',
    'train': '3009',
    'helicopter': '0263',
    'clock': '0007',
}


def decode(source, target):
    subprocess.run(
        [
            'mpv', '--no-config', '--no-video', '--really-quiet',
            f'--audio-samplerate={RATE}', '--audio-channels=mono',
            '--audio-format=s16', f'--o={target}', str(source),
        ],
        check=True,
    )
    with wave.open(str(target), 'rb') as w:
        assert (w.getnchannels(), w.getsampwidth()) == (1, 2), source
        return array.array('h', w.readframes(w.getnframes()))


def loudest_stretch(samples):
    """The start of the LENGTH-long stretch with the most energy."""
    if len(samples) <= LENGTH:
        return 0
    step = RATE // 10
    blocks = [
        sum(s * s for s in samples[i:i + step])
        for i in range(0, len(samples), step)
    ]
    width = LENGTH // step
    best, best_at, total = -1, 0, sum(blocks[:width])
    for i in range(len(blocks) - width):
        if total > best:
            best, best_at = total, i
        total += blocks[i + width] - blocks[i]
    return best_at * step


def shape(samples):
    """Evens out the loudness, gently rounding off any sharp peaks."""
    peak = max(abs(s) for s in samples) or 1
    rms = (sum(s * s for s in samples) / len(samples)) ** 0.5 or 1
    gain = PEAK / peak
    gain = max(gain, min(gain * MAX_BOOST, LOUDNESS / rms))
    out = array.array(
        'h',
        (int(LIMIT * math.tanh(s * gain / LIMIT)) for s in samples),
    )
    fade = min(FADE, len(out) // 4)
    for i in range(fade):
        out[i] = int(out[i] * i / fade)
        out[-1 - i] = int(out[-1 - i] * i / fade)
    return out


def main(source_dir, raw_dir):
    source_dir = pathlib.Path(source_dir)
    raw_dir = pathlib.Path(raw_dir)
    for name, number in SOUNDS.items():
        temp = source_dir / f'{number}.decoded.wav'
        samples = decode(source_dir / f'{number}.mp3', temp)
        start = loudest_stretch(samples)
        clip = shape(samples[start:start + LENGTH])
        target = raw_dir / f'snd_{name}.wav'
        with wave.open(str(target), 'wb') as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(clip.tobytes())
        rms = (sum(s * s for s in clip) / len(clip)) ** 0.5
        print(
            f'{name:11} {len(samples) / RATE:6.1f}s -> {len(clip) / RATE:.1f}s '
            f'from {start / RATE:5.1f}s, loudness {rms:6.0f}'
        )


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
