-- Enregistre les couleurs des pistes sélectionnées
local track_colors = {}
local num_tracks = reaper.CountSelectedTracks(0)
for i = 0, num_tracks - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    track_colors[i] = reaper.GetTrackColor(track)
end

-- Exécute l'action SWS pour rendre les pistes en stems
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWRENDERMONOSMART"), 0)

-- Supprime les 7 derniers caractères des noms des pistes sélectionnées
local num_tracks = reaper.CountSelectedTracks(0)
for i = 0, num_tracks - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    if retval and #track_name > 7 then
        local new_name = track_name:sub(1, -8)
        reaper.GetSetMediaTrackInfo_String(track, "P_NAME", new_name, true)
    end
end

-- Applique les couleurs enregistrées
for i = 0, num_tracks - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    if track_colors[i] then
        reaper.SetTrackColor(track, track_colors[i])
    end
end

-- Rafraîchit l'affichage des pistes
reaper.UpdateArrange()


