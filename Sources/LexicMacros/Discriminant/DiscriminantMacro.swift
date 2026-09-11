import Lexic
import SwiftSyntax
import SwiftSyntaxMacros

struct DiscriminantMacro {}
extension DiscriminantMacro: MemberMacro {
    static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf decl: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard let decl: EnumDeclSyntax = decl.as(EnumDeclSyntax.self) else {
            context[.error, decl] = "‘@Discriminant’ must be applied to an enum"
            return []
        }

        let nestedEnums: [EnumDeclSyntax] = decl.memberBlock.members
            .compactMap { $0.decl.as(EnumDeclSyntax.self) }

        let targetEnums: [EnumDeclSyntax] = nestedEnums.filter { nested in
            nested.attributes.contains { attribute in
                guard
                case .attribute(let attribute) = attribute else {
                    return false
                }
                return attribute.attributeName.as(
                    IdentifierTypeSyntax.self
                )?.name.text == "Discriminated"
            }
        }

        guard !targetEnums.isEmpty else {
            context[.error, decl] = """
            ‘@Discriminant’ requires a nested enum annotated with ‘@Discriminated’
            """
            return []
        }
        guard targetEnums.count == 1, let targetEnum: EnumDeclSyntax = targetEnums.first else {
            context[.error, decl] = """
            ‘@Discriminant’ found multiple nested enums annotated with ‘@Discriminated’
            """
            return []
        }

        var discriminatedAttribute: AttributeSyntax?
        for element: AttributeListSyntax.Element in targetEnum.attributes {
            guard
            case .attribute(let attribute) = element,
            attribute.attributeName.as(
                IdentifierTypeSyntax.self
            )?.name.text == "Discriminated" else {
                continue
            }
            discriminatedAttribute = attribute
            break
        }

        if  let attribute: AttributeSyntax = discriminatedAttribute,
            let config: DiscriminatedMacro.Configuration = .init(
                decoding: attribute,
                in: context
            ) {
            if  let by: TypeSyntax = config.by {
                let byText: String = by.trimmedDescription
                if  byText != decl.name.text, !byText.hasSuffix(".\(decl.name.text)") {
                    context[.error, attribute] = """
                    ‘@Discriminated’ must specify ‘by: \(decl.name.text).self’
                    """
                    return []
                }
            } else {
                context[.error, attribute] = """
                ‘@Discriminated’ nested inside ‘@Discriminant’ must specify \
                ‘by: \(decl.name.text).self’
                """
                return []
            }
        }

        let cases: [DiscriminatedMacro.Case] = DiscriminatedMacro.cases(of: targetEnum)
        var members: [DeclSyntax] = []

        for `case`: DiscriminatedMacro.Case in cases {
            members.append(
                DeclSyntax.init(
                    EnumCaseDeclSyntax.init(
                        caseKeyword: .keyword(.case, trailingTrivia: .spaces(1))
                    ) {
                        EnumCaseElementSyntax.init(
                            name: `case`.name,
                            trailingTrivia: .newlines(1)
                        )
                    }
                )
            )
        }

        let typeCases: [String] = cases.map { "case .\($0.name): self = .\($0.name)" }
        let body: String = if typeCases.isEmpty {
            ""
        } else {
            "\n    \(typeCases.joined(separator: "\n    "))\n"
        }
        let initializer: DeclSyntax = """
        \(raw: decl.inlinable)\(decl.modifiersForMember)\
        init(_ value: \(raw: targetEnum.name.text)) {
            switch value {\(raw: body)}
        }
        """
        members.append(initializer)

        return members
    }
}
extension DiscriminantMacro: ExtensionMacro {
    static func expansion(
        of attribute: AttributeSyntax,
        attachedTo decl: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) -> [ExtensionDeclSyntax] {
        guard decl.is(EnumDeclSyntax.self), !protocols.isEmpty else {
            return []
        }
        let conformances: String = protocols.map(\.trimmedDescription).joined(separator: ", ")
        guard let extensionDecl: ExtensionDeclSyntax = try? .init(
            "extension \(type.trimmed): \(raw: conformances) {}"
        ) else {
            return []
        }
        return [extensionDecl]
    }
}
