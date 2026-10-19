fx_version ('cerulean')
game ('gta5')

author ('ONE SOLUTIONS')
description ('LSPD')
version ('1.1')

escrow_ignore {
    'stream/editable/**'
}

lua54 ('yes')

this_is_a_map ('yes')

files {
    'audio/firestairs_occl_lspd_oh.dat151.rel',
    'audio/fourth_floor_lspdoccl.dat151.rel',
    'audio/lspd_doors01_game.dat151.rel',
    'audio/lspdept_occl_firstsec.dat151.rel',
    'audio/occlu_ohmy_jail_lsdept.dat151.rel',
    'audio/occlusion_lspd_floor_third.dat151.rel',
    'audio/parkingpolice_ohmy.dat151.rel',
    'data/gtxd.meta'
}

data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'
data_file 'AUDIO_GAMEDATA' 'audio/firestairs_occl_lspd_oh.dat'
data_file 'AUDIO_GAMEDATA' 'audio/fourth_floor_lspdoccl.dat'
data_file 'AUDIO_GAMEDATA' 'audio/lspd_doors01_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/lspdept_occl_firstsec.dat'
data_file 'AUDIO_GAMEDATA' 'audio/occlu_ohmy_jail_lsdept.dat'
data_file 'AUDIO_GAMEDATA' 'audio/occlusion_lspd_floor_third.dat'
data_file 'AUDIO_GAMEDATA' 'audio/parkingpolice_ohmy.dat'
data_file 'GTXD_PARENTING_DATA' 'data/gtxd.meta'
dependency '/assetpacks'