// ///Checks that all achievements have an existing icon state in the achievements icon file.
// /datum/game_test/achievements

// /datum/game_test/achievements/Run()
// 	for(var/datum/award/award as anything in subtypesof(/datum/award))
// 		if(!initial(award.name)) //Skip abstract achievements types
// 			continue
// 		var/init_icon = initial(award.icon)
// 		var/init_icon_state = initial(award.icon_state)
// 		if(!init_icon_state || !icon_exists(init_icon, init_icon_state))
// 			log_debug("Award [initial(award.name)] has a non-existent icon in [init_icon]: \"[init_icon_state || "null"]\"")

// 		if(length(initial(award.database_id)) > 32) //sql schema limit
// 			log_debug("Award [initial(award.name)] database id is too long")

// 		var/init_category = initial(award.category)
// 		if(!(init_category in GLOB.achievement_categories))
// 			log_debug("Award [initial(award.name)] has unsupported category: \"[init_category || "null"]\". Update GLOB.achievement_categories")

// 	for(var/sound_pref in GLOB.achievement_sounds)
// 		if(length(sound_pref) > 50)
// 			log_debug("Possible sound pref [sound_pref] is too long")
