import Discriminated

@Discriminant enum TopLevelEnum: Equatable {
    @Discriminated(by: TopLevelEnum.self) enum Union: Equatable {
        case item(Int)
        case text(String)
    }
}
