import Configurator

extension Configurators {
    class Overriding {
        var x: Int

        @Configurator init(
            x: Int,
            body: (Overriding) throws -> ()
        ) rethrows {
            self.x = x
            try body(self)
        }
    }
}
extension Configurators.Overriding {
    final class Subclass: Configurators.Overriding {
        var y: Int

        @Configurator override init(
            x: Int,
            body: (Configurators.Overriding) throws -> ()
        ) rethrows {
            self.y = x * 2
            try super.init(x: x, body: body)
        }
    }
}
