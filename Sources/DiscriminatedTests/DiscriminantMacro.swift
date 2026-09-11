import Testing

@Suite struct DiscriminantMacro {
    @Test static func SolitaryEnum() {
        let first: Solitary.Union = .first
        #expect(Solitary.init(first) == .first)

        let second: Solitary.Union = .second(42)
        #expect(Solitary.init(second) == .second)

        #expect(Solitary.allCases == [.first, .second])
    }

    @Test static func ExplicitTarget() {
        let first: Multiple.Target = .first
        #expect(Multiple.init(first) == .first)

        let second: Multiple.Target = .second("abc")
        #expect(Multiple.init(second) == .second)

        #expect(Multiple.allCases == [.first, .second])
    }

    @Test static func RawBacking() {
        let one: Raw.Union = .one(1)
        #expect(Raw.init(one) == .one)
        #expect(Raw.one.rawValue == "one")

        let two: Raw.Union = .two("2")
        #expect(Raw.init(two) == .two)
        #expect(Raw.two.rawValue == "two")

        #expect(Raw.allCases == [.one, .two])
    }

    @Test static func TopLevel() {
        let item: TopLevelTooltipType.Union = .item(10)
        #expect(TopLevelTooltipType.init(item) == .item)

        let text: TopLevelTooltipType.Union = .text("abc")
        #expect(TopLevelTooltipType.init(text) == .text)

        #expect(TopLevelTooltipType.allCases == [.item, .text])
    }
}
