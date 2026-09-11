import Discriminated

extension DiscriminantMacro {
    @Discriminant enum Raw: String, Equatable {
        enum Union: Equatable {
            case one(Int)
            case two(String)
        }
    }
}
