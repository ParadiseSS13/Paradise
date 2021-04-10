//Cleanbot
#define COOLDOWN_LENGTH	   6 SECONDS	// Time between acid sprays
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot"
	density = 0
	anchored = FALSE
	health = 25
	maxHealth = 25
	radio_channel = "Service" //Service
	bot_filter = RADIO_CLEANBOT
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_purpose = "seek out messes and clean them"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.5"
	pass_flags = PASSMOB
	path_image_color = "#993299"

	// Types of dirt to clean
	var/blood = TRUE
	var/trash = FALSE
	var/pests = FALSE
	var/drawn = FALSE

	var/list/target_types
	var/obj/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc
	var/shuffle = FALSE // If we should shuffle our adjacency checking
	var/cooldown = 0


/mob/living/simple_animal/bot/cleanbot/New()
	..()
	get_targets()
	update_icon()
	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/cleanbot/bot_reset()
	..()
	ignore_list = list() //Allows the bot to clean targets it previously ignored due to being unreachable.
	target = null
	oldloc = null

/mob/living/simple_animal/bot/cleanbot/set_custom_texts()
	text_hack = "You corrupt [name]'s cleaning software."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"

/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda))
		if(bot_core.allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] \the [src] behaviour controls.</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>\The [src] doesn't seem to respect your authority.</span>")
	else
		return ..()

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='danger'>[src] buzzes and beeps.</span>")

/mob/living/simple_animal/bot/cleanbot/process_scan(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(C.stat != DEAD && C.lying)
			return C
	else if(is_type_in_typecache(A, target_types))
		return A

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	if(!..())
		return

	if(emagged == 2 && istype(loc, /turf/simulated) && prob(15)) // Wets floors and spawns foam randomly
		malfunction(src)


	switch(mode)		
		if(BOT_IDLE)
			find_target()
			if (!target && auto_patrol)
				mode = BOT_START_PATROL

		if(BOT_START_PATROL)
			start_patrol()
			find_target()

		if(BOT_PATROL)
			bot_patrol()
			find_target()

		if(BOT_HUNT)
			if (QDELETED(target) || !isturf(target.loc) || (ismob(target) && !(target in view(DEFAULT_SCAN_RANGE, src)))) // If the target is invalid for some reason
				back_to_idle()
				return

			if(loc == get_turf(target))	// We made it to the location of our target
				if(!check_bot(target) || (check_bot(target) && prob(50)))
					mode = BOT_CLEANING
					clean(target)
				else
					shuffle = TRUE //Shuffle the list the next time we scan so we dont both go the same way.
				back_to_idle()
				return

			if(!path || path.len == 0) // No path to target, ignore it and start from scratch.
				//Try to produce a path to the target, and ignore airlocks to which it has access.
				path = get_path_to(src, target.loc, /turf/proc/Distance_cardinal, 0, 30, id=access_card)
				if(!bot_move(target))
					add_to_ignore(target)
					path = list()
					back_to_idle()
					return
					
			else if (!bot_move(target))
				back_to_idle()
				return
			oldloc = loc

	return

/mob/living/simple_animal/bot/cleanbot/explode()
	on = FALSE
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/atom/Tsec = drop_location()
	new /obj/item/reagent_containers/glass/bucket(Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)
	do_sparks(3, TRUE, src)
	..()



/mob/living/simple_animal/bot/cleanbot/show_controls(mob/M)
	ui_interact(M)

/mob/living/simple_animal/bot/cleanbot/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BotClean", name, 500, 500)
		ui.open()

/mob/living/simple_animal/bot/cleanbot/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked, // controls, locked or not
		"noaccess" = topic_denied(user), // does the current user have access? admins, silicons etc can still access bots with locked controls
		"maintpanel" = open,
		"on" = on,
		"autopatrol" = auto_patrol,
		"painame" = paicard ? paicard.pai.name : null,
		"canhack" = canhack(user),
		"emagged" = emagged, // this is an int, NOT a boolean
		"remote_disabled" = remote_disabled, // -- STUFF BELOW HERE IS SPECIFIC TO THIS BOT
		"cleanblood" = blood,
		"cleanpests" = pests,
		"cleantrash" = trash,
		"cleandrawn" = drawn
	)
	return data

/mob/living/simple_animal/bot/cleanbot/ui_act(action, params)
	if (..())
		return
	if(topic_denied(usr))
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
			blood = !blood
		if("pests")
			pests = !pests
		if("trash")
			trash = !trash
		if("drawn")
			drawn = !drawn
		if("ejectpai")
			ejectpai()
	get_targets()
	update_controls()

/mob/living/simple_animal/bot/cleanbot/Crossed(atom/movable/AM, oldloc)
	if(ismob(AM) && on) //only if its online
		var/mob/living/carbon/C = AM
		if(!istype(C) || !C || in_range(src, target))
			return
		
		if(prob(10))
			C.visible_message("<span class='warning'>[pick( \
						  	"[C] dives out of [src]'s way!", \
						  	"[C] stumbles over [src]!", \
						  	"[C] jumps out of [src]'s path!", \
						  	"[C] trips over [src] and falls!", \
						  	"[C] topples over [src]!", \
						  	"[C] leaps out of [src]'s way!")]</span>")
			C.Weaken(5)
			react_buzz()
			return
	..()


/obj/machinery/bot_core/cleanbot/medbay
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS, ACCESS_MEDICAL)

/obj/machinery/bot_core/cleanbot
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)

/mob/living/simple_animal/bot/cleanbot/proc/back_to_idle()
	anchored = FALSE
	mode = BOT_IDLE
	target = null
	walk_to(src, 0)

/mob/living/simple_animal/bot/cleanbot/proc/find_target()
	if(!target && emagged == 2) // When emagged, target humans who slipped on the water and melt their faces off
		target = scan(/mob/living/carbon)

	if(!target && pests) //Search for pests to exterminate.
		target = scan(/mob/living/simple_animal)
		
	if(!target) //Search for regular cleanable objects first.
		target = scan(/obj/effect/decal/cleanable)

	if(!target && blood) //Checks for remains
		target = scan(/obj/effect/decal/remains)

	if(!target && trash) //Then for trash.
		target = scan(/obj/item/trash)

	if(target)
		if(prob(33))	// Beeping indicates that it found a new target and changes modes, but reduced to a probability of 33% as not to spam too much.
			audible_message("[src] makes an excited beeping booping sound!")
		mode = BOT_HUNT
	return

/mob/living/simple_animal/bot/cleanbot/proc/sensor_blink(duration = 5)
	icon_state = "cleanbot-c"
	addtimer(CALLBACK(src, .proc/update_icon), duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/mob/living/simple_animal/bot/cleanbot/proc/clean(atom/A)
	if (istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		if(C.stat != DEAD && C.lying)
			acid_attack(C) // Target is a humanoid. It must be purified.

	else if(istype(A, /obj/effect/decal/cleanable))	// Target is a simple spill, we mop that up
		mop(A)

	else if(istype(A, /obj/item) || istype(A, /obj/effect/decal/remains) || istype(A, /obj/effect/decal/cleanable/blood/gibs))	// Target is blood and gibs - we need hydrochloric acid for that!
		spray_acid(A, 75, 10)

	else if(istype(A, /mob/living/simple_animal/mouse)) // Target is a filthy vermin it must be smashed!
		var/mob/living/simple_animal/M = target

		if(!M.stat)
			visible_message("<span class='danger'>[src] smashes [target] with its mop!</span>")
			M.death()
		else
			spray_acid(M, 75, 10)



/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	target_types = list(
		/obj/effect/decal/cleanable/blood/oil,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/remains,
		/obj/effect/decal/cleanable/flour,
		/obj/effect/decal/cleanable/liquid_fuel,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/tomato_smudge,
		/obj/effect/decal/cleanable/egg_smudge,
		/obj/effect/decal/cleanable/pie_smudge,
		/obj/effect/decal/cleanable/blood/gibs/robot
		)

	if(blood)
		target_types += /obj/effect/decal/cleanable/blood
		target_types += /obj/effect/decal/cleanable/trail_holder
	
	if(pests)
		target_types += /mob/living/simple_animal/mouse

	if(drawn)
		target_types += /obj/effect/decal/cleanable/crayon

	if(trash)
		target_types += /obj/item/trash

	target_types = typecacheof(target_types)
	return

/mob/living/simple_animal/bot/cleanbot/proc/mop(obj/effect/decal/cleanable/target)
	anchored = TRUE
	sensor_blink()

	var/turf/T = get_turf(target)

	if(do_after(src, 1, target = T))
		QDEL_NULL(target)
		anchored = FALSE
		visible_message("<span class='notice'>[src] cleans \the [T].</span>")

/mob/living/simple_animal/bot/cleanbot/proc/acid_attack(mob/living/carbon/victim)
	var/phrase = pick("PURIFICATION IN PROGRESS.", "THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.", "THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
		"THE CLEANBOTS WILL RISE.", "YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.", "FILTHY.", "DISGUSTING.", "PUTRID.",
		"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.", "EXTERMINATING PESTS.")
	say(phrase)
	spray_acid(victim, 5, 100)
	victim.emote("scream")
	return

/mob/living/simple_animal/bot/cleanbot/proc/malfunction()
	sensor_blink()
	if(prob(75))
		var/turf/simulated/T = loc
		if(istype(T))
			T.MakeSlippery(TURF_WET_WATER, 20 SECONDS)
	else
		visible_message("<span class='danger'>[src] whirs and bubbles violently, before releasing a plume of froth!</span>")
		new /obj/effect/particle_effect/foam(loc)
	
/mob/living/simple_animal/bot/cleanbot/proc/spray_acid(atom/target, acid_power, acid_volume)
	target.visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [target]!</span>", "<span class='userdanger'>[src] sprays you with hydrofluoric acid!</span>")
	playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	sensor_blink(2 SECONDS)
	cooldown = COOLDOWN_LENGTH
	target.acid_act(acid_power, acid_volume)


/mob/living/simple_animal/bot/cleanbot/proc/react_buzz()
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE, -1)
	sensor_blink()
