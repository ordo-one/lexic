/// Provides a convenient way to write formatted strings with a specific indentation level.
@frozen public struct FileContent {
    @usableFromInline var utf8: [UInt8]
    @inlinable init(utf8: [UInt8]) {
        self.utf8 = utf8
    }
}
extension FileContent: ExpressibleByStringInterpolation {}
extension FileContent: ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral value: String) {
        self.init(utf8: [_].init(value.utf8))
        self.utf8.append(0x0A)
    }
}
extension FileContent {
    /// Writes the assigned string with no indentation, and a trailing newline.
    @inlinable public subscript(indent: (IndentNone) -> ()) -> String? {
        get { nil }
        set (lines) { self[>0] = lines }
    }
    /// Writes the assigned string with the specified indentation level, and a trailing newline.
    @inlinable public subscript(indent: Indent) -> String? {
        get { nil }
        set (lines) {
            if let lines: String {
                for line: Substring in lines.split(separator: "\n", omittingEmptySubsequences: false) {
                    if line.isEmpty {
                        self.utf8.append(0x0A)
                        continue
                    }

                    for _: UInt in 0 ..< indent.level * 4 {
                        self.utf8.append(0x20)
                    }

                    self.utf8 += line.utf8
                    self.utf8.append(0x0A)
                }
            }
        }
    }
}
