local M = {}
local xd = require('engine')
local astar = require('astar')
local util = require('src.util')

M.MAX_WEIGHT = 100

---@class pathMoveNode
---@field x number
---@field y number
---@field pathX? number
---@field pathY? number

---@class pathMove
---@field i number
---@field t number
---@field from pathMoveNode

---@class node: entity
---@field pathGrid id Which grid this node belongs to
---@field pathX integer
---@field pathY integer
---@field pathSpeed? number Lower number = Move slower on path
---@field pathWeight? number
---@field pathNoDiagonal? boolean
---@field pathSolid? boolean Entity cannot be passed through
---@field pathList? node[] List of points from a generated path
---@field pathLength? number Length of all points in pathList
---@field pathMove? pathMove Current destination node from pathList

local get, set = xd.sto.new()

---@type table<number, entity>
local grids = {}

---@type node[]
local nodes = {}

---@param obj node|entity
local function getKey(obj)
    return table.concat({obj.pathGrid, obj.pathX, obj.pathY}, ',')
end

xd.sce.addDrawFn(function(entity)
    if xd.ent.has(entity, 'pathGrid') then
        -- draw dot at each node
        if entity.pathColor then
            love.graphics.setColor(entity.pathColor)
        else
            local wt = entity.pathWeight or 1
            love.graphics.setColor(xd.lume.lerp(0, 1, wt/M.MAX_WEIGHT), 0, xd.lume.lerp(1, 0, wt/M.MAX_WEIGHT))
        end
        love.graphics.translate(entity.ox, entity.oy)
        love.graphics.circle(entity.pathX ~= nil and entity.pathY ~= nil and 'fill' or 'line',-4,0,4)
        love.graphics.print(entity.pathX..','..entity.pathY, 0, -8)
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
                ---@type node
                local neighbor
                local foundEnd = false
                -- find 'heaviest' node at these coordinates
                xd.lume.each(nodes, function (item)
                    local neighborWeight = neighbor and (neighbor.pathWeight or 0) or 0
                    local itemWeight = item.pathWeight or 0
                    if not foundEnd and item.pathX == dx and item.pathY == dy and (not neighbor or itemWeight > neighborWeight) then
                        neighbor = item
                        if item == userdata.to then
                            foundEnd = true
                        end
                    end
                end)
                -- get node with largest weight
                if
                    neighbor and
                    not xd.ent.remove[neighbor.id] and
                    neighbor.id ~= node.id and
                    (not neighbor.pathNoDiagonal or not node.pathNoDiagonal or x == 0 or y == 0) and
                    ((neighbor.pathWeight or 1) < M.MAX_WEIGHT or userdata.to.id == neighbor.id) and
                    neighbor.pathGrid == node.pathGrid
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
        -- xd.debug('estimate_cost', { node=node, goal=goal })
        return self:get_cost(node, goal, userdata)
    end
    local finder = astar.new(map)
    grid = xd.ent.new{ pathFinder=finder }
    return grid
end

xd.sys.add(function(dt, entity)
    ---@cast entity node
    if xd.ent.has(entity, 'pathGrid', 'pathX', 'pathY') then
        if not grids[entity.pathGrid] then
            grids[entity.pathGrid] = newGrid(entity.pathGrid)
        end
        local grid = grids[entity.pathGrid]
        util.addToSet(nodes, entity)
    end
    -- move entity on a path
    if entity.pathList then
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
            -- get new path (in case something has changed in the path)
            local lastPoint = entity.pathList[2]
            entity.pathList = M.getPath(entity, entity.pathList[#entity.pathList])
            local to = entity.pathList[2]
            if to.pathWeight == M.MAX_WEIGHT or #entity.pathList <= 1 or (to.pathX == entity.pathX and to.pathY == entity.pathY) then
                -- stop moving on path
                entity.pathList = nil
                entity.pathLength = nil
                xd.debug(xd.ent.inspect(entity, 'pathX', 'pathY')..' done moving')
                xd.sig.emit({entity.id, 'pathDone'})
            else
                entity.pathX = lastPoint.pathX
                entity.pathY = lastPoint.pathY
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
    local pm = entity.pathMove
    if pm and entity.pathList then
        local speed = entity.pathSpeed or 1
        local dist = xd.lume.distance(pm.from.x, pm.from.y, pm.to.x, pm.to.y)
        pm.t = pm.t + dt / (dist / entity.pathLength)
        entity.x = xd.lume.lerp(pm.from.x, pm.to.x, pm.t/speed)
        entity.y = xd.lume.lerp(pm.from.y, pm.to.y, pm.t/speed)
        -- done moving to node
        if pm.t >= speed then
            entity.pathMove = nil
            entity.pathX = pm.to.pathX
            entity.pathY = pm.to.pathY
        end
    end
end)

---@param from node|entity
---@param to node|entity
---@return node[]
function M.getPath(from, to)
    if from.pathGrid == nil or to.pathGrid == nil then
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
    -- xd.debug('get path from '..tostring(from)..'('..from.pathX..','..from.pathY..')'..' to '..tostring(to)..'('..to.pathX..','..to.pathY..')')
    return grid.pathFinder:find(from, to, { to=to })
end

---@param entity entity
---@param filter? fun(node: node):boolean
---@return node?
function M.findNearestNode(entity, filter)
    local minDist = 0
    ---@type node?
    local minNode
    ---@type number?
    local dist
    xd.lume.each(nodes, function (node)
        if node.pathGrid and node.pathX ~= nil and node.pathY ~= nil then
            ---@cast node node
            dist = xd.lume.distance(node.pathX, node.pathY, entity.pathX, entity.pathY)
            if (not minNode or dist < minDist) and (not filter or filter(node)) then
                minNode = node
                minDist = dist
            end
        end
    end)
    return minNode
end

return M