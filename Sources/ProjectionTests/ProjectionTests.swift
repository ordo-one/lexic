import Testing

@Suite struct ProjectionTests {
    @Test static func SingleProjection() {
        #expect(Single.click(123).id == "123")
        #expect(Single.hover("area").id == "area")
        #expect(Single.click(nil).id == nil)
        #expect(Single.hover(nil).id == nil)
        #expect(Single.scroll.id == nil)
    }

    @Test static func MultipleProjections() {
        #expect(Multi.text("hello").owner == "hello")
        #expect(Multi.text("hello").count == 5)

        #expect(Multi.numbers([1, 2, 3]).owner == "[1, 2, 3]")
        #expect(Multi.numbers([1, 2, 3]).count == 3)

        #expect(Multi.text(nil).owner == nil)
        #expect(Multi.text(nil).count == nil)
        #expect(Multi.numbers(nil).owner == nil)
        #expect(Multi.numbers(nil).count == nil)
        #expect(Multi.none.owner == nil)
        #expect(Multi.none.count == nil)
    }

    @Test static func FlattenedOptional() {
        let tagItem: String? = Flattened.item(89).tag
        #expect(tagItem == "89")

        let tagOther: String? = Flattened.other("").tag
        #expect(tagOther == nil)

        #expect(Flattened.item(nil).tag == nil)
        #expect(Flattened.other(nil).tag == nil)
        #expect(Flattened.plain.tag == nil)
    }

    @Test static func UnflattenedOptional() {
        let tagItem: String?? = Unflattened.item(89).tag
        #expect(tagItem == .some(.some("89")))

        let tagOther: String?? = Unflattened.other("").tag
        #expect(tagOther == .some(nil))

        #expect(Unflattened.item(nil).tag == nil)
        #expect(Unflattened.other(nil).tag == nil)
        #expect(Unflattened.plain.tag == nil)
    }

    @Test static func UnsugaredOptional() {
        let tagItem: Optional<String>? = Unsugared.item(89).tag
        #expect(tagItem == .some(.some("89")))

        let tagOther: Optional<String>? = Unsugared.other("").tag
        #expect(tagOther == .some(nil))

        #expect(Unsugared.item(nil).tag == nil)
        #expect(Unsugared.other(nil).tag == nil)
        #expect(Unsugared.plain.tag == nil)
    }

    @Test static func RecursiveEnum() {
        let node: Recursive = .node(89)
        #expect(node.tag == "89")
    }

    @Test static func NonOptionalPayload() {
        let click: NonOptional = .click(89)
        #expect(click.id == "89")

        let hover: NonOptional = .hover("hovering")
        #expect(hover.id == "hovering")

        let hoverNil: NonOptional = .hover(nil)
        #expect(hoverNil.id == nil)

        let scroll: NonOptional = .scroll
        #expect(scroll.id == nil)
    }

    @Test static func ParenthesizedPayload() {
        let tagItem: String? = Parenthesized.item(89).tag
        #expect(tagItem == "89")

        let tagOther: String? = Parenthesized.other("test").tag
        #expect(tagOther == "test")

        #expect(Parenthesized.item(nil).tag == nil)
        #expect(Parenthesized.other(nil).tag == nil)
        #expect(Parenthesized.plain.tag == nil)
    }
}
