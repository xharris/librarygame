local M = {}
local xd = require('engine')
local layer = require('src.layer')

-- entity.activity
M.ACTIVITY = {NOTHING='nothing',READ='read'}
-- determines whether an actor can perform an activity
---@type table<number, fun(entity: entity): boolean>
M.ACTIVITY_COND = {
    [M.ACTIVITY.READ] = function(entity)
        return entity.happiness == nil or entity.happiness > 0
    end
}
---@type table<number, fun(entity: entity)>
M.ACTIVITY_FAIL = {
    [M.ACTIVITY.READ] = function (entity)
        entity.happiness = entity.happiness - 10
        xd.debug(tostring(entity)..' happiness -10 --> '..entity.happiness)
    end
}
-- entity.structureType
M.STRUCTURE_TYPE = {WALL='wall',TILE='tile',STORAGE='storage',ENTRANCE='entrance'}
-- entity.actorType
M.ACTORS = {
    {
        name='base',
        path='bird.png',
        anchorX=32,
        anchorY=44,
        activities={M.ACTIVITY.READ}
    }
}
-- how often actor should look for a new activity
M.CD_FIND_ACTIVITY = 3
-- entity.itemType
M.ITEM = {BOOK=0}
M.PATH_GRID = {FLOOR='floor'}

M.t = 0
-- 1 cycle = 1 world hour?
M.cycle = 0

M.layer = {
    map = xd.ent.new{ layer=layer.TYPE.INPUT_PAN, layerFollow=nil }
}

for _, entity in pairs(M.layer) do
    xd.sce.addToWorld(entity)
end

return M