public import SwiftSyntax

extension GenericRequirementSyntax {
    public func contains(symbol: String) -> Bool {
        switch self.requirement {
        case .sameTypeRequirement(let constraint):
            if  case .type(let type) = constraint.leftType, type.contains(symbol: symbol) {
                return true
            }
            if  case .type(let type) = constraint.rightType, type.contains(symbol: symbol) {
                return true
            } else {
                return false
            }

        case .conformanceRequirement(let constraint):
            return constraint.leftType.contains(symbol: symbol)
                || constraint.rightType.contains(symbol: symbol)

        case .layoutRequirement(let constraint):
            return constraint.type.contains(symbol: symbol)
        }
    }
}
