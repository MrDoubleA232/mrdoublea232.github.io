--[[

    effectReplacer.lua
    by MrDoubleA

]]

local effectReplacer = {}


local replacementFunctions = {}
local replacementIDs = {}

local blockDestroyEffects = {}
local blockDestroyFunctions = {}


function effectReplacer.registerID(originalID,replacementID,replacementFunction)
    replacementFunctions[originalID] = replacementFunction
    replacementIDs[originalID] = replacementID
end

function effectReplacer.registerBlockDestroyEffect(blockID,effectID,effectFunction)
    blockDestroyFunctions[blockID] = effectFunction
    blockDestroyEffects[blockID] = effectID
end


local function deleteEffect(e)
    e.animationFrame = -999
    e.timer = 0
    e.x = 0
    e.y = 0
end


function effectReplacer.doReplacements()
    for _,e in ipairs(Effect.get()) do
        local replacementID = replacementIDs[e.id]

        if replacementID ~= nil then
            if e.timer > 0 then
                -- Spawn new effect
                local newEffect

                if replacementID > 0 then
                    local originalConfig = Effect.config[e.id][1]
                    local config = Effect.config[replacementID][1]

                    local x = e.x - e.width *(originalConfig.xAlign - 0.5) + config.width *(config.xAlign - 0.5)
                    local y = e.y - e.height*(originalConfig.xAlign - 0.5) + config.height*(config.yAlign - 0.5)

                    newEffect = Effect.spawn(replacementID,x,y)
                    newEffect.direction = e.direction
                end

                -- Run function
                if replacementFunctions[e.id] ~= nil then
                    replacementFunctions[e.id](e,newEffect)
                end
            end

            deleteEffect(e)
        end
    end
end


local blockEffectRemovals = {}

local defaultBlockEffects = {
    [60]  = 21,  -- SMB1 underground bricks
    [188] = 51,  -- SMB1 overworld bricks
    [293] = 135, -- SMB2 breakable rocks
    [457] = 100, -- tier 3 powerup bricks
    [526] = 107, -- metroid breakable block
}

local blockEffectLifetimes = {
    [1]   = 200, -- default effect
    [21]  = 200, -- SMB1 underground bricks
    [51]  = 200, -- SMB1 overworld bricks
    [293] = 200, -- SMB2 breakable rocks
    [457] = 200, -- tier 3 powerup bricks
    [107] = 100, -- metroid breakable block
}

function effectReplacer.onTickEnd()
    local i = 1

    while (blockEffectRemovals[i] ~= nil) do
        local removal = blockEffectRemovals[i]

        for _,e in ipairs(Effect.getIntersecting(removal.x - 1,removal.y - 1,removal.x + 1,removal.y + 1)) do
            if e.id == removal.id and e.timer >= (blockEffectLifetimes[e.id] - 1) then
                deleteEffect(e)
            end
        end

        blockEffectRemovals[i] = nil
        i = i + 1
    end
end



function effectReplacer.onPostBlockRemove(block,makeEffects)
    if blockDestroyEffects[block.id] == nil or not makeEffects or block.isHidden then
        return
    end

    -- Spawn new effect
    local effectID = blockDestroyEffects[block.id]
    local newEffect

    if effectID > 0 then
        local config = Effect.config[effectID][1]

        local x = block.x + block.width *0.5 + config.width *(config.xAlign - 0.5)
        local y = block.y + block.height*0.5 + config.height*(config.yAlign - 0.5)

        newEffect = Effect.spawn(effectID,x,y)
    end

    -- Run function
    if blockDestroyFunctions[block.id] ~= nil then
        blockDestroyFunctions[block.id](block,newEffect)
    end

    -- Remove existing effects
    -- They won't spawn until after onPostBlockRemove runs, so we instead need to do it in the following onTickEnd call
    table.insert(blockEffectRemovals,{
        id = defaultBlockEffects[block.id] or 1,
        x = block.x + block.width*0.5,
        y = block.y + block.height*0.5,
    })
end



function effectReplacer.onInitAPI()
    registerEvent(effectReplacer,"onTick","doReplacements")
    registerEvent(effectReplacer,"onTickEnd","doReplacements")
    registerEvent(effectReplacer,"onDraw","doReplacements")

    registerEvent(effectReplacer,"onTickEnd")
    registerEvent(effectReplacer,"onPostBlockRemove")
end


return effectReplacer