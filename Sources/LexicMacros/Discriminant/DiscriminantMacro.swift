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

        let candidates: [(enum: EnumDeclSyntax, attribute: AttributeSyntax)] = decl
            .memberBlock.members
            .compactMap { $0.decl.as(EnumDeclSyntax.self) }
            .compactMap { nested in
                nested.attributes.first(named: "Discriminated").map { (nested, $0) }
            }

        guard !candidates.isEmpty else {
            context[.error, decl] = """
            ‘@Discriminant’ requires a nested enum annotated with ‘@Discriminated’
            """
            return []
        }
        guard candidates.count == 1, let candidate = candidates.first else {
            context[.error, decl] = """
            ‘@Discriminant’ found multiple nested enums annotated with ‘@Discriminated’
            """
            return []
        }

        if  let config: DiscriminatedMacro.Configuration = .init(
                decoding: candidate.attribute,
                in: context
            ) {
            if  let by: TypeSyntax = config.by {
                let typeName: Substring? = switch by.asProtocol((any TypeSyntaxProtocol).self) {
                case let identifier as IdentifierTypeSyntax:
                    identifier.name.unescaped
                case let member as MemberTypeSyntax:
                    member.name.unescaped
                default:
                    nil
                }
                if  typeName != decl.name.unescaped {
                    context[.error, candidate.attribute] = """
                    ‘@Discriminated’ must specify ‘by: \(decl.name.text).self’
                    """
                    return []
                }
            } else {
                context[.error, candidate.attribute] = """
                ‘@Discriminated’ nested inside ‘@Discriminant’ must specify \
                ‘by: \(decl.name.text).self’
                """
                return []
            }
        }

        var members: [DeclSyntax] = []
        for element: EnumCaseElementSyntax in candidate.enum.caseElements {
            members.append(DeclSyntax.init(EnumCaseDeclSyntax.init(case: element.name)))
        }
        return members
    }
}
