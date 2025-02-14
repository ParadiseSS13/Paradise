
/mob/living/simple_animal/bot/ed209/syndicate
	name = "Syndicate Sentry Bot"
	desc = "A syndicate security bot."
	model = "Guardian"
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "darkgygax"
	radio_channel = "Syndicate"
	health = 300
	maxHealth = 300
	declare_arrests = FALSE
	idcheck = TRUE
	no_handcuffs = TRUE
	auto_patrol = TRUE
	emagged = TRUE
	faction = list("syndicate")
	shoot_sound = 'sound/weapons/wave.ogg'
	anchored = TRUE
	window_id = "syndiebot"
	window_name = "Syndicate Bot Interface"
	var/turf/saved_turf
	var/stepsound = 'sound/mecha/mechstep.ogg'
	var/area/syndicate_depot/core/depotarea
	var/raised_alert = FALSE
	var/pathing_failed = FALSE
	var/turf/spawn_turf

/mob/living/simple_animal/bot/ed209/syndicate/Initialize(mapload)
	. = ..()
	set_weapon()
	update_icon()
	spawn_turf = get_turf(src)

/mob/living/simple_animal/bot/ed209/syndicate/setup_access()
	if(access_card)
		access_card.access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
		prev_access = access_card.access

/mob/living/simple_animal/bot/ed209/syndicate/update_icon_state()
	icon_state = initial(icon_state)

/mob/living/simple_animal/bot/ed209/syndicate/turn_on()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/ed209/syndicate/turn_off()
	..()
	update_icon()

/mob/living/simple_animal/bot/ed209/syndicate/ui_state(mob/user)
	return GLOB.default_state

/mob/living/simple_animal/bot/ed209/syndicate/ui_interact(mob/user, datum/tgui/ui = null)
	to_chat(user, "<span class='warning'>[src] has no accessible control panel!</span>")
	return

/mob/living/simple_animal/bot/ed209/syndicate/ui_data(mob/user)
	return

/mob/living/simple_animal/bot/ed209/syndicate/ui_act(action, params)
	return

/mob/living/simple_animal/bot/ed209/syndicate/Topic(href, href_list)
	return

/mob/living/simple_animal/bot/ed209/syndicate/retaliate(mob/living/carbon/human/H)
	if(!H)
		return
	target = H
	set_mode(BOT_HUNT)

/mob/living/simple_animal/bot/ed209/syndicate/emag_act(mob/user)
	to_chat(user, "<span class='warning'>[src] has no card reader slot!</span>")

/mob/living/simple_animal/bot/ed209/syndicate/try_chasing_target()
	. = ..()
	if(!lost_target)
		shootAt(target)

/mob/living/simple_animal/bot/ed209/syndicate/ed209_ai()
	var/turf/current_turf = get_turf(src)
	if(saved_turf && current_turf != saved_turf)
		playsound(loc, stepsound, 40, 1)
	if(spawn_turf && !atoms_share_level(src, spawn_turf))
		raise_alert("[src] lost in space.")
		raised_alert = FALSE
		raise_alert("[src] activated self-destruct.")
		qdel(src)
	saved_turf = current_turf
	switch(mode)
		if(BOT_IDLE)
			GLOB.move_manager.stop_looping(src)
			set_path(null)
			if(find_new_target())
				return
			if(!mode && auto_patrol)
				set_mode(BOT_START_PATROL)

		if(BOT_HUNT)
			if(frustration >= 8)
				GLOB.move_manager.stop_looping(src)
				set_path(null)
				back_to_idle()
				return

			if(!target)
				back_to_idle()
				return

			if(isliving(target) && target.stat == DEAD)
				back_to_idle()
				return

			try_chasing_target(target)

		if(BOT_START_PATROL)
			if(find_new_target())
				return
			start_patrol()

		if(BOT_PATROL)
			if(find_new_target())
				return
			bot_patrol()
		else
			back_to_idle()
	return

/mob/living/simple_animal/bot/ed209/syndicate/find_new_target()
	if(disabled)
		return
	for(var/mob/M in view(7, src))
		if(M.invisibility > see_invisible)
			continue
		if("syndicate" in M.faction)
			continue
		if(M.stat == DEAD)
			continue
		if((M.name == oldtarget_name) && (world.time < last_found + 100))
			continue
		target = M
		oldtarget_name = M.name
		set_mode(BOT_HUNT)
		INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
		return TRUE
	return FALSE


/mob/living/simple_animal/bot/ed209/syndicate/shootAt(atom/target)
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	var/obj/item/projectile/P = new projectile(loc)
	playsound(loc, shoot_sound, 100, 1)
	P.current = loc
	P.starting = loc
	P.firer = src
	P.firer_source_atom = src
	P.yo = target.y - loc.y
	P.xo = target.x - loc.x
	P.original = target
	P.fire()

/mob/living/simple_animal/bot/ed209/syndicate/explode()
	if(!QDELETED(src))
		if(depotarea)
			depotarea.list_remove(src, depotarea.guard_list)
		GLOB.move_manager.stop_looping(src)
		visible_message("<span class='userdanger'>[src] blows apart!</span>")
		do_sparks(3, 1, src)
		new /obj/effect/decal/cleanable/blood/oil(loc)
		var/obj/structure/mecha_wreckage/gygax/dark/wreck = new /obj/structure/mecha_wreckage/gygax/dark(loc)
		wreck.name = "sentry bot wreckage"

		raise_alert("[src] destroyed.")
		qdel(src)

/mob/living/simple_animal/bot/ed209/syndicate/set_weapon()
	projectile = /obj/item/projectile/bullet/a40mm

/mob/living/simple_animal/bot/ed209/syndicate/emp_act(severity)
	return

/mob/living/simple_animal/bot/ed209/syndicate/UnarmedAttack(atom/A)
	if(!on)
		return
	shootAt(A)

/mob/living/simple_animal/bot/ed209/syndicate/cuff(mob/living/carbon/C)
	shootAt(C)

/mob/living/simple_animal/bot/ed209/syndicate/stun_attack(mob/living/carbon/C)
	shootAt(C)

/mob/living/simple_animal/bot/ed209/syndicate/speak()
	return

/mob/living/simple_animal/bot/ed209/syndicate/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 1

/mob/living/simple_animal/bot/ed209/syndicate/start_patrol()
	if(tries >= BOT_STEP_MAX_RETRIES)
		if(!pathing_failed)
			pathing_failed = TRUE
			var/failmsg = "Depot: [src] at [loc.x],[loc.y],[loc.z] lacks patrol target."
			if(istype(patrol_target))
				failmsg = "Depot: [src] at [loc.x],[loc.y],[loc.z] cannot reach [patrol_target.x],[patrol_target.y]"
			log_debug(failmsg)
	return ..()

/mob/living/simple_animal/bot/ed209/syndicate/proc/raise_alert(reason)
	if(raised_alert)
		return
	raised_alert = TRUE
	if(depotarea)
		depotarea.increase_alert(reason)
