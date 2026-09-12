import Testing

@Suite struct DiscriminatedMacro {
    @Test static func Nested() {
        #expect(Action.start.type == .start)
        #expect(Action.stop.type == .stop)
        #expect(Action.reset(89).type == .reset)
    }

    @Test static func TopLevel() {
        #expect(TopLevelAction.start.type == .start)
        #expect(TopLevelAction.stop.type == .stop)
        #expect(TopLevelAction.reset(89).type == .reset)
    }

    @Test static func BackingSubstring() {
        #expect(BackedBySubstringType.foobie.rawValue == "foobie")
        #expect(BackedBySubstringType.barbie.rawValue == "barbie")
    }

    @Test static func BackingString() {
        #expect(BackedByStringType.first.rawValue == "first")
        #expect(BackedByStringType.second.rawValue == "second")
    }

    @Test static func BackingInt() {
        #expect(BackedByIntType.a.rawValue == 0)
        #expect(BackedByIntType.b.rawValue == 1)
        #expect(BackedByIntType.c.rawValue == 2)
    }

    @Test static func RecursiveEnum() {
        let leaf: Recursive = .leaf
        #expect(leaf.type == .leaf)

        let node: Recursive = .node(.leaf)
        #expect(node.type == .node)
    }
}
