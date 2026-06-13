@attached(
    peer,
    names: named(init)
) public macro Bijection(label: String = "_", where: String? = nil) = #externalMacro(
    module: "BijectionMacro",
    type: "BijectionMacro"
)
