import Ambient

extension AmbientTests {
    @ambient enum Simple: Equatable {
        case reset(Int?)
        case start
        case stop
    }
}
