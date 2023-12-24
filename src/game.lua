local M = {}
local xd = require('engine')
local g = require('src.global')

local input = require('input')

local image = require('src.image')
local isometric = require('src.isometric')
local layer = require('src.layer')
local zOrdering = require('src.zOrdering')
local pathing = require('src.pathfind')
require('src.structures.entrance')

local STRUCTURES = {
    [1]={
        path='tile.png',
        anchorX=32,
        anchorY=32,
        isFloor=true
    },
    [2]={
        path='box.png',
        anchorX=32,
        anchorY=44,
        type=g.STRUCTURE_TYPE.STORAGE
    },
    [3]={
        path='tile.png',
        anchorX=32,
        anchorY=32,
        isFloor=true,
        type=g.STRUCTURE_TYPE.ENTRANCE
    }
}

local map = {
    {3, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 2},
    {0, 1, 1, 1, 1, 1}
}

function M.load()
    input.bind_callbacks()
    love.graphics.setBackgroundColor(1, 1, 1)

    -- load map
    for y, yval in pairs(map) do
        for x, xval in pairs(yval) do
            local info = STRUCTURES[xval]
            if info then
                -- add floor
                local tileInfo = STRUCTURES[1]
                local floor = xd.ent.new{
                    image=tileInfo.path,
                    ox=tileInfo.anchorX, oy=tileInfo.anchorY,
                    isoX=x, isoY=y,
                    zOrdering=zOrdering.MODE.Y,
                    pathX=x, pathY=y,
                    structureType=info.type
                }
                xd.sce.addTo(g.layer.map, floor)

                -- set z offset
                if tileInfo.isFloor then
                    floor.zOffset = -999
                end

                -- set camera on center tile
                if y == math.floor(#map / 2) and x == math.floor(#yval / 2) then
                    -- g.layer.map.layerFollow = floor
                end

                -- add structure at this cell in map
                if info and not info.isFloor then
                    local struct = xd.ent.new{
                        image=info.path,
                        ox=info.anchorX, oy=info.anchorY,
                        isoX=x, isoY=y,
                        zOrdering=zOrdering.MODE.Y,
                        a=0.75,
                        structureType=info.type
                    }
                    xd.sce.addTo(g.layer.map, struct)
                end

                -- add to pathfinding map
                floor.pathGrid = g.PATH_GRID.FLOOR

                -- make storage structures solid for pathfinding
                if info and info.type == g.STRUCTURE_TYPE.STORAGE then
                    floor.pathNoDiagonal = true
                    floor.pathWeight = pathing.MAX_WEIGHT
                end
            end
        end
    end
end

local t = 0
local floor = math.floor
function M.update(dt)
    t = t + dt
    g.t = floor(t)
    g.cycle = floor(g.t / 60) + 1
end

--[[
    -- DEV click to find path from bird to clicked tile
    ---@type entity
    local lastNode
    xd.sys.add(function(dt, entity)
        local mx, my = layer.toWorld(g.layer.map, love.mouse.getPosition())
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
]]

return M