local missions = require("missions")
local mission = require(missions.CITY_TOWER_SOCIAL_D2)
local lib = require("lib.mission_lib")

-- Six bubbles, one authored state each, region = bubble * 8.
-- Only the bubble the client holds may be entered; another arms a teleport.
-- An object or scene binds under that bubble's lease.

-- Kept out of every seed: the Festival of the Lost dressing.
local SEED_OMIT = {
    mission.Slot.M_ENGAGEMENT_SENSOR_80B4AF2C,
    mission.Slot.M_ENGAGEMENT_SENSOR_80B4AF3D,
    mission.Slot.SQ_EVA_LEVANTE_FOTL,
    mission.Slot.M_ENGAGEMENT_SENSOR_80B4AF65,
}

-- A repeated slot name carries its object tag, so each constant names one slot.
-- A bubble's squads are the ones whose object sits in it. The client builds no vendor itself.
local BUBBLES = {
    {
        -- courtyard, the arrival bubble
        state = mission.states.STATE_80B4A0F4_0006_0000_80B4A229,
        squads = {
            mission.Squad.VENDOR_ZAVALA,
            mission.Squad.SQ_GUNSMITH,
            mission.Squad.SQ_VENDOR_CRYPTARCH,
            mission.Squad.SQ_VENDOR_POSTMASTER,
            mission.Squad.SQ_VENDOR_PVP,
            mission.Squad.SQ_VENDOR_TES_EVERIS,
            mission.Squad.TALK_GUARD_1_SQUAD,
            mission.Squad.CENTRAL_GUARD_1_SQUAD,
            mission.Squad.CENTRAL_GUARD_2_SQUAD,
            mission.Squad.CENTRAL_GUARD_3_SQUAD,
            mission.Squad.CENTRAL_GUARD_4_SQUAD,
            mission.Squad.LEFT_GUARD_1_SQUAD,
            mission.Squad.LEFT_GUARD_2_SQUAD,
            mission.Squad.RIGHT_GUARD_1_SQUAD,
            mission.Squad.TALK_CIV_1_SQUAD,
            mission.Squad.DAY_BOULEVARD_PPONG_3_SQ_NPC_MALE_FEMALE,
            mission.Squad.DAY_BOULEVARD_PPONG_4_SQ_NPC_MALE_FEMALE,
            mission.Squad.DAY_GRASS_PPONG_1_SQ_NPC_MALE_FEMALE,
            mission.Squad.DAY_GRASS_PPONG_2_SQ_NPC_MALE_FEMALE,
            mission.Squad.DAY_PVP_PAIR_1_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.DAY_PVP_PAIR_1_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.DAY_PVP_PAIR_2_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.DAY_PVP_PAIR_2_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.DUTY_CIVS_1_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.DUTY_CIVS_1_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.DUTY_CIVS_2_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.DUTY_CIVS_2_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.DUTY_CIVS_3_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.DUTY_CIVS_3_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.DUTY_CIVS_4_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.DUTY_CIVS_4_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.DUTY_CIVS_5_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.DUTY_CIVS_5_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.DUTY_CIVS_6_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.DUTY_CIVS_6_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.EXTRA_BOULEVARD_PAIR_2_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.EXTRA_BOULEVARD_PAIR_2_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.EXTRA_BOULEVARD_PAIR_4_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.EXTRA_BOULEVARD_PAIR_4_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.EXTRA_BOULEVARD_SOLO_2_SQUAD,
            mission.Squad.EXTRA_GRASS_PAIR_1_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.EXTRA_GRASS_PAIR_1_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.EXTRA_GRASS_PAIR_2_PAIRED_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.EXTRA_GRASS_PAIR_2_PAIRED_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.EXTRA_GRASS_SOLO_1_SQUAD,
            mission.Squad.EXTRA_GRASS_SOLO_2_SQUAD,
            mission.Squad.SQ_CMD_FRONT_DUMMY_1,
            mission.Squad.SQ_CMD_FRONT_DUMMY_2,
            mission.Squad.SM_CMD_FRONT_DUMMY_GROUP_3_SQUAD,
            mission.Squad.SQ_CMD_FRONT_DUMMY_4,
            mission.Squad.SQ_CMD_FRONT_DUMMY_5,
            mission.Squad.SM_CMD_FRONT_DUMMY_GROUP_6_SQUAD,
            mission.Squad.MECHANIC_1_SQUAD_80B4AA42,
            mission.Squad.MECHANIC_2_SQUAD_80B4AA42,
            mission.Squad.MECHANIC_3_SQUAD_80B4AA42,
            mission.Squad.MECHANIC_4_SQUAD_80B4AA42,
            mission.Squad.MECHANIC_1_SQUAD_80B4AA4F,
            mission.Squad.MECHANIC_2_SQUAD_80B4AA4F,
            mission.Squad.MECHANIC_3_SQUAD_80B4AA4F,
            mission.Squad.MECHANIC_4_SQUAD_80B4AA4F,
        },
        objects = {
            mission.Slot.O_FAN_1,
            mission.Slot.O_FAN_2,
            mission.Slot.O_FAN_3,
            mission.Slot.O_FAN_4,
            mission.Slot.O_CIV_0_80B4A6CB,
            mission.Slot.O_CIV_1_80B4A6CB,
            mission.Slot.O_CIV_2_80B4A6CB,
            mission.Slot.O_CIV_3_80B4A6CB,
            mission.Slot.O_CIV_4_80B4A6CB,
            mission.Slot.O_GUARD_0_80B4A920,
            mission.Slot.O_GUARD_1_80B4A920,
            mission.Slot.O_GUARD_2_80B4A920,
            mission.Slot.O_GUARD_3_80B4A920,
            mission.Slot.O_GUARD_4_80B4A920,
            mission.Slot.O_GUARD_5,
            mission.Slot.O_GUARD_6,
            mission.Slot.O_GUARD_0_80B4A9C3,
            mission.Slot.O_GUARD_1_80B4A9C3,
            -- 80B4A9C3's o_guard[2..4] repeat three posts of 80B4A920. One per post.
            mission.Slot.O_GUARD_0_80B4AA2A,
            mission.Slot.O_GUARD_1_80B4AA2A,
            mission.Slot.O_GUARD_2_80B4AA2A,
            -- 80B4AA2D repeats these posts with other actors. One per post.
            mission.Slot.O_FEM01_DPAD_TYPE_STAND,
            mission.Slot.O_STANDARD_TOWER_FOOTBALL,
            mission.Slot.O_LAVA_ORB_0_OBJECT, -- the floor-is-lava pickup
        },
        scenes = {
            mission.Scene.DAY_BOULEVARD_PPONG_3_SCENE,
            mission.Scene.DAY_BOULEVARD_PPONG_4_SCENE,
            mission.Scene.DAY_GRASS_PPONG_1_SCENE,
            mission.Scene.DAY_GRASS_PPONG_2_SCENE,
            mission.Scene.SM_CMD_FRONT_DUMMY_GROUP_3_SCENE,
            mission.Scene.SM_CMD_FRONT_DUMMY_GROUP_6_SCENE,
        },
        idles = {
            {
                sensor = mission.Slot.VENDOR_ZAVALA_IDLE,
                state = mission.PerformanceState.VENDOR_ZAVALA_IDLE.STATE_08BA6CD2,
            },
            {
                sensor = mission.Slot.SQ_GUNSMITH_IDLE,
                state = mission.PerformanceState.SQ_GUNSMITH_IDLE.STATE_36466083,
            },
            {
                sensor = mission.Slot.SQ_VENDOR_POSTMASTER_IDLE,
                state = mission.PerformanceState.SQ_VENDOR_POSTMASTER_IDLE.STATE_870A7D66,
            },
            {
                sensor = mission.Slot.SQ_VENDOR_PVP_IDLE,
                state = mission.PerformanceState.SQ_VENDOR_PVP_IDLE.STATE_D9474D64,
            },
            -- Two states, no default. The first only blinks, so the second is the idle.
            {
                sensor = mission.Slot.SQ_VENDOR_CRYPTARCH_IDLE,
                state = mission.PerformanceState.SQ_VENDOR_CRYPTARCH_IDLE.STATE_F3A6BCD7,
            },
            {
                sensor = mission.Slot.SQ_VENDOR_TES_EVERIS_IDLE,
                state = mission.PerformanceState.SQ_VENDOR_TES_EVERIS_IDLE.STATE_B2E54A10,
            },
        },
    },
    {
        -- bazaar
        state = mission.states.STATE_80B4A0F4_0001_0000_80B4A228,
        squads = {
            mission.Squad.SQ_VENDOR_HAWTHORNE,
            mission.Squad.SQ_VENDOR_NEW_MONARCHY,
            mission.Squad.BARMAN_SQUAD,
            mission.Squad.SM_PPONG_WALKER_1_SQUAD,
            mission.Squad.SM_PPONG_WALKER_2_SQUAD,
            mission.Squad.SM_PPONG_WALKER_3_SQUAD,
            mission.Squad.SM_PPONG_WALKER_4_SQUAD,
            mission.Squad.SM_PPONG_WALKER_5_SQUAD,
            mission.Squad.SM_PPONG_WALKER_7_SQUAD,
            mission.Squad.SM_PPONG_NOODLE_1_SQUAD,
            mission.Squad.SM_PPONG_NOODLE_2_SQUAD,
            mission.Squad.SM_PPONG_NOODLE_3_SQUAD,
            mission.Squad.SM_PPONG_NOODLE_4_SQUAD,
        },
        objects = {
            mission.Slot.O_IKORA_VENDOR,
            mission.Slot.O_CIV_0_80B4A140,
            mission.Slot.O_CIV_1_80B4A140,
            mission.Slot.O_CIV_2_80B4A140,
            mission.Slot.O_CIV_0_80B4A14B,
            -- 80B4A14B's o_civ[1] shares a spot with 80B4A140's o_civ[2]. One per spot.
            mission.Slot.O_CIV_2_80B4A14B,
            mission.Slot.O_CIV_0_80B4A155,
            mission.Slot.O_CIV_1_80B4A155,
            mission.Slot.O_CIV_0_80B4A15D,
            mission.Slot.O_CIV_1_80B4A15D,
            mission.Slot.O_CIV_0_80B4A17B,
            mission.Slot.O_CIV_1_80B4A17B,
            mission.Slot.O_CIV_2_80B4A17B,
            mission.Slot.O_CIV_3_80B4A17B,
            mission.Slot.O_CIV_4_80B4A17B,
            mission.Slot.O_CIV_5_80B4A17B,
            mission.Slot.O_CIV_6_80B4A17B,
            mission.Slot.O_CIV_7_80B4A17B,
            mission.Slot.O_CIV_0_80B4A1AE,
            mission.Slot.O_CIV_1_80B4A1AE,
            mission.Slot.O_CIV_2_80B4A1AE,
            mission.Slot.O_CIV_3_80B4A1AE,
            mission.Slot.O_CIV_4_80B4A1AE,
            mission.Slot.O_CIV_5_80B4A1AE,
            mission.Slot.O_CIV_6_80B4A1AE,
            mission.Slot.O_CIV_7_80B4A1AE,
            mission.Slot.O_CIV_16,
            mission.Slot.O_CIV_17,
            mission.Slot.O_CIV_0_80B4A335,
            mission.Slot.O_CIV_1_80B4A335,
            mission.Slot.O_CIV_2_80B4A335,
            mission.Slot.O_CIV_3_80B4A335,
            mission.Slot.O_CIV_4_80B4A335,
            mission.Slot.O_CIV_5_80B4A335,
            mission.Slot.O_CIV_6_80B4A335,
            mission.Slot.O_CIV_7_80B4A335,
            mission.Slot.O_CIV_8_80B4A335,
            mission.Slot.O_CIV_9,
            mission.Slot.O_CIV_10,
            mission.Slot.O_CIV_11,
            mission.Slot.O_CIV_12,
            mission.Slot.O_CIV_13,
            mission.Slot.O_CIV_14,
            mission.Slot.O_CIV_15,
            mission.Slot.O_CIV_0_80B4A356,
            mission.Slot.O_CIV_1_80B4A356,
            mission.Slot.O_CIV_0_80B4A35F,
            mission.Slot.O_CIV_1_80B4A35F,
            mission.Slot.O_CIV_0_80B4A379,
            mission.Slot.O_CIV_1_80B4A379,
            mission.Slot.O_CIV_0_80B4A38D,
            mission.Slot.O_CIV_1_80B4A38D,
            mission.Slot.O_CIV_0_80B4A411,
            mission.Slot.O_CIV_1_80B4A411,
            mission.Slot.O_CIV_2_80B4A411,
            mission.Slot.O_CIV_3_80B4A411,
            mission.Slot.O_CIV_4_80B4A411,
            mission.Slot.O_CIV_5_80B4A411,
            mission.Slot.O_CIV_6_80B4A411,
            mission.Slot.O_CIV_7_80B4A411,
            mission.Slot.O_CIV_8_80B4A411,
            -- 80B4A47F's o_civ[0], [5] and [6] share spots with 80B4A411's. One per spot.
            mission.Slot.O_CIV_1_80B4A47F,
            mission.Slot.O_CIV_2_80B4A47F,
            mission.Slot.O_CIV_3_80B4A47F,
            mission.Slot.O_CIV_4_80B4A47F,
            mission.Slot.O_CIV_7_80B4A47F,
            mission.Slot.O_CIV_8_80B4A47F,
            mission.Slot.O_CIV_0_80B4A4C1,
            mission.Slot.O_CIV_1_80B4A4C1,
            mission.Slot.O_CIV_2_80B4A4C1,
            mission.Slot.O_CIV_0_80B4A4CB,
            mission.Slot.O_CIV_1_80B4A4CB,
            mission.Slot.O_CIV_2_80B4A4CB,
        },
        scenes = {
            mission.Scene.SC_BAR_SCENE,
            mission.Scene.SM_PPONG_WALKER_1_SCENE,
            mission.Scene.SM_PPONG_WALKER_2_SCENE,
            mission.Scene.SM_PPONG_WALKER_3_SCENE,
            mission.Scene.SM_PPONG_WALKER_4_SCENE,
            mission.Scene.SM_PPONG_WALKER_5_SCENE,
            mission.Scene.SM_PPONG_WALKER_7_SCENE,
            mission.Scene.SM_PPONG_NOODLE_1_SCENE,
            mission.Scene.SM_PPONG_NOODLE_2_SCENE,
            mission.Scene.SM_PPONG_NOODLE_3_SCENE,
            mission.Scene.SM_PPONG_NOODLE_4_SCENE,
        },
        idles = {
            {
                sensor = mission.Slot.SQ_VENDOR_HAWTHORNE_IDLE,
                state = mission.PerformanceState.SQ_VENDOR_HAWTHORNE_IDLE.STATE_FD41C0E5,
            },
            {
                sensor = mission.Slot.SQ_VENDOR_NEW_MONARCHY_IDLE,
                state = mission.PerformanceState.SQ_VENDOR_NEW_MONARCHY_IDLE.STATE_E9527AF7,
            },
        },
    },
    {
        -- hangar
        state = mission.states.STATE_80B4A0F4_0007_0000_80B4A22A,
        squads = {
            mission.Squad.SQ_VENDOR_AMANDA_HOLLIDAY,
            mission.Squad.SQ_VENDOR_DEAD_ORBIT,
            mission.Squad.SQ_VENDOR_FUTURE_WAR_CULT,
            mission.Squad.SQ_PATROL_MID_INVENTORY,
            mission.Squad.SQ_PATROL_BACK_INVENTORY,
            mission.Squad.ADVENTURER_A_SQUAD,
            mission.Squad.ADVENTURER_B_SQUAD,
            mission.Squad.ADVENTURER_C_SQUAD,
            mission.Squad.WALKER_1,
            mission.Squad.WALKER_2,
            mission.Squad.WALKER_3,
            mission.Squad.WALKER_SCENE_4_SQUAD,
            mission.Squad.MECHANIC_FEMALE_STAND_1_SQUAD,
            mission.Squad.MECHANIC_MALE_STAND_1_SQUAD,
            mission.Squad.MECHANIC_ARMX_1_SQUAD,
            mission.Squad.MECHANIC_EXAMINE_STAND_1_SQUAD,
            mission.Squad.MECHANIC_DPAD_STAND_1_SQUAD,
            mission.Squad.MECHANIC_STANDING_ARMX_PING_PONG_1_SQUAD,
            mission.Squad.MECHANIC_STANDING_ARMX_PING_PONG_2_SQUAD,
            mission.Squad.MECHANIC_DATA_PAD_STAND_PING_PONG_1_SQUAD,
            mission.Squad.MECHANIC_MALE_NEUTRAL_STANDING_PING_PONG_1_SQUAD,
            mission.Squad.MECHANIC_FEMALE_NEUTRAL_STAND_PING_PONG_1_SQUAD,
            mission.Squad.MECHANIC_EXAMINE_STAND_PING_PONG_1_SQUAD,
            mission.Squad.MECHANIC_EXAMINE_STAND_PING_PONG_2_SQUAD,
            mission.Squad.MECHANIC_EXAMINE_CROUCH_PING_PONG_1_SQUAD,
            mission.Squad.MECHANIC_EXAMINE_CROUCH_PING_PONG_2_SQUAD,
            mission.Squad.BACK_LEFT_TEAM_1_MECHANIC_DATA_PAD_STAND_PING_PONG_1_SQUAD,
            mission.Squad.BACK_LEFT_TEAM_1_MECHANIC_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.BACK_LEFT_TEAM_1_MECHANIC_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.BACK_MID_TEAM_1_MECHANIC_DATA_PAD_STAND_PING_PONG_1_SQUAD,
            mission.Squad.BACK_MID_TEAM_1_MECHANIC_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.BACK_MID_TEAM_1_MECHANIC_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.BACK_MID_TEAM_2_MECHANIC_DATA_PAD_STAND_PING_PONG_1_SQUAD,
            mission.Squad.BACK_MID_TEAM_2_MECHANIC_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.BACK_MID_TEAM_2_MECHANIC_NPC_STATE_MACHINE_2_SQUAD,
            mission.Squad.BACK_RIGHT_TEAM_1_MECHANIC_DATA_PAD_STAND_PING_PONG_1_SQUAD,
            mission.Squad.BACK_RIGHT_TEAM_1_MECHANIC_NPC_STATE_MACHINE_1_SQUAD,
            mission.Squad.BACK_RIGHT_TEAM_1_MECHANIC_NPC_STATE_MACHINE_2_SQUAD,
        },
        objects = {
            mission.Slot.O_CAPTAIN,
            mission.Slot.O_PILOT,
            mission.Slot.O_COPILOT,
            mission.Slot.O_AMANDA_SCRIBE,
            mission.Slot.O_FOREMAN,
            mission.Slot.O_WORKER_1,
            mission.Slot.O_WORKER_2,
            mission.Slot.O_WORKER_4,
            mission.Slot.O_WORKER_5,
            mission.Slot.O_WORKER_7,
            mission.Slot.O_WORKER_8,
            mission.Slot.O_WORKER_9,
            mission.Slot.O_WORKER_10,
            mission.Slot.O_WORKER_11,
            mission.Slot.O_MECHANICS_1_1_80B4AEC7,
            mission.Slot.O_MECHANICS_1_2_80B4AEC7,
            mission.Slot.O_MECHANICS_3_1,
            mission.Slot.O_MECHANICS_3_2,
            mission.Slot.O_MECHANICS_4_1_80B4AEC7,
            mission.Slot.O_MECHANICS_4_2_80B4AEC7,
            mission.Slot.O_MECHANICS_5_1_80B4AEC7,
            mission.Slot.O_MECHANICS_5_2_80B4AEC7,
            mission.Slot.O_WELDER_1,
            mission.Slot.O_WELDER_2,
            mission.Slot.O_WELDER_3,
            mission.Slot.O_DEAD_ORBIT_1,
            mission.Slot.O_DEAD_ORBIT_2,
            mission.Slot.O_DEAD_ORBIT_3,
            mission.Slot.O_DEAD_ORBIT_4,
            mission.Slot.O_DEAD_ORBIT_5,
            mission.Slot.O_DEAD_ORBIT_6,
            mission.Slot.O_DEAD_ORBIT_7,
            mission.Slot.O_DEAD_ORBIT_8,
            mission.Slot.O_DEAD_ORBIT_9,
            mission.Slot.O_MECHANIC_BACK_UPPER_LEFT,
            mission.Slot.O_MECHANIC_BACK_UPPER_RIGHT,
            mission.Slot.O_MECHANIC_BACK_UPPER_MID,
            mission.Slot.O_WORKER_TABLE,
            mission.Slot.O_DO_AIDE,
            mission.Slot.O_MECHANIC_1,
            mission.Slot.O_MECHANIC_2,
            mission.Slot.O_MECHANIC_3,
            mission.Slot.O_MECHANIC_7,
            mission.Slot.O_MECHANIC_8,
            mission.Slot.O_MECHANIC_9,
            mission.Slot.O_MECHANIC_11,
            mission.Slot.O_MECHANIC_FWC,
            mission.Slot.O_MECHANICS_1_1_80B4B28D,
            mission.Slot.O_MECHANICS_1_2_80B4B28D,
            mission.Slot.O_MECHANICS_4_1_80B4B28D,
            mission.Slot.O_MECHANICS_4_2_80B4B28D,
            mission.Slot.O_MECHANICS_5_1_80B4B28D,
            mission.Slot.O_MECHANICS_5_2_80B4B28D,
            mission.Slot.O_MECHANICS_6_1,
            mission.Slot.O_MECHANICS_6_2,
            mission.Slot.O_MECHANICS_7_1,
            mission.Slot.O_MECHANICS_7_2,
            mission.Slot.O_MECHANICS_9_1,
            mission.Slot.O_MECHANICS_9_2,
            mission.Slot.O_MECHANICS_10_1,
            mission.Slot.O_MECHANICS_10_2,
            mission.Slot.O_MECHANICS_11_1,
            mission.Slot.O_MECHANICS_11_2,
            mission.Slot.O_MECHANICS_12_1,
            mission.Slot.O_MECHANICS_12_2,
            mission.Slot.O_MECHANICS_13_1,
            mission.Slot.O_MECHANICS_13_2,
            mission.Slot.O_DO_HAWK,
            -- 80B4AC14 repeats every slot of 80B4ABB8, so its football is the same ball.
            mission.Slot.O_MILITARY_FOOTBALL_80B4ABB8,
        },
        scenes = {
            mission.Scene.SC_DO_AWAY_TEAM,
            mission.Scene.SC_BACK_INVENTORY,
            mission.Scene.SC_MID_INVENTORY,
            mission.Scene.SC_WALKER_1,
            mission.Scene.SC_WALKER_2,
            mission.Scene.SC_WALKER_3,
            mission.Scene.WALKER_SCENE_4_SCENE,
            mission.Scene.SC_MECH_APPRENTICE_LOOP,
            mission.Scene.MECHANIC_FEMALE_STAND_1_SCENE,
            mission.Scene.MECHANIC_MALE_STAND_1_SCENE,
            mission.Scene.MECHANIC_ARMX_1_SCENE,
            mission.Scene.MECHANIC_EXAMINE_STAND_1_SCENE,
            mission.Scene.MECHANIC_DPAD_STAND_1_SCENE,
            mission.Scene.MECHANIC_STANDING_ARMX_PING_PONG_1_SCENE,
            mission.Scene.MECHANIC_STANDING_ARMX_PING_PONG_2_SCENE,
            mission.Scene.MECHANIC_DATA_PAD_STAND_PING_PONG_1_SCENE,
            mission.Scene.MECHANIC_MALE_NEUTRAL_STANDING_PING_PONG_1_SCENE,
            mission.Scene.MECHANIC_FEMALE_NEUTRAL_STAND_PING_PONG_1_SCENE,
            mission.Scene.MECHANIC_EXAMINE_STAND_PING_PONG_1_SCENE,
            mission.Scene.MECHANIC_EXAMINE_STAND_PING_PONG_2_SCENE,
            mission.Scene.MECHANIC_EXAMINE_CROUCH_PING_PONG_1_SCENE,
            mission.Scene.MECHANIC_EXAMINE_CROUCH_PING_PONG_2_SCENE,
            mission.Scene.BACK_LEFT_TEAM_1_MECHANIC_DATA_PAD_STAND_PING_PONG_1_SCENE,
            mission.Scene.BACK_MID_TEAM_1_MECHANIC_DATA_PAD_STAND_PING_PONG_1_SCENE,
            mission.Scene.BACK_MID_TEAM_2_MECHANIC_DATA_PAD_STAND_PING_PONG_1_SCENE,
            mission.Scene.BACK_RIGHT_TEAM_1_MECHANIC_DATA_PAD_STAND_PING_PONG_1_SCENE,
        },
        idles = {
            {
                sensor = mission.Slot.SQ_VENDOR_AMANDA_HOLLIDAY_IDLE,
                state = mission.PerformanceState.SQ_VENDOR_AMANDA_HOLLIDAY_IDLE.STATE_5E795D1C,
            },
            {
                sensor = mission.Slot.SQ_VENDOR_DEAD_ORBIT_IDLE,
                state = mission.PerformanceState.SQ_VENDOR_DEAD_ORBIT_IDLE.STATE_3E9851D6,
            },
            {
                sensor = mission.Slot.SQ_VENDOR_FUTURE_WAR_CULT_IDLE,
                state = mission.PerformanceState.SQ_VENDOR_FUTURE_WAR_CULT_IDLE.STATE_94DBC38B,
            },
        },
    },
    {
        -- annex
        state = mission.states.STATE_80B4A0F4_0000_0000_80B4A225,
        squads = {
            mission.Squad.SQ_ARMORY_VENDOR,
        },
        objects = {
            mission.Slot.O_DRIFTER_VENDOR,
        },
        scenes = {},
        idles = {
            {
                sensor = mission.Slot.SQ_ARMORY_VENDOR_IDLE,
                state = mission.PerformanceState.SQ_ARMORY_VENDOR_IDLE.STATE_FA55297B,
            },
        },
    },
}

-- A reattach reopens this script in a fresh VM, so the mark lives in mission state.
local BUILT_PREFIX = "built_"
local HELD_KEY = "held_region"

local function bubble_for_region(region)
    for _, bubble in ipairs(BUBBLES) do
        if bubble.state.region_index == region then
            return bubble
        end
    end
    return nil
end

local function built_key(bubble)
    return BUILT_PREFIX .. bubble.state.region_index
end

-- Squads first, then the state: the rest binds under its lease.
-- A bubble is entered once. The roster keeps everything, so a return asks for nothing.
local function enter_bubble(context, state, bubble)
    if state:variable(built_key(bubble)) then
        return
    end
    context:set_variable(built_key(bubble), true)
    lib.place_all(context, bubble.squads, context.sdk.squad_modes.reinforce)
    context:select_state(bubble.state, SEED_OMIT)
    lib.activate_objects(context, bubble.objects)
    lib.activate_scenes(context, bubble.scenes)
    lib.play_idles(context, bubble.idles)
end

return {
    on_event_client_state_changed = function(context, state, event)
        -- Only the held region says where the client is. The pending leg is a precache.
        local standing = bubble_for_region(event.held_region_index)
        if standing == nil or state:variable(HELD_KEY) == standing.state.region_index then
            return
        end
        context:set_variable(HELD_KEY, standing.state.region_index)
        enter_bubble(context, state, standing)
    end,
}
