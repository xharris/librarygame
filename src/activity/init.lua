local M = {}

local xd = require('engine')
local g = require('src.global')

---@class withActivity : entity
---@field activity? id
---@field activities? id[]
---@field activityTimer? number Seconds until actor looks for something to do
---@field activityThinking? id Activity is on hold and about to fail
---@field activityThinkingTime? number Time left before activity is failed

xd.sys.add(function (dt, entity)
    ---@cast entity withActivity
    if entity.activities then
        if (not entity.activity or entity.activity == g.ACTIVITY.NOTHING) and g.t % g.CD_FIND_ACTIVITY == 0 then
            -- pick an activity to do
            for _, act in ipairs(entity.activities) do
                local cond = g.ACTIVITY_COND[act]
                if cond and cond(entity) then
                    xd.debug(tostring(entity)..' wants to '..M.getActivityName(act))
                    entity.activity = act
                end
            end
        end
    end
    if M.isActivityOnHold(entity) then
        -- something stopping actor from doing the activity
        entity.activityThinkingTime = entity.activityThinkingTime - dt
        if entity.activityThinkingTime <= 0 then
            -- officially failed to do activity
            xd.debug(tostring(entity)..' failed to '..M.getActivityName(entity.activity))
            if entity.happiness ~= nil then
                entity.happiness = entity.happiness - 10
                xd.debug(tostring(entity)..' happiness -10 --> '..entity.happiness)
            end
            entity.activity = g.ACTIVITY.NOTHING
            entity.activityThinking = nil
            entity.activityThinkingTime = nil
        end
    end
end)

---@param value string|number
function M.getActivityName(value)
    if type(value) == 'string' then
        return value
    end
    local _, name = xd.lume.match(g.ACTIVITY, function (v)
        return value == v
    end)
    return name
end

--- Is an entity waiting on something else to perform at activity?
---@param entity withActivity
function M.isActivityOnHold(entity)
    return entity.activity and entity.activity ~= g.ACTIVITY.NOTHING and entity.activity == entity.activityThinking and entity.activityThinkingTime ~= nil
end

---@param entity withActivity
function M.activityFail(entity)
    local activity = entity.activity
    if activity and not entity.activityThinking then
        xd.debug(tostring(entity)..' thinking about '..M.getActivityName(activity))
        -- start thinking about the activity. start timer before officially failing
        entity.activityThinking = activity
        entity.activityThinkingTime = 5
    end
end

---@param entity withActivity
function M.activitySuccess(entity)
    local activity = entity.activity
    if activity then
        xd.debug(tostring(entity)..' finished '..M.getActivityName(activity))
        entity.activity = g.ACTIVITY.NOTHING
    end
end

return M