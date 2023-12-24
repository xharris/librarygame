

local xd = require('engine')

function love.load()
    xd.sta.load('src.game')
end

function love.update(dt)
    xd.update(dt)
    xd.sta.call('update', dt)
end

function love.draw()
    xd.sce.draw()
end