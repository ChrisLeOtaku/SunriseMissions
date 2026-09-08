-- No Ember movie indices: its native prerendered bridge is mission-specific.
return function(m, config, a)
    local E = {}
    for _, row in ipairs(config.ending) do
        assert(m.states[row.state], row.state); assert(m.slots[row.slot].type == 6, row.slot)
    end
    local function select(c, index)
        c:set_variable("prisonbreak.ending", index)
        c:clear_variable("prisonbreak.ending.playing")
        local row = config.ending[index]
        if config.cutscene_spawn_hash then
            c:select_state(m.states[row.state], {spawn_set_hash = config.cutscene_spawn_hash})
        else
            c:select_state(m.states[row.state])
        end
    end
    function E.active(s) return s:variable("prisonbreak.ending") ~= nil end
    function E.start(c, s)
        if E.active(s) then return end
        if #config.ending == 0 then
            c:set_variable("prisonbreak.pending.ending", true)
            return -- Keep gameplay loaded until the actual movie sequence is known.
        end
        select(c, 1)
    end
    function E.client(c, s, e)
        local index = s:variable("prisonbreak.ending")
        local row = index and config.ending[index]
        if not row or s:variable("prisonbreak.ending.playing") then return end
        if (e.held_region_index or e.current_region_index) ~= m.states[row.state].region_index then return end
        c:set_variable("prisonbreak.ending.playing", true)
        a.slot(c, row.slot):set_cinematic_active{active = true}
    end
    function E.terminated(c, s, e)
        local index = s:variable("prisonbreak.ending")
        local row = index and config.ending[index]
        if not row or not s:variable("prisonbreak.ending.playing") or not a.matches(c, e, row.slot) then return false end
        -- Commit the next stage before stopping to make repeated terminal events inert.
        if index < #config.ending then select(c, index + 1)
        else
            c:set_variable("prisonbreak.ending", index + 1)
            c:set_variable("prisonbreak.ending.finished", true)
            -- Completion policy remains an explicit integration task until verified.
            c:set_variable("prisonbreak.pending.completion", true)
        end
        return true
    end
    return E
end

