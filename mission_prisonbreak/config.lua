-- Installed scenario 80F7C018, activity 308 (1F13FA86).
-- This is a reconstruction for playtesting; see temp.md/MISSION_PRISONBREAK_STATUS.md.
return {
    -- Set this back to true only while deliberately testing a bubble/slice in the
    -- tooling. The retail route starts in the authored opening cinematic state.
    follow_selected_region = false,
    entry = "STATE_80F7C018_0004_0000_80F7C013",
    lower = "STATE_80F7C018_0005_0000_80F7C014",
    -- All authored type-6 cinematics in this package appear to need the same
    -- cutscene spawn context. CS2 showed partial/misaligned playback when it
    -- inherited or auto-picked a different spawn.
    cutscene_spawn_hash = 0x811C9DC5,
    -- Playable mission entry spawn for bubble 4 / region 32. Arm this only during
    -- the final CS2 -> gameplay handoff so cinematic playback keeps its cutscene spawn.
    entry_spawn_hash = 0x2EA8FB98,
    -- Current breakpoint test: run the two pre-mission cinematics directly,
    -- then land in bubble 4 / region 32 without birding.
    opening = {
        {
            state = "STATE_80F7C018_0001_0001_80F7C00D",
            slot = "CIN_COVEN_INTRO_CINEMATIC_80F7C020",
        },
        {
            state = "STATE_80F7C018_0002_0001_80F7C011",
            slot = "CIN_COVEN_INTRO_CINEMATIC_80F7C035",
        },
    },
    opening_select_entry_delay_ms = 900,
    opening_finish_entry_delay_ms = 1500,
    -- After the client reports bubble 4, wait briefly before enabling phase-1
    -- gameplay routes. This isolates the CS2 -> playable handoff from the
    -- first trigger/slot-auth wave, which is currently the Bird suspect.
    opening_playable_settle_ms = 3000,
    allow_direct_entry = false,
    arrival_cinematic = nil,
    ending = {
        {state = "STATE_80F7C018_0001_0002_80F7C00E", slot = "CIN_COVEN_INTRO_CINEMATIC_80F7C027"},
        {state = "STATE_80F7C018_0001_0003_80F7C00F", slot = "CIN_COVEN_INTRO_CINEMATIC_80F7C02E"},
    },
    security_cinematics = {
        "prison_break_security_hub_fall",
        "cayde_final_stand",
    },
    story_cinematics = {
        cayde_shot_by_uldren = {
            state = "STATE_80F7C018_0001_0001_80F7C00D",
            slot = "CIN_COVEN_INTRO_CINEMATIC_80F7C020",
        },
        vanguard_greives_cayde = {
            state = "STATE_80F7C018_0001_0003_80F7C00F",
            slot = "CIN_COVEN_INTRO_CINEMATIC_80F7C02E",
        },
        cayde_petra_arrive_at_prison = {
            state = "STATE_80F7C018_0002_0001_80F7C011",
            slot = "CIN_COVEN_INTRO_CINEMATIC_80F7C035",
        },
        prison_break_security_hub_fall = {
            state = "STATE_80F7C018_0005_0001_80F7C015",
            slot = "CIN_COVEN_INTRO_CINEMATIC_80F7D24B",
        },
        cayde_final_stand = {
            state = "STATE_80F7C018_0005_0002_80F7C016",
            slot = "CIN_COVEN_INTRO_CINEMATIC_80F7D252",
        },
        guardian_finds_cayde_dying = {
            state = "STATE_80F7C018_0001_0002_80F7C00E",
            slot = "CIN_COVEN_INTRO_CINEMATIC_80F7C027",
        },
    },
    -- Earned checkpoints enable a darkness zone and all-dead restart in their region.
    checkpoints = {
        -- Confirmed by live traversal: after Quell the Riot, before regrouping
        -- with Petra, deaths should return to this region-32 spawn set.
        riot_quell = {region = 32, hash = 0xF8C1A7DE},
    },
    -- Cue numbers remain opt-in until their text is mapped. Scene activation
    -- does not establish dialogue playback. Keys: prison_arrival, first_door,
    -- riot_quelled, petra_regroup, security_arrival.
    dialogue = {},
    -- Use the live Dialogue audition panel for mapping. Keep automatic probe
    -- playback disabled during route tests so an unknown cue cannot overlap
    -- authored cinematic or scene audio.
    dialogue_probe = nil,
    music = {
        prison = 1,
        riot = 2,
        security = 3,
        supermax = 4,
    },
}

