-- Recréer "Save tracks as track template" avec un chemin par défaut
-- L'utilisateur définit le chemin directement dans le script

-- Définir le chemin par défaut ici
local default_path = "G:/Mon Drive/LPF/CLIENT/LPF_PRESETS/REAPER/TRACK" -- À modifier selon ton système

-- Vérifier que le chemin est un dossier existant
local function is_valid_path(path)
    return reaper.RecursiveCreateDirectory(path, 0)
end

if not is_valid_path(default_path) then
    reaper.ShowMessageBox("Le chemin spécifié n'existe pas. Modifie le script pour définir un chemin valide.", "Erreur", 0)
    return
end

-- Demander le nom du template
local retval, template_name = reaper.GetUserInputs("Nom du template", 1, "Nom du fichier:", "")
if not retval or template_name == "" then
    return
end

-- Construire le chemin du fichier
local save_path = default_path .. "/" .. template_name .. ".RTrackTemplate"

-- Récupérer les pistes sélectionnées
local track_count = reaper.CountSelectedTracks(0)
if track_count == 0 then
    reaper.ShowMessageBox("Aucune piste sélectionnée.", "Erreur", 0)
    return
end

if reaper.file_exists(save_path) then
    local confirm = reaper.ShowMessageBox("Le fichier existe déjà. Voulez-vous l'écraser ?", "Confirmation", 4)
    if confirm ~= 6 then -- 6 correspond à 'Yes'
        return
    end
end

local file = io.open(save_path, "w")
if not file then
    reaper.ShowMessageBox("Impossible de créer le fichier. Vérifie les permissions du dossier.", "Erreur", 0)
    return
end

file:write("\n")

for i = 0, track_count - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local retval, chunk = reaper.GetTrackStateChunk(track, "", true)
    if retval then
        file:write(chunk .. "\n")
    end
end
file:close()

reaper.ShowMessageBox("Template enregistré dans: " .. save_path, "Succès", 0)

