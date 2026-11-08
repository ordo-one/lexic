import Configurator

extension Configurators {
    struct Unconditional {
        var x: Int

        @Configurator init(
            x: Int,
            body: (inout Self) throws -> ()
        ) throws {
            self.x = x
            try body(&self)
        }
    }
}
