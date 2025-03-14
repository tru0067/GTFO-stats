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
    "GEAR_MachineGun_Auto"            => "Machinegun (Veruta)",
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
    println("PlayerOfflineGear not found, using vanilla datablock")
end
if isfile("$DB_PATH/GameData_GearCategoryDataBlock_bin.json")
    _GearCategory      = JSON.parsefile("$DB_PATH/GameData_GearCategoryDataBlock_bin.json")
else
    _GearCategory      = JSON.parsefile("$VANILLA_DB_PATH/GameData_GearCategoryDataBlock_bin.json")
    println("GearCategory not found, using vanilla datablock")
end
if isfile("$DB_PATH/GameData_ArchetypeDataBlock_bin.json")
    _Archetype         = JSON.parsefile("$DB_PATH/GameData_ArchetypeDataBlock_bin.json")
else
    _Archetype         = JSON.parsefile("$VANILLA_DB_PATH/GameData_ArchetypeDataBlock_bin.json")
    println("Archetype not found, using vanilla datablock")
end
if isfile("$DB_PATH/GameData_MeleeArchetypeDataBlock_bin.json")
    _MeleeArchetype    = JSON.parsefile("$DB_PATH/GameData_MeleeArchetypeDataBlock_bin.json")
else
    _MeleeArchetype    = JSON.parsefile("$VANILLA_DB_PATH/GameData_MeleeArchetypeDataBlock_bin.json")
    println("MeleeArchetype not found, using vanilla datablock")
end
if isfile("$DB_PATH/GameData_MeleeAnimationSetDataBlock_bin.json")
    _MeleeAnimationSet = JSON.parsefile("$DB_PATH/GameData_MeleeAnimationSetDataBlock_bin.json")
else
    _MeleeAnimationSet = JSON.parsefile("$VANILLA_DB_PATH/GameData_MeleeAnimationSetDataBlock_bin.json")
    println("MeleeAnimationSet not found, using vanilla datablock")
end
if isfile("$DB_PATH/GameData_GearFrontPartDataBlock_bin.json")
    _GearFrontPart = JSON.parsefile("$DB_PATH/GameData_GearFrontPartDataBlock_bin.json")
else
    _GearFrontPart = JSON.parsefile("$VANILLA_DB_PATH/GameData_GearFrontPartDataBlock_bin.json")
    println("GearFrontPart not found, using vanilla datablock")
end
if isfile("$DB_PATH/GameData_GearStockPartDataBlock_bin.json")
    _GearStockPart = JSON.parsefile("$DB_PATH/GameData_GearStockPartDataBlock_bin.json")
else
    _GearStockPart = JSON.parsefile("$VANILLA_DB_PATH/GameData_GearStockPartDataBlock_bin.json")
    println("GearStockPart not found, using vanilla datablock")
end

MAIN_WEAPONS = []
SPECIAL_WEAPONS = []
MELEE_WEAPONS = []
TOOLS = []

# Processes the PlayerOfflineGear datablock, finding all main and special weapons and processing
# them.
function process_player_offline_gear()
    for player_offline_gear in _PlayerOfflineGear["Blocks"]
        if !player_offline_gear["internalEnabled"]
            # Skip if not enabled.
            continue
        end
        gear_json = JSON.parse(player_offline_gear["GearJSON"])
        for (_, component) in gear_json["Packet"]["Comps"]
            if isa(component, Dict)
                if component["c"] == 3
                    # Main weapon.
                    if component["v"] == 108 || component["v"] == 156
                        archetype = get_archetype_from_gear_json(gear_json)
                        name = get_name_from_archetype(archetype)
                        reload_sequence = get_reload_sequence_from_gear_json(gear_json)
                        push!(MAIN_WEAPONS, (name, archetype, reload_sequence))

                    end
                    # Special weapon.
                    if component["v"] == 109 || component["v"] == 110
                        archetype = get_archetype_from_gear_json(gear_json)
                        name = get_name_from_archetype(archetype)
                        reload_sequence = get_reload_sequence_from_gear_json(gear_json)
                        push!(SPECIAL_WEAPONS, (name, archetype, reload_sequence))
                    end
                end
            end
        end
    end
end

# Processes the Gear JSON for a given weapon, determining its GearCategory persistent ID and the
# weapon's fire mode.
function get_archetype_from_gear_json(gear_json)
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
    elseif fire_mode == 3
        fire_mode = "SemiBurstArchetype"
    end
    return get_archetype_from_gear_category(gear_category_id, fire_mode)
end

# Processes the GearCategory entry for a given weapon, determining which Archetype block to use.
function get_archetype_from_gear_category(gear_category_id, fire_mode)
    for gear_category in _GearCategory["Blocks"]
        if gear_category["persistentID"] == gear_category_id
            archetype_id = gear_category[fire_mode]
            return get_archetype_from_archetype(archetype_id)
        end
    end
end

# Processes the Archetype datablock to find a given archetype_id.
function get_archetype_from_archetype(archetype_id)
    for archetype in _Archetype["Blocks"]
        if archetype["persistentID"] == archetype_id
            return archetype
        end
    end
end

# Get a name from _WEAPON_NAMES if it exists, otherwise use the archetype's name.
function get_name_from_archetype(archetype)
    if haskey(_WEAPON_NAMES, archetype["name"])
        return _WEAPON_NAMES[archetype["name"]]
    else
        return archetype["name"]
    end
end

# Processes the Gear JSON for a given weapon, finding both the front and stock parts, and then using
# those to look for the reload sequence.
function get_reload_sequence_from_gear_json(gear_json)
    found_gear_front_part_id = false
    found_gear_stock_part_id = false
    gear_front_part_id = 0
    gear_stock_part_id = 0
    for (_, component) in gear_json["Packet"]["Comps"]
        if isa(component, Dict)
            if component["c"] == 12
                found_gear_front_part_id = true
                gear_front_part_id = component["v"]
            end
            if component["c"] == 19
                found_gear_stock_part_id = true
                gear_stock_part_id = component["v"]
            end
        end
    end

    if !found_gear_front_part_id || !found_gear_stock_part_id
        println("Didn't find front and/or stock parts, cannot determine reload sequence.")
        return []
    end

    if found_gear_front_part_id
        gear_front_part_reload_sequence = get_reload_sequence_from_gear_part(gear_front_part_id, _GearFrontPart)
    end
    if found_gear_stock_part_id
        gear_stock_part_reload_sequence = get_reload_sequence_from_gear_part(gear_stock_part_id, _GearStockPart)
    end

    if length(gear_front_part_reload_sequence) == 0 && length(gear_stock_part_reload_sequence) == 0
        println("Only found empty reload sequences, cannot determine reload stats.")
        return []
    end
    if length(gear_front_part_reload_sequence) > 0 && length(gear_stock_part_reload_sequence) > 0
        println("Found two non-empty reload sequences, cannot tie-break reload stats.")
        return []
    end

    if length(gear_front_part_reload_sequence) > 0
        return gear_front_part_reload_sequence
    end
    if length(gear_stock_part_reload_sequence) > 0
        return gear_stock_part_reload_sequence
    end
    return []
end

# Processes the gear front/stock part datablock to find the reload sequence for the given id.
function get_reload_sequence_from_gear_part(gear_part_id, gear_part_datablock)
    for gear_part in gear_part_datablock["Blocks"]
        if gear_part["persistentID"] == gear_part_id
            return gear_part["ReloadSequence"]
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
