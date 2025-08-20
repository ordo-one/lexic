import Bijection
import Testing

@Suite struct BijectionMacroTests {
    enum Enum: CaseIterable, Equatable {
        case a, b, c

        @Bijection
        var value: Unicode.Scalar {
            switch self {
            case .a: "a"
            case .b: "b"
            case .c: "c"
            }
        }

        @Bijection(label: "index")
        var index: Int {
            get {
                switch self {
                case .a: 1
                case .b: 2
                case .c: 3
                }
            }
        }
    }

    @Test static func Roundtripping() {
        for `case`: Enum in Enum.allCases {
            #expect(Enum.init(`case`.value) == `case`)
        }
    }
    @Test static func RoundtrippingWithLabel() {
        for `case`: Enum in Enum.allCases {
            #expect(Enum.init(index: `case`.index) == `case`)
        }
    }
}
