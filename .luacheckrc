std = "lua52"
max_line_length = 200
globals = {
    "rom",
    "public",
    "config",
    "modutil",
    "game",
    "chalk",
    "reload",
    "_PLUGIN",
    "lib",
    "RunDirectorGodPool_Internal",
    "CurrentRun",
    "EncounterData",
    "NamedRequirementsData",
    "WeaponShopItemData",
}
read_globals = {
    "imgui",
    "import_as_fallback",
    "import",
    "SetupRunData",
    "GetInteractedGodsThisRun",
    "DeepCopyTable",
    "GetEligibleLootNames",
    "Contains",
    "TableLength",
    "LootData"
}
exclude_files = { "src/main.lua", "src/main_special.lua" }
