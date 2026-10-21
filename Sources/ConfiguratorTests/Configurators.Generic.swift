import Configurator

extension Configurators {
    struct Generic {
        var x: Int

        @Configurator init<T: BinaryInteger, E>(
            x: T,
            body: (inout Self) throws(E) -> ()
        ) throws(E) where T: Sendable {
            self.x = .init(x)
            try body(&self)
        }
    }
}
