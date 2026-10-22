import Configurator
import Testing

extension Configurators {
    struct Attributed {
        var x: Int

        @Configurator init<E>(
            x: Int,
            body: @Sendable (inout Self, Int) throws(E) -> Void
        ) throws(E) {
            self.x = x
            try body(&self, x)
        }
    }
}
extension Configurators {
    @Test static func AttributedClosure() {
        let attributed: Attributed = .init(x: 10)
        #expect(attributed.x == 10)
    }
}
