--[[ xhh 2023 ]]
local lume = require('lume')
local inspect = require('inspect')
local M = {}

M.NAN = 0/0
M.LOG={ERROR=0,WARN=1,INFO=2,DEBUG=3}
M.LOG_LEVEL=M.LOG.INFO

local LOG_ICON = {
    [M.LOG.ERROR] = '!',
    [M.LOG.WARN] =  '?', -- '⚠️',
    [M.LOG.INFO] =  'i', -- '📃',
    [M.LOG.DEBUG] =  'x', -- '🔧'
}

local debugGetInfo = debug.getinfo
---@param level number
local function log(level, ...)
    local args = {...}
    local t = debugGetInfo(3)
    -- if #args > 1 then
        print('['..LOG_ICON[level]..']', inspect.inspect(args), '\t('..t.short_src..':'..t.currentline..')')
    -- else
    --     print('['..LOG_ICON[level]..']', inspect.inspect(args[1]), '\t('..t.short_src..':'..t.currentline..')')
    -- end
end

function M.error(...)
    if M.LOG_LEVEL >= M.LOG.ERROR then
        log(M.LOG.ERROR, ...)
    end
end

function M.warn(...)
    if M.LOG_LEVEL >= M.LOG.WARN then
        log(M.LOG.WARN, ...)
    end
end

function M.info(...)
    if M.LOG_LEVEL >= M.LOG.INFO then
        log(M.LOG.INFO, ...)
    end
end

function M.debug(...)
    if M.LOG_LEVEL >= M.LOG.DEBUG then
        log(M.LOG.DEBUG, ...)
    end
end

---@alias id string

---@param prefix? string
---@return id
function M.id(prefix)
    prefix = prefix or ''
    return prefix..'-'..lume.uuid()
end

local Storage = {}
M.Storage = Storage

function Storage.new()
    ---@type table<number, table<string, any>>
    local store = {}

    ---get
    ---@param entity entity
    ---@param key string
    return function(entity, key)
        -- get
        if store[entity.id] then
            return store[entity.id][key]
        end
    end, 
    ---set
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

---@class entity
---@field id id Unique ID
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

---@type table<number, entity>
Entity.entityIDMap = {}

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
        if a.z == b.z then
            return a.id < b.id
        end
        return a.z < b.z
    end
    table.sort(entities, zsort)
end

---@return entity
function Entity.new(props)
    props = setmetatable(props or {}, {
        __tostring = function (t) return 'entity-'..t.id end,
        __eq = function (t1, t2) return t1.id == t2.id end
    })
    
    props.id = Entity._id
    props.x = props.x or 0
    props.y = props.y or 0
    props.r = props.r or 0
    props.sx = props.sx or 1
    props.sy = props.sy or 1
    props.ox = props.ox or 0
    props.oy = props.oy or 0

    table.insert(Entity.entities, props)
    Entity.entityIDMap[props.id] = props
    Entity.remove[props.id] = false
    -- increment count
    Entity._id = Entity._id + 1
    -- sort by z
    sortEntities()
    return props
end

---@param id id
function Entity.get(id)
    return Entity.entityIDMap[id]
end

function Entity.destroy(...)
    for _, id in ipairs({...}) do
        if id ~= M.Scene.world.id then
            Entity.remove[id] = true
        end
    end
end

local getZ, setZ = M.Storage.new()
function Entity.update()
    local resort = 0
    ---@type entity
    local entity
    for e = #Entity.entities, 1, -1 do 
        entity = Entity.entities[e]
        if Entity.remove[entity.id] then
            table.remove(Entity.entities, e)
            Entity.entityIDMap[entity.id] = nil
            break
        end
        -- z index changed?
        if getZ(entity, 'z') ~= entity.z then
            resort = resort + 1
            setZ(entity, 'z', entity.z)
        end
    end
    if resort > 0 then
        resort = 0
        sortEntities(Entity.entities)
    end
end

---@param entity entity
---@param ... string
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

---@param fn fun(entity: entity): boolean
function Entity.find(fn)
    for _, entity in ipairs(Entity.entities) do
        if fn(entity) then
            return entity
        end
    end
end

---@param entity? entity
---@param ... string
function Entity.inspect(entity, ...)
    if not entity then
        return 'nil'
    end
    local keys = {...}
    keys = lume.map(keys, function (key)
        return key..'='..tostring(entity[key])
    end)
    return tostring(entity)..'('..table.concat(keys, ',')..')'
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

---@class DrawingFnOptions
---@field z number

---@class DrawingFnObj
---@field fn function
---@field options DrawingFnOptions

---@type table<number, DrawingFnObj>
Scene.drawingFns = {}

---@type table<number, love.Transform>
Scene.transforms = {}

local function sortDrawingFns()
    ---@param a DrawingFnObj
    ---@param b DrawingFnObj
    local function zsort(a, b)
        if not a.options.z then
            a.options.z = 0
        end
        if not b.options.z then
            b.options.z = 0
        end
        return a.options.z < b.options.z
    end
    table.sort(Scene.drawingFns, zsort)
end

---@param fn fun(entity: entity)
---@param options? DrawingFnOptions
function Scene.addDrawFn(fn, options)
    table.insert(Scene.drawingFns, { fn=fn, options=options or {} })
    sortDrawingFns()
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
        for _, obj in pairs(Scene.drawingFns) do
            love.graphics.push('all')
            -- transform
            love.graphics.replaceTransform(transform)
            obj.fn(entity)
            love.graphics.pop()
        end
    end)
end

---@param dt number
function M.update(dt)
    System.update(dt)
    Entity.update()
    Scene.update()
end

local Signal = {}
M.Signal = Signal

---@type table<string, fun(...)[]>
Signal.listeners = {}

---@param key any|any[]
---@return string
local function getSignalKey(key)
    ---@type string
    local ret
    if type(key) == 'table' then
        ret = table.concat(key,'|')
    else
        ret = tostring(key)
    end
    if not Signal.listeners[ret] then
        Signal.listeners[ret] = {}
    end
    return ret
end

---@param key any|any[]
---@param fn fun(...):boolean? Return `true` to remove listener
function Signal.on(key, fn)
    local signalKey = getSignalKey(key)
    table.insert(Signal.listeners[signalKey], fn)
end

---@param key any|any[]
---@param ... any
function Signal.emit(key, ...)
    local signalKey = getSignalKey(key)
    local args = {...}
    Signal.listeners[signalKey] = lume.filter(Signal.listeners[signalKey], function (item)
        return item(unpack(args)) ~= true
    end)
end

local Test = {}
M.Test = Test

---Not to be used for development
---@param description string
---@param fn fun()
function Test.it(description, fn)
    local status, err = pcall(fn)
    if not status then
        print(lume.format('\27[41mFAIL\27[0m \t{desc} \t({err})', { desc=description, err=err }))
    else
        print(lume.format('\27[42mPASS\27[0m \t{desc}', { desc=description }))
    end
end

---@param expr any
---@param expected any
function Test.expect(expr, expected)
    if expr then
        if type(expr) == 'table' and type(expected) == 'table' then
            expr = inspect.inspect(expr)
            expected = inspect.inspect(expected)
        end
        if expr ~= expected then
            error(tostring(expr)..' ~= '..tostring(expected), 2)
        end
    end
end

---@param text string
function Test.describe(text)
    print(lume.format('\27[107mDESC\27[0m \t-- {desc} --', { desc=text }))
end

-- shorthand
M.sta = M.State
M.ent = M.Entity
M.sys = M.System
M.sce = M.Scene
M.sto = M.Storage
M.sig = M.Signal
M.lume = lume

return M