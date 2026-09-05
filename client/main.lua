local hairHidden = false
local savedHair = nil
local savedModel = nil
local usingScrunchie = false

local function notify(message, notifyType)
    if Config.UseOxLibNotify and GetResourceState('ox_lib') == 'started' and lib then
        lib.notify({
            title = 'Hair',
            description = message,
            type = notifyType or 'inform'
        })
        return
    end

    TriggerEvent('chat:addMessage', {
        color = { 255, 255, 255 },
        args = { 'Hair', message }
    })
end

local function saveCurrentHair(ped)
    savedHair = {
        drawable = GetPedDrawableVariation(ped, 2),
        texture = GetPedTextureVariation(ped, 2),
        palette = GetPedPaletteVariation(ped, 2)
    }

    savedModel = GetEntityModel(ped)
end

local function hideHair(ped)
    saveCurrentHair(ped)

    SetPedComponentVariation(
        ped,
        2,
        Config.HiddenHairDrawable,
        Config.HiddenHairTexture,
        Config.HiddenHairPalette
    )

    hairHidden = true
    notify('You tied your hair up. Use the scrunchie again to put it back.', 'success')
end

local function restoreHair(ped)
    if not savedHair then
        hairHidden = false
        notify('No saved hairstyle was found.', 'error')
        return
    end

    -- Prevent restoring an old hairstyle to a completely different ped model.
    if savedModel and GetEntityModel(ped) ~= savedModel then
        hairHidden = false
        savedHair = nil
        savedModel = nil
        notify('Your character model changed, so the saved hairstyle was cleared.', 'error')
        return
    end

    SetPedComponentVariation(
        ped,
        2,
        savedHair.drawable,
        savedHair.texture,
        savedHair.palette
    )

    hairHidden = false
    savedHair = nil
    savedModel = nil
    notify('You removed the scrunchie and restored your hair.', 'success')
end

local function toggleHair()
    if usingScrunchie then
        return
    end

    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then
        return
    end

    usingScrunchie = true

    if hairHidden then
        restoreHair(ped)
    else
        hideHair(ped)
    end

    SetTimeout(500, function()
        usingScrunchie = false
    end)
end

-- Called by ox_inventory when the scrunchie item is used.
exports('useScrunchie', function(data, slot)
    toggleHair()
end)

-- If the player changes character/ped while hair is hidden, clear the stored state.
CreateThread(function()
    while true do
        Wait(1500)

        if hairHidden and savedModel then
            local ped = PlayerPedId()
            if DoesEntityExist(ped) and GetEntityModel(ped) ~= savedModel then
                hairHidden = false
                savedHair = nil
                savedModel = nil
            end
        end
    end
end)
