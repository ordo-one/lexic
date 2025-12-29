import Bijection
import Testing

@Suite struct BijectionMacroTests {
    enum Enum: CaseIterable, Equatable {
        case a, b, c

        @Bijection(where: "StringProtocol") var description: String {
            switch self {
            case .a: "a"
            case .b: "b"
            case .c: "c"
            }
        }

        @Bijection var value: Unicode.Scalar {
            switch self {
            case .a: "a"
            case .b: "b"
            case .c: "c"
            }
        }

        @Bijection(label: "index") var index: Int {
            get {
                switch self {
                case .a: 1
                case .b: 2
                case .c: 3
                }
            }
        }

        @Bijection(label: "bytes") @inlinable public var bytes: (UInt8, UInt8, UInt8) {
            switch self {
            case .a: (1, 2, 3)
            case .b: (4, 5, 6)
            case .c: (7, 8, 9)
            }
        }
    }

    @Test static func RoundtrippingGeneric() {
        for `case`: Enum in Enum.allCases {
            #expect(Enum.init(`case`.description[...]) == `case`)
        }
    }
    @Test static func Roundtripping() {
        for `case`: Enum in Enum.allCases {
            #expect(Enum.init(`case`.value) == `case`)
        }
    }
    @Test static func RoundtrippingTuple() {
        for `case`: Enum in Enum.allCases {
            #expect(Enum.init(bytes: `case`.bytes) == `case`)
        }
    }
    @Test static func RoundtrippingWithLabel() {
        for `case`: Enum in Enum.allCases {
            #expect(Enum.init(index: `case`.index) == `case`)
        }
    }
}
