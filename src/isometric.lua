local M = {}
local xd = require('engine')

M.TILE_SIZE = 64

function M.toIso(x, y)
    local w, h = M.TILE_SIZE, M.TILE_SIZE / 2
    return  (x * w / 2) + (y * w / 2),
            (y * h / 2) - (x * h / 2)
end

xd.sys.add(function(dt, entity)
    if xd.ent.has(entity, 'isoX', 'isoY') then
        -- local h = entity.isoH or 0
        local isoX, isoY = entity.isoX, entity.isoY
        local tw, th = M.TILE_SIZE, M.TILE_SIZE / 2
        local xPos, yPos = M.toIso(isoX, isoY)
        entity.x = xPos - (tw/2)
        entity.y = yPos - (th/2)
    end
end)

return M