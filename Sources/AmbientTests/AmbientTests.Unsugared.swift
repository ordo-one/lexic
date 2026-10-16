import Ambient

extension AmbientTests {
    typealias _Optional = Optional

    #if LEXIC_WARNING
    @ambient enum Unsugared: Equatable {
        case a(Optional<Int>)
        case b(Optional<String>)
        case defaulted(Swift.Optional<Int> = 89)
        case plain
    }
    #else
    @ambient enum Unsugared: Equatable {
        case defaulted(_Optional<Int> = 89)
        case plain
    }
    #endif
}
