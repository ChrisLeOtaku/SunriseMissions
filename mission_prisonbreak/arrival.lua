-- Optional post-load opening movie probe. It plays only after region 32 has
-- loaded so a candidate cinematic does not chain directly from the cold-open state.
return function(m, config, a)
    local A = {}
    local movie_key = config.arrival_cinematic or "prison_arrival"
    local movie = config.story_cinematics and config.story_cinematics[movie_key]
    local entry = assert(m.states[config.entry], config.entry)
    if movie then
        movie.state_row = assert(m.states[movie.state], movie.state)
        assert(m.slots[movie.slot] and m.slots[movie.slot].type == 6, movie.slot)
    end

    function A.pending(s)
        return movie ~= nil and s:variable("prisonbreak.arrival.pending") == true
    end
    function A.playable(s)
        return not A.pending(s)
    end
    function A.arm(c, s)
        if not movie or s:variable("prisonbreak.arrival.finished") then return end
        c:set_variable("prisonbreak.arrival.pending", true)
        c:set_variable("prisonbreak.arrival.playing", false)
    end
    function A.client(c, s, e)
        if not A.pending(s) or s:variable("prisonbreak.arrival.playing") then return end
        local region = e.held_region_index or e.current_region_index
        if region ~= entry.region_index then return end
        c:set_variable("prisonbreak.arrival.playing", true)
        if config.cutscene_spawn_hash then
            c:select_state(movie.state_row, {spawn_set_hash = config.cutscene_spawn_hash})
        else
            c:select_state(movie.state_row)
        end
    end
    function A.cinematic_client(c, s, e)
        if not A.pending(s) or not s:variable("prisonbreak.arrival.playing")
            or s:variable("prisonbreak.arrival.active") then return end
        local region = e.held_region_index or e.current_region_index
        if region ~= movie.state_row.region_index then return end
        c:set_variable("prisonbreak.arrival.active", true)
        a.slot(c, movie.slot):set_cinematic_active{active = true}
    end
    local function finish(c, s)
        if s:variable("prisonbreak.arrival.finished") then return end
        c:set_variable("prisonbreak.arrival.finished", true)
        c:set_variable("prisonbreak.arrival.pending", false)
        c:set_variable("prisonbreak.arrival.playing", false)
        c:set_variable("prisonbreak.arrival.active", false)
        if config.entry_spawn_set_hash then
            c:select_state(entry, {spawn_set_hash = config.entry_spawn_set_hash})
        else
            c:select_state(entry)
        end
        c:set_phase(1)
    end
    function A.terminated(c, s, e)
        if not A.pending(s) or not s:variable("prisonbreak.arrival.active")
            or not a.matches(c, e, movie.slot) then return end
        finish(c, s)
        return true
    end
    function A.skipped(c, s, e)
        if not A.pending(s) or not a.matches(c, e, movie.slot) then return false end
        finish(c, s)
        return true
    end
    return A
end

