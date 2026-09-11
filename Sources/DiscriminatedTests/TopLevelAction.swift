import Discriminated

@Discriminated enum TopLevelAction: Equatable {
    case start
    case stop
    case reset(Int?)
}
