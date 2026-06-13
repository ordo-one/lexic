extension FileContent {
    @frozen public struct Indent {
        @usableFromInline let level: UInt
        @inlinable init(level: UInt) {
            self.level = level
        }
    }
}
