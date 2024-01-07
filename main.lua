

local xd = require('engine')
local push = require('push')

xd.LOG_LEVEL = xd.LOG.DEBUG

love.window.setMode(800, 600, {resizable = true}) -- Resizable 1280x720 window
push.setupScreen(800, 600, {upscale = "pixel-perfect"}) -- 800x600 game resolution, upscaled

function love.load()
    xd.sta.load('src.game')
end

function love.update(dt)
    xd.update(dt)
    xd.sta.call('update', dt)
end

function love.draw()
    push.start()
    xd.sce.draw()
    push.finish()
end

function love.conf(t)
    -- t.window.display = 1
end

function love.resize(width, height)
	push.resize(width, height)
end