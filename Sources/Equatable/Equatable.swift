@attached(
    peer,
    names: named(==)
) public macro Equatable() = #externalMacro(
    module: "EquatableMacro",
    type: "EquatableMacro"
)
