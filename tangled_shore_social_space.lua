local missions = require("missions")
local mission = require(missions.TANGLED_SHORE_SOCIAL_SPACE)
local lib = require("mission_lib")
local spider_safehouse = require("spider_safehouse")

-- Spider's Safehouse as its own activity. One bubble, region 168.
local SAFEHOUSE_REGION = 168

local build_safehouse = spider_safehouse(
    mission, lib.one(mission.states.STATE_80FD4401_0015_0000_80FD43FE, "safehouse state"))

-- A reattach reopens this script in a fresh VM, so the mark lives in mission state.
local BUILT_KEY = "safehouse_built"

return {
    on_event_client_state_changed = function(context, state, event)
        -- Only the held region says where the client is. The pending leg is a precache.
        if event.current_region_index ~= SAFEHOUSE_REGION or state:variable(BUILT_KEY) then
            return
        end
        context:set_variable(BUILT_KEY, true)
        build_safehouse(context)
    end,
}
