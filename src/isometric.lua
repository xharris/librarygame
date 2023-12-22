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
        local h = entity.isoH or 0
        local isoX, isoY = entity.isoX, entity.isoY
        local tw, th = M.TILE_SIZE, M.TILE_SIZE / 2
        local xPos, yPos = M.toIso(isoX, isoY)
        local isoOX, isoOY = entity.isoOX or 0, entity.isoOY or 0
        entity.x = xPos + isoOX
        entity.y = yPos + isoOY - (th/2 * h)
        entity.ox = tw/2
        entity.oy = th/2
        entity.z = yPos + (h * th)
    end
end)

return M