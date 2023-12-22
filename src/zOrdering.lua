local M = {}
local xd = require('engine')

M.debug = false

M.MODE = {NONE=0,Y=0}

xd.sys.add(function(dt, entity)
    if xd.ent.has(entity, 'zOrdering') then
        if entity.zOrdering == M.MODE.Y then
            entity.z = entity.y + entity.oy + (entity.zOffset or 0)
        end
    end
end)

xd.sce.addDrawFn(function(entity)
    if M.debug and xd.ent.has(entity, 'zOrdering') then
        if entity.zOrdering == M.MODE.Y then
            love.graphics.push('all')
            love.graphics.setColor(0,0,1)
            love.graphics.circle('fill',entity.ox,entity.oy + (entity.zOffset or 0),4)
            love.graphics.pop()
        end
    end
end)

return M