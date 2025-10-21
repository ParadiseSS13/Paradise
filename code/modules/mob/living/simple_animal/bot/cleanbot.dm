//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon_state = "cleanbot"
	density = FALSE
	health = 25
	maxHealth = 25
	radio_channel = "Service" //Service
	bot_filter = RADIO_CLEANBOT
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_purpose = "seek out messes and clean them"
	req_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.1"
	pass_flags = PASSMOB


	var/blood = TRUE
	var/list/target_types = list()
	var/obj/effect/decal/cleanable/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc
	var/area/area_locked
	var/static/list/clean_dirt = list(
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/blood/gibs/robot,
		/obj/effect/decal/cleanable/crayon,
		/obj/effect/decal/cleanable/liquid_fuel,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/tomato_smudge,
		/obj/effect/decal/cleanable/egg_smudge,
		/obj/effect/decal/cleanable/pie_smudge,
		/obj/effect/decal/cleanable/flour,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/glass
	)
	var/static/list/clean_blood = list(
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/trail_holder
	)

/mob/living/simple_animal/bot/cleanbot/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

	clean_dirt = typecacheof(clean_dirt)
	clean_blood = typecacheof(clean_blood)

	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/cleanbot/update_icon_state()
	return

/mob/living/simple_animal/bot/cleanbot/update_overlays()
	. = ..()
	if(!on)
		. += "clean_off"
		return
	if(mode == BOT_CLEANING)
		. += "clean_brush"
		. += "clean[area_locked ? "_restrict" : ""]_work"
		return
	. += "clean_[area_locked ? "restrict" : "on"]"

/mob/living/simple_animal/bot/cleanbot/bot_reset()
	..()
	clear_ignore_list()
	target = null
	oldloc = null
	area_locked = null
	update_icon()

/mob/living/simple_animal/bot/cleanbot/set_custom_texts()
	text_hack = "You corrupt [name]'s cleaning software."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"

/mob/living/simple_animal/bot/cleanbot/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda))
		if(allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] \the [src] behaviour controls.</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>\The [src] doesn't seem to respect your authority.</span>")

		return ITEM_INTERACT_COMPLETE

	return ..()

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()
	if(emagged)
		if(user)
			to_chat(user, "<span class='danger'>[src] buzzes and beeps.</span>")

/mob/living/simple_animal/bot/cleanbot/process_scan(obj/effect/decal/cleanable/D)
	if(!(is_type_in_typecache(D, clean_dirt) || blood && is_type_in_typecache(D, clean_blood)))
		return FALSE
	if(!area_locked)
		return D
	var/area/target_area = get_area(D)
	if(target_area == area_locked)
		return D
	return FALSE

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_CLEANING)
		return

	if(emagged) //Emag functions
		if(issimulatedturf(loc))
			if(prob(10)) //Wets floors randomly
				var/turf/simulated/T = loc
				T.MakeSlippery()

			if(prob(5)) //Spawns foam!
				visible_message("<span class='danger'>[src] whirs and bubbles violently, before releasing a plume of froth!</span>")
				new /obj/effect/particle_effect/foam(loc)

	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(!target) //Search for cleanables it can see.
		target = scan(/obj/effect/decal/cleanable, avoid_bot = TRUE)

	if(!target && auto_patrol) //Search for cleanables it can see.
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	if(target && loc == get_turf(target))
		start_clean(target)
		path = list()
		target = null

	if(target)
		var/target_uid = target.UID() // target can become null while path is calculated, so we need to store UID
		if(!length(path)) //No path, need a new one
			set_mode(BOT_PATHING)
			path = get_path_to(src, target, 30, access = access_card.access)
			if(!bot_move(target))
				ignore_job -= target_uid
				add_to_ignore(target)
				target = null
				path = list()
				set_mode(BOT_IDLE)
				return
			set_mode(BOT_MOVING)

		else if(!bot_move(target))
			ignore_job -= target_uid
			target = null
			set_mode(BOT_IDLE)
			return

	oldloc = loc

/mob/living/simple_animal/bot/cleanbot/proc/assign_area()
	auto_patrol = FALSE // Don't want autopatrol if we are area locked
	if(area_locked)
		area_locked = null
	else
		area_locked = get_area(loc)
	update_icon(UPDATE_OVERLAYS)

/mob/living/simple_animal/bot/cleanbot/proc/start_clean(obj/effect/decal/cleanable/target)
	anchored = TRUE
	visible_message("<span class='notice'>[src] begins to clean up [target]</span>")
	set_mode(BOT_CLEANING)
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(do_clean), target), 5 SECONDS)

/mob/living/simple_animal/bot/cleanbot/proc/do_clean(obj/effect/decal/cleanable/target)
	if(mode == BOT_CLEANING)
		ignore_job -= target.UID()
		QDEL_NULL(target)
		anchored = FALSE
	set_mode(BOT_IDLE)
	update_icon(UPDATE_OVERLAYS)

/mob/living/simple_animal/bot/cleanbot/explode()
	on = FALSE
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)
	new /obj/item/reagent_containers/glass/bucket(Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)
	do_sparks(3, 1, src)
	..()

//TGUI

/mob/living/simple_animal/bot/cleanbot/show_controls(mob/user)
	ui_interact(user)

/mob/living/simple_animal/bot/cleanbot/ui_state(mob/user)
	return GLOB.default_state

/mob/living/simple_animal/bot/cleanbot/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotClean", name)
		ui.open()

/mob/living/simple_animal/bot/cleanbot/ui_data(mob/user)
	var/list/data = ..()
	data["cleanblood"] = blood
	data["area"] = get_area_name(area_locked)
	return data

/mob/living/simple_animal/bot/cleanbot/ui_act(action, params)
	if(..())
		return
	if(action != "area" && topic_denied(usr))
		to_chat(usr, "<span class='warning'>[src]'s interface is not responding!</span>")
		return
	add_fingerprint(usr)
	. = TRUE
	switch(action)
		if("power")
			if(on)
				turn_off()
			else
				turn_on()
		if("autopatrol")
			auto_patrol = !auto_patrol
			bot_reset()
		if("hack")
			handle_hacking(usr)
		if("disableremote")
			remote_disabled = !remote_disabled
		if("blood")
			blood =!blood
		if("area")
			assign_area()
		if("ejectpai")
			ejectpai()

//END OF TGUI

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A)
	if(istype(A,/obj/effect/decal/cleanable))
		start_clean(A)
	else
		..()
