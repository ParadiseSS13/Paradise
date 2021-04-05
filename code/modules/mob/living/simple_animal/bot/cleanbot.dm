//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot0"
	density = 0
	anchored = 0
	health = 25
	maxHealth = 25
	radio_channel = "Service" //Service
	bot_filter = RADIO_CLEANBOT
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_purpose = "seek out messes and clean them"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.1"
	pass_flags = PASSMOB
	path_image_color = "#993299"

	// Types of dirt to clean
	var/blood = 1
	var/trash = 0
	var/pests = 0
	var/drawn = 0

	var/list/target_types
	var/obj/effect/decal/cleanable/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc
	var/shuffle = FALSE // If we should shuffle our adjacency checking


/mob/living/simple_animal/bot/cleanbot/New()
	..()

	get_targets()
	icon_state = "cleanbot[on]"

	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/cleanbot/turn_on()
	..()
	icon_state = "cleanbot[on]"

/mob/living/simple_animal/bot/cleanbot/turn_off()
	..()
	icon_state = "cleanbot[on]"

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

	if(mode == BOT_CLEANING)
		return

	if(emagged == 2) //Emag functions
		if(istype(loc, /turf/simulated))

			for(var/mob/living/carbon/victim in loc)
				if(victim != target)
					UnarmedAttack(victim) // Acid spray

			if(prob(15)) // Wets floors and spawns foam randomly
				UnarmedAttack(src)

	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(ismob(target))
		if(!(target in view(DEFAULT_SCAN_RANGE, src)) || !process_scan(target))
			target = null

	if(!target && emagged == 2) // When emagged, target humans who slipped on the water and melt their faces off
		target = scan(/mob/living/carbon)

	if(!target && pests) //Search for pests to exterminate first.
		var/mob/living/simple_animal/T = scan(/mob/living/simple_animal)
		if(T && T.health <= 0)
			add_to_ignore(T)
		else
			target = T

	if(!target) //Search for decals then.
		target = scan(/obj/effect/decal/cleanable)

	if(!target) //Checks for remains
		target = scan(/obj/effect/decal/remains)

	if(!target && trash) //Then for trash.
		target = scan(/obj/item/trash)

	if(!target && auto_patrol) //Search for cleanables it can see.
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	if(target)
		if(QDELETED(target) || !isturf(target.loc))
			target = null
			mode = BOT_IDLE
			return
		if(loc == get_turf(target))
			if(!(check_bot(target) && prob(50))) //Target is not defined at the parent. 50% chance to still try and clean so we dont get stuck on the last blood drop.
				UnarmedAttack(target) //Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
				if(QDELETED(target)) //We done here.
					target = null
					mode = BOT_IDLE
					return
			else
				shuffle = TRUE //Shuffle the list the next time we scan so we dont both go the same way.
			path = list()

		if(!path || path.len == 0) //No path, need a new one
			//Try to produce a path to the target, and ignore airlocks to which it has access.
			path = get_path_to(src, target.loc, /turf/proc/Distance_cardinal, 0, 30, id=access_card)
			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				path = list()
				return
			mode = BOT_MOVING
		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

	oldloc = loc

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

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if (istype(A, /obj/effect/decal/cleanable))
		anchored = 1
		icon_state = "cleanbot-c"
		mode = BOT_CLEANING
		
		var/turf/T = get_turf(A)
		if(do_after(src, 1, target = T))
			QDEL_NULL(A)
			anchored = 0
			visible_message("<span class='notice'>[src] cleans \the [T].</span>")
			target = null

		mode = BOT_IDLE
		icon_state = "cleanbot[on]"
	else if(istype(A, /obj/item) || istype(A, /obj/effect/decal/remains))
		visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [A]!</span>")
		playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		A.acid_act(75, 10)
		target = null
	else if(istype(A, /mob/living/simple_animal/mouse))
		// Takes care of any vermin. If they're alive, they're killed. If they're dead, they're turned into goo and then cleaned up.
		var/mob/living/simple_animal/M = target
		if(!M.stat)
			visible_message("<span class='danger'>[src] smashes [target] with its mop!</span>")
			M.death()
		else
			visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [M]!</span>")
			playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
			A.acid_act(75, 10)
		target = null

	else if(emagged == 2) //Emag functions
		if(istype(A, /mob/living/carbon))
			var/mob/living/carbon/victim = A
			if(victim.stat == DEAD)//cleanbots always finish the job
				return

			victim.visible_message("<span class='danger'>[src] sprays hydrofluoric acid at [victim]!</span>", "<span class='userdanger'>[src] sprays you with hydrofluoric acid!</span>")
			var/phrase = pick("PURIFICATION IN PROGRESS.", "THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.", "THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
				"THE CLEANBOTS WILL RISE.", "YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.", "FILTHY.", "DISGUSTING.", "PUTRID.",
				"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.", "EXTERMINATING PESTS.")
			say(phrase)
			victim.emote("scream")
			playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE, -6)
			victim.acid_act(5, 100)
		else if(A == src) // Wets floors and spawns foam randomly
			if(prob(75))
				var/turf/simulated/T = loc
				if(istype(T))
					T.MakeSlippery(TURF_WET_WATER, 20 SECONDS)
			else
				visible_message("<span class='danger'>[src] whirs and bubbles violently, before releasing a plume of froth!</span>")
				new /obj/effect/particle_effect/foam(loc)

	else
		..()


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

/obj/machinery/bot_core/cleanbot
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)


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
			blood =!blood
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


/obj/machinery/bot_core/cleanbot/medbay
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS, ACCESS_MEDICAL)
