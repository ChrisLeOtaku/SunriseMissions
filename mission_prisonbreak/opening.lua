-- Opening type-6 movie and the handoff to the first playable prison state.
return function(m, config, a, states)
    local entry = assert(m.states[config.entry])
    local movies = config.opening
    if movies and movies.state then movies = {movies} end
    for _, movie in ipairs(movies or {}) do
        movie.state_row = assert(m.states[movie.state])
        assert(m.slots[movie.slot].type == 6)
    end
    local O = {}
    if movies and #movies > 0 then O.initial_state = movies[1].state_row
    elseif not config.follow_selected_region then O.initial_state = entry end
    -- The main dispatcher applies the exact state kind gate.  Keep this flag
    -- as the opening movie's lifecycle flag so a cinematic termination can
    -- complete before the next state event settles.
    function O.playable(s) return s:variable("prisonbreak.opening") == 2 end
    local function select_entry(c, s)
        if s:variable("prisonbreak.opening.handoff_selected") then return false end
        local attempts = s:variable("prisonbreak.opening.handoff_attempts") or 0
        c:set_variable("prisonbreak.opening.handoff_attempts", attempts + 1)
        c:set_variable("prisonbreak.opening.handoff_selected", true)
        if config.entry_spawn_hash then
            c:select_state(entry, {spawn_set_hash = config.entry_spawn_hash})
        else
            c:select_state(entry)
        end
        return true
    end
    function O.client(c, s, e)
        local region = e.held_region_index or e.current_region_index
        if s:variable("prisonbreak.opening") == 3 then
            local held = e.held_region_index
            if held == entry.region_index then
                if select_entry(c, s) then
                    c:set_variable("prisonbreak.opening.handoff_source", "client")
                end
                if not s:variable("prisonbreak.opening.entry_seen") then
                    c:set_variable("prisonbreak.opening.entry_seen", true)
                    c:set_variable("prisonbreak.opening.entry_region", region)
                    c:start_timer("prisonbreak.opening.finish_entry", config.opening_finish_entry_delay_ms or 1500)
                end
            elseif held == s:variable("prisonbreak.opening.handoff_region") then
                -- Retain the cinematic region while the client is only
                -- reporting the handoff source region.  Selection waits for
                -- an actual held report for the playable destination.
            elseif s:variable("prisonbreak.opening.entry_seen") then
                c:clear_variable("prisonbreak.opening.entry_seen")
                c:clear_variable("prisonbreak.opening.entry_region")
            end
            return
        end
        if O.playable(s) then return end
        if s:variable("prisonbreak.opening") == 4 then return end
        -- Accept direct playable entry only when deliberately testing the
        -- bubble route. The normal mission must not treat an early/stale
        -- region-32 report as proof that CS1/CS2 completed.
        if region == entry.region_index and config.allow_direct_entry == true then
            c:set_variable("prisonbreak.opening", 2); c:set_phase(1)
            return
        end
        if not movies or #movies == 0 then
            local row = region and states.for_region(region)
            if row and row.kind == "gameplay" then
                c:set_variable("prisonbreak.opening", 2); c:set_phase(1)
            end
            return
        end
        for index, movie in ipairs(movies) do
            if region == movie.state_row.region_index
                and s:variable("prisonbreak.opening.active") ~= index then
                c:set_variable("prisonbreak.opening", 1)
                c:set_variable("prisonbreak.opening.index", index)
                c:set_variable("prisonbreak.opening.active", index)
                a.slot(c, movie.slot):set_cinematic_active{active = true}
                return
            end
        end
    end
    local function current(s)
        local index = s:variable("prisonbreak.opening.index") or 1
        return index, movies and movies[index]
    end
    local function handoff(c, s)
        c:set_variable("prisonbreak.opening", 3)
        c:set_variable("prisonbreak.opening.handoff_region", s:variable("prisonbreak.region") or 17)
        c:set_variable("prisonbreak.opening.handoff_selected", false)
        c:set_variable("prisonbreak.opening.handoff_attempts", 0)
        c:set_variable("prisonbreak.opening.handoff_source", "pending")
        c:clear_variable("prisonbreak.opening.entry_seen")
        c:clear_variable("prisonbreak.opening.entry_region")
        c:start_timer("prisonbreak.opening.select_entry", config.opening_select_entry_delay_ms or 250)
    end
    local function finish(c, s, movie)
        c:set_variable("prisonbreak.opening.active", 0)
        -- Match Ember's proven cinematic-to-play ordering: settle the script phase,
        -- stop the finished movie, then select the playable state in the same event.
        -- Do not defer this through a timer; that advertises the old cinematic host
        -- after the client has already begun its playable handoff.
        c:set_variable("prisonbreak.opening", 2)
        c:set_phase(1)
        a.slot(c, movie.slot):set_cinematic_active{active = false}
        select_entry(c, s)
        if config.arrival_cinematic then c:set_variable("prisonbreak.arrival.pending_request", true) end
    end
    local function advance(c, s, e, force)
        local index, movie = current(s)
        if not movie or (not force and s:variable("prisonbreak.opening") ~= 1) then return false end
        -- Some retail cinematic deliveries report the generated registry key
        -- instead of the authored slot key.  While this opening index is
        -- active, accept any type-6 termination/skip for the current movie.
        if not a.matches(c, e, movie.slot) then return false end
        local next_movie = movies[index + 1]
        if next_movie then
            c:set_variable("prisonbreak.opening.active", 0)
            c:set_variable("prisonbreak.opening.index", index + 1)
            -- Both opening movies use the same authored cutscene spawn context.
            if config.cutscene_spawn_hash then
                c:select_state(next_movie.state_row, {spawn_set_hash = config.cutscene_spawn_hash})
            else
                c:select_state(next_movie.state_row)
            end
        else
            finish(c, s, movie)
        end
        return true
    end
    function O.terminated(c, s, e) return advance(c, s, e) end
    function O.skipped(c, s, e) return advance(c, s, e) end
    function O.timer(c, s, e)
        if e.timer_name == "prisonbreak.opening.select_entry" and s:variable("prisonbreak.opening") == 3 then
            -- Start loading bubble 4, but keep the mission in handoff state
            -- until the client reports that destination as held.
            if select_entry(c, s) then c:set_variable("prisonbreak.opening.handoff_source", "timer") end
            return true
        end
        if e.timer_name == "prisonbreak.opening.finish_entry" and s:variable("prisonbreak.opening") == 3 then
            if s:variable("prisonbreak.opening.entry_seen") and s:variable("prisonbreak.opening.entry_region") == entry.region_index then
                c:set_variable("prisonbreak.opening", 4)
                c:clear_variable("prisonbreak.opening.entry_seen")
                c:start_timer("prisonbreak.opening.enable_playable", config.opening_playable_settle_ms or 3000)
            end
            return true
        end
        if e.timer_name == "prisonbreak.opening.enable_playable" and s:variable("prisonbreak.opening") == 4 then
            c:set_variable("prisonbreak.opening", 2); c:set_phase(1)
            if config.arrival_cinematic then c:set_variable("prisonbreak.arrival.pending_request", true) end
            return true
        end
        return false
    end
    function O.transport(c, s, e)
        return false
    end
    return O
end






