local logic = {}

local godList
local lootKeyLookup
local godLookup
local runStateCacheName

local function ReadValue(source, alias)
    if type(source) == "function" then
        return source(alias)
    end
    return source.get(alias):read()
end

local function GetRunState(runtime)
    if not runtime or not runtime.cache then return nil end
    return runtime.cache.currentRun.get(runStateCacheName)
end

logic.GetRunState = GetRunState

function logic.isGodEnabledInPool(godKey, source)
    local god = godLookup[godKey]
    if not god then return true end
    if not source then return true end
    return ReadValue(source, god.alias) ~= false
end

local PREVENT_EARLY_REQUIREMENT = {
    Path = { "CurrentRun", "LootTypeHistory" },
    CountOf = {
        "AphroditeUpgrade", "ApolloUpgrade", "DemeterUpgrade",
        "HephaestusUpgrade", "HestiaUpgrade", "HeraUpgrade",
        "PoseidonUpgrade", "ZeusUpgrade", "AresUpgrade",
    },
    Comparison = ">=",
    Value = 1,
}

local PREVENT_EARLY_REQUIREMENT_KEYS = {
    "SpellDropRequirements",
    "HermesUpgradeRequirements",
    "HammerLootRequirements",
}

function logic.buildPatchPlan(_, runtime, plan)
    local data = runtime and runtime.data
    if ReadValue(data, "BoostElementGathering") then
        plan:setMany(WeaponShopItemData.ToolExorcismBook2, { ElementChance = 1.0 })
        plan:setMany(WeaponShopItemData.ToolShovel2, { ElementChance = 1.0 })
        plan:setMany(WeaponShopItemData.ToolPickaxe2, { ElementChance = 1.0 })
        plan:setMany(WeaponShopItemData.ToolFishingRod2, { ElementChance = 1.0 })
    end

    if ReadValue(data, "PreventEarlySeleneHermes") then
        for _, key in ipairs(PREVENT_EARLY_REQUIREMENT_KEYS) do
            plan:appendUnique(NamedRequirementsData, key, PREVENT_EARLY_REQUIREMENT)
        end
    end
end

function logic.registerHooks(module)
    module.hooks.wrap("GetEligibleLootNames", function(host, runtime, base, excludeLootNames)
        if not host.isEnabled() then return base(excludeLootNames) end

        local data = runtime.data
        local state = GetRunState(runtime)
        if not state then return base(excludeLootNames) end
        state.MaxGodsPerRunOverride = state.MaxGodsPerRunOverride or ReadValue(data, "MaxGodsPerRun")

        local eligible = base(excludeLootNames)
        local filtered = {}
        local overrides = state.EnabledGodsOverride or {}

        for _, lootName in ipairs(eligible) do
            if overrides[lootName] then
                table.insert(filtered, lootName)
            else
                local god = lootKeyLookup[lootName]
                if not god or logic.isGodEnabledInPool(god.key, data) then
                    table.insert(filtered, lootName)
                end
            end
        end

        if #filtered == 0 then
            local excludeSet = {}
            for _, lootName in ipairs(excludeLootNames or {}) do
                excludeSet[lootName] = true
            end
            for _, god in ipairs(godList) do
                if logic.isGodEnabledInPool(god.key, data) and not excludeSet[god.lootKey] then
                    table.insert(filtered, god.lootKey)
                end
            end
            for lootName, enabled in pairs(overrides) do
                if enabled and not excludeSet[lootName] then
                    table.insert(filtered, lootName)
                end
            end
        end

        return filtered
    end)

    module.hooks.wrap("ReachedMaxGods", function(host, runtime, base, excludedGods)
        if not host.isEnabled() then return base(excludedGods) end
        local data = runtime.data
        local state = GetRunState(runtime)
        if not state then return base(excludedGods) end
        local maxGods = state.MaxGodsPerRunOverride or ReadValue(data, "MaxGodsPerRun")
        local gods = {}
        for _, godName in pairs(excludedGods or {}) do gods[godName] = true end
        for _, godName in pairs(GetInteractedGodsThisRun() or {}) do gods[godName] = true end
        return TableLength(gods) >= maxGods
    end)

    module.hooks.wrap("GiveLoot", function(host, runtime, base, args)
        if not host.isEnabled() then return base(args) end
        local data = runtime.data
        local state = GetRunState(runtime)
        if not state then return base(args) end

        local lootName = args.ForceLootName or args.Name
        if lootName and LootData[lootName] and LootData[lootName].GodLoot then
            local god = lootKeyLookup[lootName]
            local isDisabled = god and not logic.isGodEnabledInPool(god.key, data)
            if isDisabled and ReadValue(data, "KeepsakeAddsGod") then
                if not state.EnabledGodsOverride[lootName] then
                    state.EnabledGodsOverride[lootName] = true
                    state.MaxGodsPerRunOverride = (state.MaxGodsPerRunOverride or ReadValue(data, "MaxGodsPerRun")) + 1
                end
            end
        end

        return base(args)
    end)

    module.hooks.wrap("SpawnRoomReward", function(host, runtime, base, eventSource, args)
        if host.isEnabled() and ReadValue(runtime.data, "PrioritizeHammerFirstRoomEnabled") and
        CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.BiomeStartRoom then
            args = args or {}
            if args.WaitUntilPickup then
                args.RewardOverride = "WeaponUpgrade"
                args.LootName = nil
            end
        end
        return base(eventSource, args)
    end)
end

function logic.bind(data)
    godList = data.godList
    lootKeyLookup = data.lootKeyLookup
    godLookup = data.godLookup
    runStateCacheName = data.runStateCacheName
    return logic
end

return logic
