import Configurator

extension Configurators {
    struct OptionalClosure {
        var x: Int
        var y: Int

        @Configurator init(
            x: Int,
            first: (() throws -> Int)?,
            body: (inout Self) throws -> ()
        ) rethrows {
            self.x = x
            self.y = try first?() ?? 0
            try body(&self)
        }
    }
}
