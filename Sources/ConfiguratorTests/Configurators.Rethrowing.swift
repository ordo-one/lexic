import Configurator

extension Configurators {
    struct Rethrowing {
        var x: Int

        @Configurator init(
            x: Int,
            body: (inout Self) throws -> ()
        ) rethrows {
            self.x = x
            try body(&self)
        }
    }
}
