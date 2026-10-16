public import SwiftSyntax

extension TokenSyntax {
    /// Strips any number of leading and trailing backticks from the token’s text.
    @inlinable public var unescaped: Substring {
        var text: Substring = self.text[...]
        text = text.drop { $0 == "`" }
        while case "`"? = text.last {
            text.removeLast()
        }
        return text
    }
}
