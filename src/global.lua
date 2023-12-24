local M = {}
local xd = require('engine')
local layer = require('src.layer')

M.STRUCTURE_TYPE = {WALL=0,TILE=1,STORAGE=2,ENTRANCE=3}
M.ACTORS = {
    [0]={
        path='bird.png',
        anchorX=32,
        anchorY=44,
        likes={''}
    }
}
M.PATH_GRID = {FLOOR=0}

M.t = 0
M.cycle = 0

M.layer = {
    map = xd.ent.new{ layer=layer.TYPE.INPUT_PAN, layerFollow=nil }
}

for _, entity in pairs(M.layer) do
    xd.sce.addToWorld(entity)
end

return M