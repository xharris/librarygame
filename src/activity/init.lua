local M = {}

local xd = require('engine')
local g = require('src.global')

---@class entityWithActivity : entity
---@field activity? id
---@field activities? id[]
---@field activityThinking? id Activity is on hold and about to fail
---@field activityThinkingTime? number Time left before activity is failed

xd.sys.add(function (dt, entity)
    ---@cast entity entityWithActivity
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
        entity.activityThinkingTime = entity.activityThinkingTime - dt
        if entity.activityThinkingTime <= 0 then
            -- officially failed to do activity
            xd.debug(tostring(entity)..' failed to '..M.getActivityName(entity.activity))
            if g.ACTIVITY_FAIL[entity.activity] then
                g.ACTIVITY_FAIL[entity.activity](entity)
            end
            entity.activity = g.ACTIVITY.NOTHING
            entity.activityThinking = nil
            entity.activityThinkingTime = nil
        end
    end
end)

---@param value string
function M.getActivityName(value)
    local _, name = xd.lume.match(g.ACTIVITY, function (v)
        return value == v
    end)
    return name
end

---@param entity entityWithActivity
function M.isActivityOnHold(entity)
    return entity.activity and entity.activity ~= g.ACTIVITY.NOTHING and entity.activity == entity.activityThinking and entity.activityThinkingTime ~= nil
end

---@param entity entityWithActivity
---@param activity string
function M.activityFail(entity, activity)
    if not entity.activityThinking then
        xd.debug(tostring(entity)..' thinking about '..M.getActivityName(activity))
        -- start thinking about the activity. start timer before officially failing
        entity.activityThinking = activity
        entity.activityThinkingTime = 5
    end
end

return M