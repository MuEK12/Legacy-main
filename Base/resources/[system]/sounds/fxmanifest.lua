fx_version "bodacious"
game "gta5"
lua54 "yes"

ui_page "web-side/index.html"

client_scripts {
	"client-side/exports/info.lua",
	"client-side/exports/play.lua",
	"client-side/exports/manipulation.lua",
	"client-side/effects/main.lua",
	"client-side/main.lua",
	"client-side/events.lua"
}

server_scripts {
	"server-side/hensa.lua",
	"server-side/exports/play.lua",
	"server-side/exports/manipulation.lua"
}

shared_scripts {
	"shared-side/config.lua"
}

files {
	"web-side/index.html",
	"web-side/scripts/listener.js",
	"web-side/scripts/SoundPlayer.js",
	"web-side/scripts/functions.js",
	"web-side/sounds/*.mp3"
}
