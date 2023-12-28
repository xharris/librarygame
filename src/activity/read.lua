--[[
    - move to book storage
    - take book
]]

---@class reader: entityWithActivity
---@field inventory? entity[]
---@field activity? any
---@field pathList? node[]
---@field readingStart? number Time left for reading

local xd = require('engine')
local g = require('src.global')
local pathfind = require('src.pathfind')
local activity = require('src.activity')
local timer = require('src.timer')

---@param inventory entity[]
local function getBookFromInventory(inventory)
    ---@type entity?
    local book
    local newInventory = xd.lume.filter(inventory, function (item)
        if item.itemType == g.ITEM.BOOK then
            book = item
            return false
        end
        return true
    end)
    return book, newInventory
end

xd.sys.add(function (dt, entity)
    ---@cast entity reader

    if entity.readingStart ~= nil then
        -- reading
        entity.readingStart = entity.readingStart - dt
        if entity.readingStart <= 0 then
            -- return the book to storage
            xd.debug(tostring(entity)..' is done reading')
        end
    end

    if entity.readingStart == nil and entity.inventory and entity.activity == g.ACTIVITY.READ and not activity.isActivityOnHold(entity) then
        -- start activity
        local book = xd.lume.match(entity.inventory, function (item)
            return item.itemType == g.ITEM.BOOK
        end)
        if not book and not entity.pathList then
            xd.debug(tostring(entity)..' looking for storage')
            -- find storage that is holding a book
            ---@type node[]?
            local storagePath
            local storage = xd.lume.match(xd.ent.entities, function (value)
                if value.structureType == g.STRUCTURE_TYPE.STORAGE and value.inventory then
                    book = getBookFromInventory(value.inventory)
                    if not book then
                        return false
                    end
                    storagePath = pathfind.getPath(entity, value)
                    if not storagePath then
                        return false
                    end
                    return true
                end
                return false
            end)
            if not storage then
                xd.info(tostring(entity)..' could not find storage containing a book')
                activity.activityFail(entity)
            end
            if storage and not entity.pathList then
                xd.debug(tostring(entity)..' pathing to storage '..tostring(storage))
                -- move to storage
                entity.pathList = pathfind.getPath(entity, storage)
                if not entity.pathList then
                    xd.info(tostring(entity)..' cannot reach storage')
                    activity.activityFail(entity)
                end
                xd.sig.on({entity.id, 'pathDone'}, function ()
                    -- become a wall while looking through storage
                    local previousWeight = entity.pathWeight
                    entity.pathWeight = pathfind.MAX_WEIGHT
                    xd.debug(tostring(entity)..' arrived at storage '..tostring(storage))
                    -- take a book, calling method again in case inventory has changed
                    book, storage.inventory = getBookFromInventory(storage.inventory)
                    if not book then
                        xd.info(tostring(entity)..' could not find book in storage '..tostring(storage))
                        activity.activityFail(entity)
                    end
                    if book and not entity.pathList and entity.readingStart == nil then
                        table.insert(entity.inventory, book)
                        timer.after(1, function ()
                            entity.pathWeight = previousWeight
                            -- find a place to sit
                            local readingSpot = pathfind.findNearestNode(entity, function (node)
                                return not node.hasReader and xd.lume.distance(entity.pathX, entity.pathY, node.pathX, node.pathY) > 1
                            end)
                            if not readingSpot then
                                xd.info(tostring(entity)..' could not find a spot to read')
                                activity.activityFail(entity)
                            else
                                xd.debug(xd.ent.inspect(entity)..' pathing to reading spot '..tostring(readingSpot))
                                -- move to spot
                                entity.pathList = pathfind.getPath(entity, readingSpot)
                                xd.sig.on({entity.id, 'pathDone'}, function ()
                                    readingSpot.hasReader = true
                                    entity.readingStart = 5 -- TODO reading time changes depending on actor
                                    xd.debug(xd.ent.inspect(entity, 'readingStart')..' started reading')
                                    return true
                                end)
                            end
                        end)
                    end
                    return true
                end)
            end
        end
    end
end)