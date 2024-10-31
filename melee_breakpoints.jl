using Printf

SEP = "\t"

struct Melee
    name
    l_damage
    c_damage
    l_prec
    c_prec
    l_stag
    c_stag
    l_env
    c_env
    l_back
    c_back
    l_sleep
    c_sleep
end

struct Breakpoint
    name
    hp
    uses_prec
    uses_stag
    uses_env
    uses_back
    skip_sleeping
    allow_followup
end

struct ActiveMultipliers
    prec
    stag
    env
    back
    sleep
end

function cubic(charge, light, charged)
    return (charged - light) * charge^3 + light
end

function damage(charge, melee::Melee, active_multipliers::ActiveMultipliers)
    damage = cubic(charge, melee.l_damage, melee.c_damage)
    if active_multipliers.prec
        damage *= cubic(charge, melee.l_prec, melee.c_prec)
    end
    if active_multipliers.stag
        damage *= cubic(charge, melee.l_stag, melee.c_stag)
    end
    if active_multipliers.env
        damage *= cubic(charge, melee.l_env, melee.c_env)
    end
    if active_multipliers.back
        # Always assume max back multi and then also apply backstab multi.
        damage *= 2
        damage *= cubic(charge, melee.l_back, melee.c_back)
    end
    if active_multipliers.sleep
        damage *= cubic(charge, melee.l_sleep, melee.c_sleep)
    end
    return damage
end

function melee_breakpoint(melee::Melee, breakpoint::Breakpoint)
    if breakpoint.skip_sleeping && (melee.l_sleep != 1 || melee.c_sleep != 1)
        return "N/A"
    end

    # Start with a sleeping hit.
    active_multipliers = ActiveMultipliers(breakpoint.uses_prec, breakpoint.uses_stag, breakpoint.uses_env, breakpoint.uses_back, true)
    damage_first_full_charge = damage(1, melee, active_multipliers)

    # First full charge perfectly kills.
    if damage_first_full_charge == breakpoint.hp
        return "100.0"
    end
    # Need less than one full charge.
    if damage_first_full_charge > breakpoint.hp
        charge = 0
        while charge <= 1
            if damage(charge, melee, active_multipliers) >= breakpoint.hp
                # Success!
                return @sprintf("%.1f", 100*charge)
            end
            charge += 0.0005
        end
    end

    # Need more than one full charge.
    if !breakpoint.allow_followup
        return "-"
    end

    full_charges = 0
    total_damage = 0
    if (damage_first_full_charge = damage(1, melee, active_multipliers)) < breakpoint.hp
        # Any subsequent hits will not use the sleeping multiplier.
        active_multipliers = ActiveMultipliers(breakpoint.uses_prec, breakpoint.uses_stag, breakpoint.uses_env, breakpoint.uses_back, false)
        damage_per_full_charge = damage(1, melee, active_multipliers)
        # Find out how many extra full charges before we can't fit any more.
        full_charges = div(breakpoint.hp - damage_first_full_charge, damage_per_full_charge) + 1
        total_damage = damage_first_full_charge + (full_charges - 1) * damage_per_full_charge
    end

    charge = 0
    while charge <= 1
        if damage(charge, melee, active_multipliers) >= breakpoint.hp - total_damage
            # Success!
            if full_charges > 0
                return @sprintf("%d + %.1f", full_charges, 100*charge)
            else
                return @sprintf("%.1f", 100*charge)
            end
        end

        charge += 0.0005
    end

    return "ERROR"
end

function main()
    # Set up melees.
    melees = [  #                  dmg      prec      stag    env       back    sleep
        Melee("Sledgehammer",     3, 20,   1,   1,   1, 1.3, 3,   3,   1, 1,   1, 1),
        Melee("Bat",              3, 12,   1,   1,   5, 7,   5,   5,   1, 1,   1, 1),
        Melee("Spear",            2, 17.5, 1.3, 1.5, 1, 1,   2,   3,   1, 1,   1, 1),
        Melee("Knife",            2,  5.5, 1,   1.5, 1, 1,   0.8, 1.5, 1, 1.7, 1, 1),
        Melee("Knife (Sleeping)", 2,  5.5, 1,   1.5, 1, 1,   0.8, 1.5, 1, 1.7, 1, 1.5)
    ]

    # Set up breakpoints.
    breakpoints = [  #                                  HP   prec   stag    env   back  sleep followup
        Breakpoint("Striker: Front",                     20, false, false, false, false, false,  true),
        Breakpoint("Striker: Back",                      20, false, false, false,  true, false,  true),
        Breakpoint("Striker: Head",                    20/3,  true, false, false, false, false,  true),
        Breakpoint("Striker: Occi",                    20/3,  true, false, false,  true, false,  true),

        Breakpoint("Shooter: Front",                     30, false, false, false, false, false,  true),
        Breakpoint("Shooter: Back",                      30, false, false, false,  true, false,  true),
        Breakpoint("Shooter: Head",                    30/5,  true, false, false, false, false,  true),
        Breakpoint("Shooter: Occi",                    30/5,  true, false, false,  true, false,  true),

        Breakpoint("Giant: Front Limb Break",            15, false, false, false, false, false,  true),
        Breakpoint("Giant: Back Limb Break",             15, false, false, false,  true, false,  true),
        Breakpoint("Giant: Head Limb Break",         15/1.5,  true, false, false, false, false,  true),
        Breakpoint("Giant: Occi Limb Break",         15/1.5,  true, false, false,  true, false,  true),

        Breakpoint("Giant: Front Stagger",               40, false,  true, false, false, false,  true),
        Breakpoint("Giant: Back Stagger",                40, false,  true, false,  true, false,  true),
        Breakpoint("Giant: Head Stagger",            40/1.5,  true,  true, false, false, false,  true),
        Breakpoint("Giant: Occi Stagger",            40/1.5,  true,  true, false,  true, false,  true),

        Breakpoint("Big Shooter/Hybrid: Head Stagger", 40/2,  true,  true, false, false, false,  true),
        Breakpoint("Big Shooter/Hybrid: Occi Stagger", 40/2,  true,  true, false,  true, false,  true),

        Breakpoint("Charger: Front",                     30, false, false, false, false, false,  true),
        Breakpoint("Charger: Back",                      30, false, false, false,  true, false,  true),

        Breakpoint("Nightmare Striker: Front",           37, false, false, false, false, false,  true),
        Breakpoint("Nightmare Striker: Back",            37, false, false, false,  true, false,  true),
        Breakpoint("Nightmare Striker: Head",          37/2,  true, false, false, false, false,  true),
        Breakpoint("Nightmare Striker: Occi",          37/2,  true, false, false,  true, false,  true),

        Breakpoint("Nightmare Shooter: Front",           18, false, false, false, false, false,  true),
        Breakpoint("Nightmare Shooter: Back",            18, false, false, false,  true, false,  true),
        Breakpoint("Nightmare Shooter: Head",          18/3,  true, false, false, false, false,  true),
        Breakpoint("Nightmare Shooter: Occi",          18/3,  true, false, false,  true, false,  true),

        Breakpoint("Baby: Front",                         5, false, false, false, false, false, false),
        Breakpoint("Baby: Back",                          5, false, false, false,  true, false, false),
        Breakpoint("Baby: Head",                        5/2,  true, false, false, false, false, false),
        Breakpoint("Baby: Occi",                        5/2,  true, false, false,  true, false, false),

        Breakpoint("Scout: Front",                       42, false, false, false, false,  true, false),
        Breakpoint("Scout: Back",                        42, false, false, false,  true,  true, false),
        Breakpoint("Scout: Head",                      42/3,  true, false, false, false,  true, false),
        Breakpoint("Scout: Occi",                      42/3,  true, false, false,  true,  true, false),

        Breakpoint("Zoomer Scout: Front",                33, false, false, false, false,  true, false),
        Breakpoint("Zoomer Scout: Back",                 33, false, false, false,  true,  true, false),
        Breakpoint("Zoomer Scout: Head",               33/3,  true, false, false, false,  true, false),
        Breakpoint("Zoomer Scout: Occi",               33/3,  true, false, false,  true,  true, false),

        Breakpoint("Tank: Stagger",                   400/3,  true,  true, false, false, false,  true),
        Breakpoint("Mother: Stagger",                1000/5,  true,  true, false, false, false,  true),
        Breakpoint("pMother: Stagger",               2500/5,  true,  true, false, false, false,  true),

        Breakpoint("Lock",                               15, false, false,  true, false, false,  true),
    ]

    out = ""
    for melee in melees
        out *= SEP * melee.name
    end
    out *= "\n"

    for breakpoint in breakpoints
        out *= breakpoint.name
        for melee in melees
            out *= SEP * melee_breakpoint(melee, breakpoint)
        end
        out *= "\n"
    end
    write("out.csv", out)
    println(out)
end

main()
