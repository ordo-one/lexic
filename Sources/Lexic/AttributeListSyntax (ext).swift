public import SwiftSyntax

extension AttributeListSyntax {
    public var attributeNodes: [AttributeSyntax] {
        self.compactMap {
            guard case .attribute(let attribute) = $0 else {
                return nil
            }
            return attribute
        }
    }

    public func first(named name: String) -> AttributeSyntax? {
        for case .attribute(let attribute) in self where attribute.baseName == name {
            return attribute
        }
        return nil
    }

    public func contains(named name: String) -> Bool {
        self.first(named: name) != nil
    }
}
