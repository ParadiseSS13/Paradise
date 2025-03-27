/datum/buildmode_mode/boom
	key = "boom"

	// Range of Total Devastation
	var/devastation = -1
	// Ramge of Heavy Impact
	var/heavy = -1
	// Range of Light Impact
	var/light = -1
	// Range of Flash
	var/flash = -1
	// Range of Flames
	var/flames = -1

/datum/buildmode_mode/boom/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Mouse Button on obj  = Kaboom</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/boom/change_settings(mob/user)
	devastation = tgui_input_number(user, "Range of Total Devasation", "Devastation", -1, min_value = -1)
	heavy = tgui_input_number(user, "Range of Heavy Impact", "Heavy Impact", -1, min_value = -1)
	light = tgui_input_number(user, "Range of Light Impact", "Light Impact", -1, min_value = -1)
	flash = tgui_input_number(user, "Range of Flash", "Flash", -1, min_value = -1)
	flames = tgui_input_number(user, "Range of Flames", "Flames", -1, min_value = -1)

/datum/buildmode_mode/boom/handle_click(mob/user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")

	if(left_click)
		log_admin("Build Mode: [key_name(user)] created an explosion at ([object.x],[object.y],[object.z])")
		explosion(object, devastation, heavy, light, flash, null, TRUE, flames, cause = "[user.ckey]: Buildmode boom")
