import SwiftCompilerPlugin
import SwiftSyntaxMacros
@main struct Lexic: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        BijectionMacro.self,
    ]
}
