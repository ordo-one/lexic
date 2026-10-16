import Discriminated

extension DiscriminatedMacro {
    @Discriminated enum Action: Equatable {
        case start
        case stop
        case reset(Int?)
    }
}
