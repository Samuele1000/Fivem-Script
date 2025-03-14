fx_version 'cerulean'
game 'gta5'

author 'Simaatje69'
description 'Taxi Job Script with NPC and Player Transport'
version '1.0.0'

-- Shared scripts
shared_scripts {
    'config.lua',
}

-- Client-side scripts
client_scripts {
    'client/main.lua',
    'client/npc_manager.lua',
    'client/player_transport.lua',
    'client/utils.lua'
}

-- Server-side scripts
server_scripts {
    'server/main.lua',
    'server/player_transport.lua'
}

-- UI
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png'
}