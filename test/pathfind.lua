local xd = require('engine')
local describe, it, expect = xd.Test.describe, xd.Test.it, xd.Test.expect

local pathfind = require('src.pathfind')

---@param grid table<number, table<number>>
local function genNodes(grid)
    local pathGrid = xd.lume.uuid()
    for x, xval in ipairs(grid) do
        for y, yval in ipairs(xval) do
            local node = xd.ent.new{ pathGrid=pathGrid, pathX=x, pathY=y, pathWeight=yval }
            grid[x][y] = node
        end
    end
    xd.sys.update(0)
    return grid, pathGrid
end

describe('Pathfinding')

it('Finds a path', function()
    local grid = genNodes({
        {1,1,1,1},
        {1,1,1,1},
        {1,1,1,1},
        {1,1,1,1}
    })
    local path = pathfind.getPath(grid[1][1], grid[3][4])
    expect(path, {grid[1][1], grid[2][2], grid[2][3], grid[3][4]})
end)

it('Cannot pass through MAX_WEIGHT node', function()
    local S = pathfind.MAX_WEIGHT
    local grid = genNodes({
        {1,1,1,1},
        {1,1,1,1},
        {1,1,S,S},
        {1,1,S,1}
    })
    local path = pathfind.getPath(grid[1][1], grid[4][4])
    expect(path, {})
end)