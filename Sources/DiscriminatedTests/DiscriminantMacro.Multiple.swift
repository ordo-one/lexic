import Discriminated

extension DiscriminantMacro {
    @Discriminant(of: "Target") enum Multiple: Equatable {
        enum Unrelated {}
        enum Target: Equatable {
            case first
            case second(String)
        }
    }
}
