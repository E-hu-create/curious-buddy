# Recorded sounds

The 13 clips in `android/app/src/main/res/raw/snd_*.wav` are cut from real
recordings on [BigSoundBank](https://bigsoundbank.com/licenses.html). Each
recording's own page said "CC0 (public domain): Free and royalty-free" when it
was checked on 2026-10-30, and the product owner approved the list that day.
Credit isn't required; this list is kept so anyone can check where they came
from.

| Clip | BigSoundBank number | Recording |
|---|---|---|
| `snd_rooster` | 0283 | [Rooster Song](https://bigsoundbank.com/song-of-rooster-s0283.html) |
| `snd_cow` | 2383 | [Cow moos #3](https://bigsoundbank.com/cow-moos-3-s2383.html) |
| `snd_sheep` | 2343 | [Sheep #1](https://bigsoundbank.com/sheep-1-s2343.html) |
| `snd_dog` | 2955 | [Barking dog #3](https://bigsoundbank.com/barking-dog-3-s2955.html) |
| `snd_cat` | 1890 | [Meow Cat #2](https://bigsoundbank.com/meow-cat-2-s1890.html) |
| `snd_frog` | 0997 | [Frogs #1](https://bigsoundbank.com/frogs-1_s0997.html) |
| `snd_bee` | 1000 | [Bumblebee #1](https://bigsoundbank.com/bumblebee-1-s1000.html) |
| `snd_thunder` | 3113 | [Thunder #2](https://bigsoundbank.com/thunder-2-s3113.html) |
| `snd_rain` | 1290 | [Rain on Puddle](https://bigsoundbank.com/rain-on-puddle-s1290.html) |
| `snd_sea` | 0266 | [Sea: Waves](https://bigsoundbank.com/sea-waves-s0266.html) |
| `snd_train` | 3009 | [Steam Locomotive, Passage](https://bigsoundbank.com/steam-locomotive-passage-s3009.html) |
| `snd_helicopter` | 0263 | [Helicopter #1](https://bigsoundbank.com/helicopter-1-s0263.html) |
| `snd_clock` | 0007 | [Clock](https://bigsoundbank.com/clock-s0007.html) |

`tool/prepare_game_sounds.py` made the clips: the loudest four seconds at most,
with soft fades and an even volume.

## Buddy's recorded voice

`assets/voice/` holds one AAC clip per sentence, named by
`VoiceClips.name`, with `index.txt` listing what is recorded. Lines with any
sentence missing use the phone's own voice. Made offline with the Kokoro-82M
model (Apache 2.0 licence, voice `bf_emma`), so the clips may ship in a paid
app. Do not swap in voices from free online tools without checking their
licence. To add lines: run `tool/export_voice_lines_test.dart`, then
`tool/record_voice.py`, then rebuild `index.txt`.
