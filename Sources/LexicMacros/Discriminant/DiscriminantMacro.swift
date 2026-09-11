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

        guard let configuration: Configuration = .init(decoding: attribute, in: context) else {
            return []
        }

        let nestedEnums: [EnumDeclSyntax] = decl.memberBlock.members
            .compactMap { $0.decl.as(EnumDeclSyntax.self) }

        let targetEnum: EnumDeclSyntax
        if  let of: String = configuration.of {
            guard let match: EnumDeclSyntax = nestedEnums.first(where: { $0.name.text == of }) else {
                context[.error, decl] = "‘@Discriminant’ requires a nested enum named ‘\(of)’"
                return []
            }
            targetEnum = match
        } else {
            guard !nestedEnums.isEmpty else {
                context[.error, decl] = "‘@Discriminant’ requires a nested enum"
                return []
            }
            guard nestedEnums.count == 1, let solitary: EnumDeclSyntax = nestedEnums.first else {
                context[.error, decl] = "‘@Discriminant’ found multiple nested enums; specify the target enum using ‘of:’"
                return []
            }
            targetEnum = solitary
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
        \(raw: decl.inlinable)\(decl.modifiersForMember)init(_ value: \(raw: targetEnum.name.text)) {
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
        guard !protocols.isEmpty else {
            return []
        }
        let conformances: String = protocols.map(\.trimmedDescription).joined(separator: ", ")
        let extensionDecl: ExtensionDeclSyntax = try! .init(
            "extension \(type.trimmed): \(raw: conformances) {}"
        )
        return [extensionDecl]
    }
}
