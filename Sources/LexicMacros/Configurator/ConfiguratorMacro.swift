import Lexic
public import SwiftSyntax
public import SwiftSyntaxMacros

@_spi(testable) public struct ConfiguratorMacro {}
extension ConfiguratorMacro: PeerMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingPeersOf decl: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard let decl: InitializerDeclSyntax = decl.as(InitializerDeclSyntax.self) else {
            context[.error, attribute] = "‘@Configurator’ must be applied to an initializer"
            return []
        }

        let parameters: FunctionParameterListSyntax = decl.signature.parameterClause.parameters

        guard let closure: FunctionParameterSyntax = parameters.last else {
            context[.error, decl.signature.parameterClause] = """
            ‘@Configurator’ initializer must declare a trailing closure parameter
            """
            return []
        }

        guard let function: FunctionTypeSyntax = closure.type.functionType else {
            context[.error, closure.type] = """
            final parameter of ‘@Configurator’ initializer must be a closure
            """
            return []
        }

        guard function.returnClause.type.isVoid else {
            context[.error, function.returnClause.type] = """
            configuration closure must return ‘Void’
            """
            return []
        }

        guard let thrown: ThrowsClauseSyntax = function.effectSpecifiers?.throwsClause else {
            context[.error, closure.type] = """
            configuration closure does not throw; provide a default argument ‘= { _ in }’ \
            instead of using ‘@Configurator’
            """
            return []
        }

        for parameter: FunctionParameterSyntax in parameters {
            if  let ellipsis: TokenSyntax = parameter.ellipsis {
                context[.error, ellipsis] = """
                ‘@Configurator’ cannot forward variadic parameters
                """
                return []
            }
        }

        let preceding: [FunctionParameterSyntax] = parameters.dropLast()

        for parameter: FunctionParameterSyntax in preceding {
            if  case .wildcard = (parameter.secondName ?? parameter.firstName).tokenKind {
                context[.error, parameter] = """
                ‘@Configurator’ cannot forward unnamed parameters
                """
                return []
            }
        }

        //  Determine whether the closure throws a generic error type declared on the
        //  initializer, which can be substituted with `Never` and removed from the peer.
        let error: GenericParameterSyntax?
        if  let generics: GenericParameterClauseSyntax = decl.genericParameterClause,
            let type: IdentifierTypeSyntax = thrown.type?.as(IdentifierTypeSyntax.self),
            case nil = type.genericArgumentClause {
            error = generics.parameters.first { $0.name.unescaped == type.name.unescaped }
        } else {
            error = nil
        }

        var generics: GenericParameterClauseSyntax? = decl.genericParameterClause

        if  let error: GenericParameterSyntax,
            let clause: GenericParameterClauseSyntax = generics {
            let symbol: String = .init(error.name.unescaped)

            for parameter: FunctionParameterSyntax in preceding
                where parameter.type.contains(symbol: symbol) {
                context[.error, parameter.type] = """
                error type ‘\(symbol)’ of configuration closure is referenced by another \
                parameter and cannot be removed from the generated initializer
                """
                return []
            }
            for element: TupleTypeElementSyntax in function.parameters
                where element.type.contains(symbol: symbol) {
                context[.error, element.type] = """
                error type ‘\(symbol)’ of configuration closure is referenced by a closure \
                parameter and cannot be removed from the generated initializer
                """
                return []
            }
            for parameter: GenericParameterSyntax in clause.parameters
                where parameter.name.unescaped != error.name.unescaped {
                if  case true? = parameter.inheritedType?.contains(symbol: symbol) {
                    context[.error, parameter] = """
                    error type ‘\(symbol)’ of configuration closure is referenced by another \
                    generic parameter and cannot be removed from the generated initializer
                    """
                    return []
                }
            }
            if  let requirements: GenericRequirementListSyntax = decl.genericWhereClause?
                    .requirements {
                for requirement: GenericRequirementSyntax in requirements
                    where requirement.contains(symbol: symbol) {
                    context[.error, requirement] = """
                    error type ‘\(symbol)’ of configuration closure is constrained in a \
                    ‘where’ clause and cannot be removed from the generated initializer
                    """
                    return []
                }
            }

            var remaining: [GenericParameterSyntax] = clause.parameters.filter {
                $0.name.unescaped != error.name.unescaped
            }
            if  remaining.isEmpty {
                generics = nil
            } else {
                remaining[remaining.endIndex - 1].trailingComma = nil
                generics = clause.with(\.parameters, .init(remaining))
            }
        }

        //  Determine the effects of the peer initializer.
        let effects: FunctionEffectSpecifiersSyntax? = decl.signature.effectSpecifiers
        let otherThrowingClosures: Bool = preceding.contains {
            $0.type.functionType?.effectSpecifiers?.throwsClause != nil
        }

        let throwsClause: ThrowsClauseSyntax?
        if  let clause: ThrowsClauseSyntax = effects?.throwsClause {
            switch clause.throwsSpecifier.tokenKind {
            case .keyword(.rethrows):
                throwsClause = otherThrowingClosures ? clause : nil

            case .keyword(.throws):
                if  let error: GenericParameterSyntax,
                    let type: IdentifierTypeSyntax = clause.type?.as(IdentifierTypeSyntax.self),
                    case nil = type.genericArgumentClause,
                    type.name.unescaped == error.name.unescaped {
                    throwsClause = nil
                } else if
                    let error: GenericParameterSyntax,
                    case true? = clause.type?.contains(symbol: .init(error.name.unescaped)) {
                    context[.error, clause] = """
                    error type ‘\(error.name.unescaped)’ of configuration closure is \
                    referenced by the thrown error type of the initializer and cannot be \
                    removed from the generated initializer
                    """
                    return []
                } else {
                    throwsClause = clause
                }

            default:
                throwsClause = clause
            }
        } else {
            throwsClause = nil
        }

        let async: Bool = effects?.asyncSpecifier != nil

        //  Assemble the declaration.
        var modifiers: [String] = decl.modifiers.map { $0.trimmedDescription }

        if  case true? = context.lexicalContext.first?.is(ClassDeclSyntax.self),
           !modifiers.contains("convenience") {
            modifiers.append("convenience")
        }

        let attributes: [String] = decl.attributes.mirroredAsMemberForOverload.map {
            $0.trimmedDescription
        }

        var prefix: String = attributes.joined(separator: " ")
        if !prefix.isEmpty {
            prefix += " "
        }
        if !modifiers.isEmpty {
            prefix += modifiers.joined(separator: " ")
            prefix += " "
        }

        var signature: String = "("
        signature += preceding.map { $0.with(\.trailingComma, nil).trimmedDescription }
            .joined(separator: ", ")
        signature += ")"

        if  async {
            signature += " async"
        }
        if  let throwsClause: ThrowsClauseSyntax {
            signature += " \(throwsClause.trimmedDescription)"
        }
        if  let whereClause: GenericWhereClauseSyntax = decl.genericWhereClause {
            signature += " \(whereClause.trimmedDescription)"
        }

        var arguments: [String] = preceding.map {
            let name: TokenSyntax = $0.secondName ?? $0.firstName
            let reference: String = $0.type.isInout ? "&\(name.text)" : name.text
            if  case .wildcard = $0.firstName.tokenKind {
                return reference
            } else {
                return "\($0.firstName.unescaped): \(reference)"
            }
        }

        let closureParameters: String = function.parameters.map {
            "_: \($0.type.trimmedDescription)"
        }.joined(separator: ", ")

        let closureLiteral: String = "{ (\(closureParameters)) throws(Never) -> () in }"

        if  case .wildcard = closure.firstName.tokenKind {
            arguments.append(closureLiteral)
        } else {
            arguments.append("\(closure.firstName.unescaped): \(closureLiteral)")
        }

        var call: String = ""
        if  throwsClause != nil {
            call += "try "
        }
        if  async {
            call += "await "
        }

        let peer: DeclSyntax = """
        \(raw: prefix)init\(raw: decl.optionalMark?.text ?? "")\
        \(raw: generics?.trimmedDescription ?? "")\(raw: signature) {
            \(raw: call)self.init(\(raw: arguments.joined(separator: ", ")))
        }
        """

        return [peer]
    }
}
