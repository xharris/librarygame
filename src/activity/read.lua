--[[
    - move to book storage
    - take book
]]

---@class reader: withActivity
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
local actor = require('src.actor')

---@class withReadActivity : withActivity
---@field readState? READ_STATE
---@field readStart? number Seconds left for reading
---@field readBookId? id Book the patron is reading
---@field readSpot? id Tile the actor is sitting on

---@enum READ_STATE
local STATE = {GET_BOOK='get_book', READ_BOOK='read_book', RETURN_BOOK='return_book'}

---@param item entity
local function isBook(item)
    return item.itemType == g.ITEM.BOOK
end

xd.sys.add(function (dt, entity)
    ---@cast entity withReadActivity

    if entity.readState == STATE.READ_BOOK and entity.readStart ~= nil and entity.readBookId then
        -- reading
        entity.readStart = entity.readStart - dt
        if entity.readStart <= 0 then
            -- return the book to storage
            xd.debug(tostring(entity)..' is done reading')
            if entity.readSpot then
                local readingSpot = xd.ent.get(entity.readSpot)
                if readingSpot then
                    readingSpot.hasReader = false
                end
            end
            entity.readState = STATE.RETURN_BOOK
            storage.storeItem(entity, function (item)
                return item.id == entity.readBookId
            end, function (success)
                if not success then
                    -- drop the book on the ground
                    xd.info(tostring(entity)..' did not return book id='..entity.readBookId)
                end
                activity.activitySuccess(entity)
                entity.readState = nil
                entity.readStart = nil
                entity.readBookId = nil
            end)
        end
    end

    if entity.readState == nil and entity.activity == g.ACTIVITY.READ and not activity.isActivityOnHold(entity) then
        entity.readState = STATE.GET_BOOK
        storage.retrieveItem(entity, isBook, function (item)
            ---@cast item entity
            if not item then
                return activity.activityFail(entity)
            end
            -- find a place to sit
            actor.sit(entity, function (success)
                if success then
                    entity.readState = STATE.READ_BOOK
                    entity.readStart = 1 -- TODO reading time changes depending on actor and book
                    entity.readBookId = item.id
                    xd.debug(xd.ent.inspect(entity, 'readStart')..' started reading')
                else
                    activity.activityFail(entity)
                end
            end)
        end)
    end
end)