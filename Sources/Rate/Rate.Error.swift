extension Rate {
    public enum Error: Swift.Error, Hashable, Sendable {
        /// A rate of zero or fewer ticks per unit.
        case nonpositive
        /// Ticks counted over no units of time.
        case units
    }
}
