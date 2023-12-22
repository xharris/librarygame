local M = {}
local xd = require('engine')
local inspect = require('inspect')
local input = require('input')

local image = require('src.image')
local isometric = require('src.isometric')
local layer = require('src.layer')
local zOrdering = require('src.zOrdering')

local STRUCTURES = {
    [0]={
        path='tile.png',
        scale=1,
        anchorX=32,
        anchorY=32,
        isFloor=true
    },
    [1]={
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
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0}
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
            local imgW, imgH = image.getImage(info.path):getWidth(), image.getImage(info.path):getHeight()

            local tileInfo = STRUCTURES[0]
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
    local imgW, imgH = image.getImage(actorInfo.path):getWidth(), image.getImage(actorInfo.path):getHeight()
    local actor = xd.ent.new{
        image=actorInfo.path,
        ox=actorInfo.anchorX, oy=actorInfo.anchorY,
        followMouse=true,
        zOrdering=zOrdering.MODE.Y
    }
    actor.x, actor.y = isometric.toIso(5, 1)
    xd.sce.addTo(layerMap, actor)

    xd.sys.add(function(dt, entity)
        if xd.ent.has(entity, 'followMouse') then
            local mx, my = love.mouse.getPosition()

            entity.x = mx - layerMap.x
            entity.y = my - layerMap.y
        end
    end)
end

return M