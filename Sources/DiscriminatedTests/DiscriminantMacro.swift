import Testing

@Suite struct DiscriminantMacro {
    @Test static func SolitaryEnum() {
        let first: Solitary.Union = .first
        #expect(Solitary.init(first) == .first)
        #expect(first.type == .first)

        let second: Solitary.Union = .second(42)
        #expect(Solitary.init(second) == .second)
        #expect(second.type == .second)

        #expect(Solitary.allCases == [.first, .second])
    }

    @Test static func ExplicitTarget() {
        let first: Multiple.Target = .first
        #expect(Multiple.init(first) == .first)
        #expect(first.type == .first)

        let second: Multiple.Target = .second("abc")
        #expect(Multiple.init(second) == .second)
        #expect(second.type == .second)

        #expect(Multiple.allCases == [.first, .second])
    }

    @Test static func RawBacking() {
        let one: Raw.Union = .one(1)
        #expect(Raw.init(one) == .one)
        #expect(one.type == .one)
        #expect(Raw.one.rawValue == "one")

        let two: Raw.Union = .two("2")
        #expect(Raw.init(two) == .two)
        #expect(two.type == .two)
        #expect(Raw.two.rawValue == "two")

        #expect(Raw.allCases == [.one, .two])
    }

    @Test static func TopLevel() {
        let item: TopLevelEnum.Union = .item(10)
        #expect(TopLevelEnum.init(item) == .item)
        #expect(item.type == .item)

        let text: TopLevelEnum.Union = .text("abc")
        #expect(TopLevelEnum.init(text) == .text)
        #expect(text.type == .text)

        #expect(TopLevelEnum.allCases == [.item, .text])
    }
}
