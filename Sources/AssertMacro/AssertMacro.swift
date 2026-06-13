import SwiftSyntax
import SwiftSyntaxMacros

/// Implements the `#assert` freestanding macro.
struct AssertMacro: ExpressionMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard
        let condition: ExprSyntax = node.arguments.first?.expression,
        let message: ExprSyntax = node.arguments.last?.expression else {
            fatalError("compiler bug: macro requires two arguments")
        }

        return """
        _ = if true {
            #if ASSERT
            if \(condition) { () } else { { fatalError($0) } (\(message)) as Never }
            #else
            ()
            #endif
        } else {
            ()
        }
        """
    }
}
