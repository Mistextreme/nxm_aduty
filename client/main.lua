local ESX = nil
local InAduty = false
local CurrentRank = nil
local OriginalJob = nil
local OriginalGrade = nil
local GodModeActive = false
local PreviewActive = false
local Preview3DActive = false
local UIOpen = false
local LastToggle = 0
local BlipIds = {}
local PreviewPed = nil
local PreviewCamera = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand(Config.Command, function(source, args, rawCommand)
    if GetGameTimer() - LastToggle < Config.ToggleCooldownMs then
        TriggerEvent('esx:showNotification', string.format(_U('cooldown_wait'), 
            math.ceil((Config.ToggleCooldownMs - (GetGameTimer() - LastToggle)) / 1000)))
        return
    end
    LastToggle = GetGameTimer()
    TriggerServerEvent('aduty:toggleAduty')
end, false)

RegisterCommand(Config.OpenUICommand, function(source, args, rawCommand)
    TriggerServerEvent('aduty:requestUIOpen')
end, false)

RegisterCommand(Config.Commands.list, function(source, args, rawCommand)
    TriggerServerEvent('aduty:cmdList')
end, false)

RegisterCommand(Config.Commands.log, function(source, args, rawCommand)
    local playerId = args[1]
    TriggerServerEvent('aduty:requestUIOpen', 'logs', playerId)
end, false)

RegisterCommand(Config.Commands.forceOff, function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent('esx:showNotification', string.format(_U('off_usage'), Config.Commands.forceOff))
        return
    end
    TriggerServerEvent('aduty:cmdForceOff', tonumber(args[1]))
end, false)

RegisterNetEvent('aduty:toggleAdutyResponse', function(data)
    if data.success then
        if data.entered then
            InAduty = true
            CurrentRank = data.rank
            GodModeActive = data.godMode
            TriggerEvent('esx:showNotification', _U('aduty_entered'))
            if data.autoHeal then
                local ped = PlayerPedId()
                SetEntityHealth(ped, 200)
            end
            if data.autoArmor then
                local ped = PlayerPedId()
                SetPedArmour(ped, 100)
            end
        else
            InAduty = false
            CurrentRank = nil
            GodModeActive = false
            TriggerEvent('esx:showNotification', _U('aduty_left'))
        end
    else
        TriggerEvent('esx:showNotification', data.message or _U('no_permission'))
    end
end)

RegisterNetEvent('aduty:applyOutfit', function(components)
    if not components then return end
    TriggerEvent('skinchanger:loadClothes', 0, components)
end)

RegisterNetEvent('aduty:forceOffNotify', function(admin)
    InAduty = false
    CurrentRank = nil
    GodModeActive = false
    TriggerEvent('esx:showNotification', string.format(_U('aduty_force_off'), admin))
end)

RegisterNetEvent('aduty:jobRestored', function(job, grade)
    TriggerEvent('esx:showNotification', string.format(_U('aduty_job_restored'), job, grade))
end)

RegisterNetEvent('aduty:openUI', function(data)
    UIOpen = true
    local uiData = {
        action = 'open',
        outfits = data.outfits or {},
        fields = Config.OutfitFields or {},
        activeList = data.activeList or {},
        canManage = data.canManage,
        i18n = data.i18n or {},
        ui = Config.UI or {},
        initTab = data.initTab or 'ranks',
        logFilter = data.logFilter or '',
    }
    SendNUIMessage(uiData)
    SetNuiFocus(true, true)
end)

RegisterNetEvent('aduty:closeUI', function()
    UIOpen = false
    SendNUIMessage({ action = 'close' })
    SetNuiFocus(false, false)
end)

RegisterNetEvent('aduty:updateActiveList', function(activeList)
    if UIOpen then
        SendNUIMessage({
            action = 'updateActiveList',
            activeList = activeList,
        })
    end
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    UIOpen = false
    cb('ok')
end)

RegisterNUICallback('refresh', function(data, cb)
    TriggerServerEvent('aduty:refreshOutfits')
    cb({ outfits = {} })
end)

RegisterNUICallback('refreshActive', function(data, cb)
    TriggerServerEvent('aduty:refreshActiveList')
    cb({ activeList = {} })
end)

RegisterNUICallback('save', function(data, cb)
    TriggerServerEvent('aduty:saveOutfit', data)
    cb('ok')
end)

RegisterNUICallback('delete', function(data, cb)
    TriggerServerEvent('aduty:deleteOutfit', data.rank_key)
    cb('ok')
end)

RegisterNUICallback('forceOff', function(data, cb)
    TriggerServerEvent('aduty:forceOffPlayer', data.id)
    cb('ok')
end)

RegisterNUICallback('getLogs', function(data, cb)
    TriggerServerEvent('aduty:getLogs', data.query, data.limit)
    cb({ logs = {} })
end)

RegisterNetEvent('aduty:sendLogs', function(logs)
    SendNUIMessage({
        action = 'logs',
        logs = logs,
    })
end)

RegisterNUICallback('importCurrent', function(data, cb)
    local ped = PlayerPedId()
    TriggerEvent('skinchanger:getSkin', function(skin)
        cb({
            sex = skin.sex,
            components = skin,
        })
    end)
end)

RegisterNUICallback('preview', function(data, cb)
    if data.components then
        PreviewActive = true
        TriggerEvent('skinchanger:loadClothes', 0, data.components)
    end
    cb('ok')
end)

RegisterNUICallback('previewReset', function(data, cb)
    if PreviewActive then
        PreviewActive = false
        TriggerEvent('skinchanger:loadSkin', ESX.GetPlayerData().skin)
    end
    cb('ok')
end)

RegisterNUICallback('preview3DStart', function(data, cb)
    Preview3DActive = true
    TriggerServerEvent('aduty:preview3DStart', data.components)
    cb('ok')
end)

RegisterNUICallback('preview3DStop', function(data, cb)
    Preview3DActive = false
    TriggerServerEvent('aduty:preview3DStop')
    if PreviewPed and DoesEntityExist(PreviewPed) then
        DeleteEntity(PreviewPed)
        PreviewPed = nil
    end
    if PreviewCamera then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(PreviewCamera, false)
        PreviewCamera = nil
    end
    SendNUIMessage({ action = '3dPreviewClosed' })
    cb('ok')
end)

RegisterNUICallback('preview3DUpdate', function(data, cb)
    if Preview3DActive and data.components then
        TriggerServerEvent('aduty:preview3DUpdate', data.components)
    end
    cb('ok')
end)

RegisterNetEvent('aduty:preview3DSetup', function(pedModel, components)
    local cfg = Config.Preview3D
    local ped = PlayerPedId()
    
    RequestModel(GetHashKey(pedModel))
    while not HasModelLoaded(GetHashKey(pedModel)) do
        Wait(10)
    end
    
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    
    PreviewPed = CreatePed(4, GetHashKey(pedModel), cfg.coords.x, cfg.coords.y, cfg.coords.z, cfg.heading, true, false)
    SetBlockingOfNonTemporaryEvents(PreviewPed, true)
    
    if components then
        TriggerEvent('skinchanger:loadClothes', 0, components, PreviewPed)
    end
    
    local camCoords = GetOffsetFromEntityInWorldCoords(PreviewPed, 0, cfg.cameraDistance, 0.5)
    PreviewCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(PreviewCamera, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(PreviewCamera, PreviewPed, 0, 0, 0, true)
    RenderScriptCams(true, false, 0, true, false)
    
    local mouseX, mouseY = 0, 0
    local scrollDist = cfg.cameraDistance
    
    while Preview3DActive do
        local mx, my = GetDisabledControlNormal(0, 1), GetDisabledControlNormal(0, 2)
        mouseX = mouseX + (mx * cfg.mouseSpeed)
        mouseY = mouseY + (my * cfg.mouseSpeed)
        
        if IsControlJustPressed(0, 241) then
            scrollDist = math.min(scrollDist + 0.1, cfg.maxDistance)
        end
        if IsControlJustPressed(0, 242) then
            scrollDist = math.max(scrollDist - 0.1, cfg.minDistance)
        end
        
        local rad = math.rad(mouseX)
        local camX = GetEntityCoords(PreviewPed).x + (math.sin(rad) * scrollDist)
        local camY = GetEntityCoords(PreviewPed).y + (math.cos(rad) * scrollDist)
        local camZ = GetEntityCoords(PreviewPed).z + mouseY
        
        SetCamCoord(PreviewCamera, camX, camY, camZ)
        PointCamAtEntity(PreviewCamera, PreviewPed, 0, 0, 0, true)
        
        Wait(0)
    end
end)

RegisterNetEvent('aduty:preview3DApplyOutfit', function(components)
    if PreviewPed and DoesEntityExist(PreviewPed) then
        if components then
            TriggerEvent('skinchanger:loadClothes', 0, components, PreviewPed)
        end
    end
end)

RegisterNetEvent('aduty:addBlip', function(data)
    if data.src then
        RemoveBlip(BlipIds[data.src])
        
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.blipSprite)
        SetBlipColour(blip, data.blipColor)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentString(string.format(_U('blip_name'), data.playerName, data.rankLabel))
        EndTextCommandDisplayHelp(2)
        
        BlipIds[data.src] = blip
    end
end)

RegisterNetEvent('aduty:removeBlip', function(data)
    if data.src and BlipIds[data.src] then
        RemoveBlip(BlipIds[data.src])
        BlipIds[data.src] = nil
    end
end)

RegisterNetEvent('aduty:updateBlip', function(data)
    if data.src and BlipIds[data.src] then
        SetBlipCoords(BlipIds[data.src], data.coords.x, data.coords.y, data.coords.z)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if InAduty and GodModeActive then
            local ped = PlayerPedId()
            SetEntityInvincible(ped, true)
        end
        
        if UIOpen then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
        end
        
        if IsControlJustPressed(0, 322) and UIOpen then
            SetNuiFocus(false, false)
            UIOpen = false
            SendNUIMessage({ action = 'close' })
        end
    end
end)
