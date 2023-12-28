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
local storage = require('src.structures.storage')

---@param item entity
local function isBook(item)
    return item.itemType == g.ITEM.BOOK
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

    if not entity.retrievingBook and entity.readingStart == nil and entity.activity == g.ACTIVITY.READ and not activity.isActivityOnHold(entity) then
        entity.retrievingBook = true
        storage.retrieveItem(entity, isBook, function (item)
            ---@cast item entity
            if not item then
                return activity.activityFail(entity)
            end
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
                    entity.retrievingBook = false
                    readingSpot.hasReader = true
                    entity.readingStart = 5 -- TODO reading time changes depending on actor
                    xd.debug(xd.ent.inspect(entity, 'readingStart')..' started reading')
                    return true
                end)
            end
        end)
    end
end)