public import Rational

/// A steady beat: so many ticks in each unit of time, as an exact positive fraction.
///
/// Tick `index` lasts from `start(of: index)` up to, but not at, `start(of: index + 1)`.
/// Tick zero starts at instant zero, and ticks run both ways from there.
public struct Rate: Hashable, Sendable {
    /// Ticks in one unit of time: 30000/1001 for the NTSC frame rate in seconds.
    public let perUnit: Rational

    /// Fails with `.nonpositive` for zero or a negative fraction.
    public init(_ perUnit: Rational) throws(Error) {
        guard perUnit.polarity == .positive else { throw .nonpositive }
        self.perUnit = perUnit
    }

    /// `count` ticks in every `units` units of time. Fails with `.units` for no units and
    /// with `.nonpositive` when the fraction is zero or negative.
    public init(_ count: Integer, per units: Integer = 1) throws(Error) {
        let fraction: Rational
        do throws(Rational.Error) {
            fraction = try Rational(numerator: count, denominator: units)
        } catch {
            throw .units
        }
        try self.init(fraction)
    }
}

extension Rate {
    /// How long one tick lasts: 1001/30000 of a second at 30000/1001 a second.
    public var period: Rational {
        do throws(Rational.Error) {
            return try perUnit.inverted()
        } catch {
            preconditionFailure("a rate is positive")
        }
    }

    /// The instant tick `index` starts.
    public func start(of index: Integer) -> Rational { Rational(index) * period }

    /// The instant halfway through tick `index`.
    public func centre(of index: Integer) -> Rational { Rational(2 * index + 1) * period * Self.half }

    /// The tick that is running at `instant`. It is also the number of ticks that ended at or before a
    /// non-negative `instant`.
    public func index(at instant: Rational) -> Integer { (instant * perUnit).floor }

    /// The number of ticks that start before `instant`, counted from tick zero; negative before instant zero.
    public func started(before instant: Rational) -> Integer { (instant * perUnit).ceiling }
}

extension Rate {
    private static var half: Rational {
        do throws(Rational.Error) {
            return try Rational(numerator: 1, denominator: 2)
        } catch {
            preconditionFailure("two is not zero")
        }
    }
}
