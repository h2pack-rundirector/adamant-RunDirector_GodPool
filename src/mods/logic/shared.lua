local deps = ...
local godList = deps.godList
local pool = deps.pool

local GOD_AVAILABILITY_CACHE = "run-director.god-availability"
local GOD_AVAILABILITY_REF = "GodAvailability"

local shared = {}

local function isGodEnabledInConfig(god, config)
    if config == nil then
        return true
    end
    return config[god.alias] ~= false
end

local function buildGodAvailabilityFromConfig(config)
    local available = {}
    for _, god in ipairs(godList or {}) do
        available[god.key] = isGodEnabledInConfig(god, config)
    end
    return {
        active = true,
        available = available,
    }
end

local function buildGodAvailabilityFromRuntime(runtimeData)
    local available = {}
    for _, god in ipairs(godList or {}) do
        available[god.key] = pool.isGodEnabledInPool(god.key, runtimeData) ~= false
    end
    return {
        active = true,
        available = available,
    }
end

function shared.register(module, config)
    module.shared.data.owner(GOD_AVAILABILITY_REF, {
        id = GOD_AVAILABILITY_CACHE,
        default = buildGodAvailabilityFromConfig(config),
    })
end

function shared.publish(_, runtime)
    if not runtime or not runtime.shared then
        return false
    end
    runtime.shared.set(GOD_AVAILABILITY_REF, buildGodAvailabilityFromRuntime(runtime.data))
    return true
end

return shared
