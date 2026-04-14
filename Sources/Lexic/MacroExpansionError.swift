public import SwiftSyntax

public protocol MacroExpansionError<Node>: Error {
    associatedtype Node: SyntaxProtocol
    var node: Node { get }
}
