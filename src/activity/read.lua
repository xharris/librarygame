--[[
    - move to book storage
    - take book
]]

---@class reader: entity
---@field inventory? entity[]
---@field activity? any
---@field pathList? node[]
---@field readingStart? number Time left for reading

local xd = require('engine')
local g = require('src.global')
local pathfind = require('src.pathfind')
local activity = require('src.activity')

---@param inventory entity[]
local function getBookFromInventory(inventory)
    return xd.lume.match(inventory, function (value2)
        -- TODO also check genre
        return value2.itemType == g.ITEM.BOOK
    end)
end

xd.sys.add(function (dt, entity)
    ---@cast entity entityWithActivity
    if entity.inventory and entity.activity == g.ACTIVITY.READ and not activity.isActivityOnHold(entity) then
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
                xd.debug(tostring(entity)..' could not find storage')
                -- could not find storage containing a book
                activity.activityFail(entity, g.ACTIVITY.READ)
            end
            if storage and not entity.pathList then
                xd.debug(tostring(entity)..' pathing to storage '..tostring(storage))
                -- move to storage
                entity.pathList = pathfind.getPath(entity, storage)
                if not entity.pathList then
                    -- can't get to storage
                end
                xd.sig.on({entity.id, 'pathDone'}, function ()
                    -- TODO not being called
                    xd.debug(tostring(entity)..' arrived at storage '..tostring(storage))
                    -- take a book, calling method again in case inventory has changed
                    book = getBookFromInventory(storage.inventory)
                    if book then
                        -- find a place to sit
                        local readingSpot = pathfind.findNearestNode(entity, function (node)
                            return node.hasReader == false
                        end)
                        if readingSpot then
                            -- move to spot
                            entity.pathList = pathfind.getPath(entity, readingSpot)
                            -- xd.sig.on()
                        end
                    end
                    return true
                end)
            end
        end
    end
end)