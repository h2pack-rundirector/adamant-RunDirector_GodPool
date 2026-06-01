local patches = {}

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

function patches.buildPlan(_, runtime, plan)
    local data = runtime and runtime.data
    if data.read("BoostElementGathering") then
        plan:setMany(WeaponShopItemData.ToolExorcismBook2, { ElementChance = 1.0 })
        plan:setMany(WeaponShopItemData.ToolShovel2, { ElementChance = 1.0 })
        plan:setMany(WeaponShopItemData.ToolPickaxe2, { ElementChance = 1.0 })
        plan:setMany(WeaponShopItemData.ToolFishingRod2, { ElementChance = 1.0 })
    end

    if data.read("PreventEarlySeleneHermes") then
        for _, key in ipairs(PREVENT_EARLY_REQUIREMENT_KEYS) do
            plan:appendUnique(NamedRequirementsData, key, PREVENT_EARLY_REQUIREMENT)
        end
    end
end

return patches
