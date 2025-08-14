/datum/preferences/proc/load_preferences(datum/db_query/query)
	// Looking for the query?
	// Check ../login_processing/10-load_preferences.dm

	//general preferences
	var/raw_muted_admins
	var/raw_fptp
	while(query.NextRow())
		ooccolor = query.item[1]
		UI_style = query.item[2]
		UI_style_color = query.item[3]
		UI_style_alpha = text2num(query.item[4])
		be_special = params2list(query.item[5])
		default_slot = text2num(query.item[6])
		toggles = text2num(query.item[7])
		toggles2 = text2num(query.item[8])
		sound = text2num(query.item[9])
		light = text2num(query.item[10])
		glowlevel = query.item[11]
		volume_mixer = deserialize_volume_mixer(query.item[12])
		lastchangelog = query.item[13]
		exp = query.item[14]
		clientfps = text2num(query.item[15])
		atklog = text2num(query.item[16])
		fuid = text2num(query.item[17])
		parallax = text2num(query.item[18])
		_2fa_status = query.item[19]
		screentip_mode = query.item[20]
		screentip_color = query.item[21]
		ghost_darkness_level = query.item[22]
		colourblind_mode = query.item[23]
		keybindings = init_keybindings(raw = query.item[24])
		server_region = query.item[25]
		raw_muted_admins = query.item[26]
		viewrange = query.item[27]
		raw_fptp = query.item[28]
		toggles3 = text2num(query.item[29])

	lastchangelog_2 = lastchangelog // Clone please

	//Sanitize
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	UI_style		= sanitize_inlist(UI_style, list("White", "Midnight", "Plasmafire", "Retro", "Slimecore", "Operative", "Clockwork"), initial(UI_style))
	default_slot	= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, TOGGLES_TOTAL, initial(toggles))
	toggles2		= sanitize_integer(toggles2, 0, TOGGLES_2_TOTAL, initial(toggles2))
	toggles3		= sanitize_integer(toggles3, 0, TOGGLES_3_TOTAL, initial(toggles3))
	sound			= sanitize_integer(sound, 0, 65535, initial(sound))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	exp	= sanitize_text(exp, initial(exp))
	clientfps = sanitize_integer(clientfps, 0, 1000, initial(clientfps))
	atklog = sanitize_integer(atklog, 0, 100, initial(atklog))
	fuid = sanitize_integer(fuid, 0, 10000000, initial(fuid))
	parallax = sanitize_integer(parallax, 0, 16, initial(parallax))
	screentip_mode = sanitize_integer(screentip_mode, 0, 20, initial(screentip_mode))
	screentip_color = sanitize_hexcolor(screentip_color, initial(screentip_color))
	ghost_darkness_level = sanitize_integer(ghost_darkness_level, 0, 255, initial(ghost_darkness_level))
	colourblind_mode = sanitize_inlist(colourblind_mode, list(COLOURBLIND_MODE_NONE, COLOURBLIND_MODE_DEUTER, COLOURBLIND_MODE_PROT, COLOURBLIND_MODE_TRIT), COLOURBLIND_MODE_NONE)

	if(length(raw_muted_admins))
		try
			admin_sound_ckey_ignore = json_decode(raw_muted_admins)
		catch
			admin_sound_ckey_ignore = list() // Invalid JSON, handle safely please
	if(length(raw_fptp))
		try
			map_vote_pref_json = json_decode(raw_fptp)
		catch
			map_vote_pref_json = list()
	// Sanitize the region
	if(!(server_region in GLOB.configuration.system.region_map))
		server_region = null // This region doesnt exist anymore

	return TRUE

/datum/preferences/proc/save_preferences(client/C)
	// Might as well scrub out any malformed be_special list entries while we're here
	for(var/role in be_special)
		if(!(role in GLOB.special_roles))
			stack_trace("[C.key] had a malformed role entry: '[role]'. Removing!")
			be_special -= role

	// We're saving volume_mixer here as well, so no point in keeping the timer running
	if(volume_mixer_saving)
		deltimer(volume_mixer_saving)
		volume_mixer_saving = null

	var/datum/db_query/query = SSdbcore.NewQuery({"UPDATE player SET
		ooccolor=:ooccolour,
		UI_style=:ui_style,
		UI_style_color=:ui_colour,
		UI_style_alpha=:ui_alpha,
		be_role=:berole,
		default_slot=:defaultslot,
		toggles=:toggles,
		toggles_2=:toggles2,
		toggles_3=:toggles3,
		atklog=:atklog,
		sound=:sound,
		light=:light,
		glowlevel=:glowlevel,
		volume_mixer=:volume_mixer,
		lastchangelog=:lastchangelog,
		clientfps=:clientfps,
		parallax=:parallax,
		2fa_status=:_2fa_status,
		screentip_mode=:screentip_mode,
		screentip_color=:screentip_color,
		ghost_darkness_level=:ghost_darkness_level,
		colourblind_mode=:colourblind_mode,
		keybindings=:keybindings,
		server_region=:server_region,
		muted_adminsounds_ckeys=:muted_adminsounds_ckeys,
		viewrange=:viewrange,
		map_vote_pref_json=:map_vote_pref_json
		WHERE ckey=:ckey"}, list(
			// OH GOD THE PARAMETERS
			"ooccolour" = ooccolor,
			"ui_style" = UI_style,
			"ui_colour" = UI_style_color,
			"ui_alpha" = UI_style_alpha,
			"berole" = list2params(be_special),
			"defaultslot" = default_slot,
			// Even though its a number in the DB, you have to use num2text here, otherwise byond adds scientific notation to the number
			"toggles" = num2text(toggles, CEILING(log(10, (TOGGLES_TOTAL)), 1)),
			"toggles2" = num2text(toggles2, CEILING(log(10, (TOGGLES_2_TOTAL)), 1)),
			"toggles3" = num2text(toggles3, CEILING(log(10, (TOGGLES_3_TOTAL)), 1)),
			"atklog" = atklog,
			"sound" = sound,
			"light" = light,
			"glowlevel" = glowlevel,
			"volume_mixer" = serialize_volume_mixer(volume_mixer),
			"lastchangelog" = lastchangelog,
			"clientfps" = clientfps,
			"parallax" = parallax,
			"_2fa_status" = _2fa_status,
			"screentip_mode" = screentip_mode,
			"screentip_color" = screentip_color,
			"ghost_darkness_level" = ghost_darkness_level,
			"colourblind_mode" = colourblind_mode,
			"keybindings" = json_encode(keybindings_overrides),
			"ckey" = C.ckey,
			"server_region" = server_region,
			"muted_adminsounds_ckeys" = json_encode(admin_sound_ckey_ignore),
			"viewrange" = viewrange,
			"map_vote_pref_json" = json_encode(map_vote_pref_json)
		))

	if(!query.warn_execute())
		qdel(query)
		return

	qdel(query)
	return TRUE

/datum/preferences/proc/load_random_character_slot(client/C)
	var/list/datum/character_save/valid_slots = list()
	for(var/datum/character_save/CS in character_saves)
		if(CS.valid_save)
			valid_slots += CS

	if(!length(valid_slots))
		// They have no valid saves. Lets just randomise #1
		var/datum/character_save/CS = C.prefs.character_saves[1] // Get slot 1
		CS.randomise()
		CS.real_name = random_name(CS.gender) // Pick a name
		C.prefs.active_character = C.prefs.character_saves[1] // Set slot 1 as their active
		return

	var/datum/character_save/CS = pick(valid_slots)
	C.prefs.active_character = CS

/**
  * Saves [/datum/preferences/proc/volume_mixer] for the current client.
  */
/datum/preferences/proc/save_volume_mixer()
	volume_mixer_saving = null

	var/datum/db_query/update_query = SSdbcore.NewQuery(
		"UPDATE player SET volume_mixer=:volume_mixer WHERE ckey=:ckey",
		list(
			"volume_mixer" = serialize_volume_mixer(volume_mixer),
			"ckey" = parent.ckey
		)
	)

	if(!update_query.warn_execute())
		qdel(update_query)
		return FALSE

	qdel(update_query)
	return TRUE
