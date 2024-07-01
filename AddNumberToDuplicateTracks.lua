-- Function to generate a unique name with incrementing number suffix
function generateUniqueName(baseName, counter)
    return baseName .. "_" .. string.format("%02d", counter)
end

-- Function to extract the base name and current number suffix from a track name
function extractBaseNameAndCounter(name)
    local baseName, counter = name:match("^(.-)_(%d%d)$")
    if baseName and counter then
        return baseName, tonumber(counter)
    else
        return name, 0
    end
end

-- Table to store track names and their highest numerical suffixes
local trackNames = {}

-- Function to rename a track if needed
function renameTrackIfNeeded(track)
    local _, trackName = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    
    if trackName ~= "" then
        local baseName, counter = extractBaseNameAndCounter(trackName)
        
        if trackNames[baseName] then
            trackNames[baseName] = trackNames[baseName] + 1
        else
            trackNames[baseName] = 1
        end
        
        local newTrackName = generateUniqueName(baseName, trackNames[baseName])
        reaper.GetSetMediaTrackInfo_String(track, "P_NAME", newTrackName, true)
    end
end

-- Variable to store track count from the last check
local lastTrackCount = reaper.CountTracks(0)

-- Function to monitor track list changes and rename tracks as needed
function monitorTrackListChanges()
    local currentTrackCount = reaper.CountTracks(0)

    -- Check if tracks were added or removed
    if currentTrackCount ~= lastTrackCount then
        -- Reset trackNames table to start fresh
        trackNames = {}

        -- Iterate over all tracks and rename them if needed
        for i = 0, currentTrackCount - 1 do
            local track = reaper.GetTrack(0, i)
            renameTrackIfNeeded(track)
        end

        -- Update lastTrackCount to reflect current state
        lastTrackCount = currentTrackCount
    end

    -- Schedule the function to run again after a delay (e.g., 0.5 seconds)
    reaper.defer(monitorTrackListChanges)
end

-- Initialize track renaming and monitoring
monitorTrackListChanges()

