import Discriminated

extension DiscriminantMacro {
    @Discriminant enum Solitary: Equatable {
        @Discriminated(by: Solitary.self) enum Union: Equatable {
            case first
            case second(Int)
        }
    }
}
