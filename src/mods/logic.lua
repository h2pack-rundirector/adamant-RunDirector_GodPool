local internal = RunDirectorGodPool_Internal
local godList = internal.godList
local lootKeyLookup = internal.lootKeyLookup
local godLookup = internal.godLookup

local function Read(key)
    return store.read(key)
end

local function IsEnabled()
    return lib.isEnabled(store, public.definition.modpack)
end

function internal.GetRunState()
    if not CurrentRun then return nil end
    if not CurrentRun.RunDirector_GodPool_State then
        CurrentRun.RunDirector_GodPool_State = {
            EnabledGodsOverride = {},
            MaxGodsPerRunOverride = nil,
            BiomePrioritySatisfied = {},
        }
    end
    return CurrentRun.RunDirector_GodPool_State
end

function internal.IsGodEnabledInPool(godKey)
    local god = godLookup[godKey]
    if not god then return true end
    return Read(god.configKey) ~= false
end

local function PriorityKeyForBiome(biomeIndex)
    biomeIndex = math.max((biomeIndex or 0) - 1, 0)
    if biomeIndex == 0 then return Read("PriorityBiome1") or "" end
    if biomeIndex == 1 then return Read("PriorityBiome2") or "" end
    if biomeIndex == 2 then return Read("PriorityBiome3") or "" end
    if biomeIndex == 3 then return Read("PriorityBiome4") or "" end
    return ""
end

local function PriorityKeyForTrial(trialIndex)
    if trialIndex == 1 then return Read("PriorityTrial1") or "" end
    if trialIndex == 2 then return Read("PriorityTrial2") or "" end
    return ""
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

local PREVENT_EARLY_REQUIRE_NOT_ROOM_REWARD = {
    "Boon", "SpellDrop", "Devotion", "HermesUpgrade", "WeaponUpgrade",
    "AphroditeUpgrade", "ApolloUpgrade", "DemeterUpgrade",
    "HephaestusUpgrade", "HestiaUpgrade", "HeraUpgrade",
    "PoseidonUpgrade", "ZeusUpgrade", "AresUpgrade",
}

local PREVENT_EARLY_REQUIREMENT_KEYS = {
    "SpellDropRequirements",
    "HermesUpgradeRequirements",
    "HammerLootRequirements",
}

function internal.BuildPatchPlan(plan)
    plan:setMany(WeaponShopItemData.ToolExorcismBook2, { ElementChance = 1.0 })
    plan:setMany(WeaponShopItemData.ToolShovel2, { ElementChance = 1.0 })
    plan:setMany(WeaponShopItemData.ToolPickaxe2, { ElementChance = 1.0 })
    plan:setMany(WeaponShopItemData.ToolFishingRod2, { ElementChance = 1.0 })
    if Read("PreventEarlySeleneHermes") then
        plan:set(
            EncounterData.BaseArtemisCombat,
            "RequireNotRoomReward",
            PREVENT_EARLY_REQUIRE_NOT_ROOM_REWARD
        )
        for _, key in ipairs(PREVENT_EARLY_REQUIREMENT_KEYS) do
            plan:appendUnique(NamedRequirementsData, key, PREVENT_EARLY_REQUIREMENT)
        end
    end
end

function internal.RegisterHooks()
    modutil.mod.Path.Wrap("GetEligibleLootNames", function(base, excludeLootNames)
        if not IsEnabled() then return base(excludeLootNames) end

        local state = internal.GetRunState()
        if not state then return base(excludeLootNames) end
        state.MaxGodsPerRunOverride = state.MaxGodsPerRunOverride or Read("MaxGodsPerRun")
        state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}

        local eligible = base(excludeLootNames)
        local filtered = {}
        local overrides = state.EnabledGodsOverride or {}
        local currentBiomeIndex = CurrentRun and CurrentRun.ClearedBiomes or 0
        local priorityLootKey = PriorityKeyForBiome(currentBiomeIndex)

        local isPriorityMode = Read("PrioritizeSpecificRewardEnabled") and priorityLootKey ~= "" and
            not state.BiomePrioritySatisfied[currentBiomeIndex]
        if isPriorityMode and Contains(eligible, priorityLootKey) then
            return { priorityLootKey }
        end

        for _, lootName in ipairs(eligible) do
            if overrides[lootName] then
                table.insert(filtered, lootName)
            else
                local god = lootKeyLookup[lootName]
                if not god or internal.IsGodEnabledInPool(god.key) then
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
                if internal.IsGodEnabledInPool(god.key) and not excludeSet[god.lootKey] then
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

    modutil.mod.Path.Wrap("ReachedMaxGods", function(base, excludedGods)
        if not IsEnabled() then return base(excludedGods) end
        local state = internal.GetRunState()
        if not state then return base(excludedGods) end
        local maxGods = state.MaxGodsPerRunOverride or Read("MaxGodsPerRun")
        local gods = {}
        for _, godName in pairs(excludedGods or {}) do gods[godName] = true end
        for _, godName in pairs(GetInteractedGodsThisRun() or {}) do gods[godName] = true end
        return TableLength(gods) >= maxGods
    end)

    modutil.mod.Path.Wrap("GiveLoot", function(base, args)
        if not IsEnabled() then return base(args) end
        local state = internal.GetRunState()
        if not state then return base(args) end

        local lootName = args.ForceLootName or args.Name
        if lootName and LootData[lootName] and LootData[lootName].GodLoot then
            local god = lootKeyLookup[lootName]
            local isDisabled = god and not internal.IsGodEnabledInPool(god.key)
            if isDisabled and Read("KeepsakeAddsGod") then
                if not state.EnabledGodsOverride[lootName] then
                    state.EnabledGodsOverride[lootName] = true
                    state.MaxGodsPerRunOverride = (state.MaxGodsPerRunOverride or Read("MaxGodsPerRun")) + 1
                end
            end
        end

        local result = base(args)
        if Read("PrioritizeSpecificRewardEnabled") and
        lootName == PriorityKeyForBiome(CurrentRun and CurrentRun.ClearedBiomes or 0) then
            state.BiomePrioritySatisfied[CurrentRun and CurrentRun.ClearedBiomes or 0] = true
        end
        return result
    end)

    modutil.mod.Path.Wrap("SetupRoomReward", function(base, currentRun, room, previouslyChosenRewards, args)
        base(currentRun, room, previouslyChosenRewards, args)
        if not IsEnabled() then return end
        local chosenRewardType = args and args.ChosenRewardType or room.ChosenRewardType
        if chosenRewardType ~= "Devotion" or not room or not room.Encounter then return end

        if not Read("PrioritizeTrialRewardEnabled") then return end

        local prioA = PriorityKeyForTrial(1)
        local prioB = PriorityKeyForTrial(2)
        local interacted = GetInteractedGodsThisRun() or {}
        if prioA ~= "" and prioB ~= "" and prioA ~= prioB and
        Contains(interacted, prioA) and Contains(interacted, prioB)
            and Contains(GetEligibleLootNames(), prioA)
            and Contains(GetEligibleLootNames({ prioA }), prioB) then
            room.Encounter.LootAName = prioA
            room.Encounter.LootBName = prioB
        end
    end)

    modutil.mod.Path.Wrap("SpawnRoomReward", function(base, eventSource, args)
        if IsEnabled() and Read("PrioritizeHammerFirstRoomEnabled") and
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
