import SwiftSyntax
import SwiftSyntaxMacros

public protocol ExpressionListDecodable<CodingKey> {
    associatedtype CodingKey: Hashable & Sendable & RawRepresentable<String>
    init(from list: inout ExpressionListDecoder<CodingKey>) throws
}
extension ExpressionListDecodable {
    init(decoding attribute: borrowing AttributeSyntax) throws {
        var decoder: ExpressionListDecoder<CodingKey> = .init(indexing: attribute)
        try self.init(from: &decoder)
    }

    init?(
        decoding attribute: borrowing AttributeSyntax,
        in context: some MacroExpansionContext
    ) {
        do {
            self = try .init(decoding: attribute)
        } catch let error as any MacroExpansionError {
            context[.error, error.node] = "\(error)"
            return nil
        } catch let error {
            context[.error, copy attribute] = "\(error)"
            return nil
        }
    }
}
