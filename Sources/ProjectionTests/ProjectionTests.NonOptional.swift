import Projection

extension ProjectionTests {
    @Projection(through: "id") enum NonOptional: Equatable {
        case click(Int)
        case hover(String?)
        case scroll

        @inline(always) static func id(_ value: some CustomStringConvertible) -> String {
            value.description
        }
    }
}
