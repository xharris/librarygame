local M = {}
local xd = require('engine')
local input = require('input')

M.LAYER_TYPE = {STATIC=0, INPUT_PAN=1}
M.MIN_ZOOM = 0.75
M.MAX_ZOOM = 1.5

local get, put = xd.sto.new()

xd.sys.add(function(dt, entity)
    if xd.ent.has(entity, 'layer') then
        local gw, gh = love.graphics.getDimensions()
        local mx, my = love.mouse.getPosition()
        -- follow an entity
        if entity.layerFollow then
            entity.x = -entity.layerFollow.x + (gw/2)
            entity.y = -entity.layerFollow.y + (gh/2)
        end
        if entity.layer == M.LAYER_TYPE.INPUT_PAN then
            local dragstart = get(entity, 'dragstart')
            -- drag start
            if input.down('mouse1') and not dragstart then
                put(entity, 'dragstart', {entity.x, entity.y, mx, my})
            end
            -- drag move
            if dragstart and xd.lume.distance(dragstart[3], dragstart[4], mx, my) > 3 then
                entity.layerFollow = nil
                entity.x = dragstart[1] + -dragstart[3] + mx
                entity.y = dragstart[2] + -dragstart[4] + my
            end
            -- drag end
            if not input.down('mouse1') and dragstart then
                put(entity, 'dragstart', nil)
            end
            -- zoom https://love2d.org/forums/viewtopic.php?p=253786#p253786
            local moved, wheely = input.down('wheely')
            if moved then
                local tx, ty = entity.x, entity.y
                local scale = entity.sx
                local newScale = math.min(M.MAX_ZOOM, math.max(M.MIN_ZOOM, scale + wheely * 5 * dt))

                entity.sx = newScale
                entity.sy = newScale

                -- zoom to mouse
                -- TODO should layerFollow be unset here?
                if not entity.layerFollow then
                    entity.x = (mx-((mx-tx)/scale)*newScale)
                    entity.y = (my-((my-ty)/scale)*newScale)
                end
            end
        end
    end
end)

return M