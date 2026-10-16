import SwiftSyntax

extension EnumCaseDeclSyntax {
    init(case name: TokenSyntax) {
        self.init(caseKeyword: .keyword(.case, trailingTrivia: .spaces(1))) {
            EnumCaseElementSyntax.init(name: name, trailingTrivia: .newlines(1))
        }
    }
}
