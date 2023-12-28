local xd = require('engine')
local describe, it, expect = xd.Test.describe, xd.Test.it, xd.Test.expect

describe('Engine')

it('Emits a signal with string key', function ()
    local called = false
    xd.sig.on('test', function ()
        called = true
    end)
    xd.sig.emit('test')
    expect(called, true)
end)

it('Emits a signal with table key', function ()
    local called = false
    local entity = xd.ent.new()
    xd.sig.on({entity.id, 'test'}, function ()
        called = true
    end)
    xd.sig.emit({entity.id, 'test'})
    expect(called, true)
end)

it('Removes signal when `true` is returned', function ()
    local called = 0
    xd.sig.on('test', function ()
        called = called + 1
        return true
    end)
    xd.sig.emit('test')
    xd.sig.emit('test')
    expect(called, 1)
end)