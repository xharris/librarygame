local xd = require('engine')
local it, expect = xd.Test.it, xd.Test.expect

local isometric = require('src.isometric')

function love.load()
    love.window.close()

    it('Converts screen to isometric coordinates', function()
        expect({isometric.toIso(0, 0)}, {0, 0})
        expect({isometric.toIso(2, 3)}, {160, 16})
    end)

    love.event.quit()
end