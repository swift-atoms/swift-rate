# swift-rate

Use this package when something happens at a steady rate and you must say exactly when: video frames at 30000/1001 a second, audio samples at 48000 a second, a control loop at 120 a second. Start from `Rate`, an exact positive fraction of ticks per unit of time, and ask it when a tick starts, which tick holds an instant, and how many ticks started before an instant. Instants are `Rational`s in whatever unit the rate is per; the rate does not know whether that is a second. When you need a conversion factor between two typed domains rather than a beat in time, use swift-ratio. When you only need the fraction, use `Rational` from swift-rational.

## Laws

- A rate is positive. `Rate(_:)` fails with `.nonpositive` for zero or a negative fraction, and `Rate(_:per:)` fails with `.units` when the ticks are counted over no units. Equal fractions are equal rates: 60 per 2 is 30 per 1.
- `frequency` is the rate as a fraction, ticks per unit of time, and `period` is one over it, exactly.
- Tick zero starts at instant zero. Tick `index` starts at `index` periods and lasts up to, but not at, the start of the next, so every instant belongs to exactly one tick. Indices run below zero for instants before zero.
- `centre(of:)` is as far from the tick's start as from the next tick's start.
- `index(at:)` is the tick that holds the instant: `index(at: start(of: i))` is `i`, and so is the index at any instant up to, but not at, `start(of: i + 1)`.
- `started(before:)` counts the ticks that start before the instant, from tick zero. At a tick's start it equals `index(at:)`; anywhere inside a tick it is one more.
- Nothing rounds and nothing overflows: indices are arbitrary-precision `Integer`s and instants are `Rational`s. So differences of `started(before:)` or of `index(at:)` over consecutive stretches add up to the value for the whole stretch. The audio samples that start in each video frame, summed over any run of frames, are exactly the samples that start in the run: at 48000 a second against 30000/1001 a second the counts are 1602 and 1601 and never drift.
