import Discriminated

extension DiscriminatedMacro {
    @Discriminated(backing: Int.self) enum BackedByInt {
        case a
        case b
        case c
    }
}
