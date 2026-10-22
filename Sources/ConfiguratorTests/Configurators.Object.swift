import Configurator
import Testing

extension Configurators {
    final class Object {
        var x: Int

        @Configurator init<E>(
            x: Int,
            body: (Object) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(self)
        }
    }
}
extension Configurators {
    @Test static func Convenience() {
        let object: Object = .init(x: 5)
        #expect(object.x == 5)
    }
}
