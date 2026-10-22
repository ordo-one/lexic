import Configurator
import Testing

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
extension Configurators {
    @Test static func OtherThrowingClosure() throws {
        let other: Other = .init(x: 8) { 9 }
        #expect(other.x == 8)
        #expect(other.y == 9)

        #expect(throws: Other.Failure.self) {
            try Other.init(x: 8) { throw Other.Failure.init() }
        }
    }
}
