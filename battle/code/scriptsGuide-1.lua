function onTick()
    if player.keys.dropItem == KEYS_PRESSED then
        player.speedY = -20
        SFX.play(43)
    end
end