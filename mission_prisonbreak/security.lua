-- The control-room repair is deliberately gated: its six Hive sensors have no
-- generated Squad entries, and server-rack channel completion is not documented.
return function(m, config, a, interlude)
    local S = {}
    local console = "GL_DOOR_80F7C95B"
    local gates = {
        {"PT_SPAWN", {"turret_entry"}},
        {"PT_FIRST_SECTION_EXIT", {"turret_last"}},
        {"PT_HIVE_START", {"security_hive"}},
        {"PT_HIVE_FINALE", {"security_hive"}},
        {"PT_CABAL_START", {"security_cabal"}},
        {"PT_CABAL_FINALE", {"security_cabal"}},
    }
    -- The authored reveal on 80F7CB32 is a bundle of one-shot effects.  The
    -- engine leaves these inactive until the player reaches the approach
    -- trigger; keeping the list here also lets reset() reliably clear a
    -- partially played reveal after a wipe.
    local control_reveal_objects = {
        "O_CONTROL_ROOM_REVEAL_FIRE", "O_CONTROL_ROOM_REVEAL_FIRE_REAR",
        "O_SHANK_REPAIR_1", "O_SHANK_REPAIR_2", "O_SHANK_REPAIR_3", "O_SHANK_REPAIR_4",
        "O_FALLING_DEBRIS_1", "O_FALLING_DEBRIS_3", "O_FALLING_DEBRIS_4",
        "O_FALLING_DEBRIS_5", "O_FALLING_DEBRIS_6", "O_FALLING_DEBRIS_C", "O_FALLING_DEBRIS_F",
        "O_DARK_SMOKE_LARGE", "O_DARK_SMOKE_LARGE_1",
        "O_CONTROL_ROOM_REVEAL_FIRE_SMALL", "O_CONTROL_ROOM_REVEAL_FIRE_SMALL_1",
        "O_CONTROL_ROOM_REVEAL_FIRE_SMALL_2", "O_CONTROL_ROOM_REVEAL_FIRE_SMALL_3",
        "O_CONTROL_ROOM_REVEAL_FIRE_SMALL_4", "O_CONTROL_ROOM_REVEAL_FIRE_SMALL_5",
        "O_CONTROL_ROOM_REVEAL_FIRE_TINY",
        "O_CONTROL_ROOM_EXPLOSION", "O_CONTROL_ROOM_EXPLOSION_1", "O_CONTROL_ROOM_EXPLOSION_2",
    }
    local function stop_control_reveal(c)
        for _, name in ipairs(control_reveal_objects) do a.object(c, name, false) end
    end
    local function control_reveal(c, s)
        if not a.once(c, s, "control.room.reveal") then return end
        for _, name in ipairs(control_reveal_objects) do a.object(c, name, true) end
        -- These authored alarm channels are part of the same hub reveal and
        -- provide the room lighting/audio bed while the debris settles.
        a.device(c, "D_ALARM_LIGHTS_80F7C1FD", true)
        a.device(c, "D_ALARM_SOUNDS", true)
        c:start_timer("prisonbreak.control.reveal.fx", 2400)
    end
    local function preload_control_room(c, s)
        if not a.once(c, s, "control.room.preload") then return end
        -- These authored actors are placed in the room before the player
        -- crosses the chamber volume.  This removes the visible pop-in while
        -- leaving their performance scene gated by the room trigger.
        a.spawn(c, s, {"control_room_exploders", "control_room_cayde"})
        for i = 1, 4 do a.object(c, "O_CONTROL_ROOM_DOOR_SPARK_" .. i, false) end
        a.object(c, "O_DOOR_BLOCKER", true)
    end
    function S.enter(c, s)
        -- Reassert the region music when the client settles or respawns.
        a.music(c, s, config.music and config.music.security, true)
        if not a.once(c, s, "security.enter") then return end
        local names = {"PT_DOOR", "PT_QUARANTINE_AREA", "PT_PLAYER_NEAR_CAYDE",
            "PT_PLAYER_ENTERS_CHAMBER", "PT_PLAYER_NEAR_PERFORMANCE", "PT_PLAYER_ENTERS_AREA",
            "PT_PLAYER_OUTSIDE_CONTROL_ROOM", "PT_PLAYER_APPROACHING_CONTROL_ROOM",
            "PT_PLAYER_APPROACHING_WALKWAY", "PT_INSIDE_CONTROL_ROOM",
            "PT_CONTROL_ROOM_REVEAL_EXPLOSIONS", "PT_APPROACHING_CONTROL_ROOM",
            "PT_PLAYER_CLOSE", "PT_START_RUNOVER", "PT_PLAYER_APPROACHING",
            "PT_CAYDE_IN_SIGHT_80F7C273", "PT_SCORCH_CANNON_CABAL_FALL"}
        for _, row in ipairs(gates) do names[#names + 1] = row[1] end
        a.arm(c, names)
    end
    function S.trigger(c, s, e)
        if not s:variable("prisonbreak.once.petra.regroup") then return end
        -- Keep the post-Petra score alive across authored dialogue and scenes.
        a.music(c, s, config.music and config.music.security, true)
        if a.matches(c, e, "PT_PLAYER_CLOSE") then
            a.spawn(c, s, {"hallway_chase"})
            if a.once(c, s, "hallway.chase.scene") then
                local request = a.scene(c, "SC_CHASE_80F7C0C7")
                c:set_variable("prisonbreak.hallway.chase.request", request.value)
            end
            return
        end
        if a.matches(c, e, "PT_START_RUNOVER") then
            a.spawn(c, s, {"train_runover"})
            if a.once(c, s, "train.runover.scene") then
                for _, name in ipairs({"O_CABAL_CANNON_1", "O_CABAL_CANNON_2",
                    "O_FALLEN_CANNON_1", "O_FALLEN_CANNON_2", "O_TRAIN", "O_PETRA_AUDIO"}) do
                    a.object(c, name, true)
                end
                a.device(c, "D_PETRA_AUDIO", true)
                local request = a.scene(c, "S_TRAIN_RUNOVER")
                c:set_variable("prisonbreak.train.runover.request", request.value)
            end
            return
        end
        if a.matches(c, e, "PT_PLAYER_APPROACHING")
            or a.matches(c, e, "PT_CAYDE_IN_SIGHT_80F7C273") then
            a.spawn(c, s, {"cayde_bridge"})
            if a.once(c, s, "cayde.bridge.scene") then
                -- This authored scene contains Cayde's real Golden Gun rounds
                -- and the shielded charging Hive combatant on the bridge.
                local request = a.scene(c, "SCENE_CAYDE_NADE_PINEAPPLE")
                c:set_variable("prisonbreak.cayde.bridge.request", request.value)
            end
            return
        end
        if a.matches(c, e, "PT_SCORCH_CANNON_CABAL_FALL") then
            a.spawn(c, s, {"cayde_bridge"})
            if a.once(c, s, "cayde.bridge.rocket.scene") then
                local request = a.scene(c, "SCENE_FALLEN_KILLED_BY_ROCKET_1")
                c:set_variable("prisonbreak.cayde.bridge.rocket.request", request.value)
            end
            return
        end
        if a.matches(c, e, "PT_CONTROL_ROOM_REVEAL_EXPLOSIONS") then
            control_reveal(c, s)
            preload_control_room(c, s)
            a.directive(c, s, "ENTER_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7CB32")
            return
        end
        if a.matches(c, e, "PT_APPROACHING_CONTROL_ROOM") then
            control_reveal(c, s)
            preload_control_room(c, s)
            a.directive(c, s, "ENTER_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7CB32")
            return
        end
        if a.matches(c, e, "PT_QUARANTINE_AREA") then
            -- Preload the hub arena before the player reaches its door.
            a.spawn(c, s, {"security_hive", "security_cabal"})
            a.directive(c, s, "ENTER_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7C95B")
            return
        end
        if a.matches(c, e, "PT_DOOR") then
            if a.once(c, s, "security.entry.door") then
                a.device(c, "D_DOOR_0_80F7C95B", true)
                a.device(c, "D_DOOR_1_80F7C95B", true)
            end
            a.spawn(c, s, {"security_hive", "security_cabal"})
            a.directive(c, s, "ENTER_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7C95B")
            return
        end
        for _, row in ipairs(gates) do
            if a.matches(c, e, row[1]) then
                a.spawn(c, s, row[2])
                a.directive(c, s, "ENTER_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7C95B")
                return
            end
        end
        if a.matches(c, e, "PT_PLAYER_ENTERS_AREA") or a.matches(c, e, "PT_PLAYER_ENTERS_CHAMBER") then
            c:set_variable("prisonbreak.pending.security", true)
            preload_control_room(c, s)
            a.directive(c, s, "REPAIR_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7C693")
            return
        end
        if a.matches(c, e, "PT_PLAYER_OUTSIDE_CONTROL_ROOM")
            or a.matches(c, e, "PT_PLAYER_APPROACHING_CONTROL_ROOM")
            or a.matches(c, e, "PT_PLAYER_APPROACHING_WALKWAY") then
            preload_control_room(c, s)
            a.directive(c, s, "ENTER_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7C1FD")
            return
        end
        if a.matches(c, e, "PT_PLAYER_NEAR_PERFORMANCE") then
            if a.once(c, s, "control.exploder.scene") then
                local request = a.scene(c, "SCENE_EXPLODING_UNITS_1")
                c:set_variable("prisonbreak.control.exploder.request", request.value)
            end
            return
        end
        if a.matches(c, e, "PT_PLAYER_NEAR_CAYDE") then
            a.spawn(c, s, {"control_room_cayde"})
            a.directive(c, s, "RESCUE_CAYDE", "M_ENGAGEMENT_SENSOR_80F7C1FD", "SQUAD_CAYDE_1")
            return
        end
        if a.matches(c, e, "PT_INSIDE_CONTROL_ROOM") then
            c:set_variable("prisonbreak.pending.security", true)
            a.spawn(c, s, {"control_room_cayde"})
            a.directive(c, s, "REPAIR_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7C693")
            if a.once(c, s, "control.cayde.scene") then
                local request = a.scene(c, "SCENE_CONTROL_ROOM_CAYDE_1")
                c:set_variable("prisonbreak.control.cayde.request", request.value)
            end
            a.music(c, s, config.music and config.music.security)
            a.cue(c, s, "security_arrival")
        end
    end
    function S.scene_finished(c, s, e)
        local exploder_token = e.activation_token ~= nil
            and e.activation_token == tonumber(s:variable("prisonbreak.control.exploder.request"))
        if exploder_token or a.matches(c, e, "SCENE_EXPLODING_UNITS_1") then
            if not a.once(c, s, "control.exploder.scene.finished") then return end
            -- The authored performance owns the blast; only its completion
            -- releases the blocker and opens the hub approach door.
            a.object(c, "O_DOOR_BLOCKER", false)
            a.device(c, "D_DOOR", true)
            a.directive(c, s, "ENTER_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7C1FD")
            return
        end
        local cayde_token = e.activation_token ~= nil
            and e.activation_token == tonumber(s:variable("prisonbreak.control.cayde.request"))
        if cayde_token or a.matches(c, e, "SCENE_CONTROL_ROOM_CAYDE_1") then
            if not a.once(c, s, "control.cayde.scene.finished") then return end
            a.directive(c, s, "RESCUE_CAYDE", "M_ENGAGEMENT_SENSOR_80F7C1FD", "SQUAD_CAYDE_1")
        end
    end
    function S.cleared(c, s, name)
        a.reset_objective(c, s, name)
        if name == "turret_last" and a.clear(s, {"turret_entry", "turret_last"}) then
            a.device(c, "D_DOOR_1_80F7C9E4", true)
            a.device(c, "D_DOOR_0_80F7C9E4", true)
        end
        if (name == "security_hive" or name == "security_cabal") and a.clear(s, {"security_hive", "security_cabal"}) then
            if a.once(c, s, "security.console") then
                local generation = (s:variable("prisonbreak.security.console_generation") or 0) + 1
                c:set_variable("prisonbreak.security.console_generation", generation)
                a.slot(c, console):set_ghost_link{generation = generation, enabled = true}
            end
            a.device(c, "D_DOOR_0_80F7C95B", true)
            a.device(c, "D_DOOR_1_80F7C95B", true)
            -- This is the separate control-room entrance device on 80F7C1FD;
            -- opening only the two arena doors leaves the hub visually absent.
            a.device(c, "D_DOOR", true)
            a.object(c, "O_DOOR_BLOCKER", false)
            a.directive(c, s, "ENTER_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7C1FD")
        end
    end
    function S.ghost(c, s, e)
        if not s:variable("prisonbreak.once.security.console") then return end
        if not a.matches(c, e, console) or e.generation ~= s:variable("prisonbreak.security.console_generation")
            or e.active ~= false or e.progress == nil or e.progress < 1 then return end
        if not a.once(c, s, "security.door.open") then return end
        a.device(c, "D_DOOR_1_80F7C95B", true)
        a.slot(c, console):set_ghost_link{generation = e.generation + 1, enabled = false}
        a.directive(c, s, "REPAIR_THE_SECURITY_HUB", "M_ENGAGEMENT_SENSOR_80F7C693")
        c:set_variable("prisonbreak.pending.security", true)
        interlude.start(c, s)
    end
    function S.timer(c, s, e)
        if e.timer_name ~= "prisonbreak.control.reveal.fx" then return end
        stop_control_reveal(c)
    end
    function S.reset(c, s)
        for _, name in ipairs({"turret_entry", "turret_last", "hallway_chase", "train_runover",
            "cayde_bridge", "security_hive", "security_cabal",
            "control_room_exploders", "control_room_cayde"}) do
            if a.groups[name]:phase(s) ~= 0 then a.groups[name]:reset(c) end
        end
        local generation = (s:variable("prisonbreak.security.console_generation") or 0) + 1
        c:set_variable("prisonbreak.security.console_generation", generation)
        a.slot(c, console):set_ghost_link{generation = generation, enabled = false}
        for _, key in ipairs({"security.enter", "security.entry.door", "security.console", "security.door.open",
            "hallway.chase.scene", "train.runover.scene", "cayde.bridge.scene",
            "cayde.bridge.rocket.scene", "control.room.preload", "control.room.reveal", "control.cayde.scene",
            "control.exploder.scene.finished", "control.cayde.scene.finished",
            "dialogue.security_arrival"}) do c:clear_variable("prisonbreak.once." .. key) end
        c:clear_variable("prisonbreak.control.exploder.request")
        c:clear_variable("prisonbreak.control.cayde.request")
        c:clear_variable("prisonbreak.hallway.chase.request")
        c:clear_variable("prisonbreak.train.runover.request")
        c:clear_variable("prisonbreak.cayde.bridge.request")
        c:clear_variable("prisonbreak.cayde.bridge.rocket.request")
        c:cancel_timer("prisonbreak.control.reveal.fx")
        stop_control_reveal(c)
        c:clear_variable("prisonbreak.pending.security")
        a.device(c, "D_DOOR_1_80F7C95B", false)
        a.device(c, "D_DOOR_1_80F7C9E4", false)
        a.device(c, "D_DOOR_0_80F7C95B", false)
        a.device(c, "D_ALARM_LIGHTS_80F7C1FD", false)
        a.device(c, "D_ALARM_SOUNDS", false)
        S.enter(c, s)
    end
    return S
end
