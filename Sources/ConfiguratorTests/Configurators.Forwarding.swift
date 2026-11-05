import Configurator

extension Configurators {
    struct Forwarding {
        var sum: Int
        var e: String
        var `default`: Int

        @Configurator init<E>(
            _ a: Int,
            b c: Int,
            d: inout Int,
            e: String = "e",
            `default` f: Int = 0,
            body: (inout Self) throws(E) -> (),
        ) throws(E) {
            self.sum = a + c + d
            self.e = e
            self.default = f
            d += 1
            try body(&self)
        }
    }
}
