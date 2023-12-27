local M = {}

local xd = require('engine')

---@generic I
---@param t I[]
---@param fn fun(item:I):string|number
---@return I? 
function M.tableMax(t, fn)
    local maxValue
    local maxItem
    local value
    xd.lume.each(t, function(item)
        value = fn(item)
        if not maxItem or value > maxValue then
            maxItem = item
            maxValue = value
        end
    end)
    return maxItem
end

function M.addToSet(t, item)
    if not xd.lume.find(t, item) then
        table.insert(t, item)
    end
end

return M