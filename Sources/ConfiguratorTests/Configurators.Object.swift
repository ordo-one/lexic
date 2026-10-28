import Configurator

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
