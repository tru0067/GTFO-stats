# The enemy datablocks aren't particularly helpful, as they don't give projectile damage and the
# value for Snatcher's stagger HP is incorrect. As a result, trying to read these values from the
# datablocks would have likely caused more difficulty than just hard coding the values.

struct Enemy
    name
    hp
    crit_mult
    back_mult
    stagger_hp
    bodypart_hp  # Tumor HP for boss enemies.
    melee_damage
    tentacle_damage
    projectile_damage
end

const STRIKER           = Enemy("Striker",             20,   3, 2,    5,   10, "N/A", "12%",        "N/A")
const SHOOTER           = Enemy("Shooter",             30,   5, 2,    5,   15, "N/A", "N/A",         "5%")
const GIANT             = Enemy("Giant",              120, 1.5, 2,   40,   15,  "40%","24%",        "N/A")
const BIG_SHOOTER       = Enemy("Big Shooter",        150,   2, 2,   40,  150, "N/A", "N/A",     "3 × 6%")
const HYBRID            = Enemy("Hybrid",             150,   2, 2,   40,  150, "12%", "N/A", "14 × 3.57%")
const SHADOW            = Enemy("Shadow",              20,   3, 2,    5,   17, "N/A", "12%",        "N/A")
const CHARGER           = Enemy("Charger",             30,   1, 2,  6.5,   30,  "4%", "18%",        "N/A")
const NIGHTMARE_STRIKER = Enemy("Nightmare Striker",   37,   2, 2,   20,   37,  "8%", "16%",        "N/A")
const NIGHTMARE_SHOOTER = Enemy("Nightmare Shooter",   18,   3, 2,    8,   18, "N/A", "12%",  "3 × 5.55%")
const BABY              = Enemy("Baby",                 5,   2, 2,    5,    2, "N/A",  "4%",        "N/A")
const FLYER             = Enemy("Flyer",             16.2,   3, 2,    4, 16.2, "N/A", "N/A",     "2 × 4%")
const SCOUT             = Enemy("Scout",               42,   3, 2,    5,   42, "N/A", "N/A",     "3 × 4%")
const CSCOUT            = Enemy("Charger Scout",       60,   1, 2,    5,   60, "12%", "N/A",        "N/A")
const SNATCHER          = Enemy("Snatcher",           225,   1, 2,   40,  225, "N/A", "17%",        "N/A")
const MOTHER            = Enemy("Mother",            1000,   5, 1, 1000,  126, "N/A", "N/A",        "N/A")
const PMOTHER           = Enemy("pMother",           2500,   5, 1, 2500,  313, "N/A", "N/A",        "N/A")
const TANK              = Enemy("Tank",              1000,   3, 1,  400,  150, "32%", "14%",        "N/A")

const ENEMIES = (
    STRIKER, SHOOTER, GIANT, BIG_SHOOTER, HYBRID, SHADOW, CHARGER, NIGHTMARE_STRIKER, NIGHTMARE_SHOOTER,
    BABY, FLYER, SCOUT, CSCOUT, SNATCHER, MOTHER, PMOTHER, TANK,
)
