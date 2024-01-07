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
require('src.activity')
require('src.activity.read')

local STRUCTURES = {
    [1]={
        path='new/tile.png',
        isFloor=true
    },
    [2]={
        path='new/box.png',
        type=g.STRUCTURE_TYPE.STORAGE,
        color={161/255, 136/255, 127/255, 1}
    },
    [3]={
        path='tile.png',
        isFloor=true,
        type=g.STRUCTURE_TYPE.ENTRANCE
    }
}

local map = {
    {3, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 1, 1},
    {0, 1, 1, 1, 2, 1},
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
                local iw, ih = image.getImage(tileInfo.path):getDimensions()
                local floor = xd.ent.new{
                    image=tileInfo.path,
                    ox=iw/2, oy=ih/2,
                    isoX=x, isoY=y,
                    zOrdering=zOrdering.MODE.Y,
                    pathGrid=g.PATH_GRID.FLOOR,
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
                    g.layer.map.layerFollow = floor
                end

                -- add structure at this cell in map
                if info and not info.isFloor then
                    local iw, ih = image.getImage(info.path):getDimensions()
                    local struct = xd.ent.new{
                        image=info.path,
                        ox=iw/2, oy=ih/2 + (isometric.TILE_SIZE/4),
                        pathX=x, pathY=y,
                        pathGrid=g.PATH_GRID.FLOOR,
                        isoX=x, isoY=y,
                        zOrdering=zOrdering.MODE.Y,
                        structureType=info.type,
                        imageColor=tileInfo.color,
                    }
                    xd.sce.addTo(g.layer.map, struct)

                    if info and info.type == g.STRUCTURE_TYPE.STORAGE then
                        -- make storage structures solid for pathfinding
                        struct.pathNoDiagonal = true
                        struct.pathWeight = pathing.MAX_WEIGHT
                        -- add a book
                        local book = xd.ent.new{
                            itemType=g.ITEM.BOOK
                        }
                        struct.inventory = {book}
                    end

                    if info and info.type == g.STRUCTURE_TYPE.ENTRANCE then
                        struct.pathNoDiagonal = true
                    end
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
                        xd.debug({node.x, node.y})
                    end)
                end
            end
        end
    end)
]]

return M