local lib = rom.mods['adamant-ModpackLib']
local internal = RunDirectorGodPool_Internal
local godList = internal.godList
local lootKeyLookup = internal.lootKeyLookup
local godLookup = internal.godLookup

local function IsEnabled()
    return lib.isEnabled(config, public.definition.modpack)
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
    return config[god.configKey] ~= false
end

local function ListContainsEquivalent(list, template)
    if type(list) ~= "table" then return false end
    for _, entry in ipairs(list) do
        local same = true
        for k, v in pairs(template) do
            if type(v) == "table" then
                if not ListContainsEquivalent({ entry[k] }, v) then
                    same = false
                    break
                end
            elseif entry[k] ~= v then
                same = false
                break
            end
        end
        if same then
            return true
        end
    end
    return false
end

local function PriorityKeyForBiome(biomeIndex)
    biomeIndex = math.max((biomeIndex or 0) - 1, 0)
    if biomeIndex == 0 then return config.PriorityBiome1 or "" end
    if biomeIndex == 1 then return config.PriorityBiome2 or "" end
    if biomeIndex == 2 then return config.PriorityBiome3 or "" end
    if biomeIndex == 3 then return config.PriorityBiome4 or "" end
    return ""
end

local function PriorityKeyForTrial(trialIndex)
    if trialIndex == 1 then return config.PriorityTrial1 or "" end
    if trialIndex == 2 then return config.PriorityTrial2 or "" end
    return ""
end

local function EnsurePreventEarlySeleneHermesRequirement(backup)
    local additionalReq = {
        Path = { "CurrentRun", "LootTypeHistory" },
        CountOf = {
            "AphroditeUpgrade", "ApolloUpgrade", "DemeterUpgrade",
            "HephaestusUpgrade", "HestiaUpgrade", "HeraUpgrade",
            "PoseidonUpgrade", "ZeusUpgrade", "AresUpgrade",
        },
        Comparison = ">=",
        Value = 1,
    }

    backup(EncounterData, "BaseArtemisCombat")
    EncounterData.BaseArtemisCombat.RequireNotRoomReward = {
        "Boon", "SpellDrop", "Devotion", "HermesUpgrade", "WeaponUpgrade",
        "AphroditeUpgrade", "ApolloUpgrade", "DemeterUpgrade",
        "HephaestusUpgrade", "HestiaUpgrade", "HeraUpgrade",
        "PoseidonUpgrade", "ZeusUpgrade", "AresUpgrade",
    }

    for _, key in ipairs({ "SpellDropRequirements", "HermesUpgradeRequirements", "HammerLootRequirements" }) do
        backup(NamedRequirementsData, key)
        local list = DeepCopyTable(NamedRequirementsData[key] or {})
        if not ListContainsEquivalent(list, additionalReq) then
            table.insert(list, DeepCopyTable(additionalReq))
        end
        NamedRequirementsData[key] = list
    end
end

function internal.ApplyDataMutation(backup)
    if config.PreventEarlySeleneHermes then
        EnsurePreventEarlySeleneHermesRequirement(backup)
    end

    backup(WeaponShopItemData.ToolExorcismBook2, "ElementChance")
    backup(WeaponShopItemData.ToolShovel2, "ElementChance")
    backup(WeaponShopItemData.ToolPickaxe2, "ElementChance")
    backup(WeaponShopItemData.ToolFishingRod2, "ElementChance")
    WeaponShopItemData.ToolExorcismBook2.ElementChance = 1.0
    WeaponShopItemData.ToolShovel2.ElementChance = 1.0
    WeaponShopItemData.ToolPickaxe2.ElementChance = 1.0
    WeaponShopItemData.ToolFishingRod2.ElementChance = 1.0
end

function internal.RegisterHooks()
    modutil.mod.Path.Wrap("GetEligibleLootNames", function(base, excludeLootNames)
        if not IsEnabled() then return base(excludeLootNames) end

        local state = internal.GetRunState()
        if not state then return base(excludeLootNames) end
        state.MaxGodsPerRunOverride = state.MaxGodsPerRunOverride or config.MaxGodsPerRun
        state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}

        local eligible = base(excludeLootNames)
        local filtered = {}
        local overrides = state.EnabledGodsOverride or {}
        local currentBiomeIndex = CurrentRun and CurrentRun.ClearedBiomes or 0
        local priorityLootKey = PriorityKeyForBiome(currentBiomeIndex)

        local isPriorityMode = config.PrioritizeSpecificRewardEnabled and priorityLootKey ~= "" and
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
        local maxGods = state.MaxGodsPerRunOverride or config.MaxGodsPerRun
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
            if isDisabled and config.KeepsakeAddsGod then
                if not state.EnabledGodsOverride[lootName] then
                    state.EnabledGodsOverride[lootName] = true
                    state.MaxGodsPerRunOverride = (state.MaxGodsPerRunOverride or config.MaxGodsPerRun) + 1
                end
            end
        end

        local result = base(args)
        if config.PrioritizeSpecificRewardEnabled and
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

        if not config.PrioritizeTrialRewardEnabled then return end

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
        if IsEnabled() and config.PrioritizeHammerFirstRoomEnabled and
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
