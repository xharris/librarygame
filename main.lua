

local engine = require('engine')
local State = engine.State


function love.load()
    State.load('src.game')
end

function love.update(dt)
    engine.update(dt)
end

function love.draw()
    State.call('draw')
    engine.sce.draw()
end