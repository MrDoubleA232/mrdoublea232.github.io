function onTick()
    for _,p in ipairs(Player.get()) do
        if p.keys.dropItem == KEYS_PRESSED then
            p.speedY = -20
            SFX.play(43)
        end
    end
end