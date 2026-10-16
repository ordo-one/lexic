import Testing

@Suite struct AmbientTests {
    @Test static func SingleParameter() {
        #expect(Simple.reset == .reset(nil))
    }

    @Test static func LabeledAndMultiParameter() {
        #expect(Labeled.single == .single(value: nil))
        #expect(Labeled.multi == .multi(first: nil, second: nil))
    }

    @Test static func RecursiveEnum() {
        let node: Recursive = .node
        #expect(node == .node(nil))
    }

    @Test static func DefaultValues() {
        #expect(Enum.default == .default(count: 10))
        #expect(Enum.defaultOptionalWithNonOptional == .defaultOptionalWithNonOptional("guest"))
        #expect(Enum.defaultOptionalWithNil == .defaultOptionalWithNil(tag: nil))
        #expect(Enum.defaultOptionalWithout == .defaultOptionalWithout(status: nil))
        #expect(Enum.defaultMultiple == .defaultMultiple(x: 1, y: "hello", z: nil))
        #expect(Enum.defaultUnlabeled == .defaultUnlabeled(89))
    }

    @Test static func UnsugaredPayload() {
        #expect(Unsugared.defaulted == .defaulted(89))
    }
}
