import Testing

@Suite struct Configurators {
    @Test static func TypedError() {
        let typed: Typed = .init(x: 1)
        #expect(typed.x == 1)
    }

    @Test static func RethrowingInitializer() {
        let rethrowing: Rethrowing = .init(x: 2)
        #expect(rethrowing.x == 2)
    }

    @Test static func UnconditionalThrows() throws {
        let unconditional: Unconditional = try .init(x: 3)
        #expect(unconditional.x == 3)
    }

    @Test static func AsynchronousInitializer() async {
        let asynchronous: Asynchronous = await .init(x: 4)
        #expect(asynchronous.x == 4)
    }

    @Test static func Convenience() {
        let object: Object = .init(x: 5)
        #expect(object.x == 5)
    }

    @Test static func FailableInitializer() {
        let failable: Failable? = .init(x: 6)
        #expect(failable?.x == 6)
        #expect(Failable.init(x: -1) == nil)
    }

    @Test static func MultipleGenerics() {
        let generic: Generic = .init(x: 7 as UInt8)
        #expect(generic.x == 7)
    }

    @Test static func ForwardedParameters() {
        var d: Int = 3
        let forwarding: Forwarding = .init(1, b: 2, d: &d)
        #expect(forwarding.sum == 6)
        #expect(forwarding.e == "e")
        #expect(forwarding.default == 0)
        #expect(d == 4)
    }

    @Test static func OtherThrowingClosure() throws {
        let other: Other = .init(x: 8) { 9 }
        #expect(other.x == 8)
        #expect(other.y == 9)

        #expect(throws: Other.Failure.self) {
            try Other.init(x: 8) { throw Other.Failure.init() }
        }
    }

    @Test static func AttributedClosure() {
        let attributed: Attributed = .init(x: 10)
        #expect(attributed.x == 10)
    }

    @Test static func UnlabeledClosure() {
        let unlabeled: Unlabeled = .init(x: 11)
        #expect(unlabeled.x == 11)
    }
}
