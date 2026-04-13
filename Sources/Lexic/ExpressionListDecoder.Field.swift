public import SwiftSyntax

extension ExpressionListDecoder {
    @frozen public struct Field<Value> {
        let id: CodingKey
        private let owner: TypeSyntax
        private let value: Value
        private let missing: Bool

        init(id: CodingKey, owner: TypeSyntax, value: Value, missing: Bool = false) {
            self.id = id
            self.owner = owner
            self.value = value
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
