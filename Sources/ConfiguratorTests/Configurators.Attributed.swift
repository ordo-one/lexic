import Configurator

extension Configurators {
    struct Attributed {
        var x: Int

        @Configurator init<E>(
            x: Int,
            body: @Sendable (inout Self, Int) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(&self, x)
        }
    }
}
