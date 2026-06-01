local deps = ...
local godLookup = deps.godLookup

local pool = {}

function pool.isGodEnabledInPool(godKey, runtimeData)
    local god = godLookup[godKey]
    if not god then return true end
    if not runtimeData then return true end
    return runtimeData.read(god.alias) ~= false
end

return pool
