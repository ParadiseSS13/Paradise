/// Join MOTD for the server
GLOBAL_VAR(join_motd)
GLOBAL_PROTECT(join_motd) // Takes up a lot of space in VV
/// Join TOS for the server
GLOBAL_VAR(join_tos)
GLOBAL_PROTECT(join_tos) // Takes up a lot of space. Also dont touch this shit

/// The current game year
GLOBAL_VAR_INIT(game_year, (text2num(time2text(world.realtime, "YYYY")) + 544))

/// Allow new players to enter the game?
GLOBAL_VAR_INIT(enter_allowed, TRUE)

/// Is OOC currently enabled?
GLOBAL_VAR_INIT(ooc_enabled, TRUE)

/// Is LOOC currently enabled?
GLOBAL_VAR_INIT(looc_enabled, TRUE)

/// Is OOC currently enabled for dead people?
GLOBAL_VAR_INIT(dooc_enabled, TRUE)

/// Is deadchat currently enabled?
GLOBAL_VAR_INIT(dsay_enabled, TRUE)

/// Enable debugging of things such as job starts and other things
GLOBAL_VAR_INIT(debug2, TRUE)
