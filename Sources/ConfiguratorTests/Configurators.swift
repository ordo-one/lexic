import Configurator
import Testing

@Suite struct Configurators {
    struct Typed {
        var x: Int

        @Configurator init<E>(
            x: Int,
            body: (inout Self) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(&self)
        }
    }

    @Test static func TypedError() {
        let typed: Typed = .init(x: 1)
        #expect(typed.x == 1)
    }

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

    @Test static func RethrowingInitializer() {
        let rethrowing: Rethrowing = .init(x: 2)
        #expect(rethrowing.x == 2)
    }

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

    @Test static func UnconditionalThrows() throws {
        let unconditional: Unconditional = try .init(x: 3)
        #expect(unconditional.x == 3)
    }

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

    @Test static func AsynchronousInitializer() async {
        let asynchronous: Asynchronous = await .init(x: 4)
        #expect(asynchronous.x == 4)
    }

    final class Object {
        var x: Int

        @Configurator init<E>(
            x: Int,
            body: (Object) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(self)
        }
    }

    @Test static func Convenience() {
        let object: Object = .init(x: 5)
        #expect(object.x == 5)
    }

    struct Failable {
        var x: Int

        @Configurator init?<E>(
            x: Int,
            body: (inout Self) throws(E) -> ()
        ) throws(E) {
            guard x >= 0 else {
                return nil
            }
            self.x = x
            try body(&self)
        }
    }

    @Test static func FailableInitializer() {
        let failable: Failable? = .init(x: 6)
        #expect(failable?.x == 6)
        #expect(Failable.init(x: -1) == nil)
    }

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

    @Test static func MultipleGenerics() {
        let generic: Generic = .init(x: 7 as UInt8)
        #expect(generic.x == 7)
    }

    struct Forwarding {
        var sum: Int
        var e: String
        var `default`: Int

        @Configurator init<E>(
            _ a: Int,
            b c: Int,
            d: inout Int,
            e: String = "e",
            `default` f: Int = 0,
            body: (inout Self) throws(E) -> (),
        ) throws(E) {
            self.sum = a + c + d
            self.e = e
            self.default = f
            d += 1
            try body(&self)
        }
    }

    @Test static func ForwardedParameters() {
        var d: Int = 3
        let forwarding: Forwarding = .init(1, b: 2, d: &d)
        #expect(forwarding.sum == 6)
        #expect(forwarding.e == "e")
        #expect(forwarding.default == 0)
        #expect(d == 4)
    }

    struct Other {
        struct Failure: Error {}

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

    @Test static func OtherThrowingClosure() throws {
        let other: Other = .init(x: 8) { 9 }
        #expect(other.x == 8)
        #expect(other.y == 9)

        #expect(throws: Other.Failure.self) {
            try Other.init(x: 8) { throw Other.Failure.init() }
        }
    }

    struct Attributed {
        var x: Int

        @Configurator init<E>(
            x: Int,
            body: @Sendable (inout Self, Int) throws(E) -> Void
        ) throws(E) {
            self.x = x
            try body(&self, x)
        }
    }

    @Test static func AttributedClosure() {
        let attributed: Attributed = .init(x: 10)
        #expect(attributed.x == 10)
    }

    struct Unlabeled {
        var x: Int

        @Configurator init<E>(
            x: Int,
            _ body: (inout Self) throws(E) -> ()
        ) throws(E) {
            self.x = x
            try body(&self)
        }
    }

    @Test static func UnlabeledClosure() {
        let unlabeled: Unlabeled = .init(x: 11)
        #expect(unlabeled.x == 11)
    }
}
