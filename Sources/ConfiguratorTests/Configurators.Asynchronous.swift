import Configurator

extension Configurators {
    struct Asynchronous {
        var x: Int

        @Configurator init<E>(
            x: Int,
            body: (inout Self) throws(E) -> ()
        ) async throws(E) {
            await Task.yield()
            self.x = x
            try body(&self)
        }
    }
}
