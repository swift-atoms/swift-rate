import Rate
import Testing

enum `Rate Tests` {}

extension `Rate Tests` {
    @Suite
    struct `A rate lays ticks end to end from instant zero` {}
}

extension `Rate Tests`.`A rate lays ticks end to end from instant zero` {
    static let rates: [Rate] = [(30000, 1001), (24000, 1001), (30, 1), (48000, 1), (1, 3), (7, 5)].map { pair in
        try! Rate(Integer(pair.0), per: Integer(pair.1))
    }

    @Test
    func `only a positive fraction is a rate`() throws {
        #expect(throws: Rate.Error.nonpositive) { try Rate(0) }
        #expect(throws: Rate.Error.nonpositive) { try Rate(-30) }
        #expect(throws: Rate.Error.nonpositive) { try Rate(30, per: -1) }
        #expect(throws: Rate.Error.units) { try Rate(30, per: 0) }
        #expect(try Rate(60, per: 2) == Rate(30))
        #expect(try Rate(-30, per: -1) == Rate(30))
        #expect(try Rate(30000, per: 1001).period == Rational(numerator: 1001, denominator: 30000))
    }

    @Test
    func `every tick starts where the one before ends and holds its own centre`() throws {
        for rate in Self.rates {
            #expect(rate.start(of: 0) == .zero)
            (-40...40).map(Integer.init).forEach { index in
                let (start, centre, end) = (rate.start(of: index), rate.centre(of: index), rate.start(of: index + 1))
                #expect(end - start == rate.period)
                #expect(centre - start == end - centre)
                #expect(rate.index(at: start) == index)
                #expect(rate.index(at: centre) == index)
                #expect(rate.index(at: end) == index + 1)
            }
        }
    }

    @Test
    func `ticks ended and ticks started differ only inside a tick`() throws {
        for rate in Self.rates {
            (-40...40).map(Integer.init).forEach { index in
                #expect(rate.started(before: rate.start(of: index)) == index)
                #expect(rate.started(before: rate.centre(of: index)) == index + 1)
                #expect(rate.index(at: rate.centre(of: index)) == index)
            }
        }
    }

    @Test
    func `the ticks of one rate inside the ticks of another add up without drift`() throws {
        let frames = try Rate(30000, per: 1001)
        let samples = try Rate(48000)
        var total = Integer.zero
        var counts: Set<Integer> = []
        (0..<3003).map(Integer.init).forEach { frame in
            let count = samples.started(before: frames.start(of: frame + 1)) - samples.started(before: frames.start(of: frame))
            counts.insert(count)
            total += count
        }
        // 3003 frames at 30000/1001 a second last 100.2001 seconds exactly: 4 809 604.8 samples.
        #expect(total == 4_809_605)
        #expect(counts == [1601, 1602])
        #expect(samples.index(at: frames.start(of: 3003)) == 4_809_604)
    }
}
