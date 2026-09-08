-- One encounter's progress lives in transactional mission state, never module-local tables.
local AI = require("mission_prisonbreak.combat_ai")
local Encounter = {}
Encounter.__index = Encounter

function Encounter.new(tag, squads, cleared, reserved, options)
    assert(#squads > 0 and #squads <= 30, "encounter needs 1..30 squads")
    local required = 0
    for _, name in ipairs(options and options.required or {}) do
        local found = false
        for index, squad in ipairs(squads) do
            if squad.name == name then required = required | (1 << (index - 1)); found = true; break end
        end
        assert(found, "required encounter squad is absent: " .. name)
    end
    return setmetatable({tag = tag, squads = squads, cleared = cleared,
                         full = (1 << #squads) - 1, required = required,
                         required_only = options and options.required_only == true,
                         reserved = reserved or false}, Encounter)
end

function Encounter:phase(state)
    return state:variable(self.tag .. ".phase") or 0
end

function Encounter:enter(context, state)
    if self:phase(state) ~= 0 then
        return false
    end
    -- Resolve everything before staging the first placement. Missing SDK rows are errors.
    local handles = {}
    for index, squad in ipairs(self.squads) do
        handles[index] = context:squad(squad.id)
        local count = 0
        for _, value in ipairs(handles[index].default_counts) do
            assert(value >= 0, "squad has unresolved authored counts: " .. squad.name)
            count = count + value
        end
        assert(count > 0, "encounter squad has no authored members: " .. squad.name)
    end
    context:set_variable(self.tag .. ".seen", 0)
    context:set_variable(self.tag .. ".alive", 0)
    context:set_variable(self.tag .. ".phase", 1)
    for index, handle in ipairs(handles) do
        handle:place{mode = self.reserved and context.sdk.squad_modes.reserve or context.sdk.squad_modes.replace}
        local squad = self.squads[index]
        if squad.objective then
            AI.assign(context, squad.sensor, squad.objective, squad.fixed_task or -1, self.reserved)
            local word = (index - 1) // 12
            if (index - 1) % 12 == 0 then context:set_variable(self.tag .. ".ai." .. word, 0) end
        end
    end
    return true
end

function Encounter:on_squad_state(context, state, event)
    if self:phase(state) ~= 1 then
        return
    end
    local bit, matched
    for index, squad in ipairs(self.squads) do
        local slot = context:slot(squad.sensor)
        if event.registry_key == slot.registry_key and event.slot_type == slot.slot_type
            and event.slot_index == slot.slot_index then
            bit = 1 << (index - 1)
            matched = squad
            if squad.objective and squad.fixed_task == nil then
                AI.update(context, state, self.tag .. ".ai." .. ((index - 1) // 12),
                          squad.sensor, squad.objective, 24, event, (index - 1) % 12 + 1, self.reserved)
            end
            break
        end
    end
    if bit == nil or event.alive_count == nil then
        return
    end
    local seen = state:variable(self.tag .. ".seen") or 0
    local alive = state:variable(self.tag .. ".alive") or 0
    -- Native A9CAA0/4E5C80 publish root ordinal 8 from the squad's state flags.
    -- It is also set on real deaths; it does not identify a squad unload.
    -- Require evidence of a population or a fully consumed authored slot before
    -- accepting a zero count.  A death receipt is also sufficient: the native
    -- squad surface may omit slot_counts on an entity-died update.
    local death_receipt = event.alive_count == 0 and (event.previous_alive_count or 0) > 0
    if event.alive_count > 0 or (event.previous_alive_count or 0) > 0 then
        seen = seen | bit
    end
    -- Sense .11 counts consumed requests (native 4E8660/4E8200), not births.
    -- Zero living actors while requests remain is an incomplete placement, not
    -- a cleared wave. Keep that squad outstanding until every authored slot is
    -- accounted for, including waves whose members arrive over several frames.
    -- A removal edge is the native terminal publication for actors that are
    -- retired by a checkpoint/scene rather than killed one by one.  It carries
    -- no consumed-count list, so treating it like an incomplete placement
    -- strands the objective at zero alive forever.
    local accounted = death_receipt or event.removal_flag == true or event.slot_counts ~= nil
    if not death_receipt then
        for index, requested in ipairs(context:squad(matched.id).default_counts) do
            if not event.slot_counts or (event.slot_counts[index] or -1) < requested then
                accounted = false
            end
        end
    end
    if event.alive_count > 0 or not accounted then
        alive = alive | bit
    else
        alive = alive & ~bit
    end
    context:set_variable(self.tag .. ".seen", seen)
    context:set_variable(self.tag .. ".alive", alive)
    -- Some authored riot rows are conditional spawn-rule alternatives. Once
    -- the faction boss has appeared, an empty set of all observed squads is a
    -- real clear even if an unused alternative never published a population.
    local required_seen = self.required ~= 0 and (seen & self.required) == self.required
    local required_clear = self.required_only and required_seen and (alive & self.required) == 0
    if (alive == 0 and (seen == self.full or required_seen)) or required_clear then
        context:set_variable(self.tag .. ".phase", 2)
        -- Retire the native requested counts as well as the Lua encounter. The host
        -- republishes retained Auth when regions return; a completed wave must retain
        -- zero requests, not its original spawn composition.
        for _, squad in ipairs(self.squads) do
            local handle = context:squad(squad.id)
            local counts = handle:counts()
            for index = 1, #handle.default_counts do counts:set(index, 0) end
            handle:place{counts = counts,
                mode = self.reserved and context.sdk.squad_modes.reserve or context.sdk.squad_modes.replace}
        end
        self.cleared(context, state)
    end
end

-- Called only by a confirmed checkpoint reset, not by region transit or script reload.
function Encounter:reset(context)
    for _, squad in ipairs(self.squads) do
        local handle = context:squad(squad.id)
        local counts = handle:counts()
        for index = 1, #handle.default_counts do counts:set(index, 0) end
        handle:place{counts = counts,
            mode = self.reserved and context.sdk.squad_modes.reserve or context.sdk.squad_modes.replace}
    end
    context:clear_variable(self.tag .. ".phase")
    context:clear_variable(self.tag .. ".seen")
    context:clear_variable(self.tag .. ".alive")
end

return Encounter

