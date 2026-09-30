import Lexic

extension Expressions {
    struct Call: ExpressionListDecodable {
        let name: String
        let value: Int?

        enum CodingKey: String, Sendable {
            case name
            case value
        }

        init(from list: inout ExpressionListDecoder<CodingKey>) throws {
            self.name = try list[.name].decode()
            self.value = try list[.value]?.decode()
        }
    }
}
