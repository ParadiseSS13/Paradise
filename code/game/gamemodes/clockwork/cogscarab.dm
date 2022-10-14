// Little Coggy Droney!
/mob/living/silicon/robot/cogscarab
	name = "cogscarab"
	desc = "A strange, drone-like machine. It constantly emits the hum of gears."
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "drone"
	health = 50
	maxHealth = 50
	speed = 0
	density = 0
	ventcrawler = 2
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE

	speak_emote = list("clanks", "clinks", "clunks", "clangs")
	speak_statement = "clinks"
	speak_exclamation = "proclaims"
	speak_query = "requests"
	bubble_icon = "clock"
	braintype = "Clockwork"

	lawupdate = FALSE
	scrambledcodes = TRUE
	has_camera = FALSE
	viewalerts = FALSE
	modules_break = FALSE

	req_one_access = list(ACCESS_CENT_COMMANDER) //I dare you to try
	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD)

	pull_force = MOVE_FORCE_VERY_WEAK // Can only drag small items
	holder_type = /obj/item/holder/cogscarab
	lamp_max = 5

	var/static/list/allowed_bumpable_objects = list(/obj/machinery/door, /obj/machinery/disposal/deliveryChute, /obj/machinery/teleport/hub, /obj/effect/portal, /obj/structure/transit_tube/station)

	var/list/pullable_items = list(
		/obj/item/pipe,
		/obj/structure/disposalconstruct,
		/obj/item/stack/cable_coil,
		/obj/item/stack/rods,
		/obj/item/stack/sheet,
		/obj/item/stack/tile,
		/obj/item/clockwork
	)


/mob/living/silicon/robot/cogscarab/Initialize()
	. = ..()
	remove_language("Robot Talk")
	add_language("Drone Talk", 1)
	if(radio)
		radio.wires.cut(WIRE_RADIO_TRANSMIT)

	//Shhhh it's a secret. No one needs to know about infinite power for clockwork drone
	cell = new /obj/item/stock_parts/cell/high/slime(src)
	mmi = null
	verbs -= /mob/living/silicon/robot/verb/Namepick
	module = new /obj/item/robot_module/cogscarab(src)

	if(!isclocker(src))
		SSticker.mode.add_clocker(mind)

	update_icons()

/mob/living/silicon/robot/cogscarab/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/ratvar()
	connected_ai = null

	aiCamera = new/obj/item/camera/siliconcam/drone_camera(src)
	additional_law_channels["Drone"] = ":d "

	playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)

/mob/living/silicon/robot/cogscarab/rename_character(oldname, newname)
	// force it to not actually change most things
	return ..(newname, newname)

/mob/living/silicon/robot/cogscarab/get_default_name()
	return "cogscarab [pick(list("Nycun", "Oenib", "Havsbez", "Ubgry", "Fvreen"))]-[rand(10, 99)]"

/mob/living/silicon/robot/cogscarab/update_icons()
	overlays.Cut()
	if(stat == CONSCIOUS)
		overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"

/mob/living/silicon/robot/cogscarab/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/borg/upgrade))
		return

	return ..()

/mob/living/silicon/robot/cogscarab/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return

/mob/living/silicon/robot/cogscarab/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
		return TRUE
	return ..()

/mob/living/silicon/robot/cogscarab/choose_icon()
	return

/mob/living/silicon/robot/cogscarab/pick_module()
	return

/mob/living/silicon/robot/cogscarab/emag_act()
	return

/mob/living/silicon/robot/cogscarab/emp_act(severity)
	return

/mob/living/silicon/robot/cogscarab/ratvar_act(weak)
	if(!isclocker(src))
		SSticker.mode.add_clocker(mind)
	return

/mob/living/silicon/robot/cogscarab/allowed(obj/item/I) //No opening cover
	return FALSE

/mob/living/silicon/robot/cogscarab/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = 50
		stat = CONSCIOUS
		return
	health = 50 - (getBruteLoss() + getFireLoss())
	update_stat("updatehealth([reason])")

/mob/living/silicon/robot/cogscarab/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	if(health <= -maxHealth && stat != DEAD)
		gib()
		log_debug("died of damage, trigger reason: [reason]")
		return
	return ..(reason)


/mob/living/silicon/robot/cogscarab/death(gibbed)
	. = ..(gibbed)
	SSticker.mode.remove_clocker(mind, FALSE)
	adjustBruteLoss(health)

/mob/living/silicon/robot/cogscarab/Bump(atom/movable/AM, yes)
	if(is_type_in_list(AM, allowed_bumpable_objects))
		return ..()

/mob/living/silicon/robot/cogscarab/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)

	if(is_type_in_list(AM, pullable_items))
		..(AM, force = INFINITY) // Drone power! Makes them able to drag pipes and such

	else if(istype(AM,/obj/item))
		var/obj/item/O = AM
		if(O.w_class > WEIGHT_CLASS_SMALL)
			if(show_message)
				to_chat(src, "<span class='warning'>You are too small to pull that.</span>")
			return
		else
			..()
	else
		if(show_message)
			to_chat(src, "<span class='warning'>You are too small to pull that.</span>")

/mob/living/silicon/robot/cogscarab/add_robot_verbs()
	src.verbs |= silicon_subsystems

/mob/living/silicon/robot/cogscarab/remove_robot_verbs()
	src.verbs -= silicon_subsystems

/mob/living/silicon/robot/cogscarab/toggle_sensor_mode()
	var/sensor_type = input("Please select sensor type.", "Sensor Integration", null) in list("Medical","Diagnostic", "Multisensor","Disable")
	remove_med_sec_hud()
	switch(sensor_type)
		if("Medical")
			add_med_hud()
			to_chat(src, "<span class='notice'>Life signs monitor overlay enabled.</span>")
		if("Diagnostic")
			add_diag_hud()
			to_chat(src, "<span class='notice'>Robotics diagnostic overlay enabled.</span>")
		if("Multisensor")
			add_med_hud()
			add_diag_hud()
			to_chat(src, "<span class='notice'>Multisensor overlay enabled.</span>")
		if("Disable")
			to_chat(src, "Sensor augmentations disabled.")


/mob/living/silicon/robot/cogscarab/get_access()
	return list() //none cause from gears.

/mob/living/silicon/robot/cogscarab/flash_eyes(intensity, override_blindness_check, affect_silicon, visual, type)
	return

/mob/living/silicon/robot/cogscarab/use_power() //it's made of gears...
	return

/mob/living/silicon/robot/cogscarab/verb/hide()
	set name = "Hide"
	set desc = "Allows you to hide beneath tables or certain items. Toggled on or off."
	set category = "Cogscarab"

	if(layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

/mob/living/silicon/robot/cogscarab/verb/light()
	set name = "Light On/Off"
	set desc = "Activate a low power omnidirectional LED. Toggled on or off."
	set category = "Cogscarab"

	if(lamp_intensity)
		lamp_intensity = lamp_max // setting this to lamp_max will make control_headlamp shutoff the lamp
	control_headlamp()

/mob/living/silicon/robot/cogscarab/control_headlamp()
	if(stat || lamp_recharging || low_power_mode)
		to_chat(src, "<span class='danger'>This function is currently offline.</span>")
		return

//Some sort of magical "modulo" thing which somehow increments lamp power by 2, until it hits the max and resets to 0.
	lamp_intensity = (lamp_intensity+1) % (lamp_max+1)
	to_chat(src, "[lamp_intensity ? "Headlamp power set to Level [lamp_intensity]" : "Headlamp disabled."]")
	update_headlamp()

/mob/living/silicon/robot/cogscarab/update_headlamp(var/turn_off = 0, var/cooldown = 100)
	set_light(0)

	if(lamp_intensity && (turn_off || stat || low_power_mode))
		to_chat(src, "<span class='danger'>Your headlamp has been deactivated.</span>")
		lamp_intensity = 0
		lamp_recharging = 1
		spawn(cooldown) //10 seconds by default, if the source of the deactivation does not keep stat that long.
			lamp_recharging = 0
	else
		set_light(lamp_intensity)

	if(lamp_button)
		lamp_button.icon_state = "lamp[lamp_intensity*2]"

	update_icons()
