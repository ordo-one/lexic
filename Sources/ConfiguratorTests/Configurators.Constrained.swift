import Configurator

extension Configurators {
    struct Constrained {
        var x: Int

        @Configurator init<E: Error>(
            x: Int,
            body: (inout Self) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(&self)
        }
    }
}
