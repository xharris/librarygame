local lume = require('lume')
local inspect = require('inspect')
local M = {}

M.NAN = 0/0

function M.log(...)
    local args = {...}
    if #args > 1 then
        print(inspect.inspect(args))
    else
        print(inspect.inspect(args[1]))
    end
end

---@class entity
---@field id number Unique ID
---@field z number Z index used for Scene sorting
---@field x? number Position X
---@field y? number Position Y
---@field r? number Rotation (radians)
---@field sx? number Scale X
---@field sy? number Scale Y
---@field ox? number Offset Position X
---@field oy? number Offset Position Y
---@field kx? number Shear X
---@field ky? number Shear Y

local Entity = {}
M.Entity = Entity

Entity._id = 0

---@type entity[]
Entity.entities = {}

---@type table<number, boolean>
Entity.remove = {}

---@param entities? entity[]
local function sortEntities(entities)
    if not entities then
        entities = Entity.entities
    end
    local function zsort(a, b)
        if not a.z then
            a.z = 0
        end
        if not b.z then
            b.z = 0
        end
        return a.z < b.z
    end
    table.sort(entities, zsort)
end

---@return entity
function Entity.new(props)
    props = props or {}
    
    props.id = Entity._id
    props.x = props.x or 0
    props.y = props.y or 0
    props.r = props.r or 0
    props.sx = props.sx or 1
    props.sy = props.sy or 1
    props.ox = props.ox or 0
    props.oy = props.oy or 0

    table.insert(Entity.entities, props)
    Entity.remove[props.id] = false
    -- increment count
    Entity._id = Entity._id + 1
    -- sort by z
    sortEntities()
    return props
end

function Entity.destroy(...)
    for _, id in ipairs({...}) do
        if id ~= M.Scene.world.id then
            Entity.remove[id] = true 
        end
    end
end

---@type table<number, number>
local lastZ = {}
function Entity.update()
    local resort = false
    ---@type entity
    local entity
    for e = #Entity.entities, 1, -1 do 
        entity = Entity.entities[e]
        if Entity.remove[entity.id] then
            table.remove(Entity.entities, e)
            break
        end
        -- z index changed?
        if lastZ[entity.id] ~= entity.z then
            resort = true
            lastZ[entity.id] = entity.z
        end
    end
    if resort then
        resort = false
        sortEntities(Entity.entities)
    end
end

function Entity.has(entity, ...)
    if not entity then return false end
    for _, key in ipairs({...}) do
        if entity[key] == false or entity[key] == nil then
            return false
        end
    end
    return true
end

function Entity.missing(entity, ...)
    if not entity then return true end
    for _, key in ipairs({...}) do
        if entity[key] == false or entity[key] == nil then
            return true
        end
    end
    return false
end

---@param fn fun(entity: entity, idx: number)
function Entity.forEach(fn)
    for e, entity in ipairs(Entity.entities) do
        fn(entity, e)
    end
end

local System = {}
M.System = System

System.systems = {}

---@vararg fun(dt:number, entity:entity)
function System.add(...)
    for _, system in ipairs({...}) do 
        table.insert(System.systems, system)
    end
end

function System.update(dt)
    for _, entity in ipairs(Entity.entities) do
        for _, system in ipairs(System.systems) do 
            system(dt, entity)
        end
    end
end

function System.clear()
    System.systems = {}
end


local State = {}
M.State = State
State.states = { 'dodgem' }
local loaded_states = {}
function State.load(path, ...)
    local state = require(path)
    assert(type(state) == 'table', 'State object is not a table. Did you include a return at the end of the script? ('..path..')')
    if state then
        if state.load then 
            state.load(...)
        end
        state.running = true
    end
    loaded_states[path] = state
    return state
end
function State.quit(path, ...)
    local state = loaded_states[path]
    if state then      
        if state.quit then 
            state.quit(...)
        end
        state.running = false
    end
    loaded_states[path] = nil
end
function State.call(fnName, ...)
    for _, state in pairs(loaded_states) do 
        if state[fnName] then 
            state[fnName](...)
        end
    end
end

local Scene = {}
M.Scene = Scene

Scene.world = Entity.new()

---@type table<number, entity[]>
Scene.children = { [Scene.world.id]={} }

---@type table<number, number>
Scene.childToParent = {}

---@type table<number, function>
Scene.drawingFns = {}

---@type table<number, love.Transform>
Scene.transforms = {}

---@param fn fun(entity: entity)
function Scene.addDrawFn(fn)
    table.insert(Scene.drawingFns, fn)
end

---@param parent entity
---@vararg entity
function Scene.addTo(parent, ...)
    if not Scene.children[parent.id] then
       Scene.children[parent.id] = {}
    end
    for _, child in pairs({...}) do
        if Scene.childToParent[child.id] ~= parent.id then
            -- remove from previous parent
            Scene.children[parent.id] = lume.filter(Scene.children[parent.id], function(id) return id ~= child.id end)
            -- add to parent
            table.insert(Scene.children[parent.id], child)
            Scene.childToParent[child.id] = parent.id
        end
    end
    -- sort by z
    sortEntities()
end

---@vararg entity
function Scene.addToWorld(...)
    return Scene.addTo(Scene.world, ...)
end

local floor = math.floor
---@param x number
local function round(x)
    return floor(x + 5)
end

local tempTransform = love.math.newTransform()

---@param entity? entity
---@param parentTransform? love.Transform
function Scene.update(entity, parentTransform) -- TODO
    if not entity then
        entity = Scene.world
    end
    if not Scene.transforms[entity.id] then
        Scene.transforms[entity.id] = love.math.newTransform()
    end
    -- update transform
    local transform = Scene.transforms[entity.id]
    if parentTransform then
        tempTransform:setTransformation(round(entity.x), round(entity.y), entity.r, entity.sx, entity.sy, round(entity.ox), round(entity.oy), entity.kx, entity.ky)
        transform = parentTransform:clone()
        Scene.transforms[entity.id] = transform:apply(tempTransform)
    else
        transform:setTransformation(round(entity.x), round(entity.y), entity.r, entity.sx, entity.sy, round(entity.ox), round(entity.oy), entity.kx, entity.ky)        
    end
    -- iterate children
    local children = Scene.children[entity.id]
    if children then
        for c, child in lume.ripairs(children) do
            if Entity.remove[child.id] then
                table.remove(children, c)
            else
                Scene.update(child, transform)
            end
        end
    end
end

function Scene.draw()
    Entity.forEach(function(entity)
        local transform = Scene.transforms[entity.id]
        if not transform then return end
        -- draw entity
        for _, fn in pairs(Scene.drawingFns) do
            love.graphics.push('all')
            -- transform
            love.graphics.replaceTransform(transform)
            fn(entity)
            love.graphics.pop()
        end
    end)
end

local Storage = {}
M.Storage = Storage

function Storage.new()
    ---@type table<number, table<string, any>>
    local store = {}

    ---@param entity entity
    ---@param key string
    return function(entity, key)
        -- get
        if store[entity.id] then
            return store[entity.id][key]
        end
    end, 
    ---@param entity entity
    ---@param key string
    ---@param value? any
    function(entity, key, value)
        -- put
        if not store[entity.id] then
            store[entity.id] = {}
        end
        store[entity.id][key] = value
    end
end

---@param dt number
function M.update(dt)
    System.update(dt)
    Entity.update()
    Scene.update()
end

-- shorthand
M.sta = M.State
M.ent = M.Entity
M.sys = M.System
M.sce = M.Scene
M.sto = M.Storage
M.lume = lume

return M