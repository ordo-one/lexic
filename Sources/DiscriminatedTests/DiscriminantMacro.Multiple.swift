import Discriminated

extension DiscriminantMacro {
    @Discriminant enum Multiple: Equatable {
        enum Unrelated {}
        @Discriminated(by: Multiple.self) enum Target: Equatable {
            case first
            case second(String)
        }
    }
}
