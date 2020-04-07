
/mob/living/simple_animal/bot/ed209/syndicate
	name = "Syndicate Sentry Bot"
	desc = "A syndicate security bot."
	model = "Guardian"
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "darkgygax"
	radio_channel = "Syndicate"
	health = 300
	maxHealth = 300
	declare_arrests = 0
	idcheck = 1
	arrest_type = 1
	auto_patrol = 1
	emagged = 2
	faction = list("syndicate")
	shoot_sound = 'sound/weapons/wave.ogg'
	anchored = 1
	window_id = "syndiebot"
	window_name = "Syndicate Bot Interface"
	var/turf/saved_turf
	var/stepsound = 'sound/mecha/mechstep.ogg'
	var/area/syndicate_depot/core/depotarea
	var/raised_alert = FALSE
	var/pathing_failed = FALSE
	var/turf/spawn_turf

/mob/living/simple_animal/bot/ed209/syndicate/New()
	..()
	set_weapon()
	update_icon()
	spawn_turf = get_turf(src)

/mob/living/simple_animal/bot/ed209/syndicate/setup_access()
	if(access_card)
		access_card.access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
		prev_access = access_card.access

/mob/living/simple_animal/bot/ed209/syndicate/update_icon()
	icon_state = initial(icon_state)

/mob/living/simple_animal/bot/ed209/syndicate/turn_on()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/ed209/syndicate/turn_off()
	..()
	update_icon()

/mob/living/simple_animal/bot/ed209/syndicate/get_controls(mob/user)
	to_chat(user, "<span class='warning'>[src] has no accessible control panel!</span>")
	return

/mob/living/simple_animal/bot/ed209/syndicate/show_controls(mob/M)
	return

/mob/living/simple_animal/bot/ed209/syndicate/Topic(href, href_list)
	return

/mob/living/simple_animal/bot/ed209/syndicate/retaliate(mob/living/carbon/human/H)
	if(!H)
		return
	target = H
	mode = BOT_HUNT

/mob/living/simple_animal/bot/ed209/syndicate/emag_act(mob/user)
	to_chat(user, "<span class='warning'>[src] has no card reader slot!</span>")

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
			walk_to(src,0)
			look_for_perp()
			if(!mode && auto_patrol)
				mode = BOT_START_PATROL
		if(BOT_HUNT)
			if(frustration >= 8)
				walk_to(src,0)
				back_to_idle()
			if(target)
				if(isliving(target))
					if(target.stat == DEAD)
						back_to_idle()
						return
				shootAt(target)
				var/turf/olddist = get_dist(src, target)
				walk_to(src, target,1,4)
				if((get_dist(src, target)) >= (olddist))
					frustration++
				else
					frustration = 0
			else
				back_to_idle()
		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()
		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()
		else
			back_to_idle()
	return

/mob/living/simple_animal/bot/ed209/syndicate/look_for_perp()
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
		mode = BOT_HUNT
		spawn(0)
			handle_automated_action()
		break
	for(var/obj/spacepod/P in view(7, src))
		if((P.name == oldtarget_name) && (world.time < last_found + 100))
			continue
		if(!P.pilot)
			continue
		if("syndicate" in P.pilot.faction)
			continue
		if(P.pilot.stat == DEAD)
			continue
		target = P
		oldtarget_name = P.name
		mode = BOT_HUNT
		spawn(0)
			handle_automated_action()
		break


/mob/living/simple_animal/bot/ed209/syndicate/shootAt(atom/target)
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	var/obj/item/projectile/P = new projectile(loc)
	playsound(loc, shoot_sound, 100, 1)
	P.current = loc
	P.starting = loc
	P.firer = src
	P.yo = target.y - loc.y
	P.xo = target.x - loc.x
	P.original = target
	P.fire()

/mob/living/simple_animal/bot/ed209/syndicate/explode()
	if(!QDELETED(src))
		if(depotarea)
			depotarea.list_remove(src, depotarea.guard_list)
		walk_to(src,0)
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

/mob/living/simple_animal/bot/ed209/UnarmedAttack(atom/A)
	if(!on)
		return
	shootAt(A)

/mob/living/simple_animal/bot/ed209/syndicate/cuff(mob/living/carbon/C)
	shootAt(C)

/mob/living/simple_animal/bot/ed209/syndicate/stun_attack(mob/living/carbon/C)
	shootAt(C)

/mob/living/simple_animal/bot/ed209/syndicate/speak()
	return

/mob/living/simple_animal/bot/ed209/syndicate/Process_Spacemove(movement_dir = 0)
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
