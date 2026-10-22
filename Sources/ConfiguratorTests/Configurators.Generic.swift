import Configurator
import Testing

extension Configurators {
    struct Generic {
        var x: Int

        @Configurator init<T: BinaryInteger, E>(
            x: T,
            body: (inout Self) throws(E) -> ()
        ) throws(E) where T: Sendable {
            self.x = .init(x)
            try body(&self)
        }
    }
}
extension Configurators {
    @Test static func MultipleGenerics() {
        let generic: Generic = .init(x: 7 as UInt8)
        #expect(generic.x == 7)
    }
}
