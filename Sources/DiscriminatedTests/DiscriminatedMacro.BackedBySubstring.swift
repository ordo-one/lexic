import Discriminated

extension DiscriminatedMacro {
    @Discriminated(backing: Substring.self) enum BackedBySubstring {
        case foobie
        case barbie(String?)
    }
}
