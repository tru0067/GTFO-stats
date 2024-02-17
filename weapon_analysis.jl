# Firemodes.
const SEMI = 0
const BURST = 1
const AUTO = 2

# Gets the damage per shot of a particular weapon. Accounts for shotgun pellets.
function d(wdb)
    if wdb["ShotgunBulletCount"] == 0
        return wdb["Damage"]
    else
        return wdb["Damage"] * wdb["ShotgunBulletCount"]
    end
end
