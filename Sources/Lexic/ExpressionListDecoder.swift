public import SwiftSyntax

@frozen public struct ExpressionListDecoder<CodingKey>: ~Copyable
    where CodingKey: Hashable & Sendable & RawRepresentable<String> {
    private let owner: TypeSyntax
    private var index: [CodingKey: ArraySlice<ExprSyntax>]
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
                self.index[id, default: []].append(argument.expression)
            }
        }
    }
}
extension ExpressionListDecoder {
    public subscript(key: CodingKey) -> Field<ExprSyntax>? {
        mutating get {
            guard let expression: ExprSyntax = self.index[key]?.popFirst() else {
                return nil
            }
            return .init(id: key, owner: self.owner, value: expression)
        }
    }
    public subscript(key: CodingKey) -> Field<ExprSyntax?> {
        mutating get {
            {
                // this helps us distinguish the case where the user mistakenly attempted to
                // decode the same argument twice (or more times)
                if  case nil = $0 {
                    return .init(id: key, owner: self.owner, value: nil, missing: true)
                } else {
                    return .init(id: key, owner: self.owner, value: $0?.popFirst())
                }
            } (&self.index[key])
        }
    }
}
