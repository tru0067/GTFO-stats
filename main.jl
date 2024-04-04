VANILLA_DB_PATH = "C:/Users/Admin/AppData/Roaming/r2modmanPlus-local/GTFO/profiles/gamedatadump/BepInEx/GameData-Dump/34850"
# Vanilla
DB_PATH = VANILLA_DB_PATH
# Vanilla Reloaded
#DB_PATH = "C:/Users/Admin/Documents/games/gtfo/modding/VanillaReloaded/BepInEx/plugins/VanillaReloaded"
# Inferno
#DB_PATH = "C:/Users/Admin/AppData/Roaming/r2modmanPlus-local/GTFO/profiles/inferno/BepInEx/plugins/Dovah-Inferno/Inferno"
# Occlusion
#DB_PATH = "C:/Users/Admin/AppData/Roaming/r2modmanPlus-local/GTFO/profiles/occlusion/BepInEx/plugins/Dakstar-Occlusion/Occlusion"
# Breakthrough
#DB_PATH = "C:/Users/Admin/AppData/Roaming/r2modmanPlus-local/GTFO/profiles/breakthrough/BepInEx/plugins/GTFO_Modding_Admin_Team-BREAKTHROUGH_2/Breakthrough 2"

include("enemies.jl")
include("read_datablocks.jl")
include("weapon_analysis.jl")

SEP = "\t"  # Separator to use in the CSV file.

# These could be read in from the datablocks, but they're unlikely to change.
AMMO_REFILL_MAIN    = 90
AMMO_START_MAIN     = 300
AMMO_MAX_MAIN       = 460
AMMO_REFILL_SPECIAL = 90
AMMO_START_SPECIAL  = 150
AMMO_MAX_SPECIAL    = 230
TOOL_REFILL_SENTRY  = 30/0.285
TOOL_START_SENTRY   = 100/0.285
TOOL_MAX_SENTRY     = 150/0.285

####################################################################################################
#                                           Weapon Stats                                           #
####################################################################################################

STATS_COLS = (
    ("name",
        :(wdb["name"])),
    ("Weapon",
        :(weapon[1])),
    ("Damage",
        :(d(wdb))),
    ("Precision Multiplier",
        :(wdb["PrecisionDamageMulti"])),
    ("Stagger Multiplier",
        :(wdb["StaggerDamageMulti"])),
    ("Clip Size",
        :(wdb["DefaultClipSize"])),
    ("Damage per Clip",
        :("""=$(stats_cell("Damage", weapon))\
              *$(stats_cell("Clip Size", weapon))""")),
    ("Rounds per Refill",
        :("""=$(main ? AMMO_REFILL_MAIN : AMMO_REFILL_SPECIAL)\
              /$(stats_cell("Bullet Cost", weapon))""")),
    ("Damage per Refill",
        :("""=$(stats_cell("Damage", weapon))\
              *$(stats_cell("Rounds per Refill", weapon))""")),
    ("Starting Ammo",
        :("""=$(main ? AMMO_START_MAIN : AMMO_START_SPECIAL)\
              /$(stats_cell("Bullet Cost", weapon))""")),
    ("Max Ammo without Clip",
        :("""=rounddown($(main ? AMMO_MAX_MAIN : AMMO_MAX_SPECIAL)\
              /$(stats_cell("Bullet Cost", weapon)))""")),
    ("Max Ammo with Clip",
        :("""=$(stats_cell("Max Ammo without Clip", weapon))\
              +$(stats_cell("Clip Size", weapon))""")),
    ("Refill (%)",
        :("""=($(stats_cell("Rounds per Refill", weapon))\
               /$(stats_cell("Max Ammo with Clip", weapon)))\
              *100""")),
    ("Bullet Cost",
        :(wdb["CostOfBullet"])),
    ("Piercing",
        :(wdb["PiercingBullets"] ? wdb["PiercingDamageCountLimit"] : "N/A")),
    ("Reload Time",
        :(wdb["DefaultReloadTime"])),
    ("Shot Delay",
        :(wdb["ShotDelay"])),
    ("Burst Delay",
        :(wdb["FireMode"] == BURST ? wdb["BurstDelay"] : "N/A")),
    ("Burst Count",
        :(wdb["FireMode"] == BURST ? wdb["BurstShotCount"] : "N/A")),
    ("Pellet Count",
        :(wdb["ShotgunBulletCount"] != 0 ? wdb["ShotgunBulletCount"] : "1")),
    ("Charge Time",
        :(wdb["SpecialChargetupTime"])),
    ("Cooldown Time",
        :(wdb["SpecialCooldownTime"])),
    #("Equip Time",
    #    ""),
    #("Aim Time",
    #    ""),
    #("Cone Size",
    #    ""),
    #("Spread",
    #    ""),
    #("Hip Spread",
    #    ""),
    ("Falloff Start",
        :(wdb["DamageFalloff"]["x"])),
    ("Falloff End",
        :(wdb["DamageFalloff"]["y"])),
    ("DPS (Mid Clip)",
        :("""=ifs($(stats_cell("Fire Mode", weapon))="Semi",\
                      $(stats_cell("Damage", weapon))\
                      /(max($(stats_cell("Shot Delay", weapon)),\
                            $(stats_cell("Cooldown Time", weapon)))\
                        +$(stats_cell("Charge Time", weapon))),\
                  $(stats_cell("Fire Mode", weapon))="Burst",\
                      $(stats_cell("Burst Count", weapon))\
                      *$(stats_cell("Damage", weapon))\
                      /(($(stats_cell("Burst Count", weapon))-1)\
                        *$(stats_cell("Shot Delay", weapon))\
                        +(max($(stats_cell("Shot Delay", weapon)),\
                              $(stats_cell("Cooldown Time", weapon)),\
                              $(stats_cell("Burst Delay", weapon)))\
                          +$(stats_cell("Charge Time", weapon)))),\
                  $(stats_cell("Fire Mode", weapon))="Auto",\
                      $(stats_cell("Damage", weapon))\
                      /$(stats_cell("Shot Delay", weapon)))""")),
    ("Time to Empty Clip",
        :("""=ifs($(stats_cell("Fire Mode", weapon))="Semi",\
                      max($(stats_cell("Shot Delay", weapon)),\
                          $(stats_cell("Cooldown Time", weapon))\
                          +$(stats_cell("Charge Time", weapon)))\
                      *($(stats_cell("Clip Size", weapon))-1),\
                  $(stats_cell("Fire Mode", weapon))="Burst",\
                      ($(stats_cell("Burst Count", weapon))-1)\
                      *$(stats_cell("Shot Delay", weapon))\
                      *$(stats_cell("Clip Size", weapon))\
                      /$(stats_cell("Burst Count", weapon))\
                      +max($(stats_cell("Shot Delay", weapon)),\
                           $(stats_cell("Cooldown Time", weapon))\
                           +$(stats_cell("Charge Time", weapon)),\
                           $(stats_cell("Burst Delay", weapon)))\
                      *($(stats_cell("Clip Size", weapon))\
                        /$(stats_cell("Burst Count", weapon))-1),\
                  $(stats_cell("Fire Mode", weapon))="Auto",\
                      $(stats_cell("Charge Time", weapon))\
                      +$(stats_cell("Shot Delay", weapon))\
                      *($(stats_cell("Clip Size", weapon))-1))""")),
    ("Fire Mode",
        :(wdb["FireMode"] == SEMI ? "Semi" : (wdb["FireMode"]) == BURST ? "Burst" : "Auto")),
    #("Flashlight",
    #    ""),
)

gen_stats_string = @eval function(weapon; main=true)
    wdb = weapon[2]
    # Since these expressions are being evaluated in a weird scope, they're not allowed to have
    # variables as part of their invocation, thus this must all be hardcoded.
    return (    string($(STATS_COLS[1][2]))  * SEP * string($(STATS_COLS[2][2]))
        * SEP * string($(STATS_COLS[3][2]))  * SEP * string($(STATS_COLS[4][2]))
        * SEP * string($(STATS_COLS[5][2]))  * SEP * string($(STATS_COLS[6][2]))
        * SEP * string($(STATS_COLS[7][2]))  * SEP * string($(STATS_COLS[8][2]))
        * SEP * string($(STATS_COLS[9][2]))  * SEP * string($(STATS_COLS[10][2]))
        * SEP * string($(STATS_COLS[11][2])) * SEP * string($(STATS_COLS[12][2]))
        * SEP * string($(STATS_COLS[13][2])) * SEP * string($(STATS_COLS[14][2]))
        * SEP * string($(STATS_COLS[15][2])) * SEP * string($(STATS_COLS[16][2]))
        * SEP * string($(STATS_COLS[17][2])) * SEP * string($(STATS_COLS[18][2]))
        * SEP * string($(STATS_COLS[19][2])) * SEP * string($(STATS_COLS[20][2]))
        * SEP * string($(STATS_COLS[21][2])) * SEP * string($(STATS_COLS[22][2]))
        * SEP * string($(STATS_COLS[23][2])) * SEP * string($(STATS_COLS[24][2]))
        * SEP * string($(STATS_COLS[25][2])) * SEP * string($(STATS_COLS[26][2]))
        * SEP * string($(STATS_COLS[27][2])) * "\n"
    )
end

function stats_cell(col_name, weapon)
    c = "A"
    for (c_name, _) in STATS_COLS
        if c_name == col_name
            # Found the stats column, now look for the weapon row.
            row = 2
            for w in MAIN_WEAPONS
                if weapon == w
                    return "\$$c$row"
                end
                row += 1
            end
            row += 1  # Accounts for the blank line between Main and Special weapons.
            for w in SPECIAL_WEAPONS
                if weapon == w
                    return "\$$c$row"
                end
                row += 1
            end
            return "ROW NOT FOUND"
        end

        # Increment column letter(s). Assumes column letter(s) never goes beyond ZZ.
        if c == "Z"
            c = "AA"
        elseif c[end] == 'Z'
            c = (c[end-1] + 1) * "A"
        else
            c = c[1:end-1] * (c[end] + 1)
        end
    end
    return "COLUMN NOT FOUND"
end

function gen_stats_header()
    stats_header = ""
    for (h, _) in STATS_COLS[1:end-1]
        stats_header *= h * SEP
    end
    return stats_header * STATS_COLS[end][1] * "\n"
end

####################################################################################################
#                                         Efficiency Stats                                         #
####################################################################################################

EFF_COLS = (
    ("~Weapon",
        :(weapon[1])),
    ("Striker~HS+BS",
        :("""=if($(stats_cell("Damage", weapon))\
                 *$(stats_cell("Precision Multiplier", weapon))\
                 *$(enemy_cell("Critical Multiplier", STRIKER))\
                 >$(enemy_cell("HP", STRIKER)),\
                 1,\
                 roundup($(enemy_cell("Body-Part HP", STRIKER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", STRIKER))))\
                 &"+"&\
                 roundup(($(enemy_cell("HP", STRIKER))\
                          -roundup($(enemy_cell("Body-Part HP", STRIKER))\
                                   /($(stats_cell("Damage", weapon))\
                                     *$(stats_cell("Precision Multiplier", weapon))\
                                     *$(enemy_cell("Critical Multiplier", STRIKER))))\
                          *$(stats_cell("Damage", weapon))\
                          *$(stats_cell("Precision Multiplier", weapon))\
                          *$(enemy_cell("Critical Multiplier", STRIKER)))\
                         /$(stats_cell("Damage", weapon))))""")),
    ("Striker~Body",
        :("""=roundup($(enemy_cell("HP", STRIKER))\
                      /$(stats_cell("Damage", weapon)))""")),
    ("Striker~Back",
        :("""=roundup($(enemy_cell("HP", STRIKER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(enemy_cell("Back Multiplier", STRIKER))))""")),
    ("Striker~Occiput",
        :("""=if($(stats_cell("Damage", weapon))\
                 *$(stats_cell("Precision Multiplier", weapon))\
                 *$(enemy_cell("Occiput Multiplier", STRIKER))\
                 >$(enemy_cell("HP", STRIKER)),\
                 1,\
                 roundup($(enemy_cell("Body-Part HP", STRIKER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Occiput Multiplier", STRIKER))))\
                 &"+"&\
                 roundup(($(enemy_cell("HP", STRIKER))\
                          -roundup($(enemy_cell("Body-Part HP", STRIKER))\
                                   /($(stats_cell("Damage", weapon))\
                                     *$(stats_cell("Precision Multiplier", weapon))\
                                     *$(enemy_cell("Occiput Multiplier", STRIKER))))\
                          *$(stats_cell("Damage", weapon))\
                          *$(stats_cell("Precision Multiplier", weapon))\
                          *$(enemy_cell("Occiput Multiplier", STRIKER)))\
                         /($(stats_cell("Damage", weapon))\
                           *$(enemy_cell("Back Multiplier", STRIKER)))))""")),
    ("Striker~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /(roundup($(enemy_cell("Body-Part HP", STRIKER))\
                        /($(stats_cell("Damage", weapon))\
                          *$(stats_cell("Precision Multiplier", weapon))\
                          *$(enemy_cell("Critical Multiplier", STRIKER))))\
                +max(0,roundup(($(enemy_cell("HP", STRIKER))\
                                -roundup($(enemy_cell("Body-Part HP", STRIKER))\
                                         /($(stats_cell("Damage", weapon))\
                                           *$(stats_cell("Precision Multiplier", weapon))\
                                           *$(enemy_cell("Critical Multiplier", STRIKER))))\
                                *$(stats_cell("Damage", weapon))\
                                *$(stats_cell("Precision Multiplier", weapon))\
                                *$(enemy_cell("Critical Multiplier", STRIKER)))\
                               /$(stats_cell("Damage", weapon)))))""")),
    ("Striker~Body Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Striker~Body", weapon))""")),
    ("Shooter~HS+BS",
        :("""=if(and(max(roundup($(enemy_cell("HP", SHOOTER))\
                                /($(stats_cell("Damage", weapon))\
                                  *$(stats_cell("Precision Multiplier", weapon))\
                                  *$(enemy_cell("Critical Multiplier", SHOOTER))))\
                         -1,\
                         0)\
                     *($(stats_cell("Damage", weapon))\
                       *$(stats_cell("Precision Multiplier", weapon))\
                       *$(enemy_cell("Critical Multiplier", SHOOTER)))\
                     +$(stats_cell("Damage", weapon))\
                     >$(enemy_cell("HP", SHOOTER)),\
                     $(stats_cell("Damage", weapon))\
                     <$(enemy_cell("HP", SHOOTER))),\
                 roundup($(enemy_cell("HP", SHOOTER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", SHOOTER))))\
                 -1&"+1",\
                 roundup($(enemy_cell("HP", SHOOTER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", SHOOTER)))))""")),
    ("Shooter~Body",
        :("""=roundup($(enemy_cell("HP", SHOOTER))\
                      /$(stats_cell("Damage", weapon)))""")),
    ("Shooter~Back",
        :("""=roundup($(enemy_cell("HP", SHOOTER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(enemy_cell("Back Multiplier", SHOOTER))))""")),
    ("Shooter~Occiput",
        :("""=roundup($(enemy_cell("HP", SHOOTER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(stats_cell("Precision Multiplier", weapon))\
                        *$(enemy_cell("Occiput Multiplier", SHOOTER))))""")),
    ("Shooter~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /roundup($(enemy_cell("HP", SHOOTER))\
                       /($(stats_cell("Damage", weapon))\
                         *$(stats_cell("Precision Multiplier", weapon))\
                         *$(enemy_cell("Critical Multiplier", SHOOTER))))""")),
    ("Shooter~Body Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Shooter~Body", weapon))""")),
    ("Giant~HS+BS",
        :("""=if($(stats_cell("Damage", weapon))\
                 *$(stats_cell("Precision Multiplier", weapon))\
                 *$(enemy_cell("Critical Multiplier", GIANT))\
                 >$(enemy_cell("HP", GIANT)),\
                 1,\
                 roundup($(enemy_cell("Body-Part HP", GIANT))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", GIANT))))\
                 &"+"&\
                 roundup(($(enemy_cell("HP", GIANT))\
                          -roundup($(enemy_cell("Body-Part HP", GIANT))\
                                   /($(stats_cell("Damage", weapon))\
                                     *$(stats_cell("Precision Multiplier", weapon))\
                                     *$(enemy_cell("Critical Multiplier", GIANT))))\
                          *$(stats_cell("Damage", weapon))\
                          *$(stats_cell("Precision Multiplier", weapon))\
                          *$(enemy_cell("Critical Multiplier", GIANT)))\
                         /$(stats_cell("Damage", weapon))))""")),
    ("Giant~Body",
        :("""=roundup($(enemy_cell("HP", GIANT))\
                      /$(stats_cell("Damage", weapon)))""")),
    ("Giant~Back",
        :("""=roundup($(enemy_cell("HP", GIANT))\
                      /($(stats_cell("Damage", weapon))\
                        *$(enemy_cell("Back Multiplier", GIANT))))""")),
    ("Giant~Occiput",
        :("""=if($(stats_cell("Damage", weapon))\
                 *$(stats_cell("Precision Multiplier", weapon))\
                 *$(enemy_cell("Occiput Multiplier", GIANT))\
                 >$(enemy_cell("HP", GIANT)),\
                 1,\
                 roundup($(enemy_cell("Body-Part HP", GIANT))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Occiput Multiplier", GIANT))))\
                 &"+"&\
                 roundup(($(enemy_cell("HP", GIANT))\
                          -roundup($(enemy_cell("Body-Part HP", GIANT))\
                                   /($(stats_cell("Damage", weapon))\
                                     *$(stats_cell("Precision Multiplier", weapon))\
                                     *$(enemy_cell("Occiput Multiplier", GIANT))))\
                          *$(stats_cell("Damage", weapon))\
                          *$(stats_cell("Precision Multiplier", weapon))\
                          *$(enemy_cell("Occiput Multiplier", GIANT)))\
                         /($(stats_cell("Damage", weapon))\
                           *$(enemy_cell("Back Multiplier", GIANT)))))""")),
    ("Giant~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /(roundup($(enemy_cell("Body-Part HP", GIANT))\
                        /($(stats_cell("Damage", weapon))\
                          *$(stats_cell("Precision Multiplier", weapon))\
                          *$(enemy_cell("Critical Multiplier", GIANT))))\
                +max(0,roundup(($(enemy_cell("HP", GIANT))\
                                -roundup($(enemy_cell("Body-Part HP", GIANT))\
                                         /($(stats_cell("Damage", weapon))\
                                           *$(stats_cell("Precision Multiplier", weapon))\
                                           *$(enemy_cell("Critical Multiplier", GIANT))))\
                                *$(stats_cell("Damage", weapon))\
                                *$(stats_cell("Precision Multiplier", weapon))\
                                *$(enemy_cell("Critical Multiplier", GIANT)))\
                               /$(stats_cell("Damage", weapon)))))""")),
    ("Giant~Body Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Giant~Body", weapon))""")),
    ("Big Shooter/Hybrid~Head",
        :("""=if(and(max(roundup($(enemy_cell("HP", BIG_SHOOTER))\
                                /($(stats_cell("Damage", weapon))\
                                  *$(stats_cell("Precision Multiplier", weapon))\
                                  *$(enemy_cell("Critical Multiplier", BIG_SHOOTER))))\
                         -1,\
                         0)\
                     *($(stats_cell("Damage", weapon))\
                       *$(stats_cell("Precision Multiplier", weapon))\
                       *$(enemy_cell("Critical Multiplier", BIG_SHOOTER)))\
                     +$(stats_cell("Damage", weapon))\
                     >$(enemy_cell("HP", BIG_SHOOTER)),\
                     $(stats_cell("Damage", weapon))\
                     <$(enemy_cell("HP", BIG_SHOOTER))),\
                 roundup($(enemy_cell("HP", BIG_SHOOTER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", BIG_SHOOTER))))\
                 -1&"+1",\
                 roundup($(enemy_cell("HP", BIG_SHOOTER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", BIG_SHOOTER)))))""")),
    ("Big Shooter/Hybrid~Body",
        :("""=roundup($(enemy_cell("HP", BIG_SHOOTER))\
                      /$(stats_cell("Damage", weapon)))""")),
    ("Big Shooter/Hybrid~Back",
        :("""=roundup($(enemy_cell("HP", BIG_SHOOTER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(enemy_cell("Back Multiplier", BIG_SHOOTER))))""")),
    ("Big Shooter/Hybrid~Occiput",
        :("""=roundup($(enemy_cell("HP", BIG_SHOOTER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(stats_cell("Precision Multiplier", weapon))\
                        *$(enemy_cell("Occiput Multiplier", BIG_SHOOTER))))""")),
    ("Big Shooter/Hybrid~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /roundup($(enemy_cell("HP", BIG_SHOOTER))\
                       /($(stats_cell("Damage", weapon))\
                         *$(stats_cell("Precision Multiplier", weapon))\
                         *$(enemy_cell("Critical Multiplier", BIG_SHOOTER))))""")),
    ("Big Shooter/Hybrid~Body Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Big Shooter/Hybrid~Body", weapon))""")),
    ("Charger~Body",
        :("""=roundup($(enemy_cell("HP", CHARGER))\
                      /$(stats_cell("Damage", weapon)))""")),
    ("Charger~Back",
        :("""=roundup($(enemy_cell("HP", CHARGER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(enemy_cell("Back Multiplier", CHARGER))))""")),
    ("Charger~Body Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Charger~Body", weapon))""")),
    ("Nightmare Striker~HS+BS",
        :("""=if(and(max(roundup($(enemy_cell("HP", NIGHTMARE_STRIKER))\
                                /($(stats_cell("Damage", weapon))\
                                  *$(stats_cell("Precision Multiplier", weapon))\
                                  *$(enemy_cell("Critical Multiplier", NIGHTMARE_STRIKER))))\
                         -1,\
                         0)\
                     *($(stats_cell("Damage", weapon))\
                       *$(stats_cell("Precision Multiplier", weapon))\
                       *$(enemy_cell("Critical Multiplier", NIGHTMARE_STRIKER)))\
                     +$(stats_cell("Damage", weapon))\
                     >$(enemy_cell("HP", NIGHTMARE_STRIKER)),\
                     $(stats_cell("Damage", weapon))\
                     <$(enemy_cell("HP", NIGHTMARE_STRIKER))),\
                 roundup($(enemy_cell("HP", NIGHTMARE_STRIKER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", NIGHTMARE_STRIKER))))\
                 -1&"+1",\
                 roundup($(enemy_cell("HP", NIGHTMARE_STRIKER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", NIGHTMARE_STRIKER)))))""")),
    ("Nightmare Striker~Body",
        :("""=roundup($(enemy_cell("HP", NIGHTMARE_STRIKER))\
                      /$(stats_cell("Damage", weapon)))""")),
    ("Nightmare Striker~Back",
        :("""=roundup($(enemy_cell("HP", NIGHTMARE_STRIKER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(enemy_cell("Back Multiplier", NIGHTMARE_STRIKER))))""")),
    ("Nightmare Striker~Occiput",
        :("""=roundup($(enemy_cell("HP", NIGHTMARE_STRIKER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(stats_cell("Precision Multiplier", weapon))\
                        *$(enemy_cell("Occiput Multiplier", NIGHTMARE_STRIKER))))""")),
    ("Nightmare Striker~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /roundup($(enemy_cell("HP", NIGHTMARE_STRIKER))\
                       /($(stats_cell("Damage", weapon))\
                         *$(stats_cell("Precision Multiplier", weapon))\
                         *$(enemy_cell("Critical Multiplier", NIGHTMARE_STRIKER))))""")),
    ("Nightmare Striker~Body Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Nightmare Striker~Body", weapon))""")),
    ("Nightmare Shooter~HS+BS",
        :("""=if(and(max(roundup($(enemy_cell("HP", NIGHTMARE_SHOOTER))\
                                /($(stats_cell("Damage", weapon))\
                                  *$(stats_cell("Precision Multiplier", weapon))\
                                  *$(enemy_cell("Critical Multiplier", NIGHTMARE_SHOOTER))))\
                         -1,\
                         0)\
                     *($(stats_cell("Damage", weapon))\
                       *$(stats_cell("Precision Multiplier", weapon))\
                       *$(enemy_cell("Critical Multiplier", NIGHTMARE_SHOOTER)))\
                     +$(stats_cell("Damage", weapon))\
                     >$(enemy_cell("HP", NIGHTMARE_SHOOTER)),\
                     $(stats_cell("Damage", weapon))\
                     <$(enemy_cell("HP", NIGHTMARE_SHOOTER))),\
                 roundup($(enemy_cell("HP", NIGHTMARE_SHOOTER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", NIGHTMARE_SHOOTER))))\
                 -1&"+1",\
                 roundup($(enemy_cell("HP", NIGHTMARE_SHOOTER))\
                         /($(stats_cell("Damage", weapon))\
                           *$(stats_cell("Precision Multiplier", weapon))\
                           *$(enemy_cell("Critical Multiplier", NIGHTMARE_SHOOTER)))))""")),
    ("Nightmare Shooter~Body",
        :("""=roundup($(enemy_cell("HP", NIGHTMARE_SHOOTER))\
                      /$(stats_cell("Damage", weapon)))""")),
    ("Nightmare Shooter~Back",
        :("""=roundup($(enemy_cell("HP", NIGHTMARE_SHOOTER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(enemy_cell("Back Multiplier", NIGHTMARE_SHOOTER))))""")),
    ("Nightmare Shooter~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /roundup($(enemy_cell("HP", NIGHTMARE_SHOOTER))\
                       /($(stats_cell("Damage", weapon))\
                         *$(stats_cell("Precision Multiplier", weapon))\
                         *$(enemy_cell("Critical Multiplier", NIGHTMARE_SHOOTER))))""")),
    ("Nightmare Shooter~Body Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Nightmare Shooter~Body", weapon))""")),
    ("Baby~HS+BS",
        :("""=if($(stats_cell("Damage", weapon))\
                *$(stats_cell("Precision Multiplier", weapon))\
                *$(enemy_cell("Critical Multiplier", BABY))\
                >$(enemy_cell("HP", BABY)),\
                1,\
                roundup($(enemy_cell("Body-Part HP", BABY))\
                        /($(stats_cell("Damage", weapon))\
                            *$(stats_cell("Precision Multiplier", weapon))\
                            *$(enemy_cell("Critical Multiplier", BABY))))\
                &"+"&\
                roundup(($(enemy_cell("HP", BABY))\
                        -roundup($(enemy_cell("Body-Part HP", BABY))\
                                    /($(stats_cell("Damage", weapon))\
                                    *$(stats_cell("Precision Multiplier", weapon))\
                                    *$(enemy_cell("Critical Multiplier", BABY))))\
                        *$(stats_cell("Damage", weapon))\
                        *$(stats_cell("Precision Multiplier", weapon))\
                        *$(enemy_cell("Critical Multiplier", BABY)))\
                        /$(stats_cell("Damage", weapon))))""")),
    ("Baby~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /(roundup($(enemy_cell("Body-Part HP", BABY))\
                        /($(stats_cell("Damage", weapon))\
                          *$(stats_cell("Precision Multiplier", weapon))\
                          *$(enemy_cell("Critical Multiplier", BABY))))\
                +max(0,roundup(($(enemy_cell("HP", BABY))\
                                -roundup($(enemy_cell("Body-Part HP", BABY))\
                                         /($(stats_cell("Damage", weapon))\
                                           *$(stats_cell("Precision Multiplier", weapon))\
                                           *$(enemy_cell("Critical Multiplier", BABY))))\
                                *$(stats_cell("Damage", weapon))\
                                *$(stats_cell("Precision Multiplier", weapon))\
                                *$(enemy_cell("Critical Multiplier", BABY)))\
                               /$(stats_cell("Damage", weapon)))))""")),
    ("Flyer~Crit",
        :("""=roundup($(enemy_cell("HP", FLYER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(stats_cell("Precision Multiplier", weapon))\
                        *$(enemy_cell("Critical Multiplier", FLYER))))""")),
    ("Flyer~Body",
        :("""=roundup($(enemy_cell("HP", FLYER))\
                      /$(stats_cell("Damage", weapon)))""")),
    ("Flyer~Crit Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Flyer~Crit", weapon))""")),
    ("Flyer~Body Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Flyer~Body", weapon))""")),
    ("Scout~Body",
        :("""=if(if($(stats_cell("Fire Mode", weapon))="Burst",\
                    $(stats_cell("Burst Count", weapon)),\
                    1)\
                 *$(stats_cell("Damage", weapon))\
                 >$(enemy_cell("HP", SCOUT)),\
                 "Yes",\
                 "No")""")),
    ("Scout~Back",
        :("""=if(if($(stats_cell("Fire Mode", weapon))="Burst",\
                    $(stats_cell("Burst Count", weapon)),\
                    1)\
                 *$(stats_cell("Damage", weapon))\
                 >$(enemy_cell("HP", SCOUT)),\
                 "Yes",\
                 if(if($(stats_cell("Fire Mode", weapon))="Burst",\
                       $(stats_cell("Burst Count", weapon)),\
                       1)\
                    *$(stats_cell("Damage", weapon))\
                    *$(enemy_cell("Back Multiplier", SCOUT))\
                    >$(enemy_cell("HP", SCOUT)),\
                    180\
                    *acos($(enemy_cell("HP", SCOUT))\
                          /(if($(stats_cell("Fire Mode", weapon))="Burst",\
                               $(stats_cell("Burst Count", weapon)),\
                               1)\
                            *$(stats_cell("Damage", weapon)))\
                         -1.25)\
                    /pi(),\
                    "No"))""")),
    ("Scout~Head",
        :("""=if(if($(stats_cell("Fire Mode", weapon))="Burst",\
                    $(stats_cell("Burst Count", weapon)),\
                    1)\
                 *$(stats_cell("Damage", weapon))\
                 *$(stats_cell("Precision Multiplier", weapon))\
                 *$(enemy_cell("Critical Multiplier", SCOUT))\
                 >$(enemy_cell("HP", SCOUT)),\
                 "Yes",\
                 "No")""")),
    ("Scout~Occiput",
        :("""=if(if($(stats_cell("Fire Mode", weapon))="Burst",\
                    $(stats_cell("Burst Count", weapon)),\
                    1)\
                 *$(stats_cell("Damage", weapon))\
                 *$(stats_cell("Precision Multiplier", weapon))\
                 *$(enemy_cell("Critical Multiplier", SCOUT))\
                 >$(enemy_cell("HP", SCOUT)),\
                 "Yes",\
                 if(if($(stats_cell("Fire Mode", weapon))="Burst",\
                       $(stats_cell("Burst Count", weapon)),\
                       1)\
                    *$(stats_cell("Damage", weapon))\
                    *$(stats_cell("Precision Multiplier", weapon))\
                    *$(enemy_cell("Occiput Multiplier", SCOUT))\
                    >$(enemy_cell("HP", SCOUT)),\
                    180\
                    *acos($(enemy_cell("HP", SCOUT))\
                          /(if($(stats_cell("Fire Mode", weapon))="Burst",\
                               $(stats_cell("Burst Count", weapon)),\
                               1)\
                            *$(stats_cell("Damage", weapon))\
                            *$(stats_cell("Precision Multiplier", weapon))\
                            *$(enemy_cell("Critical Multiplier", SCOUT)))\
                         -1.25)\
                    /pi(),\
                    "No"))""")),
    ("Charger Scout~Body",
        :("""=if(if($(stats_cell("Fire Mode", weapon))="Burst",\
                    $(stats_cell("Burst Count", weapon)),\
                    1)\
                 *$(stats_cell("Damage", weapon))\
                 >$(enemy_cell("HP", CSCOUT)),\
                 "Yes",\
                 "No")""")),
    ("Charger Scout~Back",
        :("""=if(if($(stats_cell("Fire Mode", weapon))="Burst",\
                    $(stats_cell("Burst Count", weapon)),\
                    1)\
                 *$(stats_cell("Damage", weapon))\
                 >$(enemy_cell("HP", CSCOUT)),\
                 "Yes",\
                 if(if($(stats_cell("Fire Mode", weapon))="Burst",\
                       $(stats_cell("Burst Count", weapon)),\
                       1)\
                    *$(stats_cell("Damage", weapon))\
                    *$(enemy_cell("Back Multiplier", CSCOUT))\
                    >$(enemy_cell("HP", CSCOUT)),\
                    180\
                    *acos($(enemy_cell("HP", CSCOUT))\
                          /(if($(stats_cell("Fire Mode", weapon))="Burst",\
                               $(stats_cell("Burst Count", weapon)),\
                               1)\
                            *$(stats_cell("Damage", weapon)))\
                         -1.25)\
                    /pi(),\
                    "No"))""")),
    ("Tank~Shots per Tumor",
        :("""=roundup($(enemy_cell("Body-Part HP", TANK))\
                      /($(stats_cell("Damage", weapon))\
                        *$(stats_cell("Precision Multiplier", weapon))\
                        *$(enemy_cell("Critical Multiplier", TANK))))""")),
    ("Tank~Shots per Kill",
        :("""=roundup($(enemy_cell("HP", TANK))\
                      /($(stats_cell("Pellet Count", weapon))\
                        *min($(stats_cell("Damage", weapon))\
                             *$(stats_cell("Precision Multiplier", weapon))\
                             *$(enemy_cell("Critical Multiplier", TANK))\
                             /$(stats_cell("Pellet Count", weapon)),\
                             $(enemy_cell("Body-Part HP", TANK)))))""")),
    ("Tank~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Tank~Shots per Kill", weapon))""")),
    ("Tank~Refills per Kill",
        :("""=$(eff_cell("Tank~Shots per Kill", weapon))\
              /$(stats_cell("Rounds per Refill", weapon))""")),
    ("Mother~Shots per Tumor",
        :("""=roundup($(enemy_cell("Body-Part HP", MOTHER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(stats_cell("Precision Multiplier", weapon))\
                        *$(enemy_cell("Critical Multiplier", MOTHER))))""")),
    ("Mother~Shots per Kill",
        :("""=roundup($(enemy_cell("HP", MOTHER))\
                      /($(stats_cell("Pellet Count", weapon))\
                        *min($(stats_cell("Damage", weapon))\
                             *$(stats_cell("Precision Multiplier", weapon))\
                             *$(enemy_cell("Critical Multiplier", MOTHER))\
                             /$(stats_cell("Pellet Count", weapon)),\
                             $(enemy_cell("Body-Part HP", MOTHER)))))""")),
    ("Mother~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("Mother~Shots per Kill", weapon))""")),
    ("Mother~Refills per Kill",
        :("""=$(eff_cell("Mother~Shots per Kill", weapon))\
              /$(stats_cell("Rounds per Refill", weapon))""")),
    ("pMother~Shots per Tumor",
        :("""=roundup($(enemy_cell("Body-Part HP", PMOTHER))\
                      /($(stats_cell("Damage", weapon))\
                        *$(stats_cell("Precision Multiplier", weapon))\
                        *$(enemy_cell("Critical Multiplier", PMOTHER))))""")),
    ("pMother~Shots per Kill",
        :("""=roundup($(enemy_cell("HP", PMOTHER))\
                      /($(stats_cell("Pellet Count", weapon))\
                        *min($(stats_cell("Damage", weapon))\
                             *$(stats_cell("Precision Multiplier", weapon))\
                             *$(enemy_cell("Critical Multiplier", PMOTHER))\
                             /$(stats_cell("Pellet Count", weapon)),\
                             $(enemy_cell("Body-Part HP", PMOTHER)))))""")),
    ("pMother~Max Eff.",
        :("""=$(stats_cell("Rounds per Refill", weapon))\
              /$(eff_cell("pMother~Shots per Kill", weapon))""")),
    ("pMother~Refills per Kill",
        :("""=$(eff_cell("pMother~Shots per Kill", weapon))\
              /$(stats_cell("Rounds per Refill", weapon))""")),
)

gen_eff_string = @eval function(weapon)
    wdb = weapon[2]
    return (
          SEP * string($(EFF_COLS[1][2]))  * SEP * string($(EFF_COLS[2][2]))
        * SEP * string($(EFF_COLS[3][2]))  * SEP * string($(EFF_COLS[4][2]))
        * SEP * string($(EFF_COLS[5][2]))  * SEP * string($(EFF_COLS[6][2]))
        * SEP * string($(EFF_COLS[7][2]))  * SEP * string($(EFF_COLS[8][2]))
        * SEP * string($(EFF_COLS[9][2]))  * SEP * string($(EFF_COLS[10][2]))
        * SEP * string($(EFF_COLS[11][2])) * SEP * string($(EFF_COLS[12][2]))
        * SEP * string($(EFF_COLS[13][2])) * SEP * string($(EFF_COLS[14][2]))
        * SEP * string($(EFF_COLS[15][2])) * SEP * string($(EFF_COLS[16][2]))
        * SEP * string($(EFF_COLS[17][2])) * SEP * string($(EFF_COLS[18][2]))
        * SEP * string($(EFF_COLS[19][2])) * SEP * string($(EFF_COLS[20][2]))
        * SEP * string($(EFF_COLS[21][2])) * SEP * string($(EFF_COLS[22][2]))
        * SEP * string($(EFF_COLS[23][2])) * SEP * string($(EFF_COLS[24][2]))
        * SEP * string($(EFF_COLS[25][2])) * SEP * string($(EFF_COLS[26][2]))
        * SEP * string($(EFF_COLS[27][2])) * SEP * string($(EFF_COLS[28][2]))
        * SEP * string($(EFF_COLS[29][2])) * SEP * string($(EFF_COLS[30][2]))
        * SEP * string($(EFF_COLS[31][2])) * SEP * string($(EFF_COLS[32][2]))
        * SEP * string($(EFF_COLS[33][2])) * SEP * string($(EFF_COLS[34][2]))
        * SEP * string($(EFF_COLS[35][2])) * SEP * string($(EFF_COLS[36][2]))
        * SEP * string($(EFF_COLS[37][2])) * SEP * string($(EFF_COLS[38][2]))
        * SEP * string($(EFF_COLS[39][2])) * SEP * string($(EFF_COLS[40][2]))
        * SEP * string($(EFF_COLS[41][2])) * SEP * string($(EFF_COLS[42][2]))
        * SEP * string($(EFF_COLS[43][2])) * SEP * string($(EFF_COLS[44][2]))
        * SEP * string($(EFF_COLS[45][2])) * SEP * string($(EFF_COLS[46][2]))
        * SEP * string($(EFF_COLS[47][2])) * SEP * string($(EFF_COLS[48][2]))
        * SEP * string($(EFF_COLS[49][2])) * SEP * string($(EFF_COLS[50][2]))
        * SEP * string($(EFF_COLS[51][2])) * SEP * string($(EFF_COLS[52][2]))
        * SEP * string($(EFF_COLS[53][2])) * SEP * string($(EFF_COLS[54][2]))
        * SEP * string($(EFF_COLS[55][2])) * SEP * string($(EFF_COLS[56][2]))
        * SEP * string($(EFF_COLS[57][2])) * SEP * string($(EFF_COLS[58][2]))
        * SEP * string($(EFF_COLS[59][2])) * SEP * string($(EFF_COLS[60][2]))
        * SEP * string($(EFF_COLS[61][2])) * SEP * string($(EFF_COLS[62][2]))
        * SEP * string($(EFF_COLS[63][2])) * "\n"
    )
end

function eff_cell(col_name, weapon)
    c = "B"
    for (c_name, _) in EFF_COLS
        if c_name == col_name
            # Found the eff column, now look for the weapon row.
            # Starting row for efficiency table:
            #   main weapons and special weapons from stats cells,
            #   1 for stats header, 1 for stats main-special blank line, 1 for stats-eff blank line,
            #   2 for eff headers, 1 to get into eff cells.
            row = length(MAIN_WEAPONS) + length(SPECIAL_WEAPONS) + 6
            for w in MAIN_WEAPONS
                if weapon == w
                    return "\$$c$row"
                end
                row += 1
            end
            row += 1  # Accounts for the blank line between Main and Special weapons.
            for w in SPECIAL_WEAPONS
                if weapon == w
                    return "\$$c$row"
                end
                row += 1
            end
            return "ROW NOT FOUND"
        end

        # Increment column letter(s). Assumes column letter(s) never goes beyond ZZ.
        if c == "Z"
            c = "AA"
        elseif c[end] == 'Z'
            c = (c[end-1] + 1) * "A"
        else
            c = c[1:end-1] * (c[end] + 1)
        end
    end
    return "COLUMN NOT FOUND"
end

function gen_eff_header()
    eff_header = ""
    prev_enemy = ""
    for (h, _) in EFF_COLS[1:end]
        enemy = split(h, "~")[1]
        if enemy == prev_enemy
            eff_header *= SEP
        else
            eff_header *= SEP * enemy
        end
        prev_enemy = enemy
    end
    eff_header *= "\n"
    for (h, _) in EFF_COLS[1:end]
        eff_header *= SEP * split(h, "~")[2]
    end
    return eff_header * "\n"
end

####################################################################################################
#                                           Melee Stats                                            #
####################################################################################################

MELEE_COLS = (
    ("~Melee Weapon", :(melee_weapon[1])),
    ("Damage~Light", :(mdb["LightAttackDamage"])),
    ("Damage~Charged", :(mdb["ChargedAttackDamage"])),
    ("Precision Multiplier~Light", :(mdb["LightPrecisionMulti"])),
    ("Precision Multiplier~Charged", :(mdb["ChargedPrecisionMulti"])),
    ("Stagger Multiplier~Light", :(mdb["LightStaggerMulti"])),
    ("Stagger Multiplier~Charged", :(mdb["ChargedStaggerMulti"])),
    ("Environmental Multiplier~Light", :(mdb["LightEnvironmentMulti"])),
    ("Environmental Multiplier~Charged", :(mdb["ChargedEnvironmentMulti"])),
    ("Backstab Multiplier~Light", :(mdb["LightBackstabberMulti"])),
    ("Backstab Multiplier~Charged", :(mdb["ChargedBackstabberMulti"])),
    ("Sleeping Multiplier~Light", :(mdb["LightSleeperMulti"])),
    ("Sleeping Multiplier~Charged", :(mdb["ChargedSleeperMulti"])),
    ("Stamina Cost~Light", :(mdb["LightAttackStaminaCost"]["baseStaminaCostInCombat"])),
    ("Stamina Cost~Charged", :(mdb["ChargedAttackStaminaCost"]["baseStaminaCostInCombat"])),
    ("Stamina Cost~Shove", :(mdb["PushStaminaCost"]["baseStaminaCostInCombat"])),
    ("Charge Time~", :(madb["MaxDamageChargeTime"])),
    ("Auto-Attack Time~", :(madb["AutoAttackTime"])),
)

gen_melee_stats_string = @eval function(melee_weapon)
    mdb = melee_weapon[2]
    madb = melee_weapon[3]
    return (
          SEP * string($(MELEE_COLS[1][2]))  * SEP * string($(MELEE_COLS[2][2]))
        * SEP * string($(MELEE_COLS[3][2]))  * SEP * string($(MELEE_COLS[4][2]))
        * SEP * string($(MELEE_COLS[5][2]))  * SEP * string($(MELEE_COLS[6][2]))
        * SEP * string($(MELEE_COLS[7][2]))  * SEP * string($(MELEE_COLS[8][2]))
        * SEP * string($(MELEE_COLS[9][2]))  * SEP * string($(MELEE_COLS[10][2]))
        * SEP * string($(MELEE_COLS[11][2])) * SEP * string($(MELEE_COLS[12][2]))
        * SEP * string($(MELEE_COLS[13][2])) * SEP * string($(MELEE_COLS[14][2]))
        * SEP * string($(MELEE_COLS[15][2])) * SEP * string($(MELEE_COLS[16][2]))
        * SEP * string($(MELEE_COLS[17][2])) * SEP * string($(MELEE_COLS[18][2]))
        * "\n"
    )
end

function gen_melee_stats_header()
    melee_header = ""
    prev_melee_stat = ""
    for (h, _) in MELEE_COLS[1:end]
        melee_stat = split(h, "~")[1]
        if melee_stat == prev_melee_stat
            melee_header *= SEP
        else
            melee_header *= SEP * melee_stat
        end
        prev_melee_stat = melee_stat
    end
    melee_header *= "\n"
    for (h, _) in MELEE_COLS[1:end]
        melee_header *= SEP * split(h, "~")[2]
    end
    return melee_header * "\n"
end

####################################################################################################
#                                           Enemy Stats                                            #
####################################################################################################

ENEMY_COLS = (
    ("Enemy",
        :(enemy.name)),
    ("HP",
        :(enemy.hp)),
    ("Critical Multiplier",
        :(enemy.crit_mult)),
    ("Back Multiplier",
        :(enemy.back_mult)),
    ("Occiput Multiplier",
        :((enemy.crit_mult == 1 || enemy.back_mult == 1)
           ? "N/A"
           : """=$(enemy_cell("Critical Multiplier", enemy))\
                 *$(enemy_cell("Back Multiplier", enemy))""")),
    ("Stagger HP",
        :(enemy.stagger_hp)),
    ("Body-Part HP",
        :(enemy.bodypart_hp)),
    ("Melee Damage",
        :(enemy.melee_damage)),
    ("Tentacle Damage",
        :(enemy.tentacle_damage)),
    ("Projectile Damage",
        :(enemy.projectile_damage)),
    # TODO: Add C-foam blobs required.
)

gen_enemy_string = @eval function(enemy)
    return (
          SEP * string($(ENEMY_COLS[1][2]))  * SEP * string($(ENEMY_COLS[2][2]))
        * SEP * string($(ENEMY_COLS[3][2]))  * SEP * string($(ENEMY_COLS[4][2]))
        * SEP * string($(ENEMY_COLS[5][2]))  * SEP * string($(ENEMY_COLS[6][2]))
        * SEP * string($(ENEMY_COLS[7][2]))  * SEP * string($(ENEMY_COLS[8][2]))
        * SEP * string($(ENEMY_COLS[9][2]))  * SEP * string($(ENEMY_COLS[10][2]))
        * "\n"
    )
end

function enemy_cell(col_name, enemy)
    c = "B"
    for (c_name, _) in ENEMY_COLS
        if c_name == col_name
            # Found the relevant enemy's column, now look for the enemy row.
            # Starting row for enemy table:
            #   main weapons and special weapons from stats and efficiency cells,
            #   1 for stats header, 1 for stats main-special blank line, 1 for stats-eff blank line,
            #   2 for eff headers, 1 for efficiency main-special blank line,
            #   1 for stats-melee blank line, 2 for melee headers, 1 for melee-enemies blank line,
            #   1 for enemy header, 1 to get into enemy cells.
            row = 2*length(MAIN_WEAPONS) + 2*length(SPECIAL_WEAPONS) + length(MELEE_WEAPONS) + 12
            for e in ENEMIES
                if enemy == e
                    return "\$$c\$$row"
                end
                row += 1
            end
            return "ROW NOT FOUND"
        end

        # Increment column letter(s). Assumes column letter(s) never goes beyond ZZ.
        if c == "Z"
            c = "AA"
        elseif c[end] == 'Z'
            c = (c[end-1] + 1) * "A"
        else
            c = c[1:end-1] * (c[end] + 1)
        end
    end
    return "COLUMN NOT FOUND"
end

function gen_enemy_header()
    enemy_header = ""
    for (h, _) in ENEMY_COLS[1:end]
        enemy_header *= SEP * h
    end
    return enemy_header * "\n"
end

####################################################################################################
#                                            Tool Stats                                            #
####################################################################################################

TOOL_COLS = (
    ("name",
        :(tdb["name"])),
    ("Sentry",
        :(tool[1])),
    ("Damage",
        :(d(tdb))),
    ("Precision Multiplier",
        :(tdb["PrecisionDamageMulti"])),
    ("Stagger Multiplier",
        :(tdb["StaggerDamageMulti"])),
    ("Max Ammo",
        :("""=rounddown($TOOL_MAX_SENTRY\
              /$(tool_cell("Bullet Cost", tool))\
              /$(tool_cell("Pellet Count", tool)))""")),
    ("Damage from Full",
        :("""=$(tool_cell("Damage", tool))\
              *$(tool_cell("Max Ammo", tool))""")),
    ("Bio Symbiosis Damage from Full",
        :("""=$(tool_cell("Damage from Full", tool))\
              /$(tool_cell("Bio Symbiosis Bullet Cost Multiplier", tool))""")),
    ("Rounds per Refill",
        :("""=$TOOL_REFILL_SENTRY\
              /$(tool_cell("Bullet Cost", tool))\
              /$(tool_cell("Pellet Count", tool))""")),
    ("Starting Ammo",
        :("""=$TOOL_START_SENTRY\
              /$(tool_cell("Bullet Cost", tool))\
              /$(tool_cell("Pellet Count", tool))""")),
    ("Bullet Cost",
        :(tdb["CostOfBullet"])),
    ("Piercing",
        :(tdb["PiercingBullets"] ? tdb["PiercingDamageCountLimit"] : "N/A")),
    ("Shot Delay",
        :(tdb["ShotDelay"])),
    ("Burst Delay",
        :(tdb["FireMode"] == BURST ? tdb["BurstDelay"] : "N/A")),
    ("Burst Count",
        :(tdb["FireMode"] == BURST ? tdb["BurstShotCount"] : "N/A")),
    ("Pellet Count",
        :(tdb["ShotgunBulletCount"] != 0 ? tdb["ShotgunBulletCount"] : "1")),
    ("Lock-On Time",
        :(tdb["Sentry_StartFireDelay"])),
    ("Bio Symbiosis Lock-On Time",
        :(tdb["Sentry_StartFireDelay"] * tdb["Sentry_StartFireDelayTagMulti"])),
    ("Bio Symbiosis Bullet Cost Multiplier",
        :(tdb["Sentry_CostOfBulletTagMulti"])),
    ("Bio Symbiosis Shot Delay Multiplier",
        :(tdb["Sentry_ShotDelayTagMulti"])),
    ("Falloff Start",
        :(tdb["DamageFalloff"]["x"])),
    ("Falloff End",
        :(tdb["DamageFalloff"]["y"])),
    ("DPS",
        :("""=ifs($(tool_cell("Fire Mode", tool))="Semi",\
                      $(tool_cell("Damage", tool))\
                      /$(tool_cell("Shot Delay", tool)),\
                  $(tool_cell("Fire Mode", tool))="Burst",\
                      $(tool_cell("Burst Count", tool))\
                      *$(tool_cell("Damage", tool))\
                      /(($(tool_cell("Burst Count", tool))-1)\
                        *$(tool_cell("Shot Delay", tool))\
                        +max($(tool_cell("Shot Delay", tool)),\
                             $(tool_cell("Burst Delay", tool)))),\
                  $(tool_cell("Fire Mode", tool))="Auto",\
                      $(tool_cell("Damage", tool))\
                      /$(tool_cell("Shot Delay", tool)))""")),
    # Note: This calculation may be too simplistic for a burst-fire sentry with bio symbiosis.
    ("Bio Symbiosis DPS",
        :("""=$(tool_cell("DPS", tool))\
              /$(tool_cell("Bio Symbiosis Shot Delay Multiplier", tool))""")),
    ("Time to Empty",
        :("""=ifs($(tool_cell("Fire Mode", tool))="Semi",\
                      $(tool_cell("Max Ammo", tool))\
                      *$(tool_cell("Shot Delay", tool)),\
                  $(tool_cell("Fire Mode", tool))="Burst",\
                      $(tool_cell("Max Ammo", tool))\
                      /$(tool_cell("Burst Count", tool))\
                      *(($(tool_cell("Burst Count", tool))-1)\
                         *$(tool_cell("Shot Delay", tool))\
                         +max($(tool_cell("Shot Delay", tool)),\
                              $(tool_cell("Burst Delay", tool)))),\
                  $(tool_cell("Fire Mode", tool))="Auto",\
                      $(tool_cell("Max Ammo", tool))\
                      *$(tool_cell("Shot Delay", tool)))""")),
    ("Bio Symbiosis Time to Empty",
        :("""=$(tool_cell("Time to Empty", tool))\
              *$(tool_cell("Bio Symbiosis Shot Delay Multiplier", tool))\
              /$(tool_cell("Bio Symbiosis Bullet Cost Multiplier", tool))""")),
    ("Fire Mode",
        :(tdb["FireMode"] == SEMI ? "Semi" : (tdb["FireMode"]) == BURST ? "Burst" : "Auto")),
)

gen_tool_string = @eval function(tool)
    tdb = tool[2]
    # Since these expressions are being evaluated in a weird scope, they're not allowed to have
    # variables as part of their invocation, thus this must all be hardcoded.
    return (    string($(TOOL_COLS[1][2]))  * SEP * string($(TOOL_COLS[2][2]))
        * SEP * string($(TOOL_COLS[3][2]))  * SEP * string($(TOOL_COLS[4][2]))
        * SEP * string($(TOOL_COLS[5][2]))  * SEP * string($(TOOL_COLS[6][2]))
        * SEP * string($(TOOL_COLS[7][2]))  * SEP * string($(TOOL_COLS[8][2]))
        * SEP * string($(TOOL_COLS[9][2]))  * SEP * string($(TOOL_COLS[10][2]))
        * SEP * string($(TOOL_COLS[11][2])) * SEP * string($(TOOL_COLS[12][2]))
        * SEP * string($(TOOL_COLS[13][2])) * SEP * string($(TOOL_COLS[14][2]))
        * SEP * string($(TOOL_COLS[15][2])) * SEP * string($(TOOL_COLS[16][2]))
        * SEP * string($(TOOL_COLS[17][2])) * SEP * string($(TOOL_COLS[18][2]))
        * SEP * string($(TOOL_COLS[19][2])) * SEP * string($(TOOL_COLS[20][2]))
        * SEP * string($(TOOL_COLS[21][2])) * SEP * string($(TOOL_COLS[22][2]))
        * SEP * string($(TOOL_COLS[23][2])) * SEP * string($(TOOL_COLS[24][2]))
        * SEP * string($(TOOL_COLS[25][2])) * SEP * string($(TOOL_COLS[26][2]))
        * SEP * string($(TOOL_COLS[27][2])) * "\n"
    )
end

function tool_cell(col_name, weapon)
    c = "A"
    for (c_name, _) in TOOL_COLS
        if c_name == col_name
            # Found the tool column, now look for the tool row.
            # Starting row for tool table:
            #   main weapons and special weapons from stats and efficiency cells,
            #   1 for stats header, 1 for stats main-special blank line, 1 for stats-eff blank line,
            #   2 for eff headers, 1 for efficiency main-special blank line,
            #   1 for stats-melee blank line, 2 for melee headers, 1 for melee-enemies blank line,
            #   1 for enemy header, 1 for enemy-tool blank line, 1 for tool header,
            #   1 to get into tool cells.
            row = 2*length(MAIN_WEAPONS) + 2*length(SPECIAL_WEAPONS) + length(MELEE_WEAPONS) + length(ENEMIES) + 14
            for t in TOOLS
                if weapon == t
                    return "\$$c$row"
                end
                row += 1
            end
            return "ROW NOT FOUND"
        end

        # Increment column letter(s). Assumes column letter(s) never goes beyond ZZ.
        if c == "Z"
            c = "AA"
        elseif c[end] == 'Z'
            c = (c[end-1] + 1) * "A"
        else
            c = c[1:end-1] * (c[end] + 1)
        end
    end
    return "COLUMN NOT FOUND"
end

function gen_tool_header()
    tool_header = ""
    for (h, _) in TOOL_COLS[1:end-1]
        tool_header *= h * SEP
    end
    return tool_header * TOOL_COLS[end][1] * "\n"
end

####################################################################################################
#                                               Main                                               #
####################################################################################################

function main()
    println("Generating Stats from $DB_PATH")
    # Weapon Stats
    out = gen_stats_header()
    for weapon in MAIN_WEAPONS
        out *= gen_stats_string(weapon; main=true)
    end
    out *= "\n"
    for weapon in SPECIAL_WEAPONS
        out *= gen_stats_string(weapon; main=false)
    end
    # Efficiency Stats
    out *= "\n"
    out *= gen_eff_header()
    for weapon in MAIN_WEAPONS
        out *= gen_eff_string(weapon)
    end
    out *= "\n"
    for weapon in SPECIAL_WEAPONS
        out *= gen_eff_string(weapon)
    end
    # Melee Stats
    out *= "\n"
    out *= gen_melee_stats_header()
    for melee_weapon in MELEE_WEAPONS
        out *= gen_melee_stats_string(melee_weapon)
    end
    # Enemy Stats
    out *= "\n"
    out *= gen_enemy_header()
    for enemy in ENEMIES
        out *= gen_enemy_string(enemy)
    end
    # Tool Stats
    out *= "\n"
    out *= gen_tool_header()
    for tool in TOOLS
        out *= gen_tool_string(tool)
    end

    write("out.csv", out)
end

main()
