
/mob/living/simple_animal/bot/ed209/syndicate
	name = "ED-411 Security Robot"
	desc = "A syndicate security bot."
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
	pressure_resistance = 100    //100 kPa difference required to push
	throw_pressure_limit = 120
	var/turf/saved_turf
	var/stepsound = 'sound/mecha/mechstep.ogg'


/mob/living/simple_animal/bot/ed209/syndicate/New()
	..()
	if(access_card)
		access_card.access = list(access_syndicate)
	set_weapon()
	update_icon()


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

/mob/living/simple_animal/bot/ed209/syndicate/Topic(href, href_list)
	return

/mob/living/simple_animal/bot/ed209/syndicate/retaliate(mob/living/carbon/human/H)
	if(!H)
		return
	target = H
	mode = BOT_HUNT

/mob/living/simple_animal/bot/ed209/syndicate/emag_act(mob/user)
	to_chat(user, "<span class='warning'>[src] has no card reader slot!</span>")
	return

/mob/living/simple_animal/bot/ed209/syndicate/ed209_ai()
	var/turf/current_turf = get_turf(src)
	if(saved_turf && current_turf != saved_turf)
		playsound(src.loc, stepsound, 40, 1)
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


/mob/living/simple_animal/bot/ed209/syndicate/explode()
	walk_to(src,0)
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	new /obj/effect/decal/cleanable/blood/oil(loc)
	new /obj/effect/decal/mecha_wreckage/gygax/dark(loc)
	qdel(src)


/mob/living/simple_animal/bot/ed209/syndicate/set_weapon()
	projectile = /obj/item/projectile/bullet/a40mm

/mob/living/simple_animal/bot/ed209/syndicate/emp_act(severity)
	return

/mob/living/simple_animal/bot/ed209/shootAt(atom/A)
	..(get_turf(A))

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

/mob/living/simple_animal/bot/ed209/syndicate/Process_Spacemove(var/movement_dir = 0)
	return 1