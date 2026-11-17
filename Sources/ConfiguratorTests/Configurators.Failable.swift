import Configurator

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
