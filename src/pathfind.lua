local M = {}
local xd = require('engine')
local astar = require('astar')

M.MAX_WEIGHT = 100

---@class node
---@field pathGrid number
---@field pathX integer
---@field pathY integer
---@field pathWeight? number
---@field pathNoDiagonal? boolean
---@field pathSolid? boolean

local getNode, setNode = xd.sto.new()

---@type entity[]
local grids = {}

xd.sce.addDrawFn(function(entity)
    if xd.ent.has(entity, 'pathGrid') then
        if entity.pathColor then
            love.graphics.setColor(entity.pathColor)
        else
            local wt = entity.pathWeight or 1
            love.graphics.setColor(xd.lume.lerp(0, 1, wt/M.MAX_WEIGHT), 0, xd.lume.lerp(1, 0, wt/M.MAX_WEIGHT))
        end
        love.graphics.circle('fill',entity.ox,entity.oy,8)
    end
end, { z=99 })

xd.sce.addDrawFn(function(entity)
    if xd.ent.has(entity, 'pathList') then
        local list = entity.pathList
        local points = {}
        xd.lume.each(list, function(node)
            xd.lume.push(points, node.x+list[1].ox-entity.x, node.y+list[1].oy-entity.y)
        end)
        if #points >= 4 then
            -- love.graphics.reset()
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
        local dx, dy
        for x = -1, 1 do
            for y = -1, 1 do
                dx, dy = node.pathX + x, node.pathY + y
                ---@type entity
                local neighbor = getNode(grid, getKey({pathGrid=pathGrid, pathX=dx, pathY=dy}))
                if
                    neighbor and
                    not xd.ent.remove[neighbor.id] and
                    neighbor.id ~= node.id and
                    (not neighbor.pathNoDiagonal or x == 0 or y == 0) and
                    ((neighbor.pathWeight or 1) < M.MAX_WEIGHT or userdata.to.id == neighbor.id)
                then
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
        if from.pathWeight == nil then
            from.pathWeight = 1
        end
        if to.pathWeight == nil then
            to.pathWeight = 1
        end
        return xd.lume.distance(from.pathX, from.pathY, to.pathX, to.pathY) * math.max(1, (to.pathWeight))
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
    -- find path for entity
    if xd.ent.has(entity, 'pathGrid', 'pathX', 'pathY') then
        if not grids[entity.pathGrid] then
            grids[entity.pathGrid] = newGrid(entity.pathGrid)
        end
        local grid = grids[entity.pathGrid]
        if not getNode(grid, getKey(entity)) then
            setNode(grid, getKey(entity), entity)
        end
    end
    -- move entity on a path
    if xd.ent.has(entity, 'pathList') then
        if entity.pathLength == nil then
            -- get length of path
            entity.pathLength = 0
            local prev
            for n, node in ipairs(entity.pathList) do
                if n > 1 then
                    prev = entity.pathList[n-1]
                    entity.pathLength = entity.pathLength + xd.lume.distance(prev.x, prev.y, node.x, node.y)
                end
            end
        end
        if #entity.pathList > 1 and not entity.pathMove then
            table.remove(entity.pathList, 1)
            local to = entity.pathList[1]
            if to.pathWeight == M.MAX_WEIGHT then
                -- stop moving on path
                entity.pathList = nil
                entity.pathLength = nil
            else
                -- move to next point in path
                entity.pathMove = {
                    i=0,
                    t=0,
                    from={x=entity.x, y=entity.y},
                    to={x=to.x, y=to.y, pathX=to.pathX, pathY=to.pathY}
                }
            end
        end
    end
    if xd.ent.has(entity, 'pathMove', 'pathList') then
        local pm = entity.pathMove
        local speed = entity.pathSpeed or 1
        local dist = xd.lume.distance(pm.from.x, pm.from.y, pm.to.x, pm.to.y)
        pm.t = pm.t + dt / (dist / entity.pathLength)
        entity.y = xd.lume.lerp(pm.from.y, pm.to.y, pm.t/speed)
        entity.x = xd.lume.lerp(pm.from.x, pm.to.x, pm.t/speed)
        -- done moving to node
        if pm.t >= speed then
            entity.pathMove = nil
            entity.pathX = pm.to.pathX
            entity.pathY = pm.to.pathY
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
    return grid.pathFinder:find(from, to, { to=to })
end

return M