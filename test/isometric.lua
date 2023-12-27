local xd = require('engine')
local describe, it, expect = xd.Test.describe, xd.Test.it, xd.Test.expect

local isometric = require('src.isometric')

describe('Isometric')

it('Converts screen to isometric coordinates', function()
    expect({isometric.toIso(0, 0)}, {0, 0})
    expect({isometric.toIso(2, 3)}, {160, 16})
end)