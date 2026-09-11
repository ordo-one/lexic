import Discriminated

extension DiscriminantMacro {
    @Discriminant enum Solitary: Equatable {
        enum Union: Equatable {
            case first
            case second(Int)
        }
    }
}
