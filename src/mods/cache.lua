local GOD_AVAILABILITY_CACHE = "run-director.god-availability"
local RUN_STATE_CACHE = "RunState"
local GOD_AVAILABILITY_REF = "GodAvailability"
local cache = {}
local logic
local godList

function cache.runStateName()
    return RUN_STATE_CACHE
end

function cache.buildDeclarations()
    return {
        [RUN_STATE_CACHE] = {
            domain = "currentRun",
            key = "run",
            factory = function()
                return {
                    EnabledGodsOverride = {},
                    MaxGodsPerRunOverride = nil,
                }
            end,
        },
    }
end

local function buildGodAvailability(source)
    local available = {}
    for _, god in ipairs(godList or {}) do
        available[god.key] = logic.isGodEnabledInPool(god.key, source) ~= false
    end
    return {
        active = true,
        available = available,
    }
end

function cache.registerShared(module, config)
    module.shared.data.owner(GOD_AVAILABILITY_REF, {
        id = GOD_AVAILABILITY_CACHE,
        default = buildGodAvailability(function(alias)
            if config == nil then
                return nil
            end
            return config[alias]
        end),
    })
end

function cache.writeGodAvailability(_, runtime)
    if not runtime or not runtime.shared then
        return false
    end
    runtime.shared.set(GOD_AVAILABILITY_REF, buildGodAvailability(runtime.data))
    return true
end

function cache.bind(deps)
    logic = deps.logic
    godList = deps.godList
    return cache
end

return cache
