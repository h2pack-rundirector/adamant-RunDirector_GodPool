local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
local chalk = mods['SGG_Modding-Chalk']
local reload = mods['SGG_Modding-ReLoad']
lib = mods['adamant-ModpackLib']

local dataDefaults = import("config.lua")
local config = chalk.auto('config.lua')


local PACK_ID = "run-director"
RunDirectorGodPool_Internal = RunDirectorGodPool_Internal or {}

import("mods/data.lua")
local internal = RunDirectorGodPool_Internal

-- =============================================================================
-- FILL: Module definition
-- =============================================================================

public.definition = {
    modpack      = PACK_ID, -- Opts this module into pack discovery
    id           = "GodPool",
    name         = "God Pool",
    category     = "God Pool",
    tooltip      = "Control which gods enter the run, first-room hammer behavior, and pool support rules.",
    default      = dataDefaults.Enabled,
    affectsRunData = true, -- true if lifecycle changes require run-data rebuilds, false for hook-only mods
}

public.definition.storage = {
    { type = "int",    alias = "MaxGodsPerRun",                    configKey = "MaxGodsPerRun",                    min = 1, max = 9 },
    { type = "bool",   alias = "AphroditeEnabled",                 configKey = "AphroditeEnabled" },
    { type = "bool",   alias = "ApolloEnabled",                    configKey = "ApolloEnabled" },
    { type = "bool",   alias = "AresEnabled",                      configKey = "AresEnabled" },
    { type = "bool",   alias = "DemeterEnabled",                   configKey = "DemeterEnabled" },
    { type = "bool",   alias = "HephaestusEnabled",                configKey = "HephaestusEnabled" },
    { type = "bool",   alias = "HeraEnabled",                      configKey = "HeraEnabled" },
    { type = "bool",   alias = "HestiaEnabled",                    configKey = "HestiaEnabled" },
    { type = "bool",   alias = "PoseidonEnabled",                  configKey = "PoseidonEnabled" },
    { type = "bool",   alias = "ZeusEnabled",                      configKey = "ZeusEnabled" },
    { type = "bool",   alias = "KeepsakeAddsGod",                  configKey = "KeepsakeAddsGod" },
    { type = "bool",   alias = "PreventEarlySeleneHermes",         configKey = "PreventEarlySeleneHermes" },
    { type = "bool",   alias = "BoostElementGathering",            configKey = "BoostElementGathering" },
    { type = "bool",   alias = "PrioritizeHammerFirstRoomEnabled", configKey = "PrioritizeHammerFirstRoomEnabled" },
}

public.definition.ui = {
    {
        type = "vstack",
        gap = 8,
        children = {
            { type = "text", text = "God Pool" },
            { type = "stepper",  binds = { value = "MaxGodsPerRun" },            label = "Max Gods Per Run", quick = true, min = 1, max = 9, step = 1 },
            { type = "checkbox", binds = { value = "AphroditeEnabled" },         label = "Aphrodite",        quick = true },
            { type = "checkbox", binds = { value = "ApolloEnabled" },            label = "Apollo",           quick = true },
            { type = "checkbox", binds = { value = "AresEnabled" },              label = "Ares",             quick = true },
            { type = "checkbox", binds = { value = "DemeterEnabled" },           label = "Demeter",          quick = true },
            { type = "checkbox", binds = { value = "HephaestusEnabled" },        label = "Hephaestus",       quick = true },
            { type = "checkbox", binds = { value = "HeraEnabled" },              label = "Hera",             quick = true },
            { type = "checkbox", binds = { value = "HestiaEnabled" },            label = "Hestia",           quick = true },
            { type = "checkbox", binds = { value = "PoseidonEnabled" },          label = "Poseidon",         quick = true },
            { type = "checkbox", binds = { value = "ZeusEnabled" },              label = "Zeus",             quick = true },

            { type = "text", text = "Options" },
            { type = "checkbox", binds = { value = "KeepsakeAddsGod" },                  label = "God Keepsakes Add to The Pool" },
            { type = "checkbox", binds = { value = "PreventEarlySeleneHermes" },         label = "Prevent Early Selene/Hermes" },
            { type = "checkbox", binds = { value = "BoostElementGathering" },            label = "Guarantee Element from Gathering Tool" },
            { type = "checkbox", binds = { value = "PrioritizeHammerFirstRoomEnabled" }, label = "Force Hammer First Room" },
        },
    },
}

public.store = lib.store.create(config, public.definition, dataDefaults)
store = public.store

-- =============================================================================
-- FILL: apply() — mutate game data (use backup before changes)
-- =============================================================================

public.definition.patchPlan = function(plan)
    if internal.BuildPatchPlan then
        internal.BuildPatchPlan(plan)
    end
end

-- =============================================================================
-- FILL: registerHooks() — wrap game functions
-- =============================================================================

local function registerHooks()
    import("mods/logic.lua")
    if internal.RegisterHooks then
        internal.RegisterHooks()
    end
end

local function init()
    import_as_fallback(rom.game)
    registerHooks()
    if lib.coordinator.isEnabled(store, public.definition.modpack) then
        lib.mutation.apply(public.definition, store)
    end
    if public.definition.affectsRunData and not lib.coordinator.isCoordinated(public.definition.modpack) then
        SetupRunData()
    end
end

-- =============================================================================
-- Wiring (do not modify)
-- =============================================================================

public.isGodEnabledInPool = function(godKey)
    if internal.IsGodEnabledInPool then
        return internal.IsGodEnabledInPool(godKey)
    end
    return true
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(init, init)
end)

-- Standalone UI — menu-bar toggle when coordinator is not installed
local uiCallback = lib.coordinator.standaloneUI(public.definition, store)
---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(uiCallback)
