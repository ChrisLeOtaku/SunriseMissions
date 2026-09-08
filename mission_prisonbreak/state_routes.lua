-- Complete state map for scenario 80F7C018.
-- Keep this table explicit: region_index is the value delivered by the client
-- state event, while key is the generated SDK state identity.  A controller
-- must never infer a state from a bubble number alone.
return function(m)
    local rows = {
        {key = "STATE_80F7C018_0000_0000_80F7C00B", kind = "global", controller = nil},
        {key = "STATE_80F7C018_0001_0000_80F7C00C", kind = "cinematic", controller = "opening_stage"},
        {key = "STATE_80F7C018_0001_0001_80F7C00D", kind = "cinematic", controller = "opening_1"},
        {key = "STATE_80F7C018_0001_0002_80F7C00E", kind = "cinematic", controller = "cayde_death"},
        {key = "STATE_80F7C018_0001_0003_80F7C00F", kind = "cinematic", controller = "opening_2"},
        {key = "STATE_80F7C018_0002_0000_80F7C010", kind = "cinematic", controller = "opening_stage"},
        {key = "STATE_80F7C018_0002_0001_80F7C011", kind = "cinematic", controller = "cayde_petra_arrive_at_prison"},
        {key = "STATE_80F7C018_0003_0000_80F7C012", kind = "cinematic", controller = "arrival_stage"},
        {key = "STATE_80F7C018_0004_0000_80F7C013", kind = "gameplay", controller = "prison"},
        {key = "STATE_80F7C018_0005_0000_80F7C014", kind = "gameplay", controller = "supermax"},
        {key = "STATE_80F7C018_0005_0001_80F7C015", kind = "cinematic", controller = "unidentified_lower_1"},
        {key = "STATE_80F7C018_0005_0002_80F7C016", kind = "cinematic", controller = "unidentified_lower_2"},
        {key = "STATE_80F7C018_0006_0000_80F7C017", kind = "cinematic", controller = "epilogue_stage"},
    }
    local by_region, by_key = {}, {}
    for order, row in ipairs(rows) do
        local state = assert(m.states[row.key], "missing Prisonbreak state: " .. row.key)
        assert(by_region[state.region_index] == nil, "duplicate Prisonbreak region")
        row.state = state
        row.region = state.region_index
        row.order = order
        by_region[row.region] = row
        by_key[row.key] = row
    end
    local R = {rows = rows, by_region = by_region, by_key = by_key}
    function R.for_region(region) return by_region[region] end
    function R.for_key(key) return by_key[key] end
    function R.observe(c, s, e)
        local region = e.held_region_index or e.current_region_index
        if region == nil then return nil end
        local row = by_region[region]
        if not row then
            c:set_variable("prisonbreak.state.unknown_region", region)
            c:set_variable("prisonbreak.state.kind", "unknown")
            return nil
        end
        local previous = s:variable("prisonbreak.state")
        if previous and previous ~= row.key then
            local prior = by_key[previous]
            c:set_variable("prisonbreak.state.transition_from", previous)
            c:set_variable("prisonbreak.state.transition_valid", prior ~= nil and row.order == prior.order + 1)
        end
        c:set_variable("prisonbreak.region", row.region)
        c:set_variable("prisonbreak.state", row.key)
        c:set_variable("prisonbreak.state.kind", row.kind)
        c:set_variable("prisonbreak.state.slice_set", row.state.slice_set_index)
        c:set_variable("prisonbreak.state.ordinal", row.state.ordinal)
        c:set_variable("prisonbreak.state.seen." .. row.key, true)
        return row
    end
    function R.playable(s)
        return s:variable("prisonbreak.state.kind") == "gameplay"
    end
    return R
end
