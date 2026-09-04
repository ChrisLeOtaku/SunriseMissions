-- Spider's safehouse, region 168. No timers, so no suspend and no resume.
local lib = require("lib.mission_lib")
local spider_safehouse = require("tangled_shore.spider_safehouse")

return function(mission)
    local build = spider_safehouse(
        mission, lib.one(mission.states.STATE_80FC9645_0015_0000_80FC95F9, "safehouse state"))

    return {
        tag = "s",
        enter = function(context, scope, salt)
            build(context)
        end,
    }
end
