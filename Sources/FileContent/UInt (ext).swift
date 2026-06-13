extension UInt {
    @inlinable public static prefix func > (value: Self) -> FileContent.Indent {
        .init(level: value)
    }
}
