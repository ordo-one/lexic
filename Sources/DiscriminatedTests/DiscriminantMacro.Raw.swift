import Discriminated

extension DiscriminantMacro {
    @Discriminant enum Raw: String, Equatable {
        @Discriminated(by: Raw.self) enum Union: Equatable {
            case one(Int)
            case two(String)
        }
    }
}
