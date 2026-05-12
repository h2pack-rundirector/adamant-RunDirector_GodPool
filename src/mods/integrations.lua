local GOD_AVAILABILITY_INTEGRATION = "run-director.god-availability"
local MODULE_ID = "GodPool"
local integrations = {}
local logic

function integrations.registerIntegrations(host, store)
    lib.integrations.register(GOD_AVAILABILITY_INTEGRATION, MODULE_ID, {
        isActive = function()
            return host.isEnabled()
        end,

        isAvailable = function(godKey)
            if not host.isEnabled() then
                return true
            end
            if logic and logic.isGodEnabledInPool then
                return logic.isGodEnabledInPool(godKey, store) ~= false
            end
            return true
        end,
    })
end

function integrations.bind(deps)
    logic = deps.logic
    return integrations
end

return integrations
