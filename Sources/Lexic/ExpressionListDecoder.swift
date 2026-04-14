public import SwiftSyntax

@frozen public struct ExpressionListDecoder<CodingKey>: ~Copyable
    where CodingKey: Hashable & Sendable & RawRepresentable<String> {
    private let owner: TypeSyntax
    private var index: [CodingKey: ArraySlice<LabeledExprSyntax>]
}
extension ExpressionListDecoder {
    public init(indexing attribute: borrowing AttributeSyntax) {
        self.init(owner: attribute.attributeName, index: [:])

        guard let arguments: LabeledExprListSyntax = attribute.arguments?.as(
            LabeledExprListSyntax.self
        ) else {
            return
        }

        for argument: LabeledExprSyntax in arguments {
            // don’t bother diagnosing invalid keys, we rely on the swift compiler to catch that
            if  let id: CodingKey = .init(rawValue: argument.label?.text ?? "_") {
                self.index[id, default: []].append(argument)
            }
        }
    }
}
extension ExpressionListDecoder {
    /// Returns the token associated with the name of the attribute from which this expression
    /// list decoder was created.
    public var node: TypeSyntax { self.owner }
}
extension ExpressionListDecoder {
    public subscript(key: CodingKey) -> ExpressionListDecoderField<ExprSyntax>? {
        mutating get {
            guard let field: LabeledExprSyntax = self.index[key]?.popFirst() else {
                return nil
            }
            return .init(
                label: field.label,
                value: field.expression,
                owner: self.owner,
            )
        }
    }
    public subscript(key: CodingKey) -> ExpressionListDecoderField<ExprSyntax?> {
        mutating get {
            {
                // this helps us distinguish the case where the user mistakenly attempted to
                // decode the same argument twice (or more times)
                if  case nil = $0 {
                    return .init(
                        label: nil,
                        value: nil,
                        owner: self.owner,
                        missing: true
                    )
                } else {
                    let field: LabeledExprSyntax? = $0?.popFirst()
                    return .init(
                        label: field?.label,
                        value: field?.expression,
                        owner: self.owner,
                    )
                }
            } (&self.index[key])
        }
    }
}
