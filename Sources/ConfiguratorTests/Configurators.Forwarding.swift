import Configurator
import Testing

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
extension Configurators {
    @Test static func ForwardedParameters() {
        var d: Int = 3
        let forwarding: Forwarding = .init(1, b: 2, d: &d)
        #expect(forwarding.sum == 6)
        #expect(forwarding.e == "e")
        #expect(forwarding.default == 0)
        #expect(d == 4)
    }
}
