local M = {}
local xd = require('engine')
local astar = require('astar')

---@class node
---@field pathGrid number
---@field pathX integer
---@field pathY integer

local getNode, setNode = xd.sto.new()

---@type entity[]
local grids = {}

xd.sce.addDrawFn(function(entity)
    if xd.ent.has(entity, 'pathGrid') then
        if entity.pathColor then
            love.graphics.setColor(entity.pathColor)
        else
            love.graphics.setColor(1,0,0)
        end
        love.graphics.circle('fill',entity.ox,entity.oy,16)
    end
end)

xd.sce.addDrawFn(function(entity)
    if xd.ent.has(entity, 'pathList') then
        local list = entity.pathList
        local points = {}
        xd.lume.each(list, function(node)
            xd.lume.push(points, node.x+list[1].ox, node.y+list[1].oy)
        end)
        if #points >= 4 then
            love.graphics.setColor(0,1,0)
            love.graphics.line(points)
        end
    end
end)

---@param obj node|entity
local function getKey(obj)
    return table.concat({obj.pathGrid, obj.pathX, obj.pathY}, ',')
end

local function newGrid(pathGrid)
    local grid
    local map = {}
    -- Return all neighbor nodes. Means a target that can be moved from the current node
    -- add_neighbor_cb: function(new_node, cost)
    --    cost is optional, call map:get_cost to get cost if no cost value
    function map:get_neighbors(node, from, addNeighbor, userdata)
        for x = node.pathX - 1, node.pathX + 1 do
            for y = node.pathY - 1, node.pathY + 1 do
                ---@type entity
                local neighbor = getNode(grid, getKey({pathGrid=pathGrid, pathX=x, pathY=y}))
                if neighbor and not xd.ent.remove[neighbor.id] and neighbor.id ~= node.id then
                    addNeighbor(neighbor)
                end
            end
        end
    end
    -- Cost of two adjacent nodes.
    -- Distance, distance + cost or other comparison value you want
    ---@param from node
    ---@param to node
    function map:get_cost(from, to, userdata)
        return xd.lume.distance(from.pathX, from.pathY, to.pathX, to.pathY)
    end
    -- For heuristic. Estimate cost of current node to goal node
    -- As close to the real cost as possible
    ---@param node node
    ---@param goal node
    function map:estimate_cost(node, goal, userdata)
        -- xd.log('estimate_cost', { node=node, goal=goal })
        return self:get_cost(node, goal, userdata)
    end
    local finder = astar.new(map)
    grid = xd.ent.new{ pathFinder=finder }
    return grid
end

xd.sys.add(function(dt, entity)
    if xd.ent.has(entity, 'pathGrid', 'pathX', 'pathY') then
        if not grids[entity.pathGrid] then
            grids[entity.pathGrid] = newGrid(entity.pathGrid)
        end
        local grid = grids[entity.pathGrid]
        if not getNode(grid, getKey(entity)) then
            setNode(grid, getKey(entity), entity)
        end
    end
end)

---@param from entity
---@param to entity
---@return entity[]
function M.getPath(from, to)
    if not from.pathGrid or not to.pathGrid then
        xd.warn("pathGrid missing in 'from' or 'to'")
        return {}
    end
    if from.pathGrid ~= to.pathGrid then
        xd.warn("pathGrid for 'from' is different from 'to'")
        return {}
    end
    local grid = grids[from.pathGrid]
    if not grid or not grid.pathFinder then
        xd.warn("grid not found")
        return {}
    end
    return grid.pathFinder:find(from, to)
end

return M