import Testing

@Suite struct DiscriminatedMacro {
    @Test static func PureDiscriminator() {
        #expect(Action.start.type == .start)
        #expect(Action.stop.type == .stop)
        #expect(Action.reset(89).type == .reset)

        #expect(ActionType.allCases == [.start, .stop, .reset])
    }

    @Test static func TopLevel() {
        #expect(TopLevelAction.start.type == .start)
        #expect(TopLevelAction.stop.type == .stop)
        #expect(TopLevelAction.reset(89).type == .reset)

        #expect(TopLevelActionType.allCases == [.start, .stop, .reset])
    }

    @Test static func BackingTypes() {
        #expect(BackedByStringType.first.rawValue == "first")
        #expect(BackedByStringType.second.rawValue == "second")
        #expect(BackedByStringType.allCases == [.first, .second])

        let alpha: Substring = BackedBySubstringType.alpha.rawValue
        #expect(alpha == "alpha")
        let beta: Substring = BackedBySubstringType.beta.rawValue
        #expect(beta == "beta")

        #expect(BackedByIntType.low.rawValue == 0)
        #expect(BackedByIntType.medium.rawValue == 1)
        #expect(BackedByIntType.high.rawValue == 2)
    }

    @Test static func RecursiveEnum() {
        let leaf: Recursive = .leaf
        #expect(leaf.type == .leaf)

        let node: Recursive = .node(.leaf)
        #expect(node.type == .node)
    }
}
