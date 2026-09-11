import Discriminated

extension DiscriminatedMacro {
    @Discriminated(backing: Substring.self) enum BackedBySubstring {
        case alpha
        case beta
    }
}
