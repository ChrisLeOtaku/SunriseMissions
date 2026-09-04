-- Spider and Petra share one object. Both Tangled Shore activities build it from here.
local lib = require("lib.mission_lib")

--- @return A function that builds the safehouse under one authored state.
return function(mission, state)
    local squads = lib.list(mission.Squad.SQ_VENDOR_SPIDER, mission.Squad.SQ_VENDOR_PETRA)

    local objects = lib.list(mission.Slot.O_ARRHA_VENDOR, mission.Slot.O_RITUAL_MISSION_TOTEM)

    local idles = {
        {
            sensor = lib.one(mission.Slot.SQ_VENDOR_SPIDER_IDLE, "spider idle sensor"),
            state = lib.one(mission.PerformanceState.SQ_VENDOR_SPIDER_IDLE.STATE_22503C9B,
                            "spider idle state"),
        },
        {
            sensor = lib.one(mission.Slot.SQ_VENDOR_PETRA_IDLE, "petra idle sensor"),
            state = lib.one(mission.PerformanceState.SQ_VENDOR_PETRA_IDLE.STATE_60A2CEBA,
                            "petra idle state"),
        },
    }

    -- State first: the objects and squads bind under its lease.
    return function(context)
        context:select_state(state)
        lib.activate_objects(context, objects)
        lib.place_all(context, squads, context.sdk.squad_modes.reinforce)
        lib.play_idles(context, idles)
    end
end
