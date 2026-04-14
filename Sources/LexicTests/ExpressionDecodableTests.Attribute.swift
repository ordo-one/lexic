import Lexic

extension ExpressionDecodableTests {
    struct Attribute: ExpressionListDecodable {
        let x: Enum?
        let y: Int?

        enum CodingKey: String, Sendable {
            case x
            case y
        }

        init(from list: inout ExpressionListDecoder<CodingKey>) throws {
            self.x = try list[.x]?.decode()
            self.y = try list[.y]?.decode()
        }
    }
}
