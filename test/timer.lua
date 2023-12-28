local xd = require('engine')
local describe, it, expect = xd.Test.describe, xd.Test.it, xd.Test.expect
local timer = require('src.timer')

describe('Timer')

it('Calls function once when timer ends', function ()
    local called = 0
    timer.after(1, function ()
        called = called + 1
    end)
    -- 2 seconds
    xd.sys.update(1)
    xd.sys.update(1)
    expect(called, 1)
end)

it('Calls function after 3 seconds', function ()
    local called = 0
    timer.after(3, function ()
        called = called + 1
    end)
    -- 1 second
    xd.sys.update(1)
    expect(called, 0)
    -- 3 seconds
    xd.sys.update(1)
    xd.sys.update(1)
    expect(called, 1)
end)