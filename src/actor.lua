local M = {}
local xd = require('engine')
local zOrdering = require('src.zOrdering')
local g = require('src.global')
local isometric = require('src.isometric')
local pathfind = require('src.pathfind')
local image = require('src.image')
local layer = require('src.layer')

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
                imageLayers={
                    {'bird/bird_feet.png'},
                    {'bird/bird_fill.png', {244/255, 67/255, 54/255, 1}},
                    {'bird/bird_base.png'},
                    {'bird/bird_eyes.png'},
                    {'bird/bird_arm.png'}
                },
                oy=isometric.TILE_SIZE/4,
                zOrdering=zOrdering.MODE.Y,
                pathX=entrance.pathX, pathY=entrance.pathY,
                pathColor={0,1,0},
                pathGrid=g.PATH_GRID.FLOOR,
                pathSpeed=2,
                activities=actorInfo.activities,
                inventory={},
                happiness=100,
                actorType=actorInfo.name,
                layer=g.LAYER.MAP
            }
            layer.follow(actor)
            actor.x, actor.y = entrance.x, entrance.y
            xd.sce.addToWorld(actor)
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

---@param actor entity
---@param done fun(success:boolean)
function M.sit(actor, done)
    -- find a place to sit that's not next to storage
    local node = pathfind.findNearestNode(actor, function (node)
        if node.sittingActor then
            local actor2 = xd.ent.get(node.sittingActor)
            if actor2 and xd.lume.distance(actor2.x, actor2.y, node.x, node.y) > 3 then
                node.sittingActor = nil
            end
        end
        return node.sittingActor == nil and xd.lume.distance(actor.pathX, actor.pathY, node.pathX, node.pathY) > 1
    end)
    if not node then
        xd.info(tostring(actor)..' could not find a spot to sit')
        return done(false)
    end
    -- move there
    actor.pathList = pathfind.getPath(actor, node)
    xd.sig.on({actor.id, 'pathDone'}, function ()
        node.actorSitting = actor.id
        actor.sitting = node.id
        done(true)
        return true
    end)
end

return M