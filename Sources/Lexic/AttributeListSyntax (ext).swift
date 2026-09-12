public import SwiftSyntax

extension AttributeListSyntax {
    public func first(named name: String) -> AttributeSyntax? {
        for case .attribute(let attribute) in self where attribute.baseName == name {
            return attribute
        }
        return nil
    }
}
extension AttributeListSyntax {
    public var mirroredAsTypeForType: AttributeListSyntax {
        self.filter {
            guard case .attribute(let attribute) = $0 else {
                return false
            }
            switch attribute.baseName {
            case "available":
                return true
            case "frozen":
                return true
            case "usableFromInline":
                return true
            default:
                return false
            }
        }
    }

    public var mirroredAsTypeForMember: AttributeListSyntax {
        self.filter {
            guard case .attribute(let attribute) = $0 else {
                return false
            }
            switch attribute.baseName {
            case "available":
                return true
            default:
                return false
            }
        }
    }

    public var mirroredAsMemberForMember: AttributeListSyntax {
        self.filter {
            guard case .attribute(let attribute) = $0 else {
                return false
            }
            switch attribute.baseName {
            case "available":
                return true
            case "backDeployed":
                return true
            case "inlinable":
                return true
            case "inline":
                return true
            case "usableFromInline":
                return true
            default:
                return false
            }
        }
    }
}
