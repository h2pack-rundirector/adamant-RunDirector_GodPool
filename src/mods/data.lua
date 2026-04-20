RunDirectorGodPool_Internal = RunDirectorGodPool_Internal or {}
local internal = RunDirectorGodPool_Internal

public.definition.storage = {
    { type = "int",  alias = "MaxGodsPerRun",                    configKey = "MaxGodsPerRun",                    min = 1, max = 9 },
    { type = "bool", alias = "AphroditeEnabled",                 configKey = "AphroditeEnabled" },
    { type = "bool", alias = "ApolloEnabled",                    configKey = "ApolloEnabled" },
    { type = "bool", alias = "AresEnabled",                      configKey = "AresEnabled" },
    { type = "bool", alias = "DemeterEnabled",                   configKey = "DemeterEnabled" },
    { type = "bool", alias = "HephaestusEnabled",                configKey = "HephaestusEnabled" },
    { type = "bool", alias = "HeraEnabled",                      configKey = "HeraEnabled" },
    { type = "bool", alias = "HestiaEnabled",                    configKey = "HestiaEnabled" },
    { type = "bool", alias = "PoseidonEnabled",                  configKey = "PoseidonEnabled" },
    { type = "bool", alias = "ZeusEnabled",                      configKey = "ZeusEnabled" },
    { type = "bool", alias = "KeepsakeAddsGod",                  configKey = "KeepsakeAddsGod" },
    { type = "bool", alias = "PreventEarlySeleneHermes",         configKey = "PreventEarlySeleneHermes" },
    { type = "bool", alias = "BoostElementGathering",            configKey = "BoostElementGathering" },
    { type = "bool", alias = "PrioritizeHammerFirstRoomEnabled", configKey = "PrioritizeHammerFirstRoomEnabled" },
}

public.definition.hashGroups = {
    {
        key = "pool_1",
        "MaxGodsPerRun",
        "AphroditeEnabled",
        "ApolloEnabled",
        "AresEnabled",
        "DemeterEnabled",
        "HephaestusEnabled",
        "HeraEnabled",
        "HestiaEnabled",
        "PoseidonEnabled",
        "ZeusEnabled",
        "KeepsakeAddsGod",
        "PreventEarlySeleneHermes",
        "BoostElementGathering",
        "PrioritizeHammerFirstRoomEnabled",
    },
}

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

for _, god in ipairs(internal.godList) do
    internal.lootKeyLookup[god.lootKey] = god
    internal.godLookup[god.key] = god
end
