import Lexic
import SwiftSyntax
import Testing

@Suite struct AttributeListMirrored {
    private static var attributes: AttributeListSyntax {
        let decl: DeclSyntax = """
        @_spi(Testing) @available(*, deprecated) @inlinable @frozen @objc public var x: Int
        """
        return decl.as(VariableDeclSyntax.self)?.attributes ?? []
    }

    @Test static func AsTypeForType() {
        let mirrored: [String] = Self.attributes.mirroredAsTypeForType.map { "\($0.trimmed)" }
        #expect(mirrored == ["@_spi(Testing)", "@available(*, deprecated)", "@frozen"])
    }
    @Test static func AsTypeForMember() {
        let mirrored: [String] = Self.attributes.mirroredAsTypeForMember.map { "\($0.trimmed)" }
        #expect(mirrored == ["@_spi(Testing)", "@available(*, deprecated)"])
    }
    @Test static func AsMemberForMember() {
        let mirrored: [String] = Self.attributes.mirroredAsMemberForMember.map {
            "\($0.trimmed)"
        }
        #expect(mirrored == ["@_spi(Testing)", "@available(*, deprecated)", "@inlinable"])
    }
}
