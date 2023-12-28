local M = {}
local xd = require('engine')
local g = require('src.global')
local pathfind = require('src.pathfind')
local timer = require('src.timer')

--- Make an actor move to storage and take an item
---@param actor entity
---@param itemMatch fun(item: entity):boolean
---@param done fun(...)
function M.retrieveItem(actor, itemMatch, done)
    if not actor.inventory then
        actor.inventory = {}
    end
    timer.script(
        function (next)
            -- find storage that is holding the item
            local storage = xd.lume.match(xd.ent.entities, function (value)
                return value.structureType == g.STRUCTURE_TYPE.STORAGE and
                    value.inventory and
                    xd.lume.match(value.inventory, itemMatch)
            end)
            if not storage then
                xd.info(tostring(actor)..' could not find storage containing item')
                return done()
            end
            -- move to storage
            actor.pathList = pathfind.getPath(actor, storage)
            if not actor.pathList then
                xd.info(tostring(actor)..' cannot reach storage')
                return done()
            end
            xd.sig.on({actor.id, 'pathDone'}, function ()
                -- become a wall while looking through storage
                local previousWeight = actor.pathWeight
                actor.pathWeight = pathfind.MAX_WEIGHT
                xd.debug(tostring(actor)..' arrived at storage '..tostring(storage))
                -- take item, calling method again in case inventory has changed
                ---@type entity?
                local item
                storage.inventory = xd.lume.filter(storage.inventory, function (item2)
                    if itemMatch(item2) then
                        item = item2
                        return false
                    end
                    return true
                end)
                if item == nil then
                    xd.info(tostring(actor)..' could not find item in storage '..tostring(storage))
                    return done()
                end
                next(item, previousWeight)
                return true
            end)
        end,
        function (_, item, previousWeight)
            ---@cast item entity
            ---@cast previousWeight number
            actor.pathWeight = previousWeight
            if item then
                table.insert(actor.inventory, item)
                timer.after(1, function ()
                    done(item)
                end)
            else
                done()
            end
        end
    )
end

return M