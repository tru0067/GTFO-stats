function actual_reload_multiplier(reload_sequence)
    highest_time = 0
    last_time = reload_sequence[end]["TriggerTime"]
    for trigger in reload_sequence
        if trigger["TriggerTime"] > highest_time
            highest_time = trigger["TriggerTime"]
        end
    end
    return highest_time / last_time
end

function reload_cancel_multiplier(reload_sequence)
    highest_time = 0
    ammo_load_time = 0
    last_time = reload_sequence[end]["TriggerTime"]
    for trigger in reload_sequence
        if trigger["TriggerTime"] > highest_time
            highest_time = trigger["TriggerTime"]
        end
        if trigger["Type"] == 6
            ammo_load_time = highest_time
        end
    end
    return ammo_load_time / last_time
end
