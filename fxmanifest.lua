fx_version 'cerulean'
game 'gta5'

author 'NXM Solutions'
description 'NXM Aduty - Modern UI Edition'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'locales/en.lua',
    'locales/de.lua',
    -- add more locale files here: 'locales/fr.lua', 'locales/es.lua', etc.
    'config.lua',
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'es_extended',
    'skinchanger',
    'oxmysql'
}

escrow_ignore {
    'config.lua',
    'install.sql',
    'README.md',
    'locales/*.lua',
}

dependency '/assetpacks'