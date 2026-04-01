-- =============================================================================
-- ADAMANT MODULE TEMPLATE
-- =============================================================================
-- Copy this file as src/main.lua in a new mod folder.
-- Fill in the sections marked FILL below.
--
-- Works standalone with its own ImGui toggle.
-- When the coordinator is installed, the Framework handles UI — standalone UI is skipped.

local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-ModpackLib']

local config = chalk.auto('config.lua')
public.store = lib.createStore(config)

local backup, revert = lib.createBackupSystem()

local PACK_ID = "run-director"
RunDirectorGodPool_Internal = RunDirectorGodPool_Internal or {}

import("mods/data.lua")
local internal = RunDirectorGodPool_Internal
internal.store = public.store
local priorityOptions = internal.priorityOptions
local priorityDisplayValues = internal.priorityDisplayValues

-- =============================================================================
-- FILL: Module definition
-- =============================================================================

public.definition = {
    modpack      = PACK_ID, -- Opts this module into pack discovery
    id           = "RunDirectorGodPool",
    name         = "God Pool",
    category     = "God Pool",
    group        = "Run Setup",
    tooltip      = "Control which gods enter the run, biome priorities, and first-room hammer behavior.",
    default      = false,
    dataMutation = true, -- true if apply() modifies game tables, false for hook-only mods
    mutationMode = lib.MutationMode.Hybrid,

    -- Optional: inline options rendered below the checkbox in the Framework UI.
    -- Framework handles staging, hashing, and UI — module just reads config values in hooks.
    -- Bits auto-calculated from #values if omitted.
    --
    -- Supported types:
    --   "checkbox" — toggle, stores true/false
    --   "dropdown" — combo box, stores selected string value
    --   "radio"    — radio buttons, stores selected string value
    --
    -- IMPORTANT: configKey must be a flat string — never a table.
    -- Table-path keys are only valid in stateSchema (special modules).
    -- The configKey must also exist in config.lua with the correct default value.
    --
    options      = {
        { type = "separator", label = "God Pool" },
        { type = "stepper",  configKey = "MaxGodsPerRun",                    label = "Max Gods Per Run",            default = 4,              min = 1,     max = 9 },
        { type = "checkbox", configKey = "AphroditeEnabled",                 label = "Aphrodite",           default = true },
        { type = "checkbox", configKey = "ApolloEnabled",                    label = "Apollo",              default = true },
        { type = "checkbox", configKey = "AresEnabled",                      label = "Ares",                default = true },
        { type = "checkbox", configKey = "DemeterEnabled",                   label = "Demeter",             default = true },
        { type = "checkbox", configKey = "HephaestusEnabled",                label = "Hephaestus",          default = true },
        { type = "checkbox", configKey = "HeraEnabled",                      label = "Hera",                default = true },
        { type = "checkbox", configKey = "HestiaEnabled",                    label = "Hestia",              default = true },
        { type = "checkbox", configKey = "PoseidonEnabled",                  label = "Poseidon",            default = true },
        { type = "checkbox", configKey = "ZeusEnabled",                      label = "Zeus",                default = true },

        { type = "separator", label = "Options" },
        { type = "checkbox", configKey = "KeepsakeAddsGod",                  label = "God Keepsakes Add to The Pool",           default = false },
        { type = "checkbox", configKey = "PreventEarlySeleneHermes",         label = "Prevent Early Selene/Hermes",             default = false },
        { type = "checkbox", configKey = "PrioritizeHammerFirstRoomEnabled", label = "Force Hammer First Room",                 default = false },

        { type = "separator", label = "Biome Priority" },
        { type = "checkbox", configKey = "PrioritizeSpecificRewardEnabled",  label = "Choose First Boon in Each Biome",       default = false },
        { type = "dropdown", configKey = "PriorityBiome1",                   label = "Biome 1 Priority",            values = priorityOptions, displayValues = priorityDisplayValues, default = "", visibleIf = "PrioritizeSpecificRewardEnabled", indent = true },
        { type = "dropdown", configKey = "PriorityBiome2",                   label = "Biome 2 Priority",            values = priorityOptions, displayValues = priorityDisplayValues, default = "", visibleIf = "PrioritizeSpecificRewardEnabled", indent = true },
        { type = "dropdown", configKey = "PriorityBiome3",                   label = "Biome 3 Priority",            values = priorityOptions, displayValues = priorityDisplayValues, default = "", visibleIf = "PrioritizeSpecificRewardEnabled", indent = true },
        { type = "dropdown", configKey = "PriorityBiome4",                   label = "Biome 4 Priority",            values = priorityOptions, displayValues = priorityDisplayValues, default = "", visibleIf = "PrioritizeSpecificRewardEnabled", indent = true },

        { type = "separator", label = "Trial Priority" },
        { type = "checkbox", configKey = "PrioritizeTrialRewardEnabled",     label = "Choose Boons Priority in Trial Rooms",       default = false },
        { type = "dropdown", configKey = "PriorityTrial1",                   label = "Trial Priority A",            values = priorityOptions, displayValues = priorityDisplayValues, default = "", visibleIf = "PrioritizeTrialRewardEnabled", indent = true },
        { type = "dropdown", configKey = "PriorityTrial2",                   label = "Trial Priority B",            values = priorityOptions, displayValues = priorityDisplayValues, default = "", visibleIf = "PrioritizeTrialRewardEnabled", indent = true },
    },
}

-- =============================================================================
-- FILL: apply() — mutate game data (use backup before changes)
-- =============================================================================

local function apply()
    if internal.ApplyDataMutation then
        internal.ApplyDataMutation(backup)
    end
end

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

-- =============================================================================
-- Wiring (do not modify)
-- =============================================================================

public.definition.apply = apply
public.definition.revert = revert
public.isGodEnabledInPool = function(godKey)
    if internal.IsGodEnabledInPool then
        return internal.IsGodEnabledInPool(godKey)
    end
    return true
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(public.store, public.definition.modpack) then
            lib.applyDefinition(public.definition, public.store)
        end
        if public.definition.dataMutation and not lib.isCoordinated(public.definition.modpack) then
            SetupRunData()
        end
    end)
end)

-- Standalone UI — menu-bar toggle when coordinator is not installed
local uiCallback = lib.standaloneUI(public.definition, public.store, apply, revert)
---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(uiCallback)
