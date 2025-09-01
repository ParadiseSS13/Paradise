/datum/buildmode_mode/smoke
	key = "smoke"
	var/smoke_type = SMOKE_HARMLESS
	var/smoke_amt = 10

/datum/buildmode_mode/smoke/show_help(mob/user)
	var/list/messages = list(
		"<span class='notice'>Left Click = Smoke 'em!</span>",
		"<span class='notice'>Right Click on Tool Icon = Change Effect Type</span>",
	)
	to_chat(user, chat_box_notice(messages.Join("<br>")))

/datum/buildmode_mode/smoke/change_settings(mob/user)
	var/smoke_types = list(
		"SMOKE_HARMLESS" = SMOKE_HARMLESS,
		"SMOKE_COUGHING" = SMOKE_COUGHING,
		"SMOKE_SLEEPING" = SMOKE_SLEEPING
	)

	var/new_smonk = tgui_input_list(user, "Pick a smoke type:", "Buildmode Smoke", smoke_types)
	if(new_smonk in smoke_types)
		smoke_type = smoke_types[new_smonk]

	var/new_smonk_amt = tgui_input_number(user, "Smoke Amount:", "Buildmode Smoke", smoke_amt, 20, 1)
	if(new_smonk_amt)
		smoke_amt = new_smonk_amt


/datum/buildmode_mode/smoke/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")

	if(left_click)
		var/datum/effect_system/smoke_spread/smoke
		switch(smoke_type)
			if(SMOKE_HARMLESS)
				smoke = new /datum/effect_system/smoke_spread()
			if(SMOKE_COUGHING)
				smoke = new /datum/effect_system/smoke_spread/bad()
			if(SMOKE_SLEEPING)
				smoke = new /datum/effect_system/smoke_spread/sleeping()
		smoke.set_up(smoke_amt, FALSE, object)
		playsound(get_turf(object), 'sound/effects/smoke.ogg', 50, TRUE, -3)
		smoke.start()
