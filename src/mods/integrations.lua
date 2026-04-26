local internal = RunDirectorGodPool_Internal

local GOD_AVAILABILITY_INTEGRATION = "run-director.god-availability"
local PACK_ID = "run-director"
local MODULE_ID = "GodPool"

function internal.RegisterIntegrations()
    lib.integrations.register(GOD_AVAILABILITY_INTEGRATION, MODULE_ID, {
        isActive = function()
            return lib.isModuleEnabled(internal.store, PACK_ID)
        end,

        isAvailable = function(godKey)
            if not lib.isModuleEnabled(internal.store, PACK_ID) then
                return true
            end
            if internal.IsGodEnabledInPool then
                return internal.IsGodEnabledInPool(godKey) ~= false
            end
            return true
        end,
    })
end

return internal
