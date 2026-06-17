local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local Outfits = {}
local ActivePlayers = {}
local PlayerCooldowns = {}

local function initDatabase()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `aduty_outfits` (
            `rank_key`     VARCHAR(64)  NOT NULL,
            `label`        VARCHAR(128) NOT NULL,
            `priority`     INT          NOT NULL DEFAULT 100,
            `male_data`    LONGTEXT     NULL,
            `female_data`  LONGTEXT     NULL,
            `god_mode`     TINYINT(1)   NOT NULL DEFAULT 0,
            `auto_heal`    TINYINT(1)   NOT NULL DEFAULT 1,
            `auto_armor`   TINYINT(1)   NOT NULL DEFAULT 1,
            `blip_color`   INT          NOT NULL DEFAULT 3,
            `blip_sprite`  INT          NOT NULL DEFAULT 1,
            `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `updated_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`rank_key`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `aduty_active` (
            `identifier`     VARCHAR(64) NOT NULL,
            `original_job`   VARCHAR(64) NOT NULL,
            `original_grade` INT         NOT NULL DEFAULT 0,
            `started_at`     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `aduty_logs` (
            `id`           BIGINT       NOT NULL AUTO_INCREMENT,
            `identifier`   VARCHAR(64)  NOT NULL,
            `player_name`  VARCHAR(128) NOT NULL,
            `action`       VARCHAR(32)  NOT NULL,
            `rank_key`     VARCHAR(64)  NULL,
            `actor`        VARCHAR(128) NULL,
            `meta`         LONGTEXT     NULL,
            `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `idx_identifier` (`identifier`),
            KEY `idx_player`     (`player_name`),
            KEY `idx_created`    (`created_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
    
    MySQL.Async.execute([[
        ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `god_mode`    TINYINT(1) NOT NULL DEFAULT 0
    ]])
    MySQL.Async.execute([[
        ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `auto_heal`   TINYINT(1) NOT NULL DEFAULT 1
    ]])
    MySQL.Async.execute([[
        ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `auto_armor`  TINYINT(1) NOT NULL DEFAULT 1
    ]])
    MySQL.Async.execute([[
        ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `blip_color`  INT        NOT NULL DEFAULT 3
    ]])
    MySQL.Async.execute([[
        ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `blip_sprite` INT        NOT NULL DEFAULT 1
    ]])
    
    MySQL.Async.execute([[
        UPDATE `aduty_outfits` SET `blip_sprite` = 1 WHERE `blip_sprite` IS NULL OR `blip_sprite` <= 0
    ]])
    MySQL.Async.execute([[
        UPDATE `aduty_outfits` SET `blip_color` = 3 WHERE `blip_color` IS NULL OR `blip_color` <= 0
    ]])
end

local function loadOutfits()
    MySQL.Async.fetchAll('SELECT * FROM aduty_outfits ORDER BY priority DESC', {}, function(result)
        Outfits = {}
        if result and #result > 0 then
            for _, row in ipairs(result) do
                Outfits[row.rank_key] = {
                    rank_key = row.rank_key,
                    label = row.label,
                    priority = row.priority,
                    male_data = row.male_data and json.decode(row.male_data) or {},
                    female_data = row.female_data and json.decode(row.female_data) or {},
                    god_mode = row.god_mode == 1,
                    auto_heal = row.auto_heal == 1,
                    auto_armor = row.auto_armor == 1,
                    blip_color = row.blip_color,
                    blip_sprite = row.blip_sprite,
                }
            end
        end
        print('^2[NXM_Aduty]^7 DB-Schema OK.')
        print('^2[NXM_Aduty]^7 ' .. #Outfits .. ' Outfit(s) loaded.')
    end)
end

local function insertLog(identifier, playerName, action, rankKey, actor)
    MySQL.Async.execute(
        'INSERT INTO aduty_logs (identifier, player_name, action, rank_key, actor, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
        { identifier, playerName, action, rankKey or NULL, actor or NULL }
    )
end

local function hasPermission(source, permission)
    return IsPlayerAceAllowed(source, permission)
end

local function getRankForPlayer(source)
    local ranks = {}
    for rankKey, outfit in pairs(Outfits) do
        if hasPermission(source, 'staff.aduty.' .. rankKey) then
            table.insert(ranks, {
                key = rankKey,
                priority = outfit.priority,
            })
        end
    end
    
    if #ranks == 0 then return nil end
    
    table.sort(ranks, function(a, b) return a.priority > b.priority end)
    return ranks[1].key
end

local function getPlayerIdentifier(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, 'license:') then return id end
    end
    return nil
end

local function sendDiscordLog(title, fields)
    if not Config.Webhook or Config.Webhook == '' then return end
    
    local embed = {
        title = title,
        color = 5793266,
        fields = fields,
        footer = { text = _U('discord_footer') },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
    }
    
    PerformHttpRequest(Config.Webhook, function(err, text, headers)
    end, 'POST', json.encode({ username = Config.BotName, embeds = { embed } }), 
    { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent('aduty:toggleAduty')
AddEventHandler('aduty:toggleAduty', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    if PlayerCooldowns[src] and GetGameTimer() - PlayerCooldowns[src] < Config.ToggleCooldownMs then
        TriggerClientEvent('chat:addMessage', src, {
            args = { _U('title'), string.format(_U('cooldown_wait'), 
                math.ceil((Config.ToggleCooldownMs - (GetGameTimer() - PlayerCooldowns[src])) / 1000)) },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local identifier = getPlayerIdentifier(src)
    local playerName = xPlayer.getName()
    local rankKey = getRankForPlayer(src)
    
    if not rankKey then
        TriggerClientEvent('aduty:toggleAdutyResponse', src, {
            success = false,
            message = _U('no_permission'),
        })
        return
    end
    
    if ActivePlayers[identifier] then
        local outfit = Outfits[rankKey]
        xPlayer.setJob(ActivePlayers[identifier].original_job, ActivePlayers[identifier].original_grade)
        ActivePlayers[identifier] = nil
        
        MySQL.Async.execute(
            'DELETE FROM aduty_active WHERE identifier = ?',
            { identifier }
        )
        
        insertLog(identifier, playerName, 'leave', rankKey, nil)
        
        sendDiscordLog(_U('discord_left'), {
            { name = _U('discord_field_player'), value = playerName, inline = true },
            { name = _U('discord_field_rank'), value = outfit.label, inline = true },
            { name = _U('discord_field_job'), value = ActivePlayers[identifier] and ActivePlayers[identifier].original_job or 'N/A', inline = false },
        })
        
        TriggerClientEvent('aduty:toggleAdutyResponse', src, {
            success = true,
            entered = false,
        })
        
        TriggerClientEvent('aduty:removeBlip', -1, { src = src })
    else
        local outfit = Outfits[rankKey]
        local sex = xPlayer.get('skin').sex or 0
        local components = sex == 1 and outfit.female_data or outfit.male_data
        
        if not components or (type(components) == 'table' and not next(components)) then
            TriggerClientEvent('aduty:toggleAdutyResponse', src, {
                success = false,
                message = _U('aduty_no_outfit_for_sex'),
            })
            return
        end
        
        local oldJob = xPlayer.getJob().name
        local oldGrade = xPlayer.getJob().grade
        
        ActivePlayers[identifier] = {
            original_job = oldJob,
            original_grade = oldGrade,
            rank = rankKey,
        }
        
        MySQL.Async.execute(
            'INSERT INTO aduty_active (identifier, original_job, original_grade) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE original_job = ?, original_grade = ?',
            { identifier, oldJob, oldGrade, oldJob, oldGrade }
        )
        
        xPlayer.setJob(Config.AdutyJob, Config.AdutyGrade)
        
        insertLog(identifier, playerName, 'enter', rankKey, nil)
        
        sendDiscordLog(_U('discord_entered'), {
            { name = _U('discord_field_player'), value = playerName, inline = true },
            { name = _U('discord_field_rank'), value = outfit.label, inline = true },
            { name = _U('discord_field_oldjob'), value = oldJob, inline = true },
            { name = _U('discord_field_oldgrade'), value = tostring(oldGrade), inline = true },
            { name = _U('discord_field_newjob'), value = Config.AdutyJob, inline = false },
        })
        
        TriggerClientEvent('aduty:toggleAdutyResponse', src, {
            success = true,
            entered = true,
            rank = rankKey,
            godMode = outfit.god_mode,
            autoHeal = outfit.auto_heal,
            autoArmor = outfit.auto_armor,
        })
        
        TriggerClientEvent('aduty:applyOutfit', src, components)
        
        TriggerClientEvent('aduty:addBlip', -1, {
            src = src,
            coords = GetEntityCoords(GetPlayerPed(src)),
            blipSprite = outfit.blip_sprite,
            blipColor = outfit.blip_color,
            playerName = playerName,
            rankLabel = outfit.label,
        })
    end
    
    PlayerCooldowns[src] = GetGameTimer()
end)

RegisterServerEvent('aduty:requestUIOpen')
AddEventHandler('aduty:requestUIOpen', function(initTab, logFilter)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local canManage = hasPermission(src, 'staff.aduty.manage') or 
                      hasPermission(src, 'staff.aduty.projectlead')
    
    if not canManage then
        TriggerClientEvent('chat:addMessage', src, {
            args = { _U('title'), _U('no_permission_for_ui') },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local outfitList = {}
    for _, outfit in pairs(Outfits) do
        table.insert(outfitList, outfit)
    end
    table.sort(outfitList, function(a, b) return a.priority > b.priority end)
    
    local i18n = {}
    for k, v in pairs(Locales[Config.Locale] or Locales.en) do
        i18n[k] = v
    end
    
    local activeList = {}
    for identifier, data in pairs(ActivePlayers) do
        for i = 0, 255 do
            if GetPlayerName(i) then
                local ident = getPlayerIdentifier(i)
                if ident == identifier then
                    local outfit = Outfits[data.rank]
                    table.insert(activeList, {
                        src = i,
                        name = GetPlayerName(i),
                        rank = data.rank,
                        rank_label = outfit and outfit.label or data.rank,
                    })
                    break
                end
            end
        end
    end
    
    TriggerClientEvent('aduty:openUI', src, {
        outfits = outfitList,
        activeList = activeList,
        canManage = canManage,
        i18n = i18n,
        initTab = initTab or 'ranks',
        logFilter = logFilter or '',
    })
end)

RegisterServerEvent('aduty:saveOutfit')
AddEventHandler('aduty:saveOutfit', function(data)
    local src = source
    local canManage = hasPermission(src, 'staff.aduty.manage') or 
                      hasPermission(src, 'staff.aduty.projectlead')
    
    if not canManage then return end
    
    if not data.rank_key or data.rank_key == '' then return end
    
    local maleData = json.encode(data.male_data or {})
    local femaleData = json.encode(data.female_data or {})
    
    MySQL.Async.execute(
        [[INSERT INTO aduty_outfits (rank_key, label, priority, male_data, female_data, god_mode, auto_heal, auto_armor, blip_color, blip_sprite)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
           ON DUPLICATE KEY UPDATE label=?, priority=?, male_data=?, female_data=?, god_mode=?, auto_heal=?, auto_armor=?, blip_color=?, blip_sprite=?]],
        {
            data.rank_key, data.label, data.priority, maleData, femaleData,
            data.god_mode and 1 or 0, data.auto_heal and 1 or 0, data.auto_armor and 1 or 0,
            data.blip_color, data.blip_sprite,
            data.label, data.priority, maleData, femaleData,
            data.god_mode and 1 or 0, data.auto_heal and 1 or 0, data.auto_armor and 1 or 0,
            data.blip_color, data.blip_sprite,
        },
        function()
            loadOutfits()
            TriggerClientEvent('aduty:refreshOutfits', src)
            insertLog(getPlayerIdentifier(src), GetPlayerName(src), 'outfit_save', data.rank_key, nil)
        end
    )
end)

RegisterServerEvent('aduty:deleteOutfit')
AddEventHandler('aduty:deleteOutfit', function(rankKey)
    local src = source
    local canManage = hasPermission(src, 'staff.aduty.manage') or 
                      hasPermission(src, 'staff.aduty.projectlead')
    
    if not canManage then return end
    
    MySQL.Async.execute(
        'DELETE FROM aduty_outfits WHERE rank_key = ?',
        { rankKey },
        function()
            loadOutfits()
            TriggerClientEvent('aduty:refreshOutfits', src)
            insertLog(getPlayerIdentifier(src), GetPlayerName(src), 'outfit_delete', rankKey, nil)
        end
    )
end)

RegisterServerEvent('aduty:refreshOutfits')
AddEventHandler('aduty:refreshOutfits', function()
    local src = source
    local canManage = hasPermission(src, 'staff.aduty.manage') or 
                      hasPermission(src, 'staff.aduty.projectlead')
    
    if not canManage then return end
    
    loadOutfits()
end)

RegisterServerEvent('aduty:refreshActiveList')
AddEventHandler('aduty:refreshActiveList', function()
    local src = source
    
    local activeList = {}
    for identifier, data in pairs(ActivePlayers) do
        for i = 0, 255 do
            if GetPlayerName(i) then
                local ident = getPlayerIdentifier(i)
                if ident == identifier then
                    local outfit = Outfits[data.rank]
                    table.insert(activeList, {
                        src = i,
                        name = GetPlayerName(i),
                        rank = data.rank,
                        rank_label = outfit and outfit.label or data.rank,
                    })
                    break
                end
            end
        end
    end
    
    TriggerClientEvent('aduty:updateActiveList', src, activeList)
end)

RegisterServerEvent('aduty:cmdList')
AddEventHandler('aduty:cmdList', function()
    local src = source
    local hasRank = false
    
    for rankKey in pairs(Outfits) do
        if hasPermission(src, 'staff.aduty.' .. rankKey) then
            hasRank = true
            break
        end
    end
    
    if not hasRank then
        TriggerClientEvent('chat:addMessage', src, {
            args = { _U('title'), _U('no_permission') },
            color = { 255, 0, 0 }
        })
        return
    end
    
    if next(ActivePlayers) == nil then
        TriggerClientEvent('chat:addMessage', src, {
            args = { _U('title'), _U('list_none_active') },
            color = { 0, 255, 0 }
        })
        return
    end
    
    local count = 0
    for _ in pairs(ActivePlayers) do count = count + 1 end
    
    TriggerClientEvent('chat:addMessage', src, {
        args = { _U('title'), string.format(_U('list_header'), count) },
        color = { 0, 255, 0 }
    })
    
    for identifier, data in pairs(ActivePlayers) do
        for i = 0, 255 do
            if GetPlayerName(i) then
                local ident = getPlayerIdentifier(i)
                if ident == identifier then
                    local outfit = Outfits[data.rank]
                    TriggerClientEvent('chat:addMessage', src, {
                        args = { _U('title'), 
                            string.format(_U('list_row'), i, GetPlayerName(i), outfit and outfit.label or data.rank) },
                        color = { 0, 255, 0 }
                    })
                    break
                end
            end
        end
    end
end)

RegisterServerEvent('aduty:cmdForceOff')
AddEventHandler('aduty:cmdForceOff', function(targetId)
    local src = source
    local canManage = hasPermission(src, 'staff.aduty.manage') or 
                      hasPermission(src, 'staff.aduty.projectlead')
    
    if not canManage then
        TriggerClientEvent('chat:addMessage', src, {
            args = { _U('title'), _U('no_permission') },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    
    if not targetPlayer then
        TriggerClientEvent('chat:addMessage', src, {
            args = { _U('title'), string.format(_U('off_player_offline'), targetId) },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local identifier = getPlayerIdentifier(targetId)
    
    if not ActivePlayers[identifier] then
        TriggerClientEvent('chat:addMessage', src, {
            args = { _U('title'), string.format(_U('off_not_in_aduty'), targetId) },
            color = { 255, 0, 0 }
        })
        return
    end
    
    local data = ActivePlayers[identifier]
    targetPlayer.setJob(data.original_job, data.original_grade)
    ActivePlayers[identifier] = nil
    
    MySQL.Async.execute(
        'DELETE FROM aduty_active WHERE identifier = ?',
        { identifier }
    )
    
    insertLog(identifier, targetPlayer.getName(), 'force_off', nil, GetPlayerName(src))
    
    TriggerClientEvent('aduty:forceOffNotify', targetId, GetPlayerName(src))
    TriggerClientEvent('chat:addMessage', src, {
        args = { _U('title'), string.format(_U('off_success'), targetPlayer.getName()) },
        color = { 0, 255, 0 }
    })
    
    TriggerClientEvent('aduty:removeBlip', -1, { src = targetId })
end)

RegisterServerEvent('aduty:forceOffPlayer')
AddEventHandler('aduty:forceOffPlayer', function(targetId)
    TriggerEvent('aduty:cmdForceOff', tonumber(targetId))
end)

RegisterServerEvent('aduty:getLogs')
AddEventHandler('aduty:getLogs', function(query, limit)
    local src = source
    local canManage = hasPermission(src, 'staff.aduty.manage') or 
                      hasPermission(src, 'staff.aduty.projectlead')
    
    if not canManage then return end
    
    limit = math.min(limit or Config.LogLimit, 1000)
    
    local where = ''
    local params = {}
    
    if query and query ~= '' then
        where = ' WHERE player_name LIKE ? OR identifier LIKE ? OR action LIKE ? OR rank_key LIKE ?'
        local q = '%' .. query .. '%'
        params = { q, q, q, q }
    end
    
    MySQL.Async.fetchAll(
        'SELECT * FROM aduty_logs' .. where .. ' ORDER BY created_at DESC LIMIT ?',
        { table.unpack(params), limit },
        function(result)
            local logs = {}
            if result then
                for _, row in ipairs(result) do
                    table.insert(logs, {
                        created_at = row.created_at,
                        action = row.action,
                        player_name = row.player_name,
                        rank_key = row.rank_key or '',
                        actor = row.actor or '',
                    })
                end
            end
            TriggerClientEvent('aduty:sendLogs', src, logs)
        end
    )
end)

RegisterServerEvent('aduty:preview3DStart')
AddEventHandler('aduty:preview3DStart', function(components)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local skin = xPlayer.get('skin')
    local model = skin.model == 'a_m_m_business_1' and 'a_m_m_business_1' or 'a_f_y_business_1'
    
    TriggerClientEvent('aduty:preview3DSetup', src, model, components)
end)

RegisterServerEvent('aduty:preview3DStop')
AddEventHandler('aduty:preview3DStop', function()
end)

RegisterServerEvent('aduty:preview3DUpdate')
AddEventHandler('aduty:preview3DUpdate', function(components)
    local src = source
    TriggerClientEvent('aduty:preview3DApplyOutfit', src, components)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local identifier = getPlayerIdentifier(src)
    
    if identifier and ActivePlayers[identifier] then
        local data = ActivePlayers[identifier]
        
        insertLog(identifier, GetPlayerName(src), 'leave', data.rank, nil)
    end
end)

AddEventHandler('playerJoined', function()
    local src = source
    local identifier = getPlayerIdentifier(src)
    
    if identifier then
        MySQL.Async.fetchAll(
            'SELECT * FROM aduty_active WHERE identifier = ?',
            { identifier },
            function(result)
                if result and #result > 0 then
                    local data = result[1]
                    ActivePlayers[identifier] = {
                        original_job = data.original_job,
                        original_grade = data.original_grade,
                    }
                    
                    local xPlayer = ESX.GetPlayerFromId(src)
                    if xPlayer then
                        xPlayer.setJob(data.original_job, data.original_grade)
                        TriggerClientEvent('aduty:jobRestored', src, data.original_job, data.original_grade)
                        
                        insertLog(identifier, GetPlayerName(src), 'restore', nil, nil)
                        
                        MySQL.Async.execute(
                            'DELETE FROM aduty_active WHERE identifier = ?',
                            { identifier }
                        )
                        
                        ActivePlayers[identifier] = nil
                    end
                end
            end
        )
    end
end)

Citizen.CreateThread(function()
    Wait(500)
    initDatabase()
    Wait(1000)
    loadOutfits()
end)

Citizen.CreateThread(function()
    while true do
        Wait(Config.BlipSyncIntervalMs)
        
        for identifier, data in pairs(ActivePlayers) do
            for i = 0, 255 do
                if GetPlayerName(i) then
                    local ident = getPlayerIdentifier(i)
                    if ident == identifier then
                        local ped = GetPlayerPed(i)
                        if ped and DoesEntityExist(ped) then
                            local coords = GetEntityCoords(ped)
                            TriggerClientEvent('aduty:updateBlip', -1, {
                                src = i,
                                coords = coords,
                            })
                        end
                        break
                    end
                end
            end
        end
    end
end)
