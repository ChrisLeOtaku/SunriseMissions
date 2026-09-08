-- Owns the mid-mission security-hub cinematic and its lower-prison handoff.
return function(m, config, a)
    local I = {}
    local movies = {}
    for _, key in ipairs(assert(config.security_cinematics)) do
        local movie = assert(config.story_cinematics[key], key)
        movie.state_row = assert(m.states[movie.state], movie.state)
        assert(m.slots[movie.slot] and m.slots[movie.slot].type == 6, movie.slot)
        movies[#movies + 1] = movie
    end
    local lower_state = assert(m.states[config.lower], config.lower)

    local function current(s)
        local index = s:variable("prisonbreak.interlude.index") or 1
        return index, movies[index]
    end

    local function finish(c, s)
        if s:variable("prisonbreak.interlude.finished") then return end
        c:set_variable("prisonbreak.interlude.finished", true)
        c:set_variable("prisonbreak.interlude.active", false)
        c:set_variable("prisonbreak.interlude.playing", false)
        c:set_variable("prisonbreak.interlude.index", #movies + 1)
        c:set_variable("prisonbreak.pending.security", false)
        c:clear_variable("prisonbreak.music")
        c:select_state(lower_state)
        c:set_phase(2)
    end
    local function select_movie(c, s, index)
        local movie = movies[index]
        if not movie then finish(c, s); return end
        c:set_variable("prisonbreak.interlude.index", index)
        c:set_variable("prisonbreak.interlude.playing", false)
        if config.cutscene_spawn_hash then
            c:select_state(movie.state_row, {spawn_set_hash = config.cutscene_spawn_hash})
        else
            c:select_state(movie.state_row)
        end
    end

    function I.active(s) return s:variable("prisonbreak.interlude.active") == true end
    function I.start(c, s)
        if I.active(s) or s:variable("prisonbreak.interlude.finished") then return end
        c:set_variable("prisonbreak.interlude.active", true)
        select_movie(c, s, 1)
    end
    function I.client(c, s, e)
        if not I.active(s) or s:variable("prisonbreak.interlude.playing") then return end
        local _, movie = current(s)
        if not movie or (e.held_region_index or e.current_region_index) ~= movie.state_row.region_index then return end
        c:set_variable("prisonbreak.interlude.playing", true)
        a.slot(c, movie.slot):set_cinematic_active{active = true}
    end
    local function advance(c, s, e)
        local index, movie = current(s)
        if not I.active(s) or not s:variable("prisonbreak.interlude.playing")
            or not movie or not a.matches(c, e, movie.slot) then return false end
        if index < #movies then select_movie(c, s, index + 1)
        else finish(c, s) end
        return true
    end
    function I.terminated(c, s, e) return advance(c, s, e) end
    function I.skipped(c, s, e)
        return advance(c, s, e)
    end
    return I
end

