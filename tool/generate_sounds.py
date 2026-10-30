"""Generates Curious Buddy's sound effects from scratch.

Every sound is synthesised here (sine tones with soft decay), so there is no
third-party audio and no licence to track. Standard library only.

Run from the project root after changing a sound:
    python tool/generate_sounds.py
"""
import math
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path('android/app/src/main/res/raw')


def silence(seconds):
    return [0.0] * int(RATE * seconds)


# Bluetooth audio can take a moment to wake, which would swallow the start of
# a short sound, so the main sounds begin with a brief silence.
WAKE = silence(0.12)


def tone(freq, seconds, volume=0.85, end_freq=None):
    """A soft bell-like note: quick attack, gentle decay, a little overtone."""
    samples = []
    count = int(RATE * seconds)
    phase = 0.0
    for i in range(count):
        t = i / count
        f = freq if end_freq is None else freq + (end_freq - freq) * t
        phase += 2 * math.pi * f / RATE
        attack = min(1.0, i / (RATE * 0.004))
        decay = math.exp(-4.0 * t)
        release = min(1.0, (count - i) / (RATE * 0.01))
        value = math.sin(phase) + 0.25 * math.sin(2 * phase)
        samples.append(value / 1.25 * attack * decay * release * volume)
    return samples


def sequence(*notes):
    return [s for note in notes for s in note]


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f'{name}.wav'), 'wb') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(b''.join(
            struct.pack('<h', int(max(-1.0, min(1.0, s)) * 32767))
            for s in samples
        ))
    print(name, f'{len(samples) / RATE * 1000:.0f} ms')


# A light pop for small choices.
write('sfx_pop', tone(620, 0.08, 0.6, end_freq=920))

# Two rising notes for a right answer.
write('sfx_correct', sequence(WAKE, tone(784, 0.12), tone(1047, 0.26)))

# Two soft falling notes for a wrong answer: kind, never a buzzer.
write('sfx_gentle', sequence(WAKE, tone(392, 0.14, 0.6), tone(330, 0.20, 0.6)))

# A small rising fanfare for the big moments.
write('sfx_cheer', sequence(
    WAKE, tone(523, 0.11), tone(659, 0.11), tone(784, 0.11), tone(1047, 0.42),
))
