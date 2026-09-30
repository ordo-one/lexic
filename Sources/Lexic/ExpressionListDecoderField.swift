public import SwiftSyntax

@frozen public struct ExpressionListDecoderField<Value> {
    public let label: String?
    public let value: Value
    private let owner: Syntax
    private let missing: Bool

    init(
        label: String?,
        value: Value,
        owner: Syntax,
        missing: Bool = false
    ) {
        self.label = label
        self.value = value
        self.owner = owner
        self.missing = missing
    }
}
extension ExpressionListDecoderField {
    @inlinable public var name: String { self.label ?? "_" }
}
extension ExpressionListDecoderField<ExprSyntax> {
    public func decode<T>(
        to _: T.Type = T.self
    ) throws(ExpressionListDecodingError) -> T where T: ExpressionDecodable {
        do {
            return try .init(from: try self.value.expecting(T.Node.self))
        } catch let error {
            throw .invalid(self.label, because: error)
        }
    }
}
extension ExpressionListDecoderField<ExprSyntax?> {
    public func decode<T>(
        to _: T.Type = T.self
    ) throws(ExpressionListDecodingError) -> T where T: ExpressionDecodable {
        guard let value: ExprSyntax = self.value else {
            throw self.missing
                ? .missing(self.label, in: self.owner)
                : .consumed(self.label, in: self.owner)
        }
        do {
            return try .init(from: try value.expecting(T.Node.self))
        } catch let error {
            throw .invalid(self.label, because: error)
        }
    }
}
