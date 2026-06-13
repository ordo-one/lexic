import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main struct AssertMacros: CompilerPlugin {
    var providingMacros: [any Macro.Type] = [AssertMacro.self]
}
