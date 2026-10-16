public import SwiftSyntax

extension AttributeListSyntax {
    @inlinable public func first(named baseName: String) -> AttributeSyntax? {
        for case .attribute(let attribute) in self where attribute.baseName == baseName {
            return attribute
        }
        return nil
    }
    @inlinable public func contains<E>(
        where contains: (_ baseName: String) throws(E) -> Bool
    ) throws(E) -> Bool {
        for case .attribute(let attribute) in self {
            if  let baseName: String = attribute.baseName,
                try contains(baseName) {
                return true
            }
        }
        return false
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
