local M = {}
local xd = require('engine')
local zOrdering = require('src.zOrdering')
local g = require('src.global')
local isometric = require('src.isometric')
local pathing = require('src.pathfind')

---@type table<number, number>
local count = {}

---@param name string
local function incrCount(name)
    if count[name] == nil then
        count[name] = 0
    end
    count[name] = count[name] + 1
end

---@param name string
---@return integer
function M.getCount(name)
    return count[name] or 0
end

function M.spawnPatron()
    local entrance = xd.ent.find(function(e) return e.structureType == g.STRUCTURE_TYPE.ENTRANCE end)
    if entrance then

        local actorInfo = xd.lume.filter(g.ACTORS, function(a) return a.name == 'base' end)[1]
        if actorInfo and M.getCount(actorInfo.name) < 1 then
            local actor = xd.ent.new{
                image=actorInfo.path,
                ox=actorInfo.anchorX, oy=actorInfo.anchorY,
                zOrdering=zOrdering.MODE.Y,
                pathX=entrance.pathX, pathY=entrance.pathY,
                pathColor={0,1,0},
                pathGrid=g.PATH_GRID.FLOOR,
                pathSpeed=2,
                activities=actorInfo.activities,
                inventory={},
                happiness=100,
                actorType=actorInfo.name
            }
            actor.x, actor.y = entrance.x, entrance.y
            xd.sce.addTo(g.layer.map, actor)
            incrCount(actorInfo.name)
            return actor
        end
    end
end

---@param actor entity
---@param itemFn fun(item: entity):boolean
---@return boolean
function M.hasItem(actor, itemFn)
    if not actor.inventory then
        return false
    end
    return xd.lume.match(actor.inventory, itemFn) ~= nil
end

return M