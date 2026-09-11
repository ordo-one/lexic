import Discriminated

extension DiscriminatedMacro {
    @Discriminated(discriminant: "CustomTypeName") enum Custom {
        case first
        case second(Int)
    }
}
