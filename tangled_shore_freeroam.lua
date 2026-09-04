local missions = require("missions")
local mission = require(missions.TANGLED_SHORE_FREEROAM)
local lib = require("mission_lib")

-- Owns the held bubble. Each bubble owns its own entities and events.
local BUBBLES = {
    [112] = require("tangled_shore_freeroam.port")(mission),
    [168] = require("tangled_shore_freeroam.safehouse")(mission),
}

-- Region order is fixed, so ipairs walks them. The sandbox has no pairs.
local REGIONS = {112, 168}

-- Bubble keys carry a tag, so none collides with this key.
local HELD_KEY = "held"
local ENTERED_KEY = "in"

-- Never cleared: a bubble publishes its estate once.
local function enter(context, scope, bubble, salt)
    if scope:variable(ENTERED_KEY) then
        if bubble.resume ~= nil then
            bubble.resume(context, scope)
        end
        return
    end
    scope:set_variable(ENTERED_KEY, true)
    bubble.enter(context, scope, salt)
end

-- A bubble stops only its own timers. No request may reach one the client has left.
local function suspend_others(context, state, region)
    for _, index in ipairs(REGIONS) do
        local bubble = BUBBLES[index]
        if index ~= region and bubble.suspend ~= nil then
            local scope = lib.scope(context, state, bubble.tag)
            if scope:variable(ENTERED_KEY) then
                bubble.suspend(context, scope)
            end
        end
    end
end

return {
    on_event_client_state_changed = function(context, state, event)
        -- No held region means transit. The bubble being left stops its timers now.
        if event.current_region_index == nil then
            if event.region_index ~= nil then
                suspend_others(context, state, event.region_index)
            end
            return
        end
        local region = event.current_region_index
        context:set_variable(HELD_KEY, region)
        suspend_others(context, state, region)
        local bubble = BUBBLES[region]
        if bubble ~= nil then
            enter(context, lib.scope(context, state, bubble.tag), bubble, event.sequence)
        end
    end,
    on_event_squad_state = function(context, state, event)
        local bubble = BUBBLES[state:variable(HELD_KEY) or -1]
        if bubble ~= nil and bubble.on_squad_state ~= nil then
            bubble.on_squad_state(context, lib.scope(context, state, bubble.tag), event)
        end
    end,
    on_event_timer_elapsed = function(context, state, event)
        -- A timer carries its owner's tag. A bubble the client has left gets nothing.
        local held = state:variable(HELD_KEY) or -1
        for _, index in ipairs(REGIONS) do
            local bubble = BUBBLES[index]
            local name = lib.timer_name(bubble.tag, event.timer_name)
            if name ~= nil then
                if index == held and bubble.on_timer ~= nil then
                    bubble.on_timer(context, lib.scope(context, state, bubble.tag), name, event)
                end
                return
            end
        end
    end,
}
