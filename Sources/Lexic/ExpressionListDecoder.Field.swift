public import SwiftSyntax

extension ExpressionListDecoder {
    @frozen public struct Field<Value> {
        let id: CodingKey
        public let label: TokenSyntax?
        public let value: Value
        private let owner: TypeSyntax
        private let missing: Bool

        init(
            id: CodingKey,
            label: TokenSyntax?,
            value: Value,
            owner: TypeSyntax,
            missing: Bool = false
        ) {
            self.id = id
            self.label = label
            self.value = value
            self.owner = owner
            self.missing = missing
        }
    }
}
extension ExpressionListDecoder.Field<ExprSyntax> {
    public func decode<T>(
        to _: T.Type = T.self
    ) throws(ExpressionListDecoder.FieldError) -> T where T: ExpressionDecodable {
        do {
            return try .init(from: try self.value.expecting(T.Node.self))
        } catch let error {
            throw .invalid(self.id, because: error)
        }
    }
}
extension ExpressionListDecoder.Field<ExprSyntax?> {
    public func decode<T>(
        to _: T.Type = T.self
    ) throws(ExpressionListDecoder.FieldError) -> T where T: ExpressionDecodable {
        guard let value: ExprSyntax = self.value else {
            throw self.missing
                ? .missing(self.id, in: self.owner)
                : .consumed(self.id, in: self.owner)
        }
        do {
            return try .init(from: try value.expecting(T.Node.self))
        } catch let error {
            throw .invalid(self.id, because: error)
        }
    }
}
