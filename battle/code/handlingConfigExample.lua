local onlinePlayNPC = require("scripts/onlinePlay_npc")

-- 751 is the ID of the NPC you want to affect here.
onlinePlayNPC.onlineHandlingConfig[751] = {
    getExtraData = function(v)
        -- The owner of the NPC will run getExtraData.
        -- Its return value will then be received by everyone else in setExtraData.
        local data = v.data
        if not data.initialized then
            return nil
        end

        return {
            state = data.state,
            timer = data.timer,
        }
    end,
    setExtraData = function(v,receivedData)
        -- The data from getExtraData will be used to change the NPC's state.
        -- This is mainly for data table syncing, but it can also be used for any information about the NPC.
        local data = v.data
        if not data.initialized then
            return nil
        end

        data.state = receivedData.state
        data.timer = receivedData.timer
    end,
}