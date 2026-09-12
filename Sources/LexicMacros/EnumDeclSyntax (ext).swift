import Lexic
import SwiftSyntax

extension EnumDeclSyntax {
    var isPublicOrPackage: Bool {
        self.modifiers.contains {
            $0.name.text == "public" || $0.name.text == "package"
        }
    }

    var isUsableFromInline: Bool {
        self.attributes.contains {
            if  case .attribute(let attribute) = $0 {
                return attribute.baseName == "usableFromInline"
            } else {
                return false
            }
        }
    }

    var isInlinable: Bool {
        self.isPublicOrPackage || self.isUsableFromInline
    }

    var inlinable: String {
        self.isInlinable ? "@inlinable " : ""
    }

    var modifiersForMember: DeclModifierListSyntax {
        self.modifiers.filter { $0.name.text != "indirect" }
    }

    var caseElements: [EnumCaseElementSyntax] {
        self.memberBlock.members.flatMap {
            $0.decl.as(EnumCaseDeclSyntax.self)?.elements ?? []
        }
    }

    var attributesForPeerType: AttributeListSyntax {
        self.attributes.filter {
            guard case .attribute(let attribute) = $0 else {
                return false
            }
            switch attribute.baseName {
            case "available": return true
            case "backDeployed": return true
            case "frozen": return true
            case "usableFromInline": return true
            default: return false
            }
        }
    }
}
