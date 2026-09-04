local missions = require("missions")
local mission = require(missions.RAID_GLUTTONY_0)
local lib = require("lib.mission_lib")

-- Two authored states of one slice set: 0 playable, 1 the landing cutscene.
-- Only a state change builds the cutscene's type-6 component.
local BERTH_CINEMATIC_STATE =
    lib.one(mission.states.STATE_80B48062_0002_0001_80B4805D, "berth cinematic state")
local BERTH_PLAYABLE_STATE =
    lib.one(mission.states.STATE_80B48062_0002_0000_80B4805C, "berth playable state")

-- A reattach reopens this script in a fresh VM, so marks live in mission state.
local BERTH_KEY = "berth"
local CINE_KEY = "cine"
local SPAWNED_KEY = "spawned"
local PLAYING_KEY = "playing"

local CINE_IDLE = 0
local CINE_RUNNING = 1
local CINE_DONE = 2

local GUARD_SQUADS = lib.list(
    mission.Squad.SQ_BERTH_0_GUARD,
    mission.Squad.SQ_BERTH_1_GUARD,
    mission.Squad.SQ_BERTH_2_GUARD,
    mission.Squad.SQ_BERTH_3_GUARD,
    mission.Squad.SQ_BERTH_4_GUARD,
    mission.Squad.SQ_BERTH_5_GUARD,
    mission.Squad.SQ_BERTH_6_GUARD,
    mission.Squad.SQ_BERTH_7_GUARD
)

local CINE_SQUADS = lib.list(
    mission.Squad.SQ_BERTH_0_CINE,
    mission.Squad.SQ_BERTH_1_CINE,
    mission.Squad.SQ_BERTH_2_CINE,
    mission.Squad.SQ_BERTH_3_CINE,
    mission.Squad.SQ_BERTH_4_CINE,
    mission.Squad.SQ_BERTH_5_CINE,
    mission.Squad.SQ_BERTH_6_CINE,
    mission.Squad.SQ_BERTH_7_CINE
)

-- One type-2 combatant per squad, at the next slot index.
local GUARD_COMBATANTS = lib.list(
    mission.Slot.SQ_BERTH_0_GUARD_CELL_1,
    mission.Slot.SQ_BERTH_1_GUARD_CELL_1,
    mission.Slot.SQ_BERTH_2_GUARD_CELL_1,
    mission.Slot.SQ_BERTH_3_GUARD_CELL_1,
    mission.Slot.SQ_BERTH_4_GUARD_CELL_1,
    mission.Slot.SQ_BERTH_5_GUARD_CELL_1,
    mission.Slot.SQ_BERTH_6_GUARD_CELL_1,
    mission.Slot.SQ_BERTH_7_GUARD_CELL_1
)

local CINE_COMBATANTS = lib.list(
    mission.Slot.SQ_BERTH_0_CINE_CELL_1,
    mission.Slot.SQ_BERTH_1_CINE_CELL_1,
    mission.Slot.SQ_BERTH_2_CINE_CELL_1,
    mission.Slot.SQ_BERTH_3_CINE_CELL_1,
    mission.Slot.SQ_BERTH_4_CINE_CELL_1,
    mission.Slot.SQ_BERTH_5_CINE_CELL_1,
    mission.Slot.SQ_BERTH_6_CINE_CELL_1,
    mission.Slot.SQ_BERTH_7_CINE_CELL_1
)

-- TODO: activate from initialize_berth. Held back until doubled placements are ruled out.
local INTRO_SCENES = lib.list(
    mission.Scene.SCENE_BERTH_GUARD_INTRO_0,
    mission.Scene.SCENE_BERTH_GUARD_INTRO_1,
    mission.Scene.SCENE_BERTH_GUARD_INTRO_2,
    mission.Scene.SCENE_BERTH_GUARD_INTRO_3,
    mission.Scene.SCENE_BERTH_GUARD_INTRO_4,
    mission.Scene.SCENE_BERTH_GUARD_INTRO_5,
    mission.Scene.SCENE_BERTH_GUARD_INTRO_6,
    mission.Scene.SCENE_BERTH_GUARD_INTRO_7
)

local CINE_SCENES = lib.list(
    mission.Scene.SCENE_BERTH_GUARD_CINE_0,
    mission.Scene.SCENE_BERTH_GUARD_CINE_1,
    mission.Scene.SCENE_BERTH_GUARD_CINE_2,
    mission.Scene.SCENE_BERTH_GUARD_CINE_3,
    mission.Scene.SCENE_BERTH_GUARD_CINE_4,
    mission.Scene.SCENE_BERTH_GUARD_CINE_5,
    mission.Scene.SCENE_BERTH_GUARD_CINE_6,
    mission.Scene.SCENE_BERTH_GUARD_CINE_7
)

local ACTIVE_OBJECTS = lib.list(
    mission.Slot.O_WATERFALL_LEVER_0,
    mission.Slot.O_WATERFALL_LEVER_1,
    mission.Slot.O_WATERFALL_LEVER_2,
    mission.Slot.O_WATERFALL_LEVER_3,
    mission.Slot.O_WATERFALL_LEVER_4,
    mission.Slot.O_WATERFALL_LEVER_5,
    mission.Slot.O_SEWER_LEVER_0,
    mission.Slot.O_SEWER_LEVER_1,
    mission.Slot.O_SEWER_LEVER_2,
    mission.Slot.O_SEWER_LEVER_3,
    mission.Slot.O_SEWER_LEVER_4,
    mission.Slot.O_SEWER_LEVER_5,
    mission.Slot.O_BERTH_GLYPH_0,
    mission.Slot.O_BERTH_GLYPH_1,
    mission.Slot.O_BERTH_GLYPH_2,
    mission.Slot.O_BERTH_GLYPH_3,
    mission.Slot.O_BERTH_GLYPH_4
)

local CLOSED_DEVICES = lib.list(
    mission.Slot.D_WATERFALL_LEVER_0,
    mission.Slot.D_WATERFALL_LEVER_1,
    mission.Slot.D_WATERFALL_LEVER_2,
    mission.Slot.D_WATERFALL_LEVER_3,
    mission.Slot.D_WATERFALL_LEVER_4,
    mission.Slot.D_WATERFALL_LEVER_5,
    mission.Slot.D_SEWER_LEVER_0,
    mission.Slot.D_SEWER_LEVER_1,
    mission.Slot.D_SEWER_LEVER_2,
    mission.Slot.D_SEWER_LEVER_3,
    mission.Slot.D_SEWER_LEVER_4,
    mission.Slot.D_SEWER_LEVER_5
)

-- TODO: the combatants take this program and never run it. Four sleeps prove delivery only.
local function run_guard_atoms(context)
    for _, slot in ipairs(GUARD_COMBATANTS) do
        context:slot(slot):run_atoms{
            generation = 1,
            atoms = {
                {kind = "sleep", seconds = 2.0},
                {kind = "sleep", seconds = 2.0},
                {kind = "sleep", seconds = 2.0},
                {kind = "sleep", seconds = 2.0},
            },
        }
    end
end

local function bind_all(context, combatants)
    for _, slot in ipairs(combatants) do
        context:slot(slot):bind_combatant_to_squad{}
    end
end

local function place_berth_squads(context)
    -- The host must own the policy before a squad makes its actors.
    for _, squad in ipairs(GUARD_SQUADS) do
        context:squad(squad):actor_command{
            command = mission.ActorCommand.SET_FACTION,
            value = mission.Faction.NONE,
        }
    end
    -- A combatant binds only while its actor handle is unset. Bind before placing.
    bind_all(context, GUARD_COMBATANTS)
    bind_all(context, CINE_COMBATANTS)
    lib.place_all(context, GUARD_SQUADS, context.sdk.squad_modes.reinforce)
    lib.place_all(context, CINE_SQUADS, context.sdk.squad_modes.reinforce)
end

local function initialize_berth(context)
    lib.activate_objects(context, ACTIVE_OBJECTS)
    for _, slot in ipairs(CLOSED_DEVICES) do
        context:slot(slot):transition{
            transition = context.sdk.device_transitions.close,
            snap = true,
        }
    end
    place_berth_squads(context)
    -- The type-31 trigger holds this generation until its type-60 occupancy test passes.
    context:slot(mission.Slot.PT_FRONT_DOOR):fire_trigger()
end

-- Goes out when the player can see and move, not at the spawn.
local function show_opening_guidance(context, state)
    if not state:variable(BERTH_KEY) or not state:variable(PLAYING_KEY) then
        return
    end
    context:slot(mission.Slot.M_DIRECTIVE_SENSOR_80B48072):set_directive{
        directive = mission.Directive.ENTER_THE_ROYAL_POOLS,
    }
    context:slot(mission.Slot.M_DIALOG_SENSOR_80B48072):play_dialogue_cue{
        cue = mission.DialogueCue.M_DIALOG_SENSOR_80B48072.CUE_0,
    }
end

-- Every intent below is refused until the client holds the playable region.
local function enter_playable(context, state)
    if state:variable(BERTH_KEY) then
        return
    end
    context:set_variable(BERTH_KEY, true)
    initialize_berth(context)
    show_opening_guidance(context, state)
end

local function cinematic_phase(state)
    return state:variable(CINE_KEY) or CINE_IDLE
end

local function begin_entry_cinematic(context, state)
    -- The client holds the cutscene region, so only the Auth is owed.
    if cinematic_phase(state) ~= CINE_IDLE then
        return
    end
    context:set_variable(CINE_KEY, CINE_RUNNING)
    context:slot(mission.Slot.PF_CINEMATIC_BOOKEND_CINEMATIC):set_cinematic_active{active = true}
end

local function end_entry_cinematic(context, state)
    if cinematic_phase(state) == CINE_DONE then
        return
    end
    context:set_variable(CINE_KEY, CINE_DONE)
    -- Clear before the state change, or the rebuilt component replays the cutscene.
    context:slot(mission.Slot.PF_CINEMATIC_BOOKEND_CINEMATIC):set_cinematic_active{active = false}
    -- The state change also arms the teleport. Without the move no berth Auth can bind.
    context:select_state(BERTH_PLAYABLE_STATE)
end

return {
    -- The arrival names region 17, so the mission opens on the state that owns it.
    initial_state = BERTH_CINEMATIC_STATE,
    on_event_incident_received = function(context, state, event)
        -- The authored start edge. This region has no incident producer, so it never fires.
        begin_entry_cinematic(context, state)
    end,
    on_event_client_state_changed = function(context, state, event)
        -- The only start edge here: the client reports it holds the cutscene region.
        if event.region_index == BERTH_CINEMATIC_STATE.region_index then
            begin_entry_cinematic(context, state)
        elseif event.region_index == BERTH_PLAYABLE_STATE.region_index then
            enter_playable(context, state)
        end
        -- The client zeroes its teleport byte inside the spawn call, so 0 marks the spawn.
        if event.teleport_state == 0 then
            context:set_variable(SPAWNED_KEY, true)
        end
        -- The settle report moves no leg, spawn or teleport field. Control is back.
        if state:variable(SPAWNED_KEY) and not state:variable(PLAYING_KEY)
            and event.region_index == nil and event.current_region_index == nil
            and event.spawn_state == nil and event.teleport_state == nil then
            context:set_variable(PLAYING_KEY, true)
            show_opening_guidance(context, state)
            -- The combatants attached at berth init.
            run_guard_atoms(context)
        end
    end,
    on_event_cinematic_terminated = function(context, state, event)
        -- End, skip and refused start all arrive here.
        end_entry_cinematic(context, state)
    end,
    on_load = function(context, state, event)
        -- A reattach lands in-world, so it must not replay the cutscene.
        end_entry_cinematic(context, state)
    end,
    on_event_player_trigger = function(context, state, event)
        if lib.is_trigger(context, event, mission.Slot.PT_FRONT_DOOR,
                          mission.TriggerVolume.PT_FRONT_DOOR) then
            context:slot(mission.Slot.D_FRONT_DOOR):transition{
                transition = context.sdk.device_transitions.open,
                snap = false,
            }
        end
    end,
}
