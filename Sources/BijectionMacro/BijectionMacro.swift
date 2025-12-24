import SwiftSyntax
import SwiftSyntaxMacros

public struct BijectionMacro: PeerMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingPeersOf decl: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
        let decl: VariableDeclSyntax = decl.as(VariableDeclSyntax.self),
        let binding: PatternBindingSyntax = decl.bindings.first,
        let type: TypeSyntax = binding.typeAnnotation?.type.trimmed,
        let accessors: AccessorBlockSyntax.Accessors = binding.accessorBlock?.accessors else {
            context[.error, attribute] = """
            '@Bijection' must be applied to a computed property
            """
            return []
        }

        let getter: CodeBlockItemListSyntax

        getter: do {
            switch accessors {
            case .getter(let body):
                getter = body
            case .accessors(let accessors):
                for accessor: AccessorDeclSyntax in accessors {
                    if case .keyword(.get) = accessor.accessorSpecifier.tokenKind {
                        getter = accessor.body!.statements
                        break getter
                    }
                }

                context[.error, accessors] = "accessor list contains no getter"
                return []
            }
        }

        var mapping: SwitchExprSyntax? = nil
        for statement: CodeBlockItemSyntax in getter {
            guard
            let statement: ExpressionStmtSyntax = statement.item.as(ExpressionStmtSyntax.self),
            let expression: SwitchExprSyntax = statement.expression.as(SwitchExprSyntax.self),
            case nil = mapping else {
                context[.warning, statement] = """
                body of '@Bijection' mapping should contain only a single switch-case block, \
                with the 'return' keyword elided
                """
                continue
            }

            mapping = expression
            break
        }

        guard let mapping: SwitchExprSyntax else {
            context[.error, binding] = """
            body of '@Bijection' mapping must contain a switch-case block
            """
            return []
        }

        let rows: [(PatternSyntax, ExprSyntax)] = mapping.cases.reduce(into: []) {
            // Ensure we are handling a `case` and not a `default` block.
            guard
            case .switchCase(let pair) = $1,
            let predicate: SwitchCaseLabelSyntax = pair.label.as(SwitchCaseLabelSyntax.self),
            let pattern: PatternSyntax = predicate.caseItems.first?.pattern,
            case 1 = predicate.caseItems.count else {
                context[.error, $1] = "only one pattern may appear per case"
                return
            }

            guard
            case 1 = pair.statements.count,
            let value: CodeBlockItemSyntax = pair.statements.first,
            let value: ExprSyntax = value.item.as(ExprSyntax.self) else {
                context[.error, pair.statements] = """
                case body must be a single expression, with the 'return' keyword elided
                """
                return
            }

            $0.append((pattern.trimmed, value.trimmed))
        }

        // Parse the `label` argument from the macro attribute.
        var label: String = "_"
        if  let arguments: LabeledExprListSyntax = attribute.arguments?.as(
                LabeledExprListSyntax.self
            ) {
            for argument: LabeledExprSyntax in arguments {
                switch argument.label?.text {
                case "label"?:
                    guard
                    let value: StringLiteralExprSyntax = argument.expression.as(
                        StringLiteralExprSyntax.self
                    ),
                    case .stringSegment(let segment)? = value.segments.first,
                    case 1 = value.segments.count else {
                        context[.error, argument] = """
                        'label' argument must be a string literal
                        """
                        return []
                    }

                    label = segment.content.text

                default:
                    continue
                }
            }
        }

        // Copy the access control from the original declaration.
        var attributes: [AttributeSyntax] = []
        for case .attribute(let node) in decl.attributes {
            let attribute: TypeSyntax = node.attributeName

            guard
            let attribute: IdentifierTypeSyntax = attribute.as(IdentifierTypeSyntax.self) else {
                continue
            }

            switch attribute.name.text {
            case "available": break
            case "backDeployed": break
            case "inlinable": break
            case "inline": break
            case "usableFromInline": break
            default: continue
            }

            attributes.append(node.trimmed)
        }

        /// Note: `borrowing` is inserted, which is meaningful if the value is a ``String`` or
        /// some other allocated type, as `init`s default to `__owned`.
        let initializer: DeclSyntax = """
        \(raw: attributes.map { "\($0) " }.joined())\(decl.modifiers)\
        init?(\(raw: label) $value: borrowing \(type)) {
            switch $value {
            \(raw: rows.lazy.map { "case \($1): self = \($0)" }.joined(separator: "\n    "))
            default: return nil
            }
        }
        """

        return [initializer]
    }
}
