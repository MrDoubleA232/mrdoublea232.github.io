-- Gotta load the library!
local onlinePlay = require("scripts/onlinePlay")

-- Remember to give your command a unique enough name!
local launchPlayerCommand = onlinePlay.createCommand("launchPlayer",onlinePlay.IMPORTANCE_MAJOR)

-- The logic for launching the player has been moved into its own function.
-- This helps to reduce duplicate code.
local function launchPlayer(p)
    p.speedY = -20
    SFX.play(43)
end

-- When the command is received, it should call the launchPlayer function.
-- Note that, since player objects cannot be directly sent, a player index is used instead.
function launchPlayerCommand.onReceive(sourcePlayerIdx, playerIdx)
    local p = Player(playerIdx)

    launchPlayer(p)
end

function onTick()
    for _,p in ipairs(Player.get()) do
        if p.keys.dropItem == KEYS_PRESSED then
            -- If online, send an event to everyone else
            if onlinePlay.currentMode ~= onlinePlay.MODE_OFFLINE then
                launchPlayerCommand:send(0,p.idx)
            end

            launchPlayer(p)
        end
    end
end