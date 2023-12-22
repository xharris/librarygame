-- https://github.com/LuaLS/lua-language-server/wiki/Annotations

-- gamestate.lua

local M = {}
local xd = require('engine')

function M.load()
    M.state = {
        x = 0
    }
    xd.System.add(
        function(dt, entity)
            if xd.Entity.missing(entity, 'y') then return end
        end
    )
end

function M.draw()
    for _, entity in ipairs(xd.Entity.entities) do 

    end
end

-- main.lua

local xd = require('engine')

function love.load()
    xd.State.load('gamestate')
end

function love.update(dt)
    xd.update(dt)
end

function love.draw()
    xd.State.call('draw')
end