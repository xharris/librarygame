local M = {}
local xd = require('engine')

---@type table<string, love.Image>
local image_cache = {}

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
        end
    end
end)

return M