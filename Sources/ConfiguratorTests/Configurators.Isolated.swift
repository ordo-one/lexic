import Configurator

extension Configurators {
    struct Isolated {
        var x: Int

        @MainActor @Configurator init<E>(
            x: Int,
            body: (inout Self) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(&self)
        }
    }
}
