RunDirectorGodPool_Internal = RunDirectorGodPool_Internal or {}
local internal = RunDirectorGodPool_Internal

internal.godList = {
    { key = "Aphrodite",  lootKey = "AphroditeUpgrade",  configKey = "AphroditeEnabled" },
    { key = "Apollo",     lootKey = "ApolloUpgrade",     configKey = "ApolloEnabled" },
    { key = "Ares",       lootKey = "AresUpgrade",       configKey = "AresEnabled" },
    { key = "Demeter",    lootKey = "DemeterUpgrade",    configKey = "DemeterEnabled" },
    { key = "Hephaestus", lootKey = "HephaestusUpgrade", configKey = "HephaestusEnabled" },
    { key = "Hera",       lootKey = "HeraUpgrade",       configKey = "HeraEnabled" },
    { key = "Hestia",     lootKey = "HestiaUpgrade",     configKey = "HestiaEnabled" },
    { key = "Poseidon",   lootKey = "PoseidonUpgrade",   configKey = "PoseidonEnabled" },
    { key = "Zeus",       lootKey = "ZeusUpgrade",       configKey = "ZeusEnabled" },
}

internal.lootKeyLookup = {}
internal.godLookup = {}
internal.priorityOptions = { "" }
internal.priorityDisplayValues = { [""] = "None" }

for _, god in ipairs(internal.godList) do
    internal.lootKeyLookup[god.lootKey] = god
    internal.godLookup[god.key] = god
    table.insert(internal.priorityOptions, god.lootKey)
    internal.priorityDisplayValues[god.lootKey] = god.key
end
