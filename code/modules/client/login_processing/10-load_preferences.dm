/datum/client_login_processor/load_preferences
	priority = 10

/datum/client_login_processor/load_preferences/get_query(client/C)
	var/datum/db_query/query = SSdbcore.NewQuery({"SELECT
		ooccolor,
		UI_style,
		UI_style_color,
		UI_style_alpha,
		be_role,
		default_slot,
		toggles,
		toggles_2,
		sound,
		volume_mixer,
		lastchangelog,
		exp,
		clientfps,
		atklog,
		fuid,
		parallax,
		2fa_status,
		screentip_mode,
		screentip_color,
		ghost_darkness_level
		FROM player
		WHERE ckey=:ckey"}, list(
			"ckey" = C.ckey
		))

	return query

/datum/client_login_processor/load_preferences/process_result(datum/db_query/Q, client/C)
	C.prefs = new /datum/preferences(C, Q)
