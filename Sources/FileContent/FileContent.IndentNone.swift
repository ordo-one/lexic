extension FileContent {
    /// This type is a syntactical construct that allows writing `>0` without the `0`.
    @frozen public enum IndentNone {
        @inlinable public static prefix func > (value: Self) -> () {
        }
    }
}
