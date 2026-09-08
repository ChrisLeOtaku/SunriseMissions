-- Bounded state fields visible in Sunrise's mission script overlay. No file I/O.
return function(m)
    return function(c, s, kind, e)
        c:set_variable("prisonbreak.debug.event", kind)
        if e.held_region_index ~= nil or e.current_region_index ~= nil then
            c:set_variable("prisonbreak.debug.region", e.held_region_index or e.current_region_index)
            c:set_variable("prisonbreak.debug.state", s:variable("prisonbreak.state") or "unknown")
            c:set_variable("prisonbreak.debug.state_kind", s:variable("prisonbreak.state.kind") or "unknown")
        end
        if e.registry_key ~= nil then
            c:set_variable("prisonbreak.debug.registry", e.registry_key)
            c:set_variable("prisonbreak.debug.slot_type", e.slot_type or -1)
            c:set_variable("prisonbreak.debug.slot_index", e.slot_index or -1)
        end
        if kind == "squad" then
            if e.alive_count ~= nil then c:set_variable("prisonbreak.debug.alive", e.alive_count) end
            if e.objective_revision ~= nil then c:set_variable("prisonbreak.debug.objective_revision", e.objective_revision) end
            if e.task_costs ~= nil then
                local count = 0
                for i = 1, 24 do if e.task_costs[i] ~= nil then count = count + 1 end end
                c:set_variable("prisonbreak.debug.task_group_count", count)
            end
        end
        if kind == "effect" and e.outcome ~= "transport_staged" then
            c:set_variable("prisonbreak.debug.effect", e.outcome or "unknown")
            c:set_variable("prisonbreak.debug.effect_action", e.effect or "unknown")
            if e.request_key then c:set_variable("prisonbreak.debug.effect_request", e.request_key.value) end
        end
    end
end
