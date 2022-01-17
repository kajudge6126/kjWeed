fx_version 'bodacious'
game 'gta5'
author 'kj6126'

server_scripts {
    'config.lua',
    'server/main.lua'
}

client_scripts {
    'config.lua',
    '@PolyZone/client.lua',
    'client/main.lua',
}

dependencies { 'PolyZone' }