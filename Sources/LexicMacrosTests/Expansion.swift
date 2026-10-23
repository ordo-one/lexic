@_spi(testable) import LexicMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

/// A macro expansion test case, which expands all macros vended by this package.
struct Expansion {
    let source: String

    init(_ source: String) {
        self.source = source
    }
}
extension Expansion {
    static var macros: [String: MacroSpec] {
        [
            "Configurator": .init(type: ConfiguratorMacro.self),
        ]
    }

    func expect(
        _ expanded: String,
        diagnostics: [DiagnosticSpec] = [],
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) {
        assertMacroExpansion(
            self.source,
            expandedSource: expanded,
            diagnostics: diagnostics,
            macroSpecs: Self.macros,
            failureHandler: {
                Issue.record(
                    .init(rawValue: $0.message),
                    sourceLocation: .init(
                        fileID: $0.location.fileID,
                        filePath: $0.location.filePath,
                        line: $0.location.line,
                        column: $0.location.column
                    )
                )
            },
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
    }
}
