import Ambient

extension AmbientTests {
    @ambient indirect enum Recursive: Equatable {
        case leaf
        case node(Recursive?)
    }
}
