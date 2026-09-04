-- Shared helpers. The sandbox has no pairs, next, string.match or math.random.
local lib = {}

-- A nil constant would end an ipairs list early and hide the missing name.
function lib.one(value, name)
    assert(value ~= nil, "missing mission constant: " .. name)
    return value
end

function lib.list(...)
    local values = {...}
    for index = 1, select("#", ...) do
        assert(values[index] ~= nil, "mission list entry " .. index .. " is missing")
    end
    return values
end

-- One shared key space: 64 variables, 32 timers, 63 bytes a key. Keep tags short.
local Scope = {}
Scope.__index = Scope

function Scope:key(name)
    return self.tag .. "." .. name
end

function Scope:variable(name)
    return self.state:variable(self:key(name))
end

function Scope:set_variable(name, value)
    self.context:set_variable(self:key(name), value)
end

function Scope:clear_variable(name)
    return self.context:clear_variable(self:key(name))
end

function Scope:start_timer(name, milliseconds)
    return self.context:start_timer(self:key(name), milliseconds)
end

function Scope:cancel_timer(name)
    return self.context:cancel_timer(self:key(name))
end

function lib.scope(context, state, tag)
    assert(type(tag) == "string" and #tag > 0, "a scope needs a tag")
    return setmetatable({context = context, state = state, tag = tag}, Scope)
end

--- @return The unprefixed timer name when this tag owns it, otherwise nil.
function lib.timer_name(tag, elapsed)
    if type(elapsed) ~= "string" then
        return nil
    end
    local head = tag .. "."
    if string.sub(elapsed, 1, #head) ~= head then
        return nil
    end
    return string.sub(elapsed, #head + 1)
end

--- @return True when the event names this slot.
function lib.is_slot(context, event, slot)
    local target = context:slot(slot)
    return event.registry_key == target.registry_key
        and event.slot_type == target.slot_type
        and event.slot_index == target.slot_index
end

--- @return True when the event is this trigger firing on this volume.
function lib.is_trigger(context, event, slot, volume)
    return lib.is_slot(context, event, slot)
        and event.volume_registry_key == volume.registry_key
        and event.volume_slot_type == volume.slot_type
        and event.volume_slot_index == volume.slot_index
end

function lib.place_all(context, squads, mode)
    for _, squad in ipairs(squads) do
        context:squad(squad):place{mode = mode}
    end
end

function lib.activate_scenes(context, scenes)
    for _, scene in ipairs(scenes) do
        context:scene(scene):activate{}
    end
end

-- A sensor holds one state. Its object must be active first.
function lib.play_idles(context, idles)
    for _, idle in ipairs(idles) do
        context:slot(idle.sensor):play_performance{state = idle.state}
    end
end

-- The host takes one head row plus 63 more.
local OBJECT_RUN = 64

-- A run may not mix objects. One tag is one group.
local SLOT_PREFIX = "slot/"
local TAG_FIRST = #SLOT_PREFIX + 1
local TAG_LAST = TAG_FIRST + 7

local function object_tag(slot)
    if string.sub(slot, 1, #SLOT_PREFIX) ~= SLOT_PREFIX then
        return slot
    end
    return string.sub(slot, TAG_FIRST, TAG_LAST)
end

-- First-appearance order keeps the authored lists readable.
local function group_by_tag(slots)
    local order, by_tag = {}, {}
    for _, slot in ipairs(slots) do
        local tag = object_tag(slot)
        local group = by_tag[tag]
        if group == nil then
            group = {}
            by_tag[tag] = group
            order[#order + 1] = group
        end
        group[#group + 1] = slot
    end
    return order
end

function lib.activate_objects(context, slots)
    for _, group in ipairs(group_by_tag(slots)) do
        local index = 1
        while index <= #group do
            local last = math.min(index + OBJECT_RUN - 1, #group)
            local with = {}
            for member = index + 1, last do
                with[#with + 1] = group[member]
            end
            context:slot(group[index]):set_object_active{active = true, with = with}
            index = last + 1
        end
    end
end

return lib
