public import SwiftSyntax
public import SwiftSyntaxMacros

public protocol ExpressionListDecodable<CodingKey> {
    associatedtype CodingKey: Hashable & Sendable & RawRepresentable<String>
    init(from list: inout ExpressionListDecoder<CodingKey>) throws
}
extension ExpressionListDecodable {
    public init(decoding attribute: borrowing AttributeSyntax) throws {
        var decoder: ExpressionListDecoder<CodingKey> = .init(indexing: attribute)
        try self.init(from: &decoder)
    }

    public init?(
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
extension ExpressionListDecodable {
    public init(decoding call: borrowing FunctionCallExprSyntax) throws {
        var decoder: ExpressionListDecoder<CodingKey> = .init(indexing: call)
        try self.init(from: &decoder)
    }

    public init?(
        decoding call: borrowing FunctionCallExprSyntax,
        in context: some MacroExpansionContext
    ) {
        do {
            self = try .init(decoding: call)
        } catch let error as any MacroExpansionError {
            context[.error, error.node] = "\(error)"
            return nil
        } catch let error {
            context[.error, copy call] = "\(error)"
            return nil
        }
    }
}
extension ExpressionListDecodable {
    public init(
        decoding arguments: borrowing LabeledExprListSyntax,
        in owner: borrowing some SyntaxProtocol
    ) throws {
        var decoder: ExpressionListDecoder<CodingKey> = .init(indexing: arguments, in: owner)
        try self.init(from: &decoder)
    }

    public init?(
        decoding arguments: borrowing LabeledExprListSyntax,
        in owner: borrowing some SyntaxProtocol,
        in context: some MacroExpansionContext
    ) {
        do {
            self = try .init(decoding: arguments, in: owner)
        } catch let error as any MacroExpansionError {
            context[.error, error.node] = "\(error)"
            return nil
        } catch let error {
            context[.error, Syntax.init(copy owner)] = "\(error)"
            return nil
        }
    }
}
