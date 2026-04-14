public import SwiftSyntax

extension ExpressionListDecoder {
    @frozen public enum FieldError: Error {
        case consumed(CodingKey, in: TypeSyntax)
        case missing(CodingKey, in: TypeSyntax)
        case invalid(CodingKey, because: ExpressionDecodingError)
    }
}

extension ExpressionListDecoder.FieldError: MacroExpansionError {
    public var node: Syntax {
        switch self {
        case .consumed(_, in: let node): Syntax.init(node)
        case .missing(_, in: let node): Syntax.init(node)
        case .invalid(_, because: let reason): Syntax.init(reason.node)
        }
    }
}
extension ExpressionListDecoder.FieldError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .consumed(let id, in: _):
            """
            could not find any remaining arguments with label '\(id.rawValue)', \
            all matching instances have already been used
            """
        case .missing(let id, in: _):
            """
            could not find expected argument '\(id.rawValue)'
            """

        case .invalid(let id, because: let reason):
            """
            invalid value for argument '\(id.rawValue)', \(reason.description)
            """
        }
    }
}
