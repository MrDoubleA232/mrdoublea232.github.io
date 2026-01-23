local onlinePlay = require("scripts/onlinePlay")
local onlinePlayNPC = require("scripts/onlinePlay_npc")

-- NPC commands are created exactly like regular commands, just with a different function.
-- You should include the name of your NPC in the command name, to make it more unique.
local exampleCommand = onlinePlayNPC.createNPCCommand("myNPCName_example", onlinePlay.IMPORTANCE_MAJOR)

-- onReceive works almost the same, but there is an added argument: the NPC for the command.
function exampleCommand.onReceive(npc,sourcePlayerIdx, foo,bar)
    -- Your code here.
end

-- Command:send is also mostly the same as a regular command, just with an NPC.
exampleCommand:send(npc,0, foo,bar)