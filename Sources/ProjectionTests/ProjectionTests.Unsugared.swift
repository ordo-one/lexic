import Projection

extension ProjectionTests {
    @Projection(through: "tag") enum Unsugared: Equatable {
        case item(Int?)
        case other(String?)
        case plain

        @inline(always) static func tag(
            _ value: some CustomStringConvertible
        ) -> Optional<String> {
            let description: String = value.description
            return description.isEmpty ? nil : description
        }
    }
}
