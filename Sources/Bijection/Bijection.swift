@attached(peer, names: named(init))
public macro Bijection(label: String = "_") = #externalMacro(
    module: "BijectionMacro",
    type: "BijectionMacro"
)
