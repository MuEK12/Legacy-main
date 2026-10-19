-----------------------------------------------------------------------------------------------------------------------------------------
-- POSITION
-----------------------------------------------------------------------------------------------------------------------------------------
function Position(source, name_, pos)
    TriggerClientEvent("sounds:stateSound", source, "position", {
        soundId = name_,
        position = pos,
    })
end

exports('Position', Position)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DISTANCE
-----------------------------------------------------------------------------------------------------------------------------------------
function Distance(source, name_, distance_)
    TriggerClientEvent("sounds:stateSound", source, "distance", {
        soundId = name_,
        distance = distance_,
    })
end

exports('Distance', Distance)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROY
-----------------------------------------------------------------------------------------------------------------------------------------
function Destroy(source, name_)
    TriggerClientEvent("sounds:stateSound", source, "destroy", {
        soundId = name_,
    })
end

exports('Destroy', Destroy)

-----------------------------------------------------------------------------------------------------------------------------------------
-- PAUSE
-----------------------------------------------------------------------------------------------------------------------------------------
function Pause(source, name_)
    TriggerClientEvent("sounds:stateSound", source, "pause", {
        soundId = name_,
    })
end

exports('Pause', Pause)

-----------------------------------------------------------------------------------------------------------------------------------------
-- RESUME
-----------------------------------------------------------------------------------------------------------------------------------------
function Resume(source, name_)
    TriggerClientEvent("sounds:stateSound", source, "resume", {
        soundId = name_,
    })
end

exports('Resume', Resume)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETVOLUME
-----------------------------------------------------------------------------------------------------------------------------------------
function setVolume(source, name_, vol)
    TriggerClientEvent("sounds:stateSound", source, "volume", {
        soundId = name_,
        volume = vol,
    })
end

exports('setVolume', setVolume)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTIMESTAMP
-----------------------------------------------------------------------------------------------------------------------------------------
function setTimeStamp(source, name_, time_)
    TriggerClientEvent("sounds:stateSound", source, "timestamp", {
        soundId = name_,
        time = time_
    })
end

exports('setTimeStamp', setTimeStamp)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYONFINISH
-----------------------------------------------------------------------------------------------------------------------------------------
function destroyOnFinish(id, bool)
    TriggerClientEvent("sounds:stateSound", source, "destroyOnFinish", {
        soundId = id,
        value = bool
    })
end

exports('destroyOnFinish', destroyOnFinish)