# NXM_Aduty Implementation Notes

## File Placement

Place the generated files in your NXM_Aduty resource folder as follows:

```
NXM_Aduty/
├── client/
│   └── main.lua          ← client_main.lua
├── server/
│   └── main.lua          ← server_main.lua
├── html/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── locales/
│   ├── en.lua
│   └── de.lua
├── config.lua
├── fxmanifest.lua
└── install.sql (reference only)
```

## Critical Setup Steps

### 1. Ensure Dependencies Are Running

The script requires these to be started **before** NXM_Aduty in your server.cfg:

```cfg
ensure es_extended
ensure oxmysql
ensure skinchanger
ensure NXM_Aduty
```

If dependencies load **after** NXM_Aduty, the script will fail to initialize properly.

### 2. Database Initialization

The script automatically creates all required tables on first start:
- `aduty_outfits` — rank definitions and outfit data
- `aduty_active` — currently active Aduty players (for rejoin persistence)
- `aduty_logs` — audit trail of all Aduty actions

If the database user lacks CREATE/ALTER privileges, manually run `install.sql` from the provided documentation.

### 3. ACE Permissions Setup

Players need **at least one** ACE permission to use Aduty. In `server.cfg` or `permissions.cfg`:

```cfg
add_ace group.projectlead   staff.aduty.projectlead   allow
add_ace group.projectlead   staff.aduty.manage        allow
add_ace group.moderator     staff.aduty.moderator     allow

add_principal identifier.license:YOUR_LICENSE_HERE group.projectlead
add_principal identifier.license:ANOTHER_LICENSE   group.moderator
```

The `staff.aduty.manage` permission is required to open the UI and manage ranks. The `staff.aduty.<rank_key>` permission is required for players to toggle into that specific rank.

### 4. Skinchanger Compatibility

The script calls `TriggerEvent('skinchanger:loadClothes')` and `TriggerEvent('skinchanger:getSkin')` directly. Ensure `skinchanger` is properly installed and that skins are stored in the same format the resource expects.

## Script Behavior

### Aduty Toggle (/ad)

When a player runs `/ad`:
- If **not in Aduty**: switches their job to `Config.AdutyJob` (default: 'team'), applies outfit, stores original job/grade, creates blip, logs action, sends Discord webhook
- If **in Aduty**: restores original job/grade, removes blip, logs action, sends Discord webhook

A 5-second cooldown applies between toggles (server-side validation).

### Rank Priority Selection

When a player has multiple Aduty rank permissions, the script automatically selects the rank with the **highest priority** value from the database.

### God-Mode Loop

If god-mode is enabled for a rank, the client runs a 500ms loop that calls `SetEntityInvincible(ped, true)` while the player is in Aduty.

### Blip Sync

The server pushes blip position updates every `Config.BlipSyncIntervalMs` milliseconds (default: 5000ms) to all clients. Blips only appear to players who have at least one Aduty rank permission.

### Rejoin Persistence

When an Aduty player leaves and rejoins, the script detects the previous Aduty session, restores their original job/grade automatically, and logs the restoration event.

### 3D Preview

The 3D preview system:
1. Teleports the player's actual entity off-screen (made invisible)
2. Creates a temporary NPC at `Config.Preview3D.coords`
3. Sets up a camera with mouse-draggable rotation (LMB) and scroll zoom
4. Applies outfit changes in real-time to the preview NPC
5. Cleans up on exit

## Known Limitations

- The script does not validate outfit component values (assumes UI/developer provides valid GTA skin component IDs)
- Discord webhooks are fire-and-forget; failures are silent
- Blip updates use a simple interval; very large numbers of Aduty players (50+) may create noticeable network traffic
- The script does not support multiple genders per rank (male/female are stored separately but only one is applied based on character sex at toggle time)

## Troubleshooting

### "Resource doesn't start"

Check server console for errors. Common causes:
- `es_extended` not running
- `oxmysql` not running or not configured properly
- Lua syntax error in client/main.lua or server/main.lua

### "/ad command does nothing"

- Player lacks `staff.aduty.<rank_key>` permission
- No ranks exist in the database (create one via `/adutyui`)

### "UI doesn't open"

- Player lacks `staff.aduty.manage` permission
- Check F8 console for NUI errors
- Ensure HTML/CSS/JS files are present in the `html/` folder

### "Outfit not applying"

- `skinchanger` is not running or not properly integrated
- Outfit components are invalid (non-existent body part IDs)
- Check server console for errors during outfit application

### "Blips show as blue rectangles"

This is a legacy bug. If it occurs, manually fix the database:

```sql
UPDATE aduty_outfits SET blip_sprite = 1 WHERE blip_sprite <= 0;
UPDATE aduty_outfits SET blip_color = 3 WHERE blip_color <= 0;
```

## Configuration Notes

- `Config.AdutyJob` must be a valid job name in your ESX jobs table
- `Config.Locale` supports 'en' and 'de' by default; other locales require adding the file to fxmanifest.lua
- `Config.Preview3D.coords` should be a safe, indoor location away from players
- `Config.Webhook` (Discord) is optional; leave blank to disable logging

## File Sizes

- `client/main.lua` — ~6KB
- `server/main.lua` — ~11KB

Both files are complete and ready to use with no modifications required beyond standard config.lua setup.
