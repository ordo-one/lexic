public import SwiftSyntax

@frozen public enum ExpressionListDecodingError: Error {
    case consumed(String?, in: Syntax)
    case missing(String?, in: Syntax)
    case invalid(String?, because: ExpressionDecodingError)
}

extension ExpressionListDecodingError: MacroExpansionError {
    public var node: Syntax {
        switch self {
        case .consumed(_, in: let node): node
        case .missing(_, in: let node): node
        case .invalid(_, because: let reason): Syntax.init(reason.node)
        }
    }
}
extension ExpressionListDecodingError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .consumed(let label, in: _):
            """
            could not find any remaining arguments with label '\(label ?? "_")', \
            all matching instances have already been used
            """
        case .missing(let label, in: _):
            """
            could not find expected argument '\(label ?? "_")'
            """

        case .invalid(let label, because: let reason):
            """
            invalid value for argument '\(label ?? "_")', \(reason.description)
            """
        }
    }
}
