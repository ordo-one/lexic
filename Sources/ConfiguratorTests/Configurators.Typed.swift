import Configurator
import Testing

extension Configurators {
    struct Typed {
        var x: Int

        @Configurator init<E>(
            x: Int,
            body: (inout Self) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(&self)
        }
    }
}
extension Configurators {
    @Test static func TypedError() {
        let typed: Typed = .init(x: 1)
        #expect(typed.x == 1)
    }
}
