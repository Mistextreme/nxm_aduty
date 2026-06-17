Config = {}

-- ============================================================
-- Language / Locale
-- ============================================================
-- Available: 'en' (default), 'de'
-- Add your own by creating locales/<code>.lua and registering it in fxmanifest.lua
Config.Locale = 'en'

-- Translation helper. Use anywhere: _U('key', arg1, arg2, ...)
-- Falls back to English if a key is missing in the selected locale.
function _U(key, ...)
    local lc = (Locales and Locales[Config.Locale]) or (Locales and Locales.en) or {}
    local str = lc[key] or (Locales and Locales.en and Locales.en[key]) or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

-- ============================================================
-- Commands
-- ============================================================

-- Command to toggle in/out of Aduty
Config.Command = 'ad'

-- Command to open the management UI (requires manage permission)
Config.OpenUICommand = 'adutyui'

-- Additional admin commands
Config.Commands = {
    list     = 'adlist',  -- /adlist           -> show all active Aduty players
    log      = 'adlog',   -- /adlog [id]       -> show logs (optionally filtered by player server-id)
    forceOff = 'adoff',   -- /adoff <id>       -> force a player out of Aduty (manage perm)
}

-- ============================================================
-- Aduty Job
-- ============================================================

-- Job & grade applied while a player is in Aduty
Config.AdutyJob   = 'team'
Config.AdutyGrade = 1

-- ============================================================
-- Timing
-- ============================================================

-- Cooldown in ms between two /ad toggles (validated server-side)
Config.ToggleCooldownMs = 5000

-- Default amount of log entries returned by /adlog
Config.LogLimit = 15

-- Map blip sync interval in ms (how often the server pushes positions)
Config.BlipSyncIntervalMs = 5000

-- ============================================================
-- 3D Preview spot
-- Where the player is teleported when previewing an outfit in 3D
-- ============================================================
Config.Preview3D = {
    coords         = vector3(-1380.2069, -470.6974, 72.0421),
    heading        = 347.8627,
    cameraDistance = 2.2,
    minDistance    = 1.0,
    maxDistance    = 5.0,
    mouseSpeed     = 8.0,
}

-- ============================================================
-- Permissions
-- ============================================================

-- Who can open the management UI?
-- Anyone with AT LEAST ONE of these ACE permissions
Config.ManagePermissions = {
    'staff.aduty.manager',
    'staff.aduty.projektleitung',
}

-- ============================================================
-- Discord Logging (optional, leave empty to disable)
-- ============================================================
Config.Webhook = ''
Config.BotName = 'Aduty System'

-- ============================================================
-- Notification function
-- Called ONLY on the client side.
-- ntype: 'info' | 'success' | 'warn' | 'error'
-- Replace the body with your own notification system if you want
-- (ox_lib, sky_hud, custom NUI, etc.)
-- ============================================================
Config.Notify = function(title, message, ntype, duration)
    ntype    = ntype or 'info'
    duration = duration or 5000

    -- Default: ESX Notification
    TriggerEvent('esx:showNotification', ('[%s] %s'):format(title, message))
end

-- ============================================================
-- UI Theme & Branding (fully customizable)
-- ============================================================
Config.UI = {
    -- Branding (sidebar header)
    brandName     = 'Aduty',
    brandSubtitle = 'Admin Panel',

    -- Logo: either text (e.g. "NXM") OR an image (URL/path - logoText is ignored if set)
    logoText      = 'NXM',
    logoImage     = nil,  -- e.g. 'https://i.imgur.com/...' or 'nui://NXM_Aduty/html/logo.png'

    -- Theme (hex colors). Bound to CSS variables live when the UI opens.
    theme = {
        bg0        = '#0b0d12',  -- darkest background
        bg1        = '#12151c',
        bg2        = '#1a1f29',
        bg3        = '#232a37',
        border     = '#2a3140',
        text       = '#e6e9ef',
        textDim    = '#97a0b3',
        textMute   = '#6b7488',
        accent     = '#5b8def',  -- primary color (buttons, active tabs, highlights)
        accent2    = '#8b6cef',  -- gradient end color
        success    = '#36d399',
        danger     = '#ef4f6c',
        warn       = '#f5b440',
    },
}

-- ============================================================
-- Outfit component fields (rendered in the UI as inputs)
-- ============================================================
Config.OutfitFields = {
    'tshirt_1', 'tshirt_2',
    'torso_1',  'torso_2',
    'arms',
    'pants_1',  'pants_2',
    'shoes_1',  'shoes_2',
    'helmet_1', 'helmet_2',
    'mask_1',   'mask_2',
    'bproof_1', 'bproof_2',
    'chain_1',  'chain_2',
    'bags_1',   'bags_2',
    'decals_1', 'decals_2',
    'ears_1',   'ears_2',
    'hair_1',   'hair_2',
}
