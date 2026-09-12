import Lexic
import SwiftSyntax

extension EnumDeclSyntax {
    var packageOrHigher: Bool {
        self.modifiers.contains {
            $0.name.text == "public" || $0.name.text == "package"
        }
    }
}
extension EnumDeclSyntax {
    func attributesForMember(inlinable: Bool) -> AttributeListSyntax {
        var attributes: AttributeListSyntax = self.attributes.mirroredAsTypeForMember
        if  inlinable {
            let qualifies: Bool = self.packageOrHigher || self.attributes.contains {
                $0 == "usableFromInline"
            }
            if  qualifies {
                attributes.append(.attribute("@inlinable "))
            }
        }
        return attributes
    }

    var attributesForMember: AttributeListSyntax {
        self.attributesForMember(inlinable: true)
    }

    var modifiersForMember: DeclModifierListSyntax {
        self.modifiers.filter { $0.name.text != "indirect" }
    }

    var cases: [EnumCaseElementSyntax] {
        self.memberBlock.members.flatMap {
            $0.decl.as(EnumCaseDeclSyntax.self)?.elements ?? []
        }
    }
}
