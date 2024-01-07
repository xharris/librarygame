local M = {}
local xd = require('engine')

---@type table<string, love.Image>
local image_cache = {}

M.debug = false

---@class withImage : entity
---@field image? string
---@field imageList? string[]
---@field imageColor? number[]

---@param path string
function M.getImage(path)
    -- create Image
    if not image_cache[path] then
        image_cache[path] = love.graphics.newImage('src/assets/' .. path)
    end
    return image_cache[path]
end

---@param entity entity
---@param path string
local function drawImage(entity, path)
    local imageObj = M.getImage(path)
    if imageObj then
        love.graphics.draw(imageObj)
    end
    -- if M.debug then
    --     love.graphics.push('all')
    --     love.graphics.setColor(0,0,0,1)
    --     love.graphics.circle('fill',0,0,4)
    --     love.graphics.rectangle('line',0,0,imageObj:getWidth(),imageObj:getHeight())
    --     love.graphics.pop()
    -- end
end

xd.sce.addDrawFn(function(entity)
    ---@cast entity withImage
    -- draw image
    if entity.image or entity.imageList then
        if entity.imageColor then
            love.graphics.setColor(entity.imageColor)
        end
        if entity.image then
            drawImage(entity, entity.image)
        end
        if entity.imageList then
            for _, img in ipairs(entity.imageList) do
                drawImage(entity, img)
            end
        end
    end
end)

return M