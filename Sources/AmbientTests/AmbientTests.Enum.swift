import Ambient

extension AmbientTests {
    @ambient enum Enum: Equatable {
        case skippedNonOptional(Int)
        case skippedMixed(x: Int, y: String? = "default")
        case `default`(count: Int = 10)
        case defaultOptionalWithNonOptional(String? = "guest")
        case defaultOptionalWithNil(tag: String? = nil)
        case defaultOptionalWithout(status: Bool?)
        case defaultMultiple(x: Int = 1, y: String? = "hello", z: Double?)
        case defaultUnlabeled(Int = 89)
    }
}
