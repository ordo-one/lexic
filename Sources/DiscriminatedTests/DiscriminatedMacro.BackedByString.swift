import Discriminated

extension DiscriminatedMacro {
    @Discriminated(backing: String.self) enum BackedByString {
        case first
        case second
    }
}
