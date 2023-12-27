--[[
    - periodically spawns a patron
]]

local xd = require('engine')
local g = require('src.global')
local actor = require('src.actor')

-- local get, set = xd.sto.new()

local lastSpawnTime
xd.sys.add(function(dt, entity)
    if entity.structureType == g.STRUCTURE_TYPE.ENTRANCE then
        -- spawn a patron?
        if g.t % 3 == 0 and g.t ~= lastSpawnTime then
            lastSpawnTime = g.t
            actor.spawnPatron()
        end
    end
end)