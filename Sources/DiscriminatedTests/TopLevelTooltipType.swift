import Discriminated

@Discriminant enum TopLevelTooltipType: Equatable {
    enum Union: Equatable {
        case item(Int)
        case text(String)
    }
}
