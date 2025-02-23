/datum/buildmode_mode/boom
	key = "boom"

	// Range of Total Devastation
	var/devastation
	// Ramge of Heavy Impact
	var/heavy
	// Range of Light Impact
	var/light
	// Range of Flash
	var/flash
	// Range of Flames
	var/flames

/datum/buildmode_mode/boom/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Mouse Button on obj  = Kaboom</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/boom/change_settings(mob/user)
	devastation = tgui_input_number(user, "Range of Total Devasation", "Devastation", 0)
	heavy = tgui_input_number(user, "Range of Heavy Impact", "Heavy Impact", 0)
	light = tgui_input_number(user, "Range of Light Impact", "Light Impact", 0)
	flash = tgui_input_number(user, "Range of Flash", "Flash", 0)
	flames = tgui_input_number(user, "Range of Flames", "Flames", 0)

/datum/buildmode_mode/boom/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")

	if(left_click)
		log_admin("Build Mode: [key_name(user)] created an explosion at ([object.x],[object.y],[object.z])")
		explosion(object, devastation, heavy, light, flash, null, TRUE, flames)
