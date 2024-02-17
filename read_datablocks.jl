using JSON

# These names are just used for display purposes - the actual weapon list is generated entirely
# programmatically.
const _WEAPON_NAMES = Dict(
    "GEAR_Pistol_Semi_v2"             => "Pistol",
    "GEAR_Pistol_Burst"               => "Burst Pistol",
    "GEAR_Revolver_HEL"               => "Hel Revolver",
    "GEAR_Pistol_Auto"                => "Machine Pistol",
    "GEAR_Pistol_Auto_Staggering_HEL" => "HEL Autopistol",
    "GEAR_Bullpup_Auto"               => "Bullpup Rifle",
    "GEAR_SMG_Auto"                   => "SMG",
    "GEAR_SMG_PDW"                    => "PDW",
    "GEAR_SMG_Heavy_Auto"             => "Heavy SMG",
    "GEAR_SMG_Burst"                  => "Carbine",
    "GEAR_DMR_Semi_v2"                => "DMR",
    "GEAR_DMR_Burst"                  => "Double Tap Rifle",
    "GEAR_Rifle_Auto"                 => "Assault Rifle",
    "GEAR_Rifle_Burst"                => "Burst Rifle",
    "GEAR_Rifle_Semi"                 => "Rifle",
    "GEAR_Sawed-Off_Shotgun_Semi"     => "Sawed-Off Shotgun",
    "GEAR_HEL_Shotgun_Auto"           => "HEL Shotgun",
    "GEAR_Shotgun_Slug_Semi"          => "Slug Shotgun",
    "GEAR_Rifle_Heavy_Auto_Special"   => "Heavy Assault Rifle",
    "GEAR_SMG_Semi"                   => "Short Rifle",
    "GEAR_Shotgun_Semi_v2"            => "Shotgun",
    "GEAR_Shotgun_Auto"               => "Combat Shotgun",
    "GEAR_Scattergun_Semi"            => "Scattergun",
    "GEAR_Shotgun_Choke_Mod"          => "Choke Mod Shotgun",
    "GEAR_Revolver_Semi_v2"           => "Revolver",
    "GEAR_MachineGun_Auto_LowRPM"     => "Machinegun (Arbalist)",
    "GEAR_MachineGun_Auto"            => "Machinegun (Varuta)",
    "GEAR_MachineGun_Burst"           => "Burst Cannon",
    "GEAR_HEL_Gun - Mechinegun_Semi"  => "HEL Gun",
    "GEAR_HighCal_Pistol"             => "High Caliber Pistol",
    "GEAR_Precision_Rifle"            => "Precision Rifle",
    "GEAR_Sniper_Semi_v2"             => "Sniper",
    "GEAR_HEL_Rifle_semi"             => "HEL Rifle",
)

# These names do get used to generate the melee weapon list. They match the `name`s used in
# `MeleeArchetype` and `MeleeAnimationSet`.
const _MELEE_WEAPON_NAMES = (
    "Hammer",
    "Knife",
    "Bat",
    "Spear",
)

# These names do get used to generate the sentry list. They match the `name`s used in `Archetype`.
const _TOOL_NAMES = (
    ("GEAR_SentryGun_Burst",           "Burst"),
    ("GEAR_SentryGun_Auto_staggering", "Auto"),
    ("GEAR_SentryGun_Semi_sniper",     "Sniper"),
    ("GEAR_SentryGun_Shotgun_Semi",    "Shotgun"),
)

if isfile("$DB_PATH/GameData_PlayerOfflineGearDataBlock_bin.json")
    _PlayerOfflineGear = JSON.parsefile("$DB_PATH/GameData_PlayerOfflineGearDataBlock_bin.json")
else
    _PlayerOfflineGear = JSON.parsefile("$VANILLA_DB_PATH/GameData_PlayerOfflineGearDataBlock_bin.json")
    println("PlayerOfflineGear not found, using Vanilla datablock")
end
if isfile("$DB_PATH/GameData_GearCategoryDataBlock_bin.json")
    _GearCategory      = JSON.parsefile("$DB_PATH/GameData_GearCategoryDataBlock_bin.json")
else
    _GearCategory      = JSON.parsefile("$VANILLA_DB_PATH/GameData_GearCategoryDataBlock_bin.json")
    println("GearCategory not found, using Vanilla datablock")
end
if isfile("$DB_PATH/GameData_ArchetypeDataBlock_bin.json")
    _Archetype         = JSON.parsefile("$DB_PATH/GameData_ArchetypeDataBlock_bin.json")
else
    _Archetype         = JSON.parsefile("$VANILLA_DB_PATH/GameData_ArchetypeDataBlock_bin.json")
    println("Archetype not found, using Vanilla datablock")
end
if isfile("$DB_PATH/GameData_MeleeArchetypeDataBlock_bin.json")
    _MeleeArchetype    = JSON.parsefile("$DB_PATH/GameData_MeleeArchetypeDataBlock_bin.json")
else
    _MeleeArchetype    = JSON.parsefile("$VANILLA_DB_PATH/GameData_MeleeArchetypeDataBlock_bin.json")
    println("MeleeArchetype not found, using Vanilla datablock")
end
if isfile("$DB_PATH/GameData_MeleeAnimationSetDataBlock_bin.json")
    _MeleeAnimationSet = JSON.parsefile("$DB_PATH/GameData_MeleeAnimationSetDataBlock_bin.json")
else
    _MeleeAnimationSet = JSON.parsefile("$VANILLA_DB_PATH/GameData_MeleeAnimationSetDataBlock_bin.json")
    println("MeleeAnimationSet not found, using Vanilla datablock")
end

MAIN_WEAPONS = []
SPECIAL_WEAPONS = []
MELEE_WEAPONS = []
TOOLS = []

# Processes the PlayerOfflineGear datablock, finding all main and special weapons and processing
# them.
function process_player_offline_gear()
    for player_offline_gear in _PlayerOfflineGear["Blocks"]
        gear_json = JSON.parse(player_offline_gear["GearJSON"])
        for (_, component) in gear_json["Packet"]["Comps"]
            if isa(component, Dict)
                if component["c"] == 3
                    # Main weapon.
                    if component["v"] == 108 || component["v"] == 156
                        process_gear_json(gear_json, MAIN_WEAPONS)
                    end
                    # Special weapon.
                    if component["v"] == 109 || component["v"] == 110
                        process_gear_json(gear_json, SPECIAL_WEAPONS)
                    end
                end
            end
        end
    end
end

# Processes the Gear JSON for a given weapon, determining its GearCategory persistent ID and the
# weapon's fire mode.
function process_gear_json(gear_json, weapons_list)
    gear_category_id = 0
    fire_mode = 0
    for (_, component) in gear_json["Packet"]["Comps"]
        # Search for fire mode. Some Gear JSONs will omit the fire mode, in which case they are
        # semi-automatic.
        if isa(component, Dict)
            if component["c"] == 1
                fire_mode = component["v"]
            end
        end
        # Search for GearCategory persistent ID.
        if isa(component, Dict)
            if component["c"] == 2
                gear_category_id = component["v"]
            end
        end
    end
    # Turn fire mode index into the corresponding fire mode key for use in GearCategory.
    if fire_mode == 0
        fire_mode = "SemiArchetype"
    elseif fire_mode == 1
        fire_mode = "BurstArchetype"
    elseif fire_mode == 2
        fire_mode = "AutoArchetype"
    end
    process_gear_category(gear_category_id, fire_mode, weapons_list)
end

# Processes the GearCategory entry for a given weapon, determining which Archetype block to use.
function process_gear_category(gear_category_id, fire_mode, weapons_list)
    for gear_category in _GearCategory["Blocks"]
        if gear_category["persistentID"] == gear_category_id
            archetype_id = gear_category[fire_mode]
            process_archetype(archetype_id, weapons_list)
        end
    end
end

# Adds the Archetype entry for a given weapon to the weapon list!
function process_archetype(archetype_id, weapons_list)
    for archetype in _Archetype["Blocks"]
        if archetype["persistentID"] == archetype_id
            # Determine the name for the weapon to use.
            if haskey(_WEAPON_NAMES, archetype["name"])
                weapon_name = _WEAPON_NAMES[archetype["name"]]
            else
                weapon_name = archetype["name"]
            end
            push!(weapons_list, (weapon_name, archetype))
        end
    end
end

# Processing PlayerOfflineGear adds all the regular weapons.
process_player_offline_gear()

# Then add the melee weapons directly from their datablocks.
for melee_weapon in _MELEE_WEAPON_NAMES
    found = false
    for melee_archetype in _MeleeArchetype["Blocks"]
        if melee_weapon == melee_archetype["name"]
            for melee_animation_set in _MeleeAnimationSet["Blocks"]
                if melee_weapon == melee_animation_set["name"]
                    push!(MELEE_WEAPONS, (melee_weapon, melee_archetype, melee_animation_set))
                    found = true
                end
            end
        end
    end
    if !found
        println("$(melee_weapon) not found.")
    end
end

# And the tools directly from the Archetype datablock.
for (tool, name) in _TOOL_NAMES
    found = false
    for archetype in _Archetype["Blocks"]
        if tool == archetype["name"]
            push!(TOOLS, (name, archetype))
            found = true
        end
    end
    if !found
        println("$(tool) not found.")
    end
end
