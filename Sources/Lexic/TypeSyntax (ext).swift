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
extension TypeSyntax {
    /// The function type this type denotes, looking through attributes, specifiers such as
    /// `inout`, and redundant parentheses.
    public var function: FunctionTypeSyntax? {
        if  let function: FunctionTypeSyntax = self.as(FunctionTypeSyntax.self) {
            return function
        }
        if  let attributed: AttributedTypeSyntax = self.as(AttributedTypeSyntax.self) {
            return attributed.baseType.function
        }
        if  let tuple: TupleTypeSyntax = self.as(TupleTypeSyntax.self),
                tuple.elements.count == 1,
            let first: TupleTypeElementSyntax = tuple.elements.first,
                first.firstName == nil {
            return first.type.function
        }
        return nil
    }

    /// Indicates if this type is spelled as the empty tuple `()`, looking through redundant
    /// parentheses. The spellings `Void` and `Swift.Void` are deliberately not recognized, as
    /// they can be shadowed; see ``isUnsugaredVoid``.
    public var isVoid: Bool {
        guard
        let tuple: TupleTypeSyntax = self.as(TupleTypeSyntax.self) else {
            return false
        }
        if  tuple.elements.isEmpty {
            return true
        }
        if  tuple.elements.count == 1,
            let first: TupleTypeElementSyntax = tuple.elements.first,
                first.firstName == nil {
            return first.type.isVoid
        }
        return false
    }

    public var isUnsugaredVoidDiagnostic: String? {
        guard self.isUnsugaredVoid else {
            return nil
        }
        return """
        spelling ‘\(self.trimmed)’ is not recognized, as it could refer to a type other than \
        the empty tuple; spell it ‘()’ instead
        """
    }

    /// Indicates if this type is spelled as `Void` or `Swift.Void`, looking through attributes
    /// and redundant parentheses. This is only useful for emitting diagnostics, as either
    /// spelling could refer to a shadowing type.
    public var isUnsugaredVoid: Bool {
        self.isSuspected(standard: "Void")
    }

    /// Indicates if this type is spelled as `Error` or `Swift.Error`, looking through
    /// attributes and redundant parentheses. This is only useful for emitting diagnostics, as
    /// either spelling could refer to a shadowing type.
    public var isSuspectedError: Bool {
        self.isSuspected(standard: "Error")
    }

    private func isSuspected(standard name: String) -> Bool {
        if  let identifier: IdentifierTypeSyntax = self.as(IdentifierTypeSyntax.self) {
            return identifier.name.unescaped == name
                && identifier.genericArgumentClause == nil
        }
        if  let member: MemberTypeSyntax = self.as(MemberTypeSyntax.self) {
            guard
            member.name.unescaped == name,
            member.genericArgumentClause == nil,
            let base: IdentifierTypeSyntax = member.baseType.as(
                IdentifierTypeSyntax.self
            ) else {
                return false
            }
            return base.name.unescaped == "Swift"
        }
        if  let attributed: AttributedTypeSyntax = self.as(AttributedTypeSyntax.self) {
            return attributed.baseType.isSuspected(standard: name)
        }
        if  let tuple: TupleTypeSyntax = self.as(TupleTypeSyntax.self),
                tuple.elements.count == 1,
            let first: TupleTypeElementSyntax = tuple.elements.first,
                first.firstName == nil {
            return first.type.isSuspected(standard: name)
        }
        return false
    }

    /// The type this optional type wraps, whether spelled `T?`, `T!`, or `Optional<T>`,
    /// looking through attributes and redundant parentheses, or nil if this type is not an
    /// optional.
    public var wrapped: TypeSyntax? {
        if  let optional: OptionalTypeSyntax = self.as(OptionalTypeSyntax.self) {
            return optional.wrappedType
        }
        if  let optional: ImplicitlyUnwrappedOptionalTypeSyntax = self.as(
                ImplicitlyUnwrappedOptionalTypeSyntax.self
            ) {
            return optional.wrappedType
        }
        if  self.isUnsugaredOptional {
            let arguments: GenericArgumentListSyntax?
            if  let identifier: IdentifierTypeSyntax = self.as(IdentifierTypeSyntax.self) {
                arguments = identifier.genericArgumentClause?.arguments
            } else if
                let member: MemberTypeSyntax = self.as(MemberTypeSyntax.self) {
                arguments = member.genericArgumentClause?.arguments
            } else {
                arguments = nil
            }
            if  case .type(let wrapped)? = arguments?.first?.argument {
                return wrapped
            }
        }
        if  let attributed: AttributedTypeSyntax = self.as(AttributedTypeSyntax.self) {
            return attributed.baseType.wrapped
        }
        if  let tuple: TupleTypeSyntax = self.as(TupleTypeSyntax.self),
                tuple.elements.count == 1,
            let first: TupleTypeElementSyntax = tuple.elements.first,
                first.firstName == nil {
            return first.type.wrapped
        }
        return nil
    }

    /// Indicates if this type carries the `inout` specifier.
    public var `inout`: Bool {
        guard
        let attributed: AttributedTypeSyntax = self.as(AttributedTypeSyntax.self) else {
            return false
        }
        return attributed.specifiers.contains {
            guard
            case .simpleTypeSpecifier(let specifier) = $0 else {
                return false
            }
            return specifier.specifier.tokenKind == .keyword(.inout)
        }
    }
}
