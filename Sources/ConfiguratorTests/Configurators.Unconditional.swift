import Configurator
import Testing

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
extension Configurators {
    @Test static func UnconditionalThrows() throws {
        let unconditional: Unconditional = try .init(x: 3)
        #expect(unconditional.x == 3)
    }
}
