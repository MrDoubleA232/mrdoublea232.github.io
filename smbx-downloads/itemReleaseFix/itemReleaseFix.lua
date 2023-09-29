--[[

    itemReleaseFix.lua
    by MrDoubleA

    Fixes some jank when dropping/throwing held NPCs into walls.

]]

local itemReleaseFix = {}


itemReleaseFix.enabled = true


local previouslyHeldNPCs = {}


local function getCollidingSolids(v)
    local blocks = Colliders.getColliding{
        a = v,
        btype = Colliders.BLOCK,
        filter = function(b)
            if b.isHidden or b:mem(0x5A,FIELD_BOOL) then
                return false
            end
            
            local config = Block.config[b.id]

            if config.passthrough or config.semisolid or config.sizeable then
                return false
            end

            if config.npcfilter < 0 or config.npcfilter == v.id then
                return false
            end

            return true
        end,
    }

    local npcs = Colliders.getColliding{
        a = v,
        btype = Colliders.NPC,
        filter = function(n)
            if n == v or n.despawnTimer <= 0 or n.friendly or n:mem(0x12C,FIELD_WORD) > 0 or n:mem(0x138,FIELD_WORD) > 0 or n:mem(0x136,FIELD_BOOL) then
                return false
            end

            local config = NPC.config[n.id]

            return config.npcblock
        end,
    }

    return table.append(blocks,npcs)
end

local function ejectFromBlocks(p,v)
    -- Check for intersecting solids
    local solids = getCollidingSolids(v)

    if #solids == 0 then
        return
    end

    -- Perform two line casts - one from the NPC's top and one from its bottom -
    -- into those solids to determine where to eject it to.
    local castStartX = p.x + p.width*0.5
    local castStopX = v.x + v.width*0.5

    local bottomY = math.min(v.y + v.height,p.y + p.height) - 2
    local topY = v.y + 2

    local bottomHit,bottomHitPoint,_,_ = Colliders.linecast(vector(castStartX,bottomY),vector(castStopX,bottomY),solids)
    local topHit,topHitPoint,_,_ = Colliders.linecast(vector(castStartX,topY),vector(castStopX,topY),solids)

    if bottomHit or topHit then
        -- Snap it to the closer point
        if bottomHit and (not topHit or math.abs(castStartX - bottomHitPoint.x) <= math.abs(castStartX - topHitPoint.x)) then
            v.x = bottomHitPoint.x - v.width*(1 + p.direction)*0.5
        else
            v.x = topHitPoint.x - v.width*(1 + p.direction)*0.5
        end

        v.x = v.x - p.direction*2

        v:mem(0x132,FIELD_WORD,p.idx) -- "battle owner" (also determines solidity)
        v:mem(0x134,FIELD_WORD,0) -- crush timer
        v:mem(0x136,FIELD_BOOL,true) -- projectile state

        --Colliders.getHitbox(v):debug(true)
    end
end


function itemReleaseFix.onTickEnd()
    for _,p in ipairs(Player.get()) do
        local v = previouslyHeldNPCs[p.idx]
        local holdingNPC = p.holdingNPC

        if holdingNPC == nil and v ~= nil and v.isValid and itemReleaseFix.enabled then
            ejectFromBlocks(p,v)
        end

        previouslyHeldNPCs[p.idx] = holdingNPC
    end
end


function itemReleaseFix.onInitAPI()
    registerEvent(itemReleaseFix, "onTickEnd")
end


return itemReleaseFix