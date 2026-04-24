public = {}
_PLUGIN = { guid = "test-god-pool" }

local function deepCopy(orig)
    if type(orig) ~= "table" then
        return orig
    end
    local copy = {}
    for key, value in pairs(orig) do
        copy[key] = deepCopy(value)
    end
    return copy
end

rom = {
    mods = {},
    game = {
        DeepCopyTable = deepCopy,
        SetupRunData = function() end,
    },
    ImGui = {},
    ImGuiCol = {
        Text = 1,
    },
    gui = {
        add_to_menu_bar = function() end,
        add_imgui = function() end,
    },
}

rom.mods["SGG_Modding-ENVY"] = {
    auto = function()
        return {}
    end,
}

rom.mods["SGG_Modding-Chalk"] = {
    auto = function()
        return { DebugMode = false }
    end,
    original = function(config)
        return config
    end,
}

local registeredWraps = {}

modutil = {
    once_loaded = {
        game = function() end,
    },
    mod = {
        Path = {
            Wrap = function(path, handler)
                registeredWraps[path] = handler
                local base = _G[path]
                _G[path] = function(...)
                    return handler(base, ...)
                end
            end,
        },
    },
}
rom.mods["SGG_Modding-ModUtil"] = modutil

import = function(path, fenv, ...)
    local chunk = assert(loadfile("../../adamant-ModpackLib/src/" .. path, "t", fenv or _ENV))
    return chunk(...)
end

dofile("../../adamant-ModpackLib/src/main.lua")
lib = public
rom.mods["adamant-ModpackLib"] = lib

local function tableLength(values)
    local count = 0
    for _ in pairs(values or {}) do
        count = count + 1
    end
    return count
end

local function installBaseGlobals(opts)
    opts = opts or {}

    CurrentRun = opts.CurrentRun
    WeaponShopItemData = deepCopy(opts.WeaponShopItemData or {
        ToolExorcismBook2 = { ElementChance = 0.25 },
        ToolShovel2 = { ElementChance = 0.25 },
        ToolPickaxe2 = { ElementChance = 0.25 },
        ToolFishingRod2 = { ElementChance = 0.25 },
    })
    NamedRequirementsData = deepCopy(opts.NamedRequirementsData or {
        SpellDropRequirements = {},
        HermesUpgradeRequirements = {},
        HammerLootRequirements = {},
    })
    LootData = deepCopy(opts.LootData or {
        AphroditeUpgrade = { GodLoot = true },
        ApolloUpgrade = { GodLoot = true },
        AresUpgrade = { GodLoot = true },
        DemeterUpgrade = { GodLoot = true },
        HephaestusUpgrade = { GodLoot = true },
        HeraUpgrade = { GodLoot = true },
        HestiaUpgrade = { GodLoot = true },
        PoseidonUpgrade = { GodLoot = true },
        ZeusUpgrade = { GodLoot = true },
        HermesUpgrade = { GodLoot = false },
        WeaponUpgrade = {},
    })

    GetEligibleLootNames = opts.GetEligibleLootNames or function()
        return {
            "ApolloUpgrade",
            "ZeusUpgrade",
            "HermesUpgrade",
        }
    end
    ReachedMaxGods = opts.ReachedMaxGods or function()
        return false
    end
    GiveLoot = opts.GiveLoot or function(args)
        return args
    end
    SpawnRoomReward = opts.SpawnRoomReward or function(_, args)
        return args
    end
    GetInteractedGodsThisRun = opts.GetInteractedGodsThisRun or function()
        return {}
    end
    TableLength = tableLength
end

local function applyOverrides(target, overrides)
    for key, value in pairs(overrides or {}) do
        target[key] = value
    end
end

function ResetGodPoolHarness(opts)
    opts = opts or {}
    registeredWraps = {}
    installBaseGlobals(opts)

    RunDirectorGodPool_Internal = {
        definition = {
            modpack = "run-director",
            id = "GodPool",
            name = "God Pool",
            default = false,
            affectsRunData = true,
        },
    }

    dofile("src/mods/data.lua")
    local dataDefaults = dofile("src/config.lua")
    local config = deepCopy(dataDefaults)
    applyOverrides(config, opts.config)

    local internal = RunDirectorGodPool_Internal
    local store, session = lib.createStore(config, internal.definition, dataDefaults)
    internal.store = store

    dofile("src/mods/logic.lua")
    dofile("src/mods/integrations.lua")

    if opts.registerIntegrations then
        internal.RegisterIntegrations()
    end
    if opts.registerHooks then
        internal.host = lib.createModuleHost({
            definition = internal.definition,
            store = store,
            session = session,
            hookOwner = internal,
            registerHooks = internal.RegisterHooks,
        })
    end

    return {
        internal = internal,
        config = config,
        store = store,
        session = session,
        wrappers = registeredWraps,
    }
end
