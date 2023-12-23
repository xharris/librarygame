local M = {}
local xd = require('engine')
local input = require('input')

local image = require('src.image')
local isometric = require('src.isometric')
local layer = require('src.layer')
local zOrdering = require('src.zOrdering')
local pathing = require('src.pathfind')

local STRUCTURE_TYPE = {WALL=0,TILE=1,STORAGE=2}

local STRUCTURES = {
    [1]={
        path='tile.png',
        scale=1,
        anchorX=32,
        anchorY=32,
        isFloor=true
    },
    [2]={
        path='box.png',
        anchorX=32,
        anchorY=44,
        type=STRUCTURE_TYPE.STORAGE
    }
}

local ACTORS = {
    [0]={
        path='bird.png',
        anchorX=32,
        anchorY=44
    }
}

local PATH_GRID = {FLOOR=0}

local map = {
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 2, 2, 1},
    {1, 1, 2, 2, 1},
    {1, 1, 1, 2, 1}
}

local layerMap = xd.ent.new{ layer=layer.TYPE.INPUT_PAN, layerFollow=nil }
xd.sce.addToWorld(layerMap)


function M.load()
    input.bind_callbacks()
    love.graphics.setBackgroundColor(1, 1, 1)

    -- load map
    for y, yval in pairs(map) do
        for x, xval in pairs(yval) do
            local info = STRUCTURES[xval]

            -- add floor
            local tileInfo = STRUCTURES[1]
            local floor = xd.ent.new{
                image=tileInfo.path,
                sx=tileInfo.scale, sy=tileInfo.scale,
                ox=tileInfo.anchorX, oy=tileInfo.anchorY,
                isoX=x, isoY=y,
                zOrdering=zOrdering.MODE.Y,
                pathX=x, pathY=y,
            }
            xd.sce.addTo(layerMap, floor)

            -- set z offset
            if tileInfo.isFloor then
                floor.zOffset = -999
            end

            -- set camera on center tile
            if y == math.floor(#map / 2) and x == math.floor(#yval / 2) then
                -- layerMap.layerFollow = floor
            end

            -- add structure at this cell in map
            if info and not info.isFloor then
                local struct = xd.ent.new{
                    image=info.path,
                    sx=info.scale, sy=info.scale,
                    ox=info.anchorX, oy=info.anchorY,
                    isoX=x, isoY=y,
                    zOrdering=zOrdering.MODE.Y,
                    a=0.75
                }
                xd.sce.addTo(layerMap, struct)
            end

            -- add to pathfinding map
            floor.pathGrid = PATH_GRID.FLOOR

            if info.type == STRUCTURE_TYPE.STORAGE then
                floor.pathNoDiagonal = true
                floor.pathWeight = pathing.MAX_WEIGHT
            end
        end
    end

    -- add a bird
    local actorInfo = ACTORS[0]
    local actor = xd.ent.new{
        image=actorInfo.path,
        ox=actorInfo.anchorX, oy=actorInfo.anchorY,
        zOrdering=zOrdering.MODE.Y,
        pathGrid=PATH_GRID.FLOOR
    }
    actor.x, actor.y = isometric.toIso(0, 0)
    actor.pathX = 0
    actor.pathY = 0
    xd.sce.addTo(layerMap, actor)

    ---@type entity
    local lastNode
    xd.sys.add(function(dt, entity)
        local mx, my = layer.toWorld(layerMap, love.mouse.getPosition())
        if xd.ent.has(entity, 'pathGrid') then
            -- find a path from actor to clicked tile
            if love.mouse.isDown(1) and lastNode ~= entity and xd.lume.distance(mx, my, entity.x, entity.y) < 16 then
                if lastNode then
                    lastNode.pathColor = nil
                end
                lastNode = entity
                entity.pathColor = {0,1,0}
                actor.pathList = pathing.getPath(actor, entity)
                if actor.pathList then
                    xd.lume.each(actor.pathList, function(node)
                        xd.log({node.x, node.y})
                    end)
                end
            end
        end
    end)
end


-- xd.sys.add(function(dt, entity)
--     if xd.ent.has(entity, 'followMouse') then
--         local mx, my = love.mouse.getPosition()

--         entity.x = mx - layerMap.x
--         entity.y = my - layerMap.y
--     end
-- end)

return M