import Lexic
import SwiftSyntax
import SwiftSyntaxMacros

struct AmbientMacro {}

extension AmbientMacro: MemberMacro {
    static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf decl: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard let decl: EnumDeclSyntax = decl.as(EnumDeclSyntax.self) else {
            context[.error, decl] = "‘@ambient’ must be applied to an enum"
            return []
        }

        var members: [DeclSyntax] = []

        for element: EnumCaseElementSyntax in decl.cases {
            guard
            let list: EnumCaseParameterListSyntax = element.parameterClause?.parameters,
               !list.isEmpty else {
                continue
            }

            var arguments: [String] = []
            var canSynthesize: Bool = true

            for parameter: EnumCaseParameterSyntax in list {
                context[.warning, parameter.type] = parameter.type.isUnsugaredOptionalDiagnostic

                let isOptional: Bool = parameter.type.isOptional
                if  let defaultValue: InitializerClauseSyntax = parameter.defaultValue {
                    let value: String = defaultValue.value.trimmedDescription
                    if  let label: TokenSyntax = parameter.firstName, label.text != "_" {
                        arguments.append("\(label.text): \(value)")
                    } else {
                        arguments.append(value)
                    }
                } else if isOptional {
                    if  let label: TokenSyntax = parameter.firstName, label.text != "_" {
                        arguments.append("\(label.text): nil")
                    } else {
                        arguments.append("nil")
                    }
                } else {
                    canSynthesize = false
                }
            }

            guard canSynthesize else {
                continue
            }

            let argumentsList: String = arguments.joined(separator: ", ")

            let accessor: DeclSyntax = """
            \(decl.attributesForMember)\(decl.modifiersForMember)static var \
            \(raw: element.name): Self {
                .\(raw: element.name)(\(raw: argumentsList))
            }
            """
            members.append(accessor)
        }

        return members
    }
}
