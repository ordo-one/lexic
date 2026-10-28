import Configurator

extension Configurators {
    struct Unlabeled {
        var x: Int

        @Configurator init<E>(
            x: Int,
            _ body: (inout Self) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(&self)
        }
    }
}
