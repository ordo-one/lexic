import Discriminated

extension DiscriminatedMacro {
    @Discriminated(backing: Int.self) enum BackedByInt {
        case low
        case medium
        case high
    }
}
