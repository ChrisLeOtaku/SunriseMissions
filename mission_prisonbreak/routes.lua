return function(m, config)
    local controllers = {}
    local a = require("mission_prisonbreak.support")(m, config, function(c, s, name)
        local active = controllers[s:variable("prisonbreak.region")]
        if active then for _, controller in ipairs(active) do controller.cleared(c, s, name) end end
    end)
    local ending = require("mission_prisonbreak.ending")(m, config, a)
    local interlude = require("mission_prisonbreak.interlude")(m, config, a)
    local wipe = require("mission_prisonbreak.wipe")(m, config, function(c, s)
        assert(s:variable("prisonbreak.checkpoint.name") == "riot_quell", "checkpoint reset is not mapped")
        for _, controller in ipairs(controllers[32]) do controller.reset(c, s) end
    end)
    controllers[32] = {require("mission_prisonbreak.prison")(m, config, a), require("mission_prisonbreak.security")(m, config, a, interlude)}
    controllers[40] = {require("mission_prisonbreak.supermax")(m, config, a, ending)}
    local R = {support = a, ending = ending, interlude = interlude}
    function R.client(c, s, e)
        if wipe.active(s) then return end
        if ending.active(s) then ending.client(c, s, e); return end
        a.darkness(c, s, s:variable("prisonbreak.checkpoint.region") == s:variable("prisonbreak.region")
            and s:variable("prisonbreak.checkpoint.hash") ~= nil and not s:variable("prisonbreak.wipe.failed"))
        local active = controllers[s:variable("prisonbreak.region")]
        if not active then return end
        for _, controller in ipairs(active) do controller.enter(c, s) end
    end
    function R.client_state(c, s, e) wipe.client_state(c, s, e) end
    function R.fireteam(c, s, e) wipe.fireteam(c, s, e) end
    function R.timer(c, s, e)
        if wipe.timer(c, s, e) then return end
        R.dispatch("timer", c, s, e)
    end
    function R.effect(c, s, e)
        wipe.effect(c, s, e)
        R.dispatch("effect", c, s, e)
    end
    function R.dispatch(method, c, s, e)
        if ending.active(s) or wipe.active(s) then return end
        local active = controllers[s:variable("prisonbreak.region")]
        if active then
            for _, controller in ipairs(active) do if controller[method] then controller[method](c, s, e) end end
        end
    end
    function R.squad(c, s, e) if not ending.active(s) and not wipe.active(s) then a.squad(c, s, e) end end
    return R
end
