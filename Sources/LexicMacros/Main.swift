import SwiftCompilerPlugin
import SwiftSyntaxMacros
@main struct Main: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        AmbientMacro.self,
        BijectionMacro.self,
        DiscriminatedMacro.self,
        DiscriminantMacro.self,
        ProjectionMacro.self,
    ]
}
