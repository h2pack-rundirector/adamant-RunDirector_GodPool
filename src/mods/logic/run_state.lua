local deps = ...
local runStateCacheName = deps.runStateCacheName

local runState = {}

function runState.buildCacheDeclarations()
    return {
        [runStateCacheName] = {
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

function runState.get(runtime)
    local cache = runtime and runtime.data and runtime.data.cache
    if not cache then return nil end
    return cache.currentRun.get(runStateCacheName)
end

return runState
