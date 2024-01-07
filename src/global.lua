local M = {}
local xd = require('engine')
local layer = require('src.layer')

-- entity.activity
---@enum ACTIVITY
M.ACTIVITY = {NOTHING='nothing',READ='read'}
-- determines whether an actor can perform an activity
---@type table<STRUCTURE_TYPE, fun(entity: entity): boolean>
M.ACTIVITY_COND = {
    [M.ACTIVITY.READ] = function(entity)
        return entity.happiness == nil or entity.happiness > 0
    end
}

-- ---@type table<ACTIVITY, fun(entity: entity)>
-- M.ACTIVITY_FAIL = {
--     [M.ACTIVITY.READ] = function (entity)
--         entity.happiness = entity.happiness - 10
--         xd.debug(tostring(entity)..' happiness -10 --> '..entity.happiness)
--     end
-- }

-- entity.structureType
---@enum STRUCTURE_TYPE
M.STRUCTURE_TYPE = {WALL='wall',TILE='tile',STORAGE='storage',ENTRANCE='entrance'}
-- entity.actorType
M.ACTORS = {
    {
        name='base',
        path='new/bird_base.png',
        anchorX=16,
        anchorY=16,
        activities={M.ACTIVITY.READ}
    }
}
-- how often actor should look for a new activity
M.CD_FIND_ACTIVITY = 3
-- entity.itemType
---@enum ITEM
M.ITEM = {BOOK='book'}
---@enum PATH_GRID
M.PATH_GRID = {FLOOR='floor'}
M.DEFAULT_INVENTORY_SIZE = 3

M.t = 0
-- 1 cycle = 1 world hour?
M.cycle = 0

---@enum LAYER
M.LAYER = {
    MAP = 'map'
    -- map = xd.ent.new{ layer=layer.TYPE.INPUT_PAN, layerFollow=nil, sx=2, sy=2 }
}
layer.MAX_ZOOM = 2.5
layer.MIN_ZOOM = 1

-- for _, entity in pairs(M.layer) do
--     xd.sce.addToWorld(entity)
-- end

return M
