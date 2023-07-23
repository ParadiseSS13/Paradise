
/*
	run_armor_check(a,b)
	args
	a:def_zone - What part is getting hit, if null will check entire body
	b:attack_flag - What type of attack, bullet, laser, energy, melee

	Returns
	0 - no block
	1 - halfblock
	2 - fullblock
*/
/mob/living/proc/run_armor_check(def_zone = null, attack_flag = MELEE, absorb_text = "Your armor absorbs the blow!", soften_text = "Your armor softens the blow!", armour_penetration_flat = 0, penetrated_text = "Your armor was penetrated!", armour_penetration_percentage = 0)
	var/armor = getarmor(def_zone, attack_flag)

	if(armor == INFINITY)
		to_chat(src, "<span class='userdanger'>[absorb_text]</span>")
		return armor
	if(armor <= 0)
		return armor
	if(!armour_penetration_flat && armour_penetration_percentage <= 0)
		to_chat(src, "<span class='userdanger'>[soften_text]</span>")
		return armor

	var/armor_original = armor
	armor = max(0, (armor * ((100 - armour_penetration_percentage) / 100)) - armour_penetration_flat)
	if(armor_original <= armor)
		to_chat(src, "<span class='userdanger'>[soften_text]</span>")
	else
		to_chat(src, "<span class='userdanger'>[penetrated_text]</span>")

	return armor

//if null is passed for def_zone, then this should return something appropriate for all zones (e.g. area effect damage)
/mob/living/proc/getarmor(def_zone, type)
	return 0

/mob/living/proc/is_mouth_covered(head_only = FALSE, mask_only = FALSE)
	return FALSE

/mob/living/proc/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	return FALSE

/mob/living/bullet_act(obj/item/projectile/P, def_zone)
	//Armor
	var/armor = run_armor_check(def_zone, P.flag, armour_penetration_flat = P.armour_penetration_flat, armour_penetration_percentage = P.armour_penetration_percentage)
	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, armor)
		if(P.dismemberment)
			check_projectile_dismemberment(P, def_zone)
	return P.on_hit(src, armor, def_zone)

/mob/living/proc/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	return 0

///As the name suggests, this should be called to apply electric shocks.
/mob/living/proc/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage, source, siemens_coeff, flags)
	if(status_flags & GODMODE)	//godmode
		return FALSE
	if((flags & SHOCK_TESLA) && HAS_TRAIT(src, TRAIT_TESLA_SHOCKIMMUNE))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		return FALSE
	shock_damage *= siemens_coeff
	if(shock_damage < 1)
		return FALSE
	if(!(flags & SHOCK_ILLUSION))
		take_overall_damage(0, shock_damage, TRUE, used_weapon = "Electrocution")
		if(shock_damage > 200)
			visible_message(
				"<span class='danger'>[src] was arc flashed by \the [source]!</span>",
				"<span class='userdanger'>\The [source] arc flashes and electrocutes you!</span>",
				"<span class='italics'>You hear a lightning-like crack!</span>")
			playsound(loc, 'sound/effects/eleczap.ogg', 50, 1, -1)
			explosion(loc, -1, 0, 2, 2)
	else
		adjustStaminaLoss(shock_damage)
	visible_message(
		"<span class='danger'>[src] was shocked by \the [source]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='hear'>You hear a heavy electrical crack.</span>" \
	)
	return shock_damage

/mob/living/emp_act(severity)
	..()
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
	if(throwforce && w_class)
		return clamp((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
	else if(w_class)
		return clamp(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
	else
		return 0

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(AM))
		var/obj/item/thrown_item = AM
		var/zone = ran_zone("chest", 65)//Hits a random part of the body, geared towards the chest
		var/nosell_hit = SEND_SIGNAL(thrown_item, COMSIG_MOVABLE_IMPACT_ZONE, src, zone, throwingdatum) // TODO: find a better way to handle hitpush and skipcatch for humans
		if(nosell_hit)
			skipcatch = TRUE
			hitpush = FALSE

		if(blocked)
			return TRUE
		var/mob/thrower = locateUID(thrown_item.thrownby)
		if(thrower)
			add_attack_logs(thrower, src, "Hit with thrown [thrown_item]", !thrown_item.throwforce ? ATKLOG_ALMOSTALL : null) // Only message if the person gets damages
		if(nosell_hit)
			return ..()
		visible_message("<span class='danger'>[src] is hit by [thrown_item]!</span>", "<span class='userdanger'>You're hit by [thrown_item]!</span>")
		if(!thrown_item.throwforce)
			return
		var/armor = run_armor_check(zone, MELEE, "Your armor has protected your [parse_zone(zone)].", "Your armor has softened hit to your [parse_zone(zone)].", thrown_item.armour_penetration_flat, armour_penetration_percentage = thrown_item.armour_penetration_percentage)
		apply_damage(thrown_item.throwforce, thrown_item.damtype, zone, armor, is_sharp(thrown_item), thrown_item)
		if(QDELETED(src)) //Damage can delete the mob.
			return
		return ..()

	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1) //Item sounds are handled in the item itself
	return ..()


/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M.occupant, TRAIT_PACIFISM))
			to_chat(M.occupant, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		M.do_attack_animation(src)
		if(M.damtype == "brute")
			step_away(src,M,15)
		switch(M.damtype)
			if("brute")
				Paralyse(2 SECONDS)
				take_overall_damage(rand(M.force/2, M.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			if("fire")
				take_overall_damage(0, rand(M.force/2, M.force))
				playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			if("tox")
				M.mech_toxin_damage(src)
			else
				return
		updatehealth("mech melee attack")
		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[M.name] hits [src]!</span>", "<span class='userdanger'>[M.name] hits you!</span>")
		add_attack_logs(M.occupant, src, "Mecha-meleed with [M]")
	else
		step_away(src,M)
		add_attack_logs(M.occupant, src, "Mecha-pushed with [M]", ATKLOG_ALL)
		M.occupant_message("<span class='warning'>You push [src] out of the way.</span>")
		visible_message("<span class='warning'>[M] pushes [src] out of the way.</span>")

//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire && !HAS_TRAIT(src, TRAIT_NOFIRE))
		on_fire = TRUE
		visible_message("<span class='warning'>[src] catches fire!</span>", "<span class='userdanger'>You're set on fire!</span>")
		set_light(light_range + 3,l_color = "#ED9200")
		throw_alert("fire", /obj/screen/alert/fire)
		update_fire()
		SEND_SIGNAL(src, COMSIG_LIVING_IGNITED)
		return TRUE
	return FALSE

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		set_light(max(0,light_range - 3))
		clear_alert("fire")
		update_fire()

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	fire_stacks = clamp(fire_stacks + add_fire_stacks, -20, 20)
	if(on_fire && fire_stacks <= 0)
		ExtinguishMob()

/**
 * Burns a mob and slowly puts the fires out. Returns TRUE if the mob is on fire
 */
/mob/living/proc/handle_fire()
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks + 1)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return FALSE
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.1) //the fire is slowly consumed
		for(var/obj/item/clothing/C in contents)
			C.catch_fire()
	else
		ExtinguishMob()
		return FALSE
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.oxygen < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return FALSE
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)
	SEND_SIGNAL(src, COMSIG_LIVING_FIRE_TICK)
	return TRUE

/mob/living/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	adjust_fire_stacks(3)
	IgniteMob()

//Share fire evenly between the two mobs
//Called in MobBump() and Crossed()
/mob/living/proc/spreadFire(mob/living/L)
	if(!istype(L))
		return
	var/L_old_on_fire = L.on_fire

	if(on_fire) //Only spread fire stacks if we're on fire
		fire_stacks /= 2
		L.fire_stacks += fire_stacks
		if(L.IgniteMob())
			log_game("[key_name(src)] bumped into [key_name(L)] and set them on fire")

	if(L_old_on_fire) //Only ignite us and gain their stacks if they were onfire before we bumped them
		L.fire_stacks /= 2
		fire_stacks += L.fire_stacks
		IgniteMob()

/mob/living/can_be_pulled(user, grab_state, force, show_message = FALSE)
	return ..() && !(buckled && buckled.buckle_prevents_pull)

/mob/living/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	adjust_fire_stacks(-(volume * 0.2))
	if(method == REAGENT_TOUCH)
		// 100 volume - 20 seconds of lost sleep
		AdjustSleeping(-(volume * 0.2 SECONDS), bound_lower = 1 SECONDS) // showers cannot save you from sleeping gas, 1 second lower boundary

//This is called when the mob is thrown into a dense turf
/mob/living/proc/turf_collision(turf/T, speed)
	src.take_organ_damage(speed*5)

/mob/living/proc/near_wall(direction, distance=1)
	var/turf/T = get_step(get_turf(src),direction)
	var/turf/last_turf = src.loc
	var/i = 1

	while(i>0 && i<=distance)
		if(T.density) //Turf is a wall!
			return last_turf
		i++
		last_turf = T
		T = get_step(T,direction)

	return 0

// End BS12 momentum-transfer code.

/mob/living/proc/grabbedby(mob/living/carbon/user, supress_message = FALSE)
	if(user == src || anchored)
		return FALSE
	if(!(status_flags & CANPUSH))
		return FALSE
	if(user.pull_force < move_force)
		return FALSE

	for(var/obj/item/grab/G in grabbed_by)
		if(G.assailant == user)
			to_chat(user, "<span class='notice'>You already grabbed [src].</span>")
			return

	add_attack_logs(user, src, "Grabbed passively", ATKLOG_ALL)

	var/obj/item/grab/G = new /obj/item/grab(user, src)
	if(!G)	//the grab will delete itself in New if src is anchored
		return 0
	user.put_in_active_hand(G)
	G.synch()
	LAssailant = user

	playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	/*if(user.dir == src.dir)
		G.state = GRAB_AGGRESSIVE
		G.last_upgrade = world.time
		if(!supress_message)
			visible_message("<span class='warning'>[user] has grabbed [src] from behind!</span>")
	else*///This is an example of how you can make special types of grabs simply based on direction.
	if(!supress_message)
		visible_message("<span class='warning'>[user] has grabbed [src] passively!</span>")

	return G

/mob/living/attack_slime(mob/living/simple_animal/slime/M)
	if(!SSticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.buckled)
		if(M in buckled_mobs)
			M.Feedstop()
		return // can't attack while eating!

	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		to_chat(M, "<span class='warning'>You don't want to hurt anyone!</span>")
		return FALSE

	if(stat != DEAD)
		add_attack_logs(M, src, "Slime'd")
		M.do_attack_animation(src)
		visible_message("<span class='danger'>\The [M.name] glomps [src]!</span>", "<span class='userdanger'>\The [M.name] glomps you!</span>")
		return TRUE

/mob/living/attack_animal(mob/living/simple_animal/M)
	M.face_atom(src)
	if((M.a_intent == INTENT_HELP && M.ckey) || M.melee_damage_upper == 0)
		M.custom_emote(EMOTE_VISIBLE, "[M.friendly] [src].")
		return FALSE
	if(HAS_TRAIT(M, TRAIT_PACIFISM))
		to_chat(M, "<span class='warning'>You don't want to hurt anyone!</span>")
		return FALSE

	if(M.attack_sound)
		playsound(loc, M.attack_sound, 50, 1, 1)
	M.do_attack_animation(src)
	visible_message("<span class='danger'>\The [M] [M.attacktext] [src]!</span>", \
					"<span class='userdanger'>\The [M] [M.attacktext] [src]!</span>")
	add_attack_logs(M, src, "Animal attacked")
	return TRUE

/mob/living/attack_larva(mob/living/carbon/alien/larva/L)
	switch(L.a_intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[L.name] rubs its head against [src].</span>")
			return 0

		else
			if(HAS_TRAIT(L, TRAIT_PACIFISM))
				to_chat(L, "<span class='warning'>You don't want to hurt anyone!</span>")
				return

			L.do_attack_animation(src)
			if(prob(90))
				add_attack_logs(L, src, "Larva attacked")
				visible_message("<span class='danger'>[L.name] bites [src]!</span>", \
						"<span class='userdanger'>[L.name] bites [src]!</span>")
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				return 1
			else
				visible_message("<span class='danger'>[L.name] has attempted to bite [src]!</span>", \
					"<span class='userdanger'>[L.name] has attempted to bite [src]!</span>")
	return 0

/mob/living/attack_alien(mob/living/carbon/alien/humanoid/M)
	switch(M.a_intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")
			return FALSE
		if(INTENT_GRAB)
			grabbedby(M)
			return FALSE
		if(INTENT_HARM)
			if(HAS_TRAIT(M, TRAIT_PACIFISM))
				to_chat(M, "<span class='warning'>You don't want to hurt anyone!</span>")
				return FALSE
			M.do_attack_animation(src)
			return TRUE
		if(INTENT_DISARM)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return TRUE

/mob/living/proc/cult_self_harm(damage)
	return FALSE

/mob/living/shove_impact(mob/living/target, mob/living/attacker)
	if(IS_HORIZONTAL(src))
		return FALSE
	add_attack_logs(attacker, target, "pushed into [src]", ATKLOG_ALL)
	playsound(src, 'sound/weapons/punch1.ogg', 50, 1)
	target.KnockDown(1 SECONDS) // knock them both down
	KnockDown(1 SECONDS)
	return TRUE
