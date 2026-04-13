public import SwiftDiagnostics
import SwiftSyntaxMacros

@frozen @usableFromInline struct MacroExpansionMessage {
    @usableFromInline let severity: DiagnosticSeverity
    @usableFromInline let message: String

    @inlinable init(severity: DiagnosticSeverity, message: String) {
        self.severity = severity
        self.message = message
    }
}
extension MacroExpansionMessage: DiagnosticMessage {
    @usableFromInline var diagnosticID: MessageID {
        .init(domain: "\(Self.self)", id: "\(self.severity)")
    }
}
