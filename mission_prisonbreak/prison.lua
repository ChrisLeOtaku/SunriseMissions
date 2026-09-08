-- Authored encounter-name grouping with provisional spatial gates, for live auditing.
return function(m, config, a)
    local P = {}
    local gates = {
        {"PT_STARTED_CELLBLOCK", {"cell1_1"}},
        {"PT_DROPDOWN_REINFORCE", {"cell1_2"}},
        {"PT_CLEANUP_2_80F7C409", {"cell1_3"}},
        {"PT_START_CELLBLOCK_2", {"cell2_1"}},
        {"PT_START_THRALL_RUSH", {"cell2_2"}},
        {"PT_SPAWN_ENC3", {"cell2_3"}},
        {"PT_START_ENC4_MINIBOSS_SPAWN", {"cell2_4"}},
        {"PT_ENTERED_ARENA_80F7C86E", {"yard_cabal", "yard_fallen", "yard_fallen_boss"}},
    }
    -- 80F7CC6E groups the yard-wall blast and the burning maintenance opening.
    -- The blast/rumble are pulses; the fire, embers, smoke and steam remain as
    -- post-breach dressing until the player leaves the maintenance section.
    local yard_breach_pulses = {
        "O_WALL_EXPLOSION_HUGE", "O_YARD_WALL_SCREEN_SHAKE_RUMBLE",
    }
    local yard_breach_ambient = {
        "O_EXPLOSION_GROUND_FIRE_4", "O_EXPLOSION_GROUND_FIRE", "O_EXPLOSION_GROUND_FIRE_1",
        "O_SMOKE_PLUME_XXL_1", "O_BLOWING_EMBERS_A_1", "O_FIRE_DRIP_SMALL",
        "O_FIRE_DRIP_A_1", "O_FIRE_DRIP_A_1_FLOOR_IMPACT",
        "O_FIRE_DRIP_A_2", "O_FIRE_DRIP_A_2_FLOOR_IMPACT",
        "O_FIRE_DRIP_A_3", "O_FIRE_DRIP_A_3_FLOOR_IMPACT",
        "O_FIRE_DRIP_SMALL_1", "O_FIRE_DRIP_SMALL_1_FLOOR_IMAPCT",
        "O_FIRE_DRIP_A_4", "O_FIRE_DRIP_A_5",
        "O_PIPE_STEAM", "O_PIPE_STEAM_1", "O_PIPE_STEAM_2",
    }
    local function set_objects(c, names, active)
        for _, name in ipairs(names) do a.object(c, name, active) end
    end
    local function stop_yard_breach_pulses(c)
        set_objects(c, yard_breach_pulses, false)
    end
    local function stop_yard_breach_ambient(c)
        set_objects(c, yard_breach_ambient, false)
        a.object(c, "O_EMBERS_WAFT", false)
    end
    local function stop_first_door_fx(c)
        a.object(c, "DOOR_EXPLOSION_FX", false)
        a.object(c, "O_GLASS_CRACK", false)
        for i = 1, 5 do a.object(c, "O_CAMERA_RUMBLE_" .. i, false) end
    end
    local function first_door(c, s, source)
        c:set_variable("prisonbreak.debug.first_door_trigger", source)
        if not a.once(c, s, "first_door.breach") then return end
        -- Stage the authored FX before starting its scene.  Scene activation can
        -- be acknowledged in the same update, so doing this afterward races the
        -- scene's first explosion frame on a live client.
        a.object(c, "DOOR_EXPLOSION_FX", true)
        -- The authored scene has five rumble anchors.  Activating only the
        -- first one leaves the breach looking like a silent door toggle on
        -- clients that do not receive the scene's object deltas.
        for i = 1, 5 do a.object(c, "O_CAMERA_RUMBLE_" .. i, true) end
        a.object(c, "O_GLASS_CRACK", true)
        local request = a.scene(c, "SC_PRISONBREAK_PEN_YARD_DOOR_ENTRY")
        c:set_variable("prisonbreak.first_door.request", request.value)
        c:set_variable("prisonbreak.debug.first_door_scene", "requested")
        a.cue(c, s, "first_door")
        a.music(c, s, config.music and config.music.riot)
        c:start_timer("prisonbreak.first_door.fx", 4500)
        c:start_timer("prisonbreak.first_door.fallback", 3500)
    end
    local function regroup(c, s)
        if not s:variable("prisonbreak.riot.cleared") then return end
        if not a.once(c, s, "petra.regroup") then return end
        a.object(c, "O_ELEVATOR_DOOR", true)
        c:set_variable("prisonbreak.petra.scene.pending", true)
        c:start_timer("prisonbreak.petra.scene", 250)
        a.cue(c, s, "petra_regroup")
        -- Stage the whole route while Petra holds the player's attention.  The
        -- nearby triggers now start performances, rather than creating actors
        -- in front of the player. Reasserting music here bridges the Petra cue.
        a.spawn(c, s, {"turret_entry", "hallway_chase", "train_runover", "cayde_bridge"})
        a.music(c, s, config.music and config.music.security, true)
        -- Keep the exit closed until the authored performance completes.
        a.directive(c, s, "REACH_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7CACB")
    end
    local function start_petra_scene(c, s)
        if not s:variable("prisonbreak.petra.scene.pending") then return end
        c:clear_variable("prisonbreak.petra.scene.pending")
        local request = a.scene(c, "SCENE_PETRA_HERO")
        c:set_variable("prisonbreak.petra.scene.request", request.value)
    end
    function P.enter(c, s)
        if not a.once(c, s, "prison.enter") then return end
        local names = {"PT_START_YARD_TO_SECURITY", "PT_OPEN_ENTRANCE_DOOR_80F7CACB",
            "PT_PLAYER_APPROACHING_PETRA", "PT_PRISONBREAK_PEN_YARD_DOOR_ENTRY",
            "PT_ENTER_YARD", "PT_IN_YARD", "PT_VIEW_RIOT", "PT_YARD_TO_SECURITY_VIG_EXPLOSIONS",
            "PT_TV_PEN_HALLWAY_EXPLOSION", "PT_ADD_WRAPPED_EMBERS",
            "PT_REMOVE_WRAPPED_EMBERS", "PT_EXIT_MAINTENANCE_AREA"}
        for _, row in ipairs(gates) do names[#names + 1] = row[1] end
        -- The first door is a type-4 authored object, not D_CELLBLOCK_EXIT.
        -- Let its matching scene own animation/damaged geometry on activation.
        a.object(c, "O_FISRT_DOOR", true)
        stop_first_door_fx(c)
        a.object(c, "O_GLASS_CRACK", false)
        a.device(c, "D_YARD_EXPLODING_WALL", false)
        stop_yard_breach_pulses(c)
        stop_yard_breach_ambient(c)
        -- Closed transitions instantiate both authored elevator-room doors.
        -- Their exact proximity/performance events open them later.
        a.device(c, "D_PETRA_VIG_ENTRANCE", false)
        a.device(c, "D_PETRA_VIG_EXIT", false)
        a.arm(c, names)
        a.directive(c, s, "QUELL_THE_RIOT", "M_ENGAGEMENT_SENSOR_80F7C409")
        a.cue(c, s, "prison_arrival")
        if config.dialogue_probe ~= nil and config.dialogue.prison_arrival == nil then
            a.slot(c, "M_DIALOG_SENSOR_80F7D261"):play_dialogue_cue{
                cue = assert(m.DialogueCue.M_DIALOG_SENSOR_80F7D261["CUE_" .. config.dialogue_probe])}
            c:set_variable("prisonbreak.debug.dialogue_probe", config.dialogue_probe)
        end
        a.music(c, s, config.music and config.music.prison)
    end
    function P.trigger(c, s, e)
        for _, row in ipairs(gates) do
            if a.matches(c, e, row[1]) then a.spawn(c, s, row[2]); return end
        end
        if a.matches(c, e, "PT_VIEW_RIOT")
            or a.matches(c, e, "PT_ENTER_YARD")
            or a.matches(c, e, "PT_IN_YARD")
            or a.matches(c, e, "PT_PRISONBREAK_PEN_YARD_DOOR_ENTRY") then
            first_door(c, s, "type31")
            if a.once(c, s, "riot.vignette") then a.object(c, "O_RIOT_SFX", true) end
        elseif a.matches(c, e, "PT_YARD_TO_SECURITY_VIG_EXPLOSIONS") then
            if a.once(c, s, "yard.travel.fx") then
                a.object(c, "O_EXPLOSION_MED_A", true)
                a.object(c, "O_EXPLOSION_MED_B", true)
                c:start_timer("prisonbreak.yard_travel.fx", 1400)
            end
            if s:variable("prisonbreak.riot.cleared") then
                a.spawn(c, s, {"turret_entry"})
                a.music(c, s, config.music and config.music.security, true)
            end
        elseif a.matches(c, e, "PT_TV_PEN_HALLWAY_EXPLOSION") then
            if a.once(c, s, "hallway.fx") then
                a.object(c, "O_EXPLOSION_STANDARD", true)
                a.object(c, "O_SCREEN_SHAKE", true)
                c:start_timer("prisonbreak.hallway.fx", 1400)
            end
        elseif a.matches(c, e, "PT_PLAYER_APPROACHING_PETRA") then
            regroup(c, s)
        elseif a.matches(c, e, "PT_START_YARD_TO_SECURITY") then
            -- A redundant spatial cleanup prevents a missed/late timer receipt
            -- from leaving the huge blast emitter as a dark screen-space orb.
            stop_yard_breach_pulses(c)
            if s:variable("prisonbreak.once.petra.regroup") then
                a.spawn(c, s, {"turret_entry"})
                a.music(c, s, config.music and config.music.security, true)
                a.directive(c, s, "REACH_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7CACB")
            end
        elseif a.matches(c, e, "PT_OPEN_ENTRANCE_DOOR_80F7CACB") then
            if s:variable("prisonbreak.riot.cleared") then a.device(c, "D_PETRA_VIG_ENTRANCE", true) end
        elseif a.matches(c, e, "PT_ADD_WRAPPED_EMBERS") then
            if s:variable("prisonbreak.riot.cleared") then
                a.object(c, "O_EMBERS_WAFT", true)
                a.object(c, "O_BLOWING_EMBERS_A_1", true)
            end
        elseif a.matches(c, e, "PT_REMOVE_WRAPPED_EMBERS") then
            a.object(c, "O_EMBERS_WAFT", false)
            a.object(c, "O_BLOWING_EMBERS_A_1", false)
        elseif a.matches(c, e, "PT_EXIT_MAINTENANCE_AREA") then
            stop_yard_breach_pulses(c)
            stop_yard_breach_ambient(c)
        end
    end
    function P.occupancy(c, s, e)
        -- The SDK separately exposes the exact type-60 volume behind the type-31
        -- pulse. Accept its entry edge too; never substitute a nearby volume.
        for _, name in ipairs({"PT_VIEW_RIOT", "PT_PRISONBREAK_PEN_YARD_DOOR_ENTRY"}) do
            local volume = assert(m.TriggerVolume[name])
            if e.registry_key == volume.registry_key and e.slot_type == volume.slot_type
                and e.slot_index == volume.slot_index then first_door(c, s, "type60"); return end
        end
    end
    function P.effect(c, s, e)
        if e.request_key and e.request_key.value == s:variable("prisonbreak.first_door.request") then
            c:set_variable("prisonbreak.debug.first_door_scene", e.outcome or "unknown")
        end
    end
    function P.scene_finished(c, s, e)
        local petra_token = e.activation_token ~= nil
            and e.activation_token == tonumber(s:variable("prisonbreak.petra.scene.request"))
        if petra_token or a.matches(c, e, "SCENE_PETRA_HERO") then
            if a.once(c, s, "petra.scene.finished") then
                c:set_variable("prisonbreak.petra.scene.finished", true)
                a.device(c, "D_PETRA_VIG_EXIT", true)
                -- Petra's performance can end its local score section. Restore
                -- the route music after the scene, when the player can move on.
                a.music(c, s, config.music and config.music.security, true)
            end
            return
        end
        local token_match = e.activation_token ~= nil
            and e.activation_token == tonumber(s:variable("prisonbreak.first_door.request"))
        if not token_match and not a.matches(c, e, "SC_PRISONBREAK_PEN_YARD_DOOR_ENTRY") then return end
        c:set_variable("prisonbreak.debug.first_door_scene", "finished")
        c:set_variable("prisonbreak.first_door.finished", true)
        -- The scene owns the breach animation; remove only the intact blocker
        -- after its completion receipt, never on the initial trigger.
        a.object(c, "O_FISRT_DOOR", false)
    end
    function P.cleared(c, s, name)
        -- Commit the authored objective lane when its encounter really clears.
        -- The HUD directive alone does not advance the mission state.
        a.reset_objective(c, s, name)
        if (name == "cell2_1" or name == "cell2_2" or name == "cell2_3" or name == "cell2_4")
            and a.clear(s, {"cell2_1", "cell2_2", "cell2_3", "cell2_4"})
            and a.once(c, s, "cellblock.exit") then
            a.device(c, "D_CELLBLOCK_EXIT", true)
            -- The initial region arm can occur before this authored object is
            -- active. Rearm it now, but do not consume the breach one-shot here:
            -- doing so played the explosion offscreen at encounter completion.
            a.arm(c, {"PT_PRISONBREAK_PEN_YARD_DOOR_ENTRY", "PT_ENTER_YARD", "PT_IN_YARD"})
            c:set_variable("prisonbreak.debug.first_door_trigger", "armed_after_cellblock")
        end
        if (name == "yard_cabal" or name == "yard_fallen_boss")
            and a.clear(s, {"yard_cabal", "yard_fallen_boss"})
            and a.once(c, s, "yard.presentation") then
            c:set_variable("prisonbreak.riot.cleared", true)
            set_objects(c, yard_breach_pulses, true)
            set_objects(c, yard_breach_ambient, true)
            a.device(c, "D_YARD_EXPLODING_WALL", true)
            a.device(c, "D_YARD_POST_EXPLOSION_LIGHTS", true)
            a.checkpoint(c, s, config.checkpoints and config.checkpoints.riot_quell, "riot_quell")
            a.directive(c, s, "RENDEZVOUS_WITH_PETRA", "M_ENGAGEMENT_SENSOR_80F7CACB")
            c:squad(assert(m.Squad.SQUAD_HERO_PETRA)):place{mode = c.sdk.squad_modes.replace}
            a.device(c, "D_PETRA_VIG_ENTRANCE", false)
            a.device(c, "D_PETRA_VIG_EXIT", false)
            a.cue(c, s, "riot_quelled")
            a.music(c, s, config.music and config.music.security, true)
            c:start_timer("prisonbreak.yard_wall.fx", 900)
        end
    end
    function P.timer(c, s, e)
        local timer = e.timer_name
        if timer == "prisonbreak.first_door.fx" then
            stop_first_door_fx(c)
            return
        end
        if timer == "prisonbreak.petra.scene" then
            start_petra_scene(c, s)
            return
        end
        if timer == "prisonbreak.first_door.fallback" then
            if not s:variable("prisonbreak.first_door.finished") then
                -- A missing scene receipt must not leave the player trapped behind
                -- the intact authored blocker. The scene remains the preferred path.
                c:set_variable("prisonbreak.debug.first_door_scene", "fallback")
                c:set_variable("prisonbreak.first_door.finished", true)
                a.object(c, "O_FISRT_DOOR", false)
            end
            return
        end
        if timer == "prisonbreak.yard_wall.fx" then
            stop_yard_breach_pulses(c)
            return
        end
        if timer == "prisonbreak.yard_travel.fx" then
            a.object(c, "O_EXPLOSION_MED_A", false)
            a.object(c, "O_EXPLOSION_MED_B", false)
            return
        end
        if timer == "prisonbreak.hallway.fx" then
            a.object(c, "O_EXPLOSION_STANDARD", false)
            a.object(c, "O_SCREEN_SHAKE", false)
        end
    end
    function P.reset(c, s)
        -- Retain defeated riot waves and the breached wall at the earned checkpoint.
        c:clear_variable("prisonbreak.once.petra.regroup")
        c:clear_variable("prisonbreak.once.dialogue.petra_regroup")
        c:clear_variable("prisonbreak.once.petra.scene.finished")
        c:clear_variable("prisonbreak.petra.scene.request")
        c:clear_variable("prisonbreak.petra.scene.pending")
        c:clear_variable("prisonbreak.petra.scene.finished")
        for _, timer in ipairs({"prisonbreak.first_door.fx", "prisonbreak.first_door.fallback",
            "prisonbreak.petra.scene", "prisonbreak.yard_wall.fx",
            "prisonbreak.yard_travel.fx", "prisonbreak.hallway.fx"}) do
            c:cancel_timer(timer)
        end
        a.arm(c, {"PT_PLAYER_APPROACHING_PETRA", "PT_OPEN_ENTRANCE_DOOR_80F7CACB", "PT_START_YARD_TO_SECURITY"})
        a.device(c, "D_YARD_EXPLODING_WALL", true)
        a.device(c, "D_PETRA_VIG_ENTRANCE", false)
        a.device(c, "D_PETRA_VIG_EXIT", false)
        stop_yard_breach_pulses(c)
        -- The earned checkpoint is still beside the breached wall, so restore
        -- its safe persistent dressing after clearing stale transient effects.
        set_objects(c, yard_breach_ambient, true)
        a.object(c, "O_ELEVATOR_DOOR", true)
        c:squad(assert(m.Squad.SQUAD_HERO_PETRA)):place{mode = c.sdk.squad_modes.replace}
        a.directive(c, s, "RENDEZVOUS_WITH_PETRA", "M_ENGAGEMENT_SENSOR_80F7CACB")
    end
    return P
end
