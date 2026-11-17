import Configurator

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
