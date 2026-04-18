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
local internal = RunDirectorGodPool_Internal

-- =============================================================================
-- FILL: Module definition
-- =============================================================================

public.definition = {
    modpack      = PACK_ID, -- Opts this module into pack discovery
    id           = "GodPool",
    name         = "God Pool",
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

-- =============================================================================
-- FILL: apply() — mutate game data (use backup before changes)
-- =============================================================================

public.definition.patchPlan = function(plan)
    if internal.BuildPatchPlan then
        internal.BuildPatchPlan(plan)
    end
end

public.store = nil
store = nil
internal.standaloneUi = nil
-- =============================================================================
-- FILL: registerHooks() — wrap game functions
-- =============================================================================

local function registerHooks()
    import("mods/logic.lua")
    if internal.RegisterHooks then
        internal.RegisterHooks()
    end
    public.DrawTab = internal.DrawTab
    public.DrawQuickContent = internal.DrawQuickContent
end

local function init()
    import_as_fallback(rom.game)
    import("mods/data.lua")
    import("mods/ui.lua")
    public.store = lib.store.create(config, public.definition, dataDefaults)
    store = public.store
    registerHooks()
    if lib.coordinator.isEnabled(store, public.definition.modpack) then
        lib.mutation.apply(public.definition, store)
    end
    if public.definition.affectsRunData and not lib.coordinator.isCoordinated(public.definition.modpack) then
        SetupRunData()
    end
    internal.standaloneUi = lib.host.standaloneUI(
        public.definition,
        store,
        store.uiState,
        {
            drawTab = internal.DrawTab,
        }
    )
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

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_imgui(function()
    if internal.standaloneUi and internal.standaloneUi.renderWindow then
        internal.standaloneUi.renderWindow()
    end
end)

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(function()
    if internal.standaloneUi and internal.standaloneUi.addMenuBar then
        internal.standaloneUi.addMenuBar()
    end
end)
