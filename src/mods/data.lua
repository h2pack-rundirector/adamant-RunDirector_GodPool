RunDirectorGodPool_Internal = RunDirectorGodPool_Internal or {}
local internal = RunDirectorGodPool_Internal

function internal.BuildStorage()
    return {
        { type = "int",  alias = "MaxGodsPerRun",                    default = 4,     min = 1, max = 9 },
        { type = "bool", alias = "AphroditeEnabled",                 default = true },
        { type = "bool", alias = "ApolloEnabled",                    default = true },
        { type = "bool", alias = "AresEnabled",                      default = true },
        { type = "bool", alias = "DemeterEnabled",                   default = true },
        { type = "bool", alias = "HephaestusEnabled",                default = true },
        { type = "bool", alias = "HeraEnabled",                      default = true },
        { type = "bool", alias = "HestiaEnabled",                    default = true },
        { type = "bool", alias = "PoseidonEnabled",                  default = true },
        { type = "bool", alias = "ZeusEnabled",                      default = true },
        { type = "bool", alias = "KeepsakeAddsGod",                  default = false },
        { type = "bool", alias = "PreventEarlySeleneHermes",         default = false },
        { type = "bool", alias = "BoostElementGathering",            default = true },
        { type = "bool", alias = "PrioritizeHammerFirstRoomEnabled", default = false },
    }
end

function internal.BuildHashGroupPlan()
    return {
        {
            keyPrefix = "pool",
            items = {
                {
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
            },
        },
    }
end

internal.godList = {
    { key = "Aphrodite",  lootKey = "AphroditeUpgrade",  alias = "AphroditeEnabled" },
    { key = "Apollo",     lootKey = "ApolloUpgrade",     alias = "ApolloEnabled" },
    { key = "Ares",       lootKey = "AresUpgrade",       alias = "AresEnabled" },
    { key = "Demeter",    lootKey = "DemeterUpgrade",    alias = "DemeterEnabled" },
    { key = "Hephaestus", lootKey = "HephaestusUpgrade", alias = "HephaestusEnabled" },
    { key = "Hera",       lootKey = "HeraUpgrade",       alias = "HeraEnabled" },
    { key = "Hestia",     lootKey = "HestiaUpgrade",     alias = "HestiaEnabled" },
    { key = "Poseidon",   lootKey = "PoseidonUpgrade",   alias = "PoseidonEnabled" },
    { key = "Zeus",       lootKey = "ZeusUpgrade",       alias = "ZeusEnabled" },
}

internal.lootKeyLookup = {}
internal.godLookup = {}

for _, god in ipairs(internal.godList) do
    internal.lootKeyLookup[god.lootKey] = god
    internal.godLookup[god.key] = god
end

return internal
