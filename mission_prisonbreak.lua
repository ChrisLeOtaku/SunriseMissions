-- Last Call: first-pass SDK-backed controller. Not yet a complete retail reconstruction.
-- Known integration gaps and test procedure: temp.md/MISSION_PRISONBREAK_STATUS.md.
local missions = require("missions")
local mission = require(assert(missions.MISSION_PRISONBREAK, "mission_prisonbreak SDK module is absent"))
local config = require("mission_prisonbreak.config")
local states = require("mission_prisonbreak.state_routes")(mission)
local routes = require("mission_prisonbreak.routes")(mission, config)
local opening = require("mission_prisonbreak.opening")(mission, config, routes.support, states)
local arrival = require("mission_prisonbreak.arrival")(mission, config, routes.support)
local observe = require("mission_prisonbreak.diagnostics")(mission)
local function dispatch(method, c, s, e)
    observe(c, s, method, e)
    if opening.playable(s) and states.playable(s) and arrival.playable(s) then routes.dispatch(method, c, s, e) end
end
local function arm_arrival(c, s)
    if not s:variable("prisonbreak.arrival.pending_request") then return end
    c:clear_variable("prisonbreak.arrival.pending_request")
    arrival.arm(c, s)
end
local function terminated(c, s, e)
    if opening.terminated(c, s, e) then arm_arrival(c, s); return end
    if arrival.terminated(c, s, e) then return end
    if routes.interlude.terminated(c, s, e) then return end
    routes.ending.terminated(c, s, e)
end
return {
    initial_state = opening.initial_state,
    on_event_client_state_changed = function(c, s, e)
        -- Resolve the exact generated state before any controller runs.  A
        -- settle-only delta retains the last mapped state by design.
        states.observe(c, s, e)
        observe(c, s, "client", e)
        opening.client(c, s, e)
        arm_arrival(c, s)
        if opening.playable(s) then arrival.client(c, s, e) end
        arrival.cinematic_client(c, s, e)
        routes.interlude.client(c, s, e)
        routes.ending.client(c, s, e)
        if opening.playable(s) and states.playable(s) and arrival.playable(s) then routes.client_state(c, s, e) end
        if opening.playable(s) and states.playable(s) and arrival.playable(s) then routes.client(c, s, e) end
    end,
    on_event_player_trigger = function(c, s, e) dispatch("trigger", c, s, e) end,
    on_event_trigger_entered = function(c, s, e) dispatch("occupancy", c, s, e) end,
    on_event_object_interacted = function(c, s, e) dispatch("interaction", c, s, e) end,
    on_event_ghost_link_state = function(c, s, e) dispatch("ghost", c, s, e) end,
    on_event_squad_state = function(c, s, e)
        observe(c, s, "squad", e)
        if opening.playable(s) and arrival.playable(s) then routes.squad(c, s, e) end
    end,
    -- Death edges carry the same squad identity and alive/previous-alive
    -- counters as a squad-state update. Forward them or an encounter can
    -- remain in "alive" forever after the last actor dies.
    on_event_entity_died = function(c, s, e)
        observe(c, s, "entity_died", e)
        if opening.playable(s) and states.playable(s) and arrival.playable(s) then routes.squad(c, s, e) end
    end,
    on_event_fireteam_state = function(c, s, e)
        if opening.playable(s) and arrival.playable(s) then routes.fireteam(c, s, e) end
    end,
    on_event_timer_elapsed = function(c, s, e)
        if opening.timer(c, s, e) then arm_arrival(c, s); return end
        if opening.playable(s) and arrival.playable(s) then routes.timer(c, s, e) end
    end,
    on_event_effect_result = function(c, s, e)
        observe(c, s, "effect", e)
        if opening.playable(s) and arrival.playable(s) then routes.effect(c, s, e) end
    end,
    on_event_scene_finished = function(c, s, e)
        observe(c, s, "scene_finished", e)
        if opening.playable(s) and states.playable(s) and arrival.playable(s) then routes.dispatch("scene_finished", c, s, e) end
    end,
    on_event_objective_progress = function(c, s, e)
        observe(c, s, "objective", e)
    end,
    on_event_cinematic_terminated = terminated,
    on_event_cinematic_skip_requested = function(c, s, e)
        if opening.skipped(c, s, e) then arm_arrival(c, s); return end
        if arrival.skipped(c, s, e) then return end
        if routes.interlude.skipped(c, s, e) then return end
        routes.ending.terminated(c, s, e)
    end,
}

