--- @diagnostic disable

fx_version "cerulean"
game "gta5"
lua54 "yes"

author "MateHUN"
description "Logger library for FiveM"

server_scripts {
    "server/main.lua",
    "server/commands.lua",
}

shared_scripts {
    "@ox_lib/init.lua",
    "shared/helper.lua",
    "shared/logger.lua",
}

files {
     "init.lua",
}
