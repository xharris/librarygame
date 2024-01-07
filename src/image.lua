local M = {}
local xd = require('engine')

M.debug = false
M.DEFAULT_OFFSET = {0.5, 0.5}

---@class withImage : entity
---@field image? string
---@field imageOx? number
---@field imageOy? number
---@field imageList? string[]
---@field imageColor? number[]
---@field imageLayers? { [1]:string, [2]:number[]? }[]

---@param path string?
M.getImage = xd.lume.memoize(function(path)
    if not path then
        return nil
    end
    -- create Image
    local img = love.graphics.newImage('src/assets/' .. path)
    return img, img:getWidth(), img:getHeight()
end)

---@param path string?
---@param color number[]?
---@param ox number? imageOx
---@param oy number? imageOy
local function drawImage(path, color, ox, oy)
    if path then
        local imageObj, iw, ih = M.getImage(path)
        if imageObj then
            if color then
                love.graphics.setColor(color)
            else
                love.graphics.setColor(1,1,1,1)
            end
            love.graphics.draw(imageObj, 0, 0, 0, 1, 1, iw * (ox or M.DEFAULT_OFFSET[1]), ih * (oy or M.DEFAULT_OFFSET[2]))
        end
    end
end

xd.sce.addDrawFn(function(entity)
    ---@cast entity withImage
    -- draw image
    if entity.image then
        drawImage(entity.image, entity.imageColor, entity.imageOx, entity.imageOy)
    end
    -- multiple images
    if entity.imageList then
        for _, img in ipairs(entity.imageList) do
            drawImage(img, entity.imageColor, entity.imageOx, entity.imageOy)
        end
    end
    -- multiple images with different colors
    if entity.imageLayers then
        for _, layer in ipairs(entity.imageLayers) do
            drawImage(layer[1], layer[2], entity.imageOx, entity.imageOy)
        end
    end
end)

return M