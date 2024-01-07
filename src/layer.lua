local M = {}
local xd = require('engine')
local input = require('input')
local cameramgr = require('cameramgr')

---@class withLayer : entity
---@field layer string
---@field layerDeadzone? number

---@class withLayerManager : entity
---@field cameraManager table
---@field layerManFollow? entity|withLayer

---@enum LAYER_TYPE
M.TYPE = {STATIC=0, INPUT_PAN=1}
M.MIN_ZOOM = 0.75
M.MAX_ZOOM = 1.5
M.ZOOM_RESET_FOLLOW = false
M.DEFAULT_DEADZONE = 32

local get, set = xd.sto.new()

---@type table<string, withLayerManager>
local managers = {}

---@param entity entity|withLayer
---@return withLayerManager?
function M.getManager(entity)
    return managers[entity.layer]
end

---@param entity entity
function M.preDrawEach(entity)
    local layerMan = managers[entity.layer]
    if layerMan and layerMan.cameraManager then
        layerMan.cameraManager.attach()
    end
end

---@param entity entity
function M.postDrawEach(entity)
    local layerMan = managers[entity.layer]
    if layerMan and layerMan.cameraManager then
        layerMan.cameraManager.detach()
    end
end

---@param entity entity|withLayer
function M.follow(entity)
    local layerMan = managers[entity.layer]
    if layerMan then
        layerMan.layerManFollow = entity
    end
end

xd.sys.add(function(dt, entity)
    ---@cast entity withLayerManager|withLayer

    -- create new layerManager
    if entity.layer and not managers[entity.layer] then
        xd.debug('create layer manager', tostring(entity))
        local mgr = xd.ent.new{
            cameraManager = cameramgr.newManager()
        } --[[@as withLayerManager]]
        local gw, gh = love.graphics.getDimensions()
        mgr.cameraManager.setLerp(0.1)
        managers[entity.layer] = mgr
    end

    -- camera follow entity
    local follow = entity.layerManFollow
    if follow and entity.cameraManager then
        local tf = xd.sce.transforms[follow.id]
        if tf then
            local x, y = tf:transformPoint(0,0)
            local dz = follow.layerDeadzone or M.DEFAULT_DEADZONE
            entity.cameraManager.setDeadzone(-dz,-dz,dz,dz)
            entity.cameraManager.setTarget(x, y)
        end
    end

    -- camera zoom
    
    
    if entity.cameraManager then
        entity.cameraManager.update(dt)
    end
    -- if xd.ent.has(entity, 'layer') then
    --     local gw, gh = love.graphics.getDimensions()
    --     local mx, my = love.mouse.getPosition()
    --     entity.layerZoom = entity.layerZoom or 1
    --     entity.ox = gw/2
    --     entity.oy = gh/2
    --     -- follow an entity
    --     if entity.layerFollow then
    --         entity.x = -(entity.layerFollow.x * entity.sx) - (gw/2 * entity.sx)
    --         entity.y = -(entity.layerFollow.y * entity.sy) - (gh/2 * entity.sy)
    --     end
    --     if entity.layer == M.TYPE.INPUT_PAN then
    --         local dragstart = get(entity, 'dragstart')
    --         -- drag start
    --         if input.down('mouse1') and not dragstart then
    --             put(entity, 'dragstart', {entity.x, entity.y, mx, my})
    --         end
    --         -- drag move
    --         if dragstart and xd.lume.distance(dragstart[3], dragstart[4], mx, my) > 3 then
    --             entity.layerFollow = nil
    --             entity.x = dragstart[1] + -dragstart[3] + mx
    --             entity.y = dragstart[2] + -dragstart[4] + my
    --         end
    --         -- drag end
    --         if not input.down('mouse1') and dragstart then
    --             put(entity, 'dragstart', nil)
    --         end
    --         -- zoom https://love2d.org/forums/viewtopic.php?p=253786#p253786
    --         local moved, wheely = input.down('wheely')
    --         if moved then
    --             if M.ZOOM_RESET_FOLLOW then
    --                 entity.layerFollow = nil
    --             end
    --             local tx, ty = entity.x, entity.y
    --             local prevZoom = entity.layerZoom
    --             local newZoom = math.min(M.MAX_ZOOM, math.max(M.MIN_ZOOM, prevZoom + wheely * 5 * dt))

    --             entity.layerZoom = newZoom

    --             -- zoom to mouse
    --             if not entity.layerFollow then
    --                 entity.x = (mx-((mx-tx)/prevZoom)*newZoom)
    --                 entity.y = (my-((my-ty)/prevZoom)*newZoom)
    --             end
    --         end
    --     end

    --     entity.sx = entity.layerZoom
    --     entity.sy = entity.layerZoom
    -- end
end)

---@param layer entity
---@param x number
---@param y number
function M.toWorld(layer, x, y)
    local transform = xd.sce.transforms[layer.id]
    if transform then
        return transform:inverseTransformPoint(x, y)
    end
    return x, y
end

return M