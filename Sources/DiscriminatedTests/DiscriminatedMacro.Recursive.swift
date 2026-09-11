import Discriminated

extension DiscriminatedMacro {
    @Discriminated indirect enum Recursive {
        case leaf
        case node(Recursive)
    }
}
