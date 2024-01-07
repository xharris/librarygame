local M = {}
local xd = require('engine')
local g = require('src.global')
local pathfind = require('src.pathfind')
local timer = require('src.timer')

---@class withInventory : entity
---@field inventory entity[]
---@field inventorySize number

---@param storage entity|withInventory
function M.isFull(storage)
    if not storage.inventory then
        xd.error(tostring(storage)..' does not have inventory')
        return true
    elseif storage.inventorySize == nil then
        storage.inventorySize = g.DEFAULT_INVENTORY_SIZE
    end
    return storage.inventory and #storage.inventory >= storage.inventorySize
end

--- Make an actor move to storage and take item(s)
---@param actor withInventory|entity
---@param itemMatch fun(item: entity):boolean Match item in storage inventory
---@param done fun(item:entity?)
function M.retrieveItem(actor, itemMatch, done)
    if not actor.inventory then
        actor.inventory = {}
    end
    if M.isFull(actor) then
        xd.info(tostring(actor)..' inventor is full')
        return done()
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
            ---@cast storage withInventory
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

--- Make an actor move to storage and take item(s)
---@param actor withInventory|entity
---@param itemMatch fun(item: entity):boolean Match item in actor inventory
---@param done fun(success:boolean)
function M.storeItem(actor, itemMatch, done)
    if not actor.inventory then
        return done(false)
    end
    ---@type entity?
    local item = xd.lume.match(actor.inventory, itemMatch)
    if not item then
        xd.info(tostring(actor)..' does not have item to store')
        return done(false)
    end
    -- find storage to place item
    local storage = xd.lume.match(xd.ent.entities, function (value)
        return value.structureType == g.STRUCTURE_TYPE.STORAGE and
            not M.isFull(value)
    end)
    if not storage then
        xd.info(tostring(actor)..' could not find storage to store item '..tostring())
        return done(false)
    end
    -- move to storage
    actor.pathList = pathfind.getPath(actor, storage)
    if not actor.pathList then
        xd.info(tostring(actor)..' cannot reach storage')
        return done(false)
    end
    xd.sig.on({actor.id, 'pathDone'}, function ()
        -- become a wall while storing
        local previousWeight = actor.pathWeight
        actor.pathWeight = pathfind.MAX_WEIGHT
        xd.debug(tostring(actor)..' arrived at storage '..tostring(storage))
        -- is there still space in storage?
        if M.isFull(storage) then
            done(false)
            return true
        end
        -- store item
        actor.inventory = xd.lume.filter(actor.inventory, function (item2)
            return item2 == item
        end)
        table.insert(storage.inventory, item)
        actor.pathWeight = previousWeight
        done(true)
        return true
    end)
end

return M