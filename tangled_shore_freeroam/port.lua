-- Thieves' Landing, region 112. Owns this bubble's entities and its three public events.
-- Only runnable squads may be named. The host refuses the rest and faults the callback.
local lib = require("mission_lib")

return function(mission)
    local STATE = lib.one(mission.states.STATE_80FC9645_000E_0000_80FC95F2, "port state")

    -- The standing garrison. Placed on arrival and left alone.
    local AMBIENT = lib.list(
        mission.Squad.TAURUS_PORT_DREG_CENTER_SQUAD,
        mission.Squad.TAURUS_PORT_DREG_CENTER_SQUAD_1,
        mission.Squad.TAURUS_PORT_DREG_CENTER_SQUAD_2,
        mission.Squad.TAURUS_PORT_ZEALOT_TOP_LEFT_SQUAD,
        mission.Squad.TAURUS_PORT_ZEALOT_TOP_RIGHT_SQUAD,
        mission.Squad.TAURUS_PORT_ANCHOR_BACK_SQUAD
    )

    -- One prisoner per cage. Placed with the garrison, not as a wave.
    local CAPTIVES = lib.list(
        mission.Squad.PF_BREAKABLE_CAGE_SQ_CAPTIVE_80FD8E4F,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_CAPTIVE_80FD8E9B,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_CAPTIVE_80FD8EE7,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_CAPTIVE_80FD8F33,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_CAPTIVE_80FD8F7F,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_CAPTIVE_80FD8FCB,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_CAPTIVE_80FD9017
    )

    -- The monster closets. Each carries its own spawn rule.
    local CLOSETS = lib.list(
        -- the seven cages: a jailer over each, and its backup
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_80FD8E4F,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_80FD8E9B,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_80FD8EE7,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_80FD8F33,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_80FD8F7F,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_80FD8FCB,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_80FD9017,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_BKUP_80FD8E4F,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_BKUP_80FD8E9B,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_BKUP_80FD8EE7,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_BKUP_80FD8F33,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_BKUP_80FD8F7F,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_BKUP_80FD8FCB,
        mission.Squad.PF_BREAKABLE_CAGE_SQ_JAILER_BKUP_80FD9017,
        -- four chest skirmishes; the other two name several actor classes and refuse
        mission.Squad.PF_EVENT_CHEST_SKIRMISH_1_RESISTANCE_SQUAD_80FD90C0,
        mission.Squad.PF_EVENT_CHEST_SKIRMISH_1_RESISTANCE_SQUAD_80FD91BF,
        mission.Squad.PF_EVENT_CHEST_SKIRMISH_1_RESISTANCE_SQUAD_80FD9214,
        mission.Squad.PF_EVENT_CHEST_SKIRMISH_1_RESISTANCE_SQUAD_80FD9269,
        -- the front alley
        mission.Squad.PF2_ALLEY_FRONT_SIMPLE_SQUAD_0,
        mission.Squad.PF2_ALLEY_FRONT_SIMPLE_SQUAD_1,
        -- the town centre
        mission.Squad.MISSION_RITUAL_PORT_MARAUDER_CENTER_SQUAD,
        mission.Squad.SQ_SUPPORT
    )

    -- One site is one whole public event on one authored prefab.
    local function site(index, fields)
        assert(fields.sensor ~= nil and fields.objective ~= nil and fields.major ~= nil,
               "site " .. index .. " is missing a slot")
        fields.timer = "ev" .. index
        fields.phase = "ph" .. index
        return fields
    end

    -- Site 0x80FD93ED has no plain fodder squad: it names several actor classes and refuses.
    local SITES = lib.list(
        site(1, {
            sensor = mission.Slot.M_PUBLIC_EVENT_SENSOR_80FD9392,
            objective = mission.Slot.COWARDLY_MAJOR_CORE_OBJECTIVE_80FD9392,
            major = mission.Slot.COWARDLY_MAJOR_CORE_MAJOR_SQUAD_80FD9392,
            squads = lib.list(
                mission.Squad.COWARDLY_MAJOR_CORE_MAJOR_SQUAD_80FD9392,
                mission.Squad.COWARDLY_MAJOR_CORE_MAJOR_FODDER_SQUAD_80FD9392,
                mission.Squad.COWARDLY_MAJOR_CORE_FODDER_SQUAD_80FD9392,
                mission.Squad.COWARDLY_MAJOR_CORE_NO_LOOT_FODDER_SQUAD_80FD9392
            ),
            reward = lib.list(
                mission.Slot.COWARDLY_MAJOR_CORE_CHEST_PREFAB_SPAWN_FX_OBJECT_80FD9392,
                mission.Slot.COWARDLY_MAJOR_CORE_CHEST_PREFAB_CHEST_COWARDLY_MAJOR_OBJECT_80FD9392
            ),
        }),
        site(2, {
            sensor = mission.Slot.M_PUBLIC_EVENT_SENSOR_80FD93ED,
            objective = mission.Slot.COWARDLY_MAJOR_CORE_OBJECTIVE_80FD93ED,
            major = mission.Slot.COWARDLY_MAJOR_CORE_MAJOR_SQUAD_80FD93ED,
            squads = lib.list(
                mission.Squad.COWARDLY_MAJOR_CORE_MAJOR_SQUAD_80FD93ED,
                mission.Squad.COWARDLY_MAJOR_CORE_MAJOR_FODDER_SQUAD_80FD93ED,
                mission.Squad.COWARDLY_MAJOR_CORE_NO_LOOT_FODDER_SQUAD_80FD93ED
            ),
            reward = lib.list(
                mission.Slot.COWARDLY_MAJOR_CORE_CHEST_PREFAB_SPAWN_FX_OBJECT_80FD93ED,
                mission.Slot.COWARDLY_MAJOR_CORE_CHEST_PREFAB_CHEST_COWARDLY_MAJOR_OBJECT_80FD93ED
            ),
        }),
        site(3, {
            sensor = mission.Slot.M_PUBLIC_EVENT_SENSOR_80FD9448,
            objective = mission.Slot.COWARDLY_MAJOR_CORE_OBJECTIVE_80FD9448,
            major = mission.Slot.COWARDLY_MAJOR_CORE_MAJOR_SQUAD_80FD9448,
            squads = lib.list(
                mission.Squad.COWARDLY_MAJOR_CORE_MAJOR_SQUAD_80FD9448,
                mission.Squad.COWARDLY_MAJOR_CORE_MAJOR_FODDER_SQUAD_80FD9448,
                mission.Squad.COWARDLY_MAJOR_CORE_FODDER_SQUAD_80FD9448,
                mission.Squad.COWARDLY_MAJOR_CORE_NO_LOOT_FODDER_SQUAD_80FD9448
            ),
            reward = lib.list(
                mission.Slot.COWARDLY_MAJOR_CORE_CHEST_PREFAB_SPAWN_FX_OBJECT_80FD9448,
                mission.Slot.COWARDLY_MAJOR_CORE_CHEST_PREFAB_CHEST_COWARDLY_MAJOR_OBJECT_80FD9448
            ),
        })
    )

    local CLOSET_TIMER = "closets"
    local CLOSET_PERIOD_MS = 45000
    local EVENT_COOLDOWN_MS = 120000
    local WAVE_SIZE = 4

    -- The client copies this into the banner. Anything but 0 is unverified.
    local EVENT_STATE = 0
    local EVENT_LEAVE_SECONDS = 30.0

    local SEED_KEY = "seed"
    local PHASE_IDLE = 0
    local PHASE_RUNNING = 1
    local PHASE_CLEARED = 2

    -- One 64-bit LCG. The sandbox has no math.random, so the seed is mission state.
    local function next_seed(seed)
        return (seed * 6364136223846793005 + 1442695040888963407) & 0x7FFFFFFFFFFFFFFF
    end

    -- A u64 does not survive tonumber, so mix the bytes in.
    local function stir(seed, text)
        if type(text) ~= "string" then
            return next_seed(seed)
        end
        local mixed = seed
        for index = 1, #text do
            mixed = next_seed(mixed ~ string.byte(text, index))
        end
        return mixed
    end

    -- Partial Fisher-Yates, so one wave never places a squad twice.
    local function open_closets(context, scope, salt)
        local seed = stir(scope:variable(SEED_KEY) or 0x2545F4914F6CDD1D, salt)
        local order = {}
        for index = 1, #CLOSETS do
            order[index] = index
        end
        for index = 1, WAVE_SIZE do
            seed = next_seed(seed)
            local pick = index + ((seed >> 17) % (#CLOSETS - index + 1))
            order[index], order[pick] = order[pick], order[index]
            context:squad(CLOSETS[order[index]]):place{
                mode = context.sdk.squad_modes.replace,
            }
        end
        scope:set_variable(SEED_KEY, seed)
    end

    local function set_reward_visible(context, site, visible)
        for _, slot in ipairs(site.reward) do
            context:slot(slot):set_object_active{active = visible}
        end
    end

    local function start_event(context, scope, site)
        if scope:variable(site.phase) == PHASE_RUNNING then
            return
        end
        scope:set_variable(site.phase, PHASE_RUNNING)
        set_reward_visible(context, site, false)
        context:slot(site.objective):reset_objectives()
        lib.place_all(context, site.squads, context.sdk.squad_modes.replace)
        -- The sensor's own slot bounds the watched area.
        context:slot(site.sensor):set_public_event_state{
            state = EVENT_STATE,
            area = context:slot(site.sensor),
            leave_seconds = EVENT_LEAVE_SECONDS,
        }
    end

    local function finish_event(context, scope, site)
        if scope:variable(site.phase) ~= PHASE_RUNNING then
            return
        end
        scope:set_variable(site.phase, PHASE_CLEARED)
        set_reward_visible(context, site, true)
        scope:start_timer(site.timer, EVENT_COOLDOWN_MS)
    end

    return {
        tag = "p",

        -- State first: the squads and events bind under its lease.
        enter = function(context, scope, salt)
            context:select_state(STATE)
            lib.place_all(context, AMBIENT, context.sdk.squad_modes.reinforce)
            lib.place_all(context, CAPTIVES, context.sdk.squad_modes.reinforce)
            open_closets(context, scope, salt)
            scope:start_timer(CLOSET_TIMER, CLOSET_PERIOD_MS)
            for _, site in ipairs(SITES) do
                start_event(context, scope, site)
            end
        end,

        -- Only this bubble's timers. No request may reach one the client has left.
        suspend = function(context, scope)
            scope:cancel_timer(CLOSET_TIMER)
            for _, site in ipairs(SITES) do
                scope:cancel_timer(site.timer)
            end
        end,

        -- A return sends nothing. Waves resume and a cleared site restarts its wait.
        resume = function(context, scope)
            scope:start_timer(CLOSET_TIMER, CLOSET_PERIOD_MS)
            for _, site in ipairs(SITES) do
                if scope:variable(site.phase) == PHASE_CLEARED then
                    scope:start_timer(site.timer, EVENT_COOLDOWN_MS)
                end
            end
        end,

        -- The major is the event. The fodder squads are dressing.
        on_squad_state = function(context, scope, event)
            if event.alive_count ~= 0 or event.previous_alive_count <= 0 then
                return
            end
            for _, site in ipairs(SITES) do
                if lib.is_slot(context, event, site.major) then
                    finish_event(context, scope, site)
                    return
                end
            end
        end,

        on_timer = function(context, scope, name, event)
            if name == CLOSET_TIMER then
                open_closets(context, scope, event.timer_sequence)
                scope:start_timer(CLOSET_TIMER, CLOSET_PERIOD_MS)
                return
            end
            for _, site in ipairs(SITES) do
                if name == site.timer then
                    scope:set_variable(site.phase, PHASE_IDLE)
                    start_event(context, scope, site)
                    return
                end
            end
        end,
    }
end
