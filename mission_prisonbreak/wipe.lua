-- Earned, same-region checkpoint only; native all-dead membership handshake.
return function(m, config, reset)
    local W = {}
    local function stage(s) return s:variable("prisonbreak.wipe.stage") or 0 end
    local function checkpoint(s)
        local region, hash = s:variable("prisonbreak.checkpoint.region"), s:variable("prisonbreak.checkpoint.hash")
        if region == s:variable("prisonbreak.region") and hash and hash ~= 0 then return region, hash end
    end
    local function timer(s)
        return "prisonbreak.wipe." .. (s:variable("prisonbreak.wipe.cycle") or 0)
    end
    local function darkness(c, enabled, seconds)
        c:slot(assert(m.Slot.HARD_WIPE_GLOBALS)):set_darkness_zone{enabled = enabled, wipe_seconds = seconds}
    end
    local function cancel(c, s, failed)
        c:cancel_timer(timer(s))
        for _, key in ipairs({"stage", "seconds", "request", "release", "region", "hash"}) do
            c:clear_variable("prisonbreak.wipe." .. key)
        end
        if failed then
            c:set_variable("prisonbreak.wipe.failed", true)
            c:set_variable("prisonbreak.darkness.enabled", false)
        end
        darkness(c, checkpoint(s) ~= nil and s:variable("prisonbreak.darkness.enabled") == true)
    end
    function W.active(s) return stage(s) >= 2 end
    function W.fireteam(c, s, e)
        if s:variable("prisonbreak.ending") or stage(s) >= 2 then return end
        local all_dead = e.dead_count ~= nil and e.dead_count > 0 and e.alive_count == 0 and e.unknown_count == 0
        c:set_variable("prisonbreak.wipe.all_dead", all_dead)
        if not all_dead or not checkpoint(s) or s:variable("prisonbreak.darkness.enabled") ~= true then
            if stage(s) == 1 then cancel(c, s) end
            return
        end
        if stage(s) == 0 then
            c:set_variable("prisonbreak.wipe.cycle", (s:variable("prisonbreak.wipe.cycle") or 0) + 1)
            c:set_variable("prisonbreak.wipe.stage", 1)
            c:set_variable("prisonbreak.wipe.seconds", 3)
            darkness(c, true, 3)
            c:start_timer(timer(s), 1000)
        end
    end
    function W.timer(c, s, e)
        if e.timer_name ~= timer(s) then return false end
        if stage(s) ~= 1 then return true end
        local region, hash = checkpoint(s)
        if not region or not s:variable("prisonbreak.wipe.all_dead")
            or s:variable("prisonbreak.darkness.enabled") ~= true then cancel(c, s); return true end
        local seconds = s:variable("prisonbreak.wipe.seconds") - 1
        c:set_variable("prisonbreak.wipe.seconds", seconds)
        darkness(c, true, seconds)
        if seconds > 0 then c:start_timer(timer(s), 1000); return true end
        c:set_variable("prisonbreak.wipe.region", region)
        c:set_variable("prisonbreak.wipe.hash", hash)
        c:set_variable("prisonbreak.wipe.stage", 2)
        c:set_variable("prisonbreak.wipe.request", (c:restart_checkpoint{region = region, spawn_set_hash = hash}).value)
        return true
    end
    function W.client_state(c, s, e)
        if stage(s) == 1 and not checkpoint(s) then cancel(c, s); return end
        if stage(s) < 2 or e.spawn_state == nil then return end
        if stage(s) == 2 and e.spawn_state >= 2 then
            reset(c, s)
            c:set_variable("prisonbreak.wipe.stage", 3)
            c:set_variable("prisonbreak.wipe.release", (c:restart_checkpoint{
                region = s:variable("prisonbreak.wipe.region"), spawn_set_hash = s:variable("prisonbreak.wipe.hash"),
                release_request = s:variable("prisonbreak.wipe.request")}).value)
        elseif stage(s) == 3 and e.spawn_state == 0 then
            cancel(c, s)
        end
    end
    function W.effect(c, s, e)
        local request = e.request_key and e.request_key.value
        if request and (request == s:variable("prisonbreak.wipe.request") or request == s:variable("prisonbreak.wipe.release"))
            and e.outcome ~= "transport_staged" then cancel(c, s, true) end
    end
    return W
end
