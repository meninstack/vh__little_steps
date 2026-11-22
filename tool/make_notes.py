"""Synthesises the sounds the app plays instead of reading names aloud.

Writes into assets/sounds/:
    wood/note_1.wav .. note_8.wav   played when a child taps a card
    bell/note_1.wav .. note_8.wav   played when a child taps an animal friend
    celebrate.wav                   played when a routine is finished

The notes form a C major pentatonic scale, so any sequence a child taps
sounds pleasant. Files are mono, 16-bit, 44.1 kHz. Standard library only, and
the output is identical on every run.

Usage:
    python tool/make_notes.py [output-dir]
"""

import argparse
import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100

# C major pentatonic from C5. Small phone speakers reproduce this range well.
NOTES_HZ = [523.25, 587.33, 659.25, 783.99, 880.00, 1046.50, 1174.66, 1318.51]

# Each partial is (frequency ratio, amplitude, decay time constant in seconds).
# The ratios are those of a struck bar: 1 : 4 : ~9.2 for a tuned wooden bar,
# 1 : 2.76 : 5.4 : 8.93 for a free metal bar.
TIMBRES = {
    "wood": {
        "seconds": 0.6,
        "partials": [(1.0, 1.0, 0.16), (4.0, 0.30, 0.05), (9.2, 0.10, 0.018)],
    },
    "bell": {
        "seconds": 1.0,
        "partials": [
            (1.0, 1.0, 0.32),
            (2.76, 0.45, 0.18),
            (5.40, 0.25, 0.09),
            (8.93, 0.12, 0.045),
        ],
    },
}

# The celebration is a rising run of bell notes: C5, E5, G5, C6.
CELEBRATION_NOTES = [1, 3, 4, 6]
CELEBRATION_STEP_SECONDS = 0.13

ATTACK_SECONDS = 0.002
RELEASE_SECONDS = 0.02
PEAK = 0.85


def strike(frequency, timbre):
    """One struck note, not yet normalised."""
    spec = TIMBRES[timbre]
    count = int(spec["seconds"] * SAMPLE_RATE)
    attack = int(ATTACK_SECONDS * SAMPLE_RATE)
    release = int(RELEASE_SECONDS * SAMPLE_RATE)
    samples = []
    for index in range(count):
        t = index / SAMPLE_RATE
        value = sum(
            amplitude
            * math.exp(-t / decay)
            * math.sin(2 * math.pi * frequency * ratio * t)
            for ratio, amplitude, decay in spec["partials"]
        )
        if index < attack:
            value *= index / attack
        if index >= count - release:
            value *= (count - 1 - index) / release
        samples.append(value)
    return samples


def normalise(samples):
    loudest = max(abs(value) for value in samples)
    return [value / loudest * PEAK for value in samples]


def celebration():
    step = int(CELEBRATION_STEP_SECONDS * SAMPLE_RATE)
    notes = [strike(NOTES_HZ[number - 1], "bell") for number in CELEBRATION_NOTES]
    mix = [0.0] * (step * (len(notes) - 1) + len(notes[-1]))
    for position, note in enumerate(notes):
        for index, value in enumerate(note):
            mix[position * step + index] += value
    return mix


def write_wav(path, samples):
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(SAMPLE_RATE)
        out.writeframes(
            b"".join(
                struct.pack("<h", round(value * 32767))
                for value in normalise(samples)
            )
        )
    print(f"{path}  {path.stat().st_size} bytes")


def main():
    default_dir = Path(__file__).resolve().parent.parent / "assets" / "sounds"
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("output_dir", type=Path, nargs="?", default=default_dir)
    args = parser.parse_args()

    for timbre in TIMBRES:
        for number, frequency in enumerate(NOTES_HZ, start=1):
            write_wav(
                args.output_dir / timbre / f"note_{number}.wav",
                strike(frequency, timbre),
            )
    write_wav(args.output_dir / "celebrate.wav", celebration())


if __name__ == "__main__":
    main()
