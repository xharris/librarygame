local M = {}
local xd = require('engine')

---@class timer : entity
---@field timerT number
---@field timerFn fun()

---@type timer[]
local timers = {}

xd.sys.add(function (dt, entity)
    ---@cast entity timer
    if entity.timerT then
        if entity.timerT > 0 then
            entity.timerT = entity.timerT - (dt * 1000)
        end
        if entity.timerT <= 0 then
            entity.timerT = nil
            entity.timerFn()
            xd.ent.destroy(entity)
        end
    end
end)

---@param sec number Seconds to wait
---@param fn fun() Function to call
function M.after(sec, fn)
    local timer = xd.ent.new{ timerT=sec*1000, timerFn=fn }
    table.insert(timers, timer)
    return timer
end

return M