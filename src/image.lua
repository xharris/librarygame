local M = {}
local xd = require('engine')

---@type table<string, love.Image>
local image_cache = {}

M.debug = false

---@param path string
function M.getImage(path)
    -- create Image
    if not image_cache[path] then
        image_cache[path] = love.graphics.newImage('src/assets/' .. path)
    end
    return image_cache[path]
end

xd.sce.addDrawFn(function(entity)
    if xd.ent.has(entity, 'image') then
        -- draw image
        if xd.ent.has(entity, 'image') then
            local imageObj = M.getImage(entity.image)
            if imageObj then
                love.graphics.draw(imageObj)
            end
            if M.debug then
                love.graphics.push('all')
                love.graphics.setColor(0,0,0)
                love.graphics.circle('fill',0,0,4)
                love.graphics.rectangle('line',0,0,imageObj:getWidth(),imageObj:getHeight())
                love.graphics.pop()
            end
        end
    end
end)

return M