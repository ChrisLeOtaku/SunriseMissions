local Encounter = require("mission_prisonbreak.encounter")
local roster = require("mission_prisonbreak.roster")
return function(m, config, cleared)
    local A = {groups = {}, roster = {}, objectives = {}}
    for _, row in ipairs(roster) do
        A.roster[#A.roster + 1] = row
        A.objectives[row.name] = row.objective
        local members = {}
        for _, name in ipairs(row.squads) do
            assert(m.slots[name] and m.slots[name].type == 1, "not a squad sensor: " .. name)
            members[#members + 1] = {name = name, id = assert(m.Squad[name], name),
                sensor = assert(m.Slot[name], name),
                objective = row.objective and assert(m.Slot[row.objective], row.objective) or nil}
        end
        A.groups[row.name] = Encounter.new("prisonbreak.enc." .. row.name, members,
            function(c, s) cleared(c, s, row.name) end, row.reserved,
            {required = row.required, required_only = row.required_only})
    end
    function A.slot(c, name) return c:slot(assert(m.Slot[name], "missing Prisonbreak slot: " .. name)) end
    function A.matches(c, e, name)
        local slot = A.slot(c, name)
        return e.registry_key == slot.registry_key and e.slot_type == slot.slot_type and e.slot_index == slot.slot_index
    end
    function A.once(c, s, key)
        key = "prisonbreak.once." .. key
        if s:variable(key) then return false end
        c:set_variable(key, true); return true
    end
    function A.spawn(c, s, names)
        for _, name in ipairs(names) do assert(A.groups[name], name):enter(c, s) end
    end
    function A.clear(s, names)
        for _, name in ipairs(names) do if A.groups[name]:phase(s) ~= 2 then return false end end
        return true
    end
    function A.reset_objective(c, s, name)
        local objective = A.objectives[name] or name
        if not objective or not m.Slot[objective] then return end
        if not A.once(c, s, "objective." .. name) then return end
        A.slot(c, objective):reset_objectives{}
    end
    function A.squad(c, s, e)
        -- Only inspect active groups. Unloaded regions cannot clear another region's combat.
        for _, row in ipairs(roster) do
            if s:variable("prisonbreak.region") == row.region then
                A.groups[row.name]:on_squad_state(c, s, e)
            end
        end
    end
    function A.arm(c, names)
        for _, name in ipairs(names) do
            assert(m.slots[name] and m.slots[name].type == 31, "not a player trigger: " .. name)
            A.slot(c, name):fire_trigger{}
        end
    end
    function A.device(c, name, open)
        local slot = A.slot(c, name)
        slot:transition{transition = c.sdk.device_transitions.unlock}
        slot:transition{transition = c.sdk.device_transitions.power_on}
        slot:transition{transition = open and c.sdk.device_transitions.open or c.sdk.device_transitions.close}
    end
    function A.object(c, name, active)
        A.slot(c, name):set_object_active{active = active}
    end
    function A.scene(c, name)
        local scene = assert(m.Scene[name], "missing Prisonbreak scene: " .. name)
        return c:scene(scene):activate{}
    end
    function A.music(c, s, section, force)
        if section == nil or (not force and s:variable("prisonbreak.music") == section) then return end
        A.slot(c, "M_MUSIC_SENSOR_80F7D261"):set_music_section{
            section = section, enabled = section >= 0}
        c:set_variable("prisonbreak.music", section)
    end
    function A.checkpoint(c, s, row, name)
        if not row then return end
        if s:variable("prisonbreak.checkpoint.hash") == row.hash then return end
        c:set_variable("prisonbreak.checkpoint.region", row.region)
        c:set_variable("prisonbreak.checkpoint.hash", row.hash)
        c:set_variable("prisonbreak.checkpoint.name", name)
        -- Enable before a death: otherwise the client takes its normal default respawn.
        A.darkness(c, s, row.region == s:variable("prisonbreak.region"))
    end
    function A.darkness(c, s, enabled)
        if s:variable("prisonbreak.darkness.enabled") == enabled then return end
        A.slot(c, "HARD_WIPE_GLOBALS"):set_darkness_zone{enabled = enabled}
        c:set_variable("prisonbreak.darkness.enabled", enabled)
    end
    function A.directive(c, s, name, audience, marker)
        local signature = name .. ":" .. (marker or "")
        if s:variable("prisonbreak.hud") == signature then return end
        local target = A.slot(c, audience)
        target:set_engagement_state{flags = 0, revision = 1}
        A.slot(c, "M_DIRECTIVE_SENSOR_80F7D261"):set_directive{
            directive = assert(m.Directive[name], name), audience = target,
            navpoint = marker and A.slot(c, marker) or nil}
        c:set_variable("prisonbreak.hud", signature)
    end
    function A.cue(c, s, name)
        local index = config.dialogue[name]
        if index == nil or not A.once(c, s, "dialogue." .. name) then return end
        A.slot(c, "M_DIALOG_SENSOR_80F7D261"):play_dialogue_cue{
            cue = assert(m.DialogueCue.M_DIALOG_SENSOR_80F7D261["CUE_" .. index])}
    end
    return A
end
