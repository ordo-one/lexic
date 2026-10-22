import Configurator
import Testing

extension Configurators {
    struct Rethrowing {
        var x: Int

        @Configurator init(
            x: Int,
            body: (inout Self) throws -> ()
        ) rethrows {
            self.x = x
            try body(&self)
        }
    }
}
extension Configurators {
    @Test static func RethrowingInitializer() {
        let rethrowing: Rethrowing = .init(x: 2)
        #expect(rethrowing.x == 2)
    }
}
