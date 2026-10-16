import Projection

extension ProjectionTests {
    @Projection(through: "tag") indirect enum Recursive: Equatable {
        case leaf
        case node(Int?)

        @inline(always) static func tag(_ value: some CustomStringConvertible) -> String {
            value.description
        }
    }
}
