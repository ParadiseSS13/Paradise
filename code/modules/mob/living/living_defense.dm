
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
/mob/living/proc/run_armor_check(var/def_zone = null, var/attack_flag = "melee", var/absorb_text = null, var/soften_text = null, armour_penetration, penetrated_text)
	var/armor = getarmor(def_zone, attack_flag)

	//the if "armor" check is because this is used for everything on /living, including humans
	if(armor && armor < 100 && armour_penetration) // Armor with 100+ protection can not be penetrated for admin items
		armor = max(0, armor - armour_penetration)
		if(penetrated_text)
			to_chat(src, "<span class='userdanger'>[penetrated_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>Your armor was penetrated!</span>")

	if(armor >= 100)
		if(absorb_text)
			to_chat(src, "<span class='userdanger'>[absorb_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>Your armor absorbs the blow!</span>")
	else if(armor > 0)
		if(soften_text)
			to_chat(src, "<span class='userdanger'>[soften_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>Your armor softens the blow!</span>")
	return armor

//if null is passed for def_zone, then this should return something appropriate for all zones (e.g. area effect damage)
/mob/living/proc/getarmor(var/def_zone, var/type)
	return 0

/mob/living/proc/is_mouth_covered(head_only = FALSE, mask_only = FALSE)
	return FALSE

/mob/living/proc/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	return FALSE

/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)
	//Armor
	var/armor = run_armor_check(def_zone, P.flag, armour_penetration = P.armour_penetration)
	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, armor)
		if(P.dismemberment)
			check_projectile_dismemberment(P, def_zone)
	return P.on_hit(src, armor, def_zone)

/mob/living/proc/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	return 0

/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, tesla_shock = 0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
	if(throwforce && w_class)
		return Clamp((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
	else if(w_class)
		return Clamp(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
	else
		return 0

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = 1, blocked = 0, datum/thrownthing/throwingdatum)//Standardization and logging -Sieve
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		var/zone = ran_zone("chest", 65)//Hits a random part of the body, geared towards the chest
		var/dtype = BRUTE
		var/volume = I.get_volume_by_throwforce_and_or_w_class()
		if(istype(I, /obj/item))
			var/obj/item/W = I
			dtype = W.damtype
			if(W.throwforce > 0) //If the weapon's throwforce is greater than zero...
				if(W.hitsound) //...and hitsound is defined...
					playsound(loc, W.hitsound, volume, 1, -1) //...play the weapon's hitsound.
				else //Otherwise, if hitsound isn't defined...
					playsound(loc, 'sound/weapons/genhit1.ogg', volume, 1, -1) //...play genhit1.ogg.

		else if(I.throwforce > 0) //Otherwise, if the item doesn't have a throwhitsound and has a throwforce greater than zero...
			playsound(loc, 'sound/weapons/genhit1.ogg', volume, 1, -1)//...play genhit1.ogg
		if(!I.throwforce)// Otherwise, if the item's throwforce is 0...
			playsound(loc, 'sound/weapons/throwtap.ogg', 1, volume, -1)//...play throwtap.ogg.
		if(!blocked)
			visible_message("<span class='danger'>[src] has been hit by [I].</span>",
							"<span class='userdanger'>[src] has been hit by [I].</span>")
			var/armor = run_armor_check(zone, "melee", "Your armor has protected your [parse_zone(zone)].", "Your armor has softened hit to your [parse_zone(zone)].", I.armour_penetration)
			apply_damage(I.throwforce, dtype, zone, armor, is_sharp(I), I)
			if(I.thrownby)
				add_attack_logs(I.thrownby, src, "Hit with thrown [I]")
		else
			return 1
	else
		playsound(loc, 'sound/weapons/genhit1.ogg', 50, 1, -1) //...play genhit1.ogg.)
	..()


/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(M.damtype == "brute")
			step_away(src,M,15)
		switch(M.damtype)
			if("brute")
				Paralyse(1)
				take_overall_damage(rand(M.force/2, M.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			if("fire")
				take_overall_damage(0, rand(M.force/2, M.force))
				playsound(src, 'sound/items/welder.ogg', 50, 1)
			if("tox")
				M.mech_toxin_damage(src)
			else
				return
		updatehealth("mech melee attack")
		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[src] has been hit by [M.name].</span>", \
						"<span class='userdanger'>[src] has been hit by [M.name].</span>")
		add_attack_logs(M.occupant, src, "Mecha-meleed with [M]")
	else
		step_away(src,M)
		add_attack_logs(M.occupant, src, "Mecha-pushed with [M]", ATKLOG_ALL)
		M.occupant_message("<span class='warning'>You push [src] out of the way.</span>")
		visible_message("<span class='warning'>[M] pushes [src] out of the way.</span>")
		return

//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = 1
		visible_message("<span class='warning'>[src] catches fire!</span>", \
						"<span class='userdanger'>You're set on fire!</span>")
		set_light(light_range + 3,l_color = "#ED9200")
		throw_alert("fire", /obj/screen/alert/fire)
		update_fire()
		return 1
	return 0

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
	fire_stacks = Clamp(fire_stacks + add_fire_stacks, -20, 20)
	if(on_fire && fire_stacks <= 0)
		ExtinguishMob()

/mob/living/proc/handle_fire()
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks + 1)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return 1
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.1) //the fire is slowly consumed
	else
		ExtinguishMob()
		return
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.oxygen < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)

/mob/living/fire_act()
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

//Mobs on Fire end

/mob/living/water_act(volume, temperature)
	if(volume >= 20)	fire_stacks -= 0.5
	if(volume >= 50)	fire_stacks -= 1



//This is called when the mob is thrown into a dense turf
/mob/living/proc/turf_collision(var/turf/T, var/speed)
	src.take_organ_damage(speed*5)

/mob/living/proc/near_wall(var/direction,var/distance=1)
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
		return 0
	if(!(status_flags & CANPUSH))
		return 0

	for(var/obj/item/grab/G in grabbed_by)
		if(G.assailant == user)
			to_chat(user, "<span class='notice'>You already grabbed [src].</span>")
			return

	add_attack_logs(user, src, "Grabbed passively", ATKLOG_ALL)

	var/obj/item/grab/G = new /obj/item/grab(user, src)
	if(buckled)
		to_chat(user, "<span class='notice'>You cannot grab [src]; [p_they()] [p_are()] buckled in!</span>")
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

/mob/living/attack_slime(mob/living/carbon/slime/M)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim)
		return // can't attack while eating!

	if(stat != DEAD)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>", \
				"<span class='userdanger'>The [M.name] glomps [src]!</span>")

		if(M.powerlevel > 0)
			var/stunprob = M.powerlevel * 7 + 10  // 17 at level 1, 80 at level 10
			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				visible_message("<span class='danger'>The [M.name] has shocked [src]!</span>", \
				"<span class='userdanger'>The [M.name] has shocked [src]!</span>")

				do_sparks(5, 1, src)
				return 1
	add_attack_logs(src, M, "Slime'd")
	return

/mob/living/attack_animal(mob/living/simple_animal/M)
	if((M.a_intent == INTENT_HELP && M.ckey) || M.melee_damage_upper == 0)
		M.custom_emote(1, "[M.friendly] [src].")
		return 0
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>\The [M] [M.attacktext] [src]!</span>", \
						"<span class='userdanger'>\The [M] [M.attacktext] [src]!</span>")
		add_attack_logs(M, src, "Animal attacked")
		return 1

/mob/living/attack_larva(mob/living/carbon/alien/larva/L)
	switch(L.a_intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[L.name] rubs its head against [src].</span>")
			return 0

		else
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
			M.do_attack_animation(src)
			return TRUE
		if(INTENT_DISARM)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return TRUE

//defined here, overridden for humans in human_defense. By default, living mobs don't get to block anything
/mob/living/proc/check_block()
	return FALSE