local xd = require('engine')
local g = require('src.global')
local zOrdering = require('src.zOrdering')

-- local get, set = xd.sto.new()

local lastSpawnTime
xd.sys.add(function(dt, entity)
    if xd.ent.has(entity, 'structureType') then
        if entity.structureType == g.STRUCTURE_TYPE.ENTRANCE then
            -- spawn a patron?
            if g.t % 3 == 0 and g.t ~= lastSpawnTime then
                local entrance = xd.ent.find(function(e) return e.structureType == g.STRUCTURE_TYPE.ENTRANCE end)
                if entrance then
                    xd.log('spawn', entrance)
                    lastSpawnTime = g.t
                    local actorInfo = g.ACTORS[0]
                    local actor = xd.ent.new{
                        image=actorInfo.path,
                        ox=actorInfo.anchorX, oy=actorInfo.anchorY,
                        zOrdering=zOrdering.MODE.Y,
                        pathX=entrance.pathX, pathY=entrance.pathY,
                        isoX=entrance.isoX, isoY=entrance.isoY,
                        pathGrid=g.PATH_GRID.FLOOR,
                        pathSpeed=2
                    }
                    xd.sce.addTo(g.layer.map, actor)
                end
            end
        end
    end
end)