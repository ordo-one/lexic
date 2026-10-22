import Configurator
import Testing

extension Configurators {
    struct Failable {
        var x: Int

        @Configurator init?<E>(
            x: Int,
            body: (inout Self) throws(E) -> ()
        ) throws(E) {
            guard x >= 0 else {
                return nil
            }
            self.x = x
            try body(&self)
        }
    }
}
extension Configurators {
    @Test static func FailableInitializer() {
        let failable: Failable? = .init(x: 6)
        #expect(failable?.x == 6)
        #expect(Failable.init(x: -1) == nil)
    }
}
