public import SwiftSyntax
import SwiftSyntaxMacros

extension TypeSyntax {
    public func contains(symbol: String) -> Bool {
        switch self.asProtocol((any TypeSyntaxProtocol).self) {
        case let self as ArrayTypeSyntax:
            return self.element.contains(symbol: symbol)

        case let self as AttributedTypeSyntax:
            return self.baseType.contains(symbol: symbol)

        case is ClassRestrictionTypeSyntax:
            return false

        case let self as CompositionTypeSyntax:
            return self.elements.contains { $0.type.contains(symbol: symbol) }

        case let self as DictionaryTypeSyntax:
            return self.key.contains(symbol: symbol)
                || self.value.contains(symbol: symbol)

        case let self as FunctionTypeSyntax:
            if  case true? = self.effectSpecifiers?.throwsClause?.type?.contains(
                    symbol: symbol
                ) {
                return true
            }
            return self.parameters.contains { $0.type.contains(symbol: symbol) }
                || self.returnClause.type.contains(symbol: symbol)

        case let self as IdentifierTypeSyntax:
            if  case true? = self.genericArgumentClause?.arguments.contains(
                    where: { $0.contains(symbol: symbol) }
                ) {
                return true
            }
            switch self.name.tokenKind {
            case .identifier:
                return self.name.unescaped == symbol

            case .keyword(.Self):
                return symbol == "Self"

            default:
                return false
            }

        case let self as ImplicitlyUnwrappedOptionalTypeSyntax:
            return self.wrappedType.contains(symbol: symbol)

        case let self as InlineArrayTypeSyntax:
            return self.element.contains(symbol: symbol)

        case let self as MemberTypeSyntax:
            if  case true? = self.genericArgumentClause?.arguments.contains(
                    where: { $0.contains(symbol: symbol) }
                ) {
                return true
            }
            return self.baseType.contains(symbol: symbol)

        case let self as MetatypeTypeSyntax:
            return self.baseType.contains(symbol: symbol)

        case is MissingTypeSyntax:
            return false

        case let self as NamedOpaqueReturnTypeSyntax:
            return self.type.contains(symbol: symbol)

        case let self as OptionalTypeSyntax:
            return self.wrappedType.contains(symbol: symbol)

        case let self as PackElementTypeSyntax:
            return self.pack.contains(symbol: symbol)

        case let self as PackExpansionTypeSyntax:
            return self.repetitionPattern.contains(symbol: symbol)

        case let self as SomeOrAnyTypeSyntax:
            return self.constraint.contains(symbol: symbol)

        case let self as SuppressedTypeSyntax:
            return self.type.contains(symbol: symbol)

        case let self as TupleTypeSyntax:
            return self.elements.contains { $0.type.contains(symbol: symbol) }

        default:
            return false
        }
    }

    public var isUnsugaredOptionalDiagnostic: String? {
        guard self.isUnsugaredOptional else {
            return nil
        }
        return """
        spelling ‘\(self.trimmed)’ will not be optimized; use sugared optional ‘?’ instead
        """
    }

    public var isUnsugaredOptional: Bool {
        if  let identifier: IdentifierTypeSyntax = self.as(IdentifierTypeSyntax.self) {
            return identifier.name.unescaped == "Optional"
                && identifier.genericArgumentClause?.arguments.count == 1
        }
        if  let member: MemberTypeSyntax = self.as(MemberTypeSyntax.self) {
            guard
            member.name.unescaped == "Optional",
            member.genericArgumentClause?.arguments.count == 1,
            let base: IdentifierTypeSyntax = member.baseType.as(
                IdentifierTypeSyntax.self
            ) else {
                return false
            }
            return base.name.unescaped == "Swift"
        }
        if  let attributed: AttributedTypeSyntax = self.as(AttributedTypeSyntax.self) {
            return attributed.baseType.isUnsugaredOptional
        }
        if  let tuple: TupleTypeSyntax = self.as(TupleTypeSyntax.self),
                tuple.elements.count == 1,
            let first: TupleTypeElementSyntax = tuple.elements.first,
                first.firstName == nil {
            return first.type.isUnsugaredOptional
        }
        return false
    }

    public var isOptional: Bool {
        if  self.is(OptionalTypeSyntax.self) {
            return true
        }
        if  let attributed: AttributedTypeSyntax = self.as(AttributedTypeSyntax.self) {
            return attributed.baseType.isOptional
        }
        if  let tuple: TupleTypeSyntax = self.as(TupleTypeSyntax.self),
                tuple.elements.count == 1,
            let first: TupleTypeElementSyntax = tuple.elements.first,
                first.firstName == nil {
            return first.type.isOptional
        }
        return false
    }
}
