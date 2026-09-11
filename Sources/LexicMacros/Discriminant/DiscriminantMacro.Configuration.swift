import Lexic

extension DiscriminantMacro {
    struct Configuration {
        let of: String?
    }
}
extension DiscriminantMacro.Configuration: ExpressionListDecodable {
    enum CodingKey: String, Sendable {
        case of
    }

    init(from list: inout ExpressionListDecoder<CodingKey>) throws {
        self.init(
            of: try list[.of]?.decode()
        )
    }
}
