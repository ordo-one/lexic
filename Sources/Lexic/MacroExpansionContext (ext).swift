public import SwiftDiagnostics
public import SwiftSyntax
public import SwiftSyntaxMacros

extension MacroExpansionContext {
    /// A helper syntax for emitting macro expansion diagnostics.
    @inlinable public subscript(
        severity: DiagnosticSeverity,
        node: some SyntaxProtocol
    ) -> String? {
        get {
            nil
        }
        set(value) {
            guard let value: String else {
                return
            }

            let message: MacroExpansionMessage = .init(severity: severity, message: value)
            self.diagnose(Diagnostic.init(node: node, message: message))
        }
    }
}
