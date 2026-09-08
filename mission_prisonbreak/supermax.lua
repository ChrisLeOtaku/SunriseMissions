-- Lower-prison encounter route. Trigger timings require a real traversal audit.
return function(m, config, a, ending)
    local S = {}
    local gates = {
        {"PT_START_ENCOUNTER", {"wretch_intro"}},
        {"PT_WRETCH_AMBUSH_START", {"wretch_ambush"}},
        {"PT_RIOT_AWARE", {"wretch_riot"}},
        {"PT_RIOT_FINAL_WRETCH", {"wretch_final"}},
        {"PT_SPAWN_LOOTERS", {"looters"}},
        {"PT_VANDAL_CATWALK_START", {"catwalk"}},
        {"PT_VANDAL_INTRO_1", {"vandal_1"}},
        {"PT_VANDAL_WAVE_2", {"vandal_2"}},
        {"PT_VANDAL_WAVE_3", {"vandal_3"}},
        {"PT_CRAWLER_FLOOD_INITIAL_SPAWN", {"crawlers"}},
        {"PT_CRAWLER_FLOOD_REINFORCE", {"crawler_final"}},
    }
    function S.enter(c, s)
        if not a.once(c, s, "supermax.enter") then return end
        local triggers = {"PT_OPEN_ENTRANCE_DOOR_80F7CEF9", "PT_OPEN_EXIT_DOOR",
            "PT_OPEN_DOOR_TO_VANDALS", "PT_ARENA_START"}
        for _, row in ipairs(gates) do triggers[#triggers + 1] = row[1] end
        a.arm(c, triggers)
        a.directive(c, s, "RESCUE_CAYDE", "M_ENGAGEMENT_SENSOR_80F7D1B2", "NP_CAYDE_80F7D1F9")
        a.cue(c, s, "rescue_cayde")
        a.music(c, s, config.music and config.music.supermax)
    end
    function S.trigger(c, s, e)
        for _, row in ipairs(gates) do
            if a.matches(c, e, row[1]) then a.spawn(c, s, row[2]); return end
        end
        if a.matches(c, e, "PT_OPEN_ENTRANCE_DOOR_80F7CEF9") and a.once(c, s, "supermax.door.entry") then
            a.device(c, "D_ENTRANCE_DOOR", true)
        elseif a.matches(c, e, "PT_OPEN_EXIT_DOOR") and a.clear(s, {"wretch_riot", "wretch_final"}) then
            a.device(c, "D_EXIT_DOOR", true)
        elseif a.matches(c, e, "PT_OPEN_DOOR_TO_VANDALS") and a.once(c, s, "supermax.door.vandals") then
            a.device(c, "D_DOOR_TO_VANDALS_1", true)
        elseif a.matches(c, e, "PT_ARENA_START") and a.once(c, s, "boss.start") then
            a.spawn(c, s, {"boss", "boss_support"})
            a.directive(c, s, "DEFEAT_THE_ABOMINATION", "M_ENGAGEMENT_SENSOR_80F7D1B2")
            a.cue(c, s, "abomination")
        end
    end
    function S.cleared(c, s, name)
        a.reset_objective(c, s, name)
        if (name == "wretch_riot" or name == "wretch_final") and a.clear(s, {"wretch_riot", "wretch_final"}) then
            a.device(c, "D_EXIT_DOOR", true)
        elseif name == "boss" then
            c:set_variable("prisonbreak.boss.defeated", true)
            a.slot(c, "O_DOOR_INTERACT"):set_interactable_object{generation = 1}
            a.directive(c, s, "RESCUE_CAYDE_88B092F5", "M_ENGAGEMENT_SENSOR_80F7D1B2", "NP_BARON_EXIT_CONSOLE")
        end
    end
    function S.interaction(c, s, e)
        if s:variable("prisonbreak.boss.defeated") and a.matches(c, e, "O_DOOR_INTERACT") then
            ending.start(c, s)
        end
    end
    return S
end
