import SwiftCompilerPlugin
import SwiftSyntaxMacros
@main struct BijectionMacros: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        BijectionMacro.self,
    ]
}
