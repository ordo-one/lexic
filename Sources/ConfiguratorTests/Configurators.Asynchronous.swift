import Configurator
import Testing

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
extension Configurators {
    @Test static func AsynchronousInitializer() async {
        let asynchronous: Asynchronous = await .init(x: 4)
        #expect(asynchronous.x == 4)
    }
}
