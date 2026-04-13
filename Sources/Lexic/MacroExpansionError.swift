import SwiftSyntax

protocol MacroExpansionError<Node>: Error {
    associatedtype Node: SyntaxProtocol
    var node: Node { get }
}
