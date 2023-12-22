local M = {}
local xd = require('engine')
local inspect = require('inspect')
local input = require('input')

local image = require('src.image')
local isometric = require('src.isometric')
local layer = require('src.layer')
local zOrdering = require('src.zOrdering')

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
        -- h=1,
        anchorX=32,
        anchorY=44
    }
}

local ACTORS = {
    [0]={
        path='bird.png',
        anchorX=32,
        anchorY=44
    }
}

local map = {
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 2, 1, 1},
    {1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1}
}

local layerMap = xd.ent.new{ layer=layer.LAYER_TYPE.INPUT_PAN, layerFollow=nil }
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
                isoH=tileInfo.h,
                zOrdering=zOrdering.MODE.Y
            }
            xd.sce.addTo(layerMap, floor)

            -- set z offset
            if tileInfo.isFloor then
                floor.zOffset = -999
            end

            -- set camera on center tile
            if y == math.floor(#map / 2) and x == math.floor(#yval / 2) then
                layerMap.layerFollow = floor
            end

            -- add structure at this cell in map
            if not info.isFloor then
                local struct = xd.ent.new{
                    image=info.path,
                    sx=info.scale, sy=info.scale,
                    ox=info.anchorX, oy=info.anchorY,
                    isoX=x, isoY=y,
                    isoH=info.h,
                    zOrdering=zOrdering.MODE.Y
                }
                xd.sce.addTo(layerMap, struct)
            end

        end
    end

    -- add a bird
    local actorInfo = ACTORS[0]
    local actor = xd.ent.new{
        image=actorInfo.path,
        ox=actorInfo.anchorX, oy=actorInfo.anchorY,
        zOrdering=zOrdering.MODE.Y
    }
    actor.x, actor.y = isometric.toIso(1, 0)
    xd.sce.addTo(layerMap, actor)
end


-- xd.sys.add(function(dt, entity)
--     if xd.ent.has(entity, 'followMouse') then
--         local mx, my = love.mouse.getPosition()

--         entity.x = mx - layerMap.x
--         entity.y = my - layerMap.y
--     end
-- end)

return M