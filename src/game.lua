local M = {}
local xd = require('engine')
local inspect = require('inspect')
local input = require('input')

local image = require('src.image')
local isometric = require('src.isometric')
local layer = require('src.layer')

local TILES = {
    [0]={
        path='tile.png',
        scale=1
    },
    [1]={
        path='box.png',
        h=1,
        oy=5
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

    for y, yval in pairs(map) do
        for x, xval in pairs(yval) do
            local info = TILES[xval]
            local imgW, imgH = image.getImage(info.path):getWidth(), image.getImage(info.path):getHeight()

            local ent = xd.ent.new{
                image=info.path,
                sx=info.scale, sy=info.scale,
                isoX=x,
                isoY=y,
                isoH=info.h,
                isoOX=(imgW/2),
                isoOY=(imgH/2) + (info.oy or 0)
            }
            xd.sce.addTo(layerMap, ent)

            if xval == 1 then
                layerMap.layerFollow = ent
            end
        end
    end
end

return M