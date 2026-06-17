# NXM Aduty

A modern admin-duty system for FiveM ESX servers. Ranks, outfits, logs and active player list — fully manageable through a UI without ever touching the code.

---

## 📋 Table of Contents

1. [Requirements](#requirements)
2. [Installation in 5 minutes](#installation-in-5-minutes)
3. [ACE Permissions setup](#ace-permissions-setup)
4. [Creating your first rank](#creating-your-first-rank)
5. [Configuration (config.lua)](#configuration-configlua)
6. [Theme & Branding](#theme--branding)
7. [Language / Localization](#language--localization)
8. [Commands](#commands)
9. [Feature details](#feature-details)
10. [Troubleshooting](#troubleshooting)
11. [FAQ](#faq)

---

## Requirements

**Required:**
- ESX Legacy (`es_extended`)
- `oxmysql`
- `skinchanger`
- MariaDB / MySQL database

**Optional (for notifications):**
- `sky_hud` — auto-detected if running, otherwise falls back to ESX default

---

## Installation in 5 minutes

### 1. Drop the resource in
- Copy the `NXM_Aduty` folder into your `resources/` directory.

### 2. Enable it in `server.cfg`
After ESX, oxmysql and skinchanger:
```cfg
ensure NXM_Aduty
```

### 3. Start the server
That's it for the database. The script auto-creates the tables `aduty_outfits`, `aduty_active`, `aduty_logs` on first start.

You should see in the server console:
```
[NXM_Aduty] DB-Schema OK.
[NXM_Aduty] 0 Outfit(s) loaded.
```

If not, see [Troubleshooting](#troubleshooting).

### 4. Set up ACE permissions
To open the UI you need at least the manage permission. **In `server.cfg`** (or `permissions.cfg`):

```cfg
# Define an ACE group for project lead
add_ace group.projectlead staff.aduty.projectlead allow
add_ace group.projectlead staff.aduty.manage      allow

# Assign your identifier to that group
add_principal identifier.license:YOUR_LICENSE_HERE group.projectlead
```

### 5. `restart NXM_Aduty` (or restart the server)

### 6. In-game
- Press `F8` (console) or `T` (chat)
- Type `/adutyui` → the UI should open.

---

## ACE Permissions setup

Each rank in NXM Aduty has a **`rank_key`** (e.g. `moderator`). From it the ACE permission is derived automatically:

```
staff.aduty.<rank_key>
```

### Example: 3 ranks

In `server.cfg`:
```cfg
# Groups
add_ace group.projectlead   staff.aduty.projectlead   allow
add_ace group.projectlead   staff.aduty.manage        allow   # <-- can manage UI

add_ace group.administrator staff.aduty.administrator allow
add_ace group.moderator     staff.aduty.moderator     allow

# Assign players to groups
add_principal identifier.license:abc123... group.projectlead
add_principal identifier.license:def456... group.administrator
add_principal identifier.discord:99887766  group.moderator
```

### Who can do what?

| Permission | What it does |
|---|---|
| `staff.aduty.<rank>` | Can use `/ad` and assume this specific rank |
| `staff.aduty.manage` | Can **open the UI**, edit/delete ranks, see logs, force-off players |
| `staff.aduty.projectlead` | Implicit manage permission (via `Config.ManagePermissions`) |

> **Important:** A player needs **at least one** `staff.aduty.<rank>` permission for `/ad` to work. If they have multiple, the one with the **highest priority** in the database is auto-selected.

---

## Creating your first rank

1. In-game, run `/adutyui`
2. Click **+ New Rank** (bottom left)
3. Fill in the fields:
   - **Rank-Key**: `moderator` (this is also the ACE permission suffix)
   - **Display Name**: `Moderator`
   - **Priority**: `30` (higher = more important rank)
4. **Settings** (checkboxes):
   - **God-Mode**: Invincible while in Aduty? (recommended: project leads only)
   - **Auto-Heal**: Full health when entering Aduty
   - **Auto-Armor**: Full armor when entering Aduty
   - **Blip-Color**: GTA blip color ID (see https://docs.fivem.net/docs/game-references/blips/#blip-colors)
   - **Blip-Icon**: GTA blip sprite ID (see https://docs.fivem.net/docs/game-references/blips/)
5. **♂ Male** tab: Set outfit values for male characters
   - Tip: Put on the outfit you want in-game, then click **📥 Import Current** — values are pulled automatically from your current skin
6. **♀ Female** tab: outfit for female characters
   - Tip: **↔ Mirror** copies values from the other gender
7. **🎬 3D Preview** shows the outfit on a rotatable character (LMB drag = rotate, mouse wheel = zoom, ESC = close)
8. **💾 Save**

Done. The player just needs the ACE permission `staff.aduty.moderator` and can now use `/ad`.

---

## Configuration (config.lua)

Full overview of all configurable values:

```lua
Config = {}

-- ===== Language =====
Config.Locale = 'en'   -- 'en' (default) or 'de' - add more under locales/

-- ===== Commands =====
Config.Command       = 'ad'          -- Toggle in/out of Aduty
Config.OpenUICommand = 'adutyui'     -- Open the management UI
Config.Commands = {
    list     = 'adlist',             -- Show active players
    log      = 'adlog',              -- Show logs
    forceOff = 'adoff',              -- Force a player out of Aduty
}

-- ===== Aduty Job =====
Config.AdutyJob   = 'team'           -- Job name assigned during Aduty
Config.AdutyGrade = 1                -- Grade assigned

-- ===== Timing =====
Config.ToggleCooldownMs   = 5000     -- 5 seconds between /ad toggles
Config.LogLimit           = 15       -- Default amount of logs in /adlog
Config.BlipSyncIntervalMs = 5000     -- How often blip positions are pushed

-- ===== 3D Preview Spot =====
-- Where the player is teleported to when testing an outfit in 3D
Config.Preview3D = {
    coords         = vector3(-1380.20, -470.69, 72.04),
    heading        = 347.86,
    cameraDistance = 2.2,
    minDistance    = 1.0,
    maxDistance    = 5.0,
    mouseSpeed     = 8.0,
}

-- ===== Who can open the management UI? =====
Config.ManagePermissions = {
    'staff.aduty.manager',
    'staff.aduty.projektleitung',
}

-- ===== Discord Webhook (optional, leave empty to disable) =====
Config.Webhook = ''                  -- e.g. 'https://discord.com/api/webhooks/...'
Config.BotName = 'Aduty System'
```

### Customizing the notification function

By default `sky_hud:notify` is used if available, otherwise `esx:showNotification` is the fallback. To switch to something else (e.g. `ox_lib`), edit in `config.lua`:

```lua
Config.Notify = function(title, message, ntype, duration)
    -- Example ox_lib:
    exports.ox_lib:notify({
        title       = title,
        description = message,
        type        = ntype,
        duration    = duration or 5000,
    })

    -- Or sky_hud (default):
    -- exports['sky_hud']:notify(title, message, ntype, duration)

    -- Or ESX default:
    -- TriggerEvent('esx:showNotification', ('[%s] %s'):format(title, message))
end
```

---

## Theme & Branding

In `config.lua` there's a `Config.UI` section. **Fully driven by config** — you never need to touch HTML/CSS.

```lua
Config.UI = {
    -- Branding (sidebar header)
    brandName     = 'Aduty',           -- Main title
    brandSubtitle = 'Admin Panel',     -- Small subtitle below

    -- Logo (3-4 character text OR image URL)
    logoText  = 'NXM',                 -- Used when logoImage = nil
    logoImage = nil,                    -- e.g. 'https://i.imgur.com/your-logo.png'

    -- Colors (hex codes)
    theme = {
        -- Backgrounds (dark to darkest)
        bg0     = '#0b0d12',
        bg1     = '#12151c',
        bg2     = '#1a1f29',
        bg3     = '#232a37',
        border  = '#2a3140',

        -- Text shades
        text     = '#e6e9ef',          -- Main text
        textDim  = '#97a0b3',          -- Labels
        textMute = '#6b7488',          -- Smallprint

        -- Accent colors (buttons, tabs, highlights)
        accent   = '#5b8def',          -- Primary
        accent2  = '#8b6cef',          -- Gradient end (buttons go accent → accent2)

        -- Status colors
        success  = '#36d399',          -- Green
        danger   = '#ef4f6c',          -- Red (delete, errors)
        warn     = '#f5b440',          -- Yellow (warning)
    },
}
```

### Example: Red theme

```lua
Config.UI = {
    brandName     = 'My Server',
    brandSubtitle = 'Staff Tools',
    logoText      = 'MS',
    theme = {
        accent  = '#dc2626',  -- Red
        accent2 = '#f97316',  -- Orange
        bg0     = '#1a0a0a',  -- Dark red-black
        bg1     = '#221010',
        bg2     = '#2a1818',
        bg3     = '#3a2020',
        border  = '#4a2828',
    },
}
```

After changing: `restart NXM_Aduty` in-game or restart the server — theme applies on the next UI open.

---

## Language / Localization

The whole script (UI, notifications, chat output, Discord embeds) is fully translatable.

### Switching language

In `config.lua`:
```lua
Config.Locale = 'en'   -- or 'de'
```

Out of the box: `en` and `de`.

### Adding a new language

1. Copy `locales/en.lua` → `locales/fr.lua` (or whatever code you want).
2. Translate the values (keep the keys identical).
3. Add the file to `fxmanifest.lua`:
   ```lua
   shared_scripts {
       'locales/en.lua',
       'locales/de.lua',
       'locales/fr.lua',   -- <-- here
       'config.lua',
   }
   ```
4. Set `Config.Locale = 'fr'` in `config.lua`.
5. Restart the resource.

Missing keys automatically fall back to English, so you can ship a partially translated file without breaking anything.

---

## Commands

| Command | Who? | What? |
|---|---|---|
| `/ad` | Player with any Aduty permission | Toggle in/out of Aduty |
| `/adutyui` | Manager | Opens UI on the "Ranks" tab |
| `/adlist` | Manager **or** Aduty player | Opens UI on the "Active Players" tab |
| `/adlog [id]` | Manager | Opens UI on the "Logs" tab. `[id]` is optional → pre-filtered for that player |
| `/adoff <id>` | Manager | Forces the player with server-id `<id>` out of Aduty |

**Console commands (RCON / server console):**
- `adlist` → text output of all active players
- `adlog` → text output of the latest logs
- `adoff <id>` → force-off from the console

---

## Feature details

### Rejoin persistence

When a player **in Aduty** leaves the server:
- Their original job is stored in `aduty_active`
- On next join the original job is automatically restored
- They see a notification: "Your job [job] (grade [grade]) was restored"

### Map blips

Players in Aduty appear as blips on the map — but **only for other players with an Aduty permission**. Regular players don't see them.

- If the Aduty player is in your stream range: entity-blip with live player name
- If they're further away: coord-blip with `[Aduty] Name (Rank)` as the hover label
- Blip color and icon are configurable per rank in the database

### God-Mode / Auto-Heal / Auto-Armor

Per-rank settings in the database:
- **God-Mode**: Invincible during Aduty (500ms loop with `SetEntityInvincible`)
- **Auto-Heal**: Full health when entering Aduty
- **Auto-Armor**: Full armor (100) when entering Aduty

### Force-Off

`/adoff <id>` or clicking "⏏ Force-Off" in the active list:
- Player is immediately kicked out of Aduty
- Their original job is restored
- Their skin is reverted
- Notification on the target: "You were forced out of Aduty by [Admin]"
- A log entry with `actor` is recorded

### Logs

Every action is logged into `aduty_logs`:
- `enter` — entered Aduty
- `leave` — left Aduty
- `force_off` — removed via force-off
- `outfit_save` — outfit was saved in the DB
- `outfit_delete` — outfit was deleted
- `restore` — job was restored after rejoin

In the UI on the Logs tab you can filter by name, ID, action or rank.

### Discord webhook

If `Config.Webhook` is set: every Aduty enter/exit is sent as an embed to your Discord channel containing player name, Steam, Discord tag, license, old/new job.

---

## Troubleshooting

### "Resource doesn't start / no /ad"

1. Open the **server console**
2. Run `restart NXM_Aduty`
3. Watch for any error output

Common errors:
- `[ERROR] script:NXM_Aduty: SCRIPT ERROR: ...` → send me the line, usually a Lua error
- `no resource named 'oxmysql'` → oxmysql isn't installed or starts later
- `Couldn't find resource es_extended` → ESX isn't running

### "UI doesn't open / /adutyui does nothing"

- Do you have the `staff.aduty.manage` or `staff.aduty.projektleitung` ACE permission?
- Check: `ace_aces` in the server console lists all ACEs
- Check: `principals` lists all assignments
- Press F8 — any red errors there?

### "/adlist and /adlog show nothing"

- Server console: do you see `[NXM_Aduty] cmdList src=...` when you run the command?
  - **Yes** → command is received but output isn't reaching you — send me the server console output
  - **No** → command never reaches the script. Maybe another resource is owning the same name. Change `Config.Commands.list = 'adlist'` to `'myadlist'` in `config.lua` and retest

### "Database errors"

Tables are created automatically. If that fails:
1. DB user needs **CREATE** and **ALTER** privileges
2. Manually run `install.sql` in the database
3. On next start check that `[NXM_Aduty] DB-Schema OK.` appears

### "Blips are weird blue rectangles"

This was an old bug — happens when DB values are `blip_sprite = 0` (instead of 1). Auto-fixed by the migration script. If you ever hit it manually:
```sql
UPDATE aduty_outfits SET blip_sprite = 1 WHERE blip_sprite <= 0;
UPDATE aduty_outfits SET blip_color  = 3 WHERE blip_color  <= 0;
```

### "Import current outfit does nothing"

- Check that `skinchanger` is running (`ensure skinchanger`)
- Check the F8 console for errors when clicking

---

## FAQ

**Q: Do I need to run `install.sql` manually?**
A: No. The script creates all required tables + migrations on first start. `install.sql` is only included as a reference.

**Q: Can I insert outfits directly via SQL?**
A: Yes, but the UI is way easier. If you must: `INSERT INTO aduty_outfits (rank_key, label, priority, male_data, female_data) VALUES (...)`. `male_data` / `female_data` are JSON.

**Q: Will a player lose their items in Aduty?**
A: No. Only their job is switched to `Config.AdutyJob` — inventory stays untouched.

**Q: What happens if I delete a rank someone is currently using?**
A: They stay in Aduty (on job `team`), but as soon as they run `/ad`, they fall back to their original job. Force-off also works.

**Q: Can I change the Aduty job (not 'team')?**
A: Yes — `config.lua` → `Config.AdutyJob = 'admin'` etc. The job must exist in the ESX jobs table though.

**Q: How many ranks can I create?**
A: Unlimited. Performance isn't an issue (everything is cached).

**Q: Does it work with QBCore?**
A: No, the script is explicitly built for ESX Legacy. A QBCore port would need adjustments (`xPlayer.setJob`, `skinchanger`, etc.).

**Q: What about `escrow_ignore`?**
A: `config.lua`, `install.sql`, `README.md`, and `locales/*.lua` remain **readable/editable** after cfx.re encryption. The Lua logic and UI are protected.

---

## License / Support

Private server use. Reselling forbidden.
For bugs / questions: NXM Solutions Discord.

Made with ❤ by **NXM Solutions**.
