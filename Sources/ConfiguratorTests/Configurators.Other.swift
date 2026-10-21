import Configurator

extension Configurators {
    struct Other {
        var x: Int
        var y: Int

        @Configurator init(
            x: Int,
            first: () throws -> Int,
            body: (inout Self) throws -> ()
        ) rethrows {
            self.x = x
            self.y = try first()
            try body(&self)
        }
    }
}
extension Configurators.Other {
    struct Failure: Error {}
}
