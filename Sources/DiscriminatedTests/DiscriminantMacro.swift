import Testing

@Suite struct DiscriminantMacro {
    @Test static func SolitaryEnum() {
        let first: Solitary.Union = .first
        #expect(first.type == .first)

        let second: Solitary.Union = .second(42)
        #expect(second.type == .second)
    }

    @Test static func ExplicitTarget() {
        let first: Multiple.Target = .first
        #expect(first.type == .first)

        let second: Multiple.Target = .second("abc")
        #expect(second.type == .second)
    }

    @Test static func RawBacking() {
        let one: Raw.Union = .one(1)
        #expect(one.type == .one)
        #expect(Raw.one.rawValue == "one")

        let two: Raw.Union = .two("2")
        #expect(two.type == .two)
        #expect(Raw.two.rawValue == "two")
    }

    @Test static func TopLevel() {
        let item: TopLevelEnum.Union = .item(10)
        #expect(item.type == .item)

        let text: TopLevelEnum.Union = .text("abc")
        #expect(text.type == .text)
    }
}
