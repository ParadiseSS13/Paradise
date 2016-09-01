
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


/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)
	//Armor
	var/armor = run_armor_check(def_zone, P.flag, armour_penetration = P.armour_penetration)
	var/proj_sharp = is_sharp(P)
	var/proj_edge = has_edge(P)
	if((proj_sharp || proj_edge) && prob(getarmor(def_zone, P.flag)))
		proj_sharp = 0
		proj_edge = 0

	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, armor)
	return P.on_hit(src, armor, def_zone)

/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, tesla_shock = 0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM as mob|obj,var/speed = 5)//Standardization and logging -Sieve
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		var/zone = ran_zone("chest", 65)//Hits a random part of the body, geared towards the chest
		var/dtype = BRUTE
		if(istype(I, /obj/item/weapon))
			var/obj/item/weapon/W = I
			dtype = W.damtype
			if(W.hitsound && W.throwforce > 0)
				playsound(loc, W.hitsound, 30, 1, -1)

		//run to-hit check here

		var/throw_damage = I.throwforce*(speed/5)

		src.visible_message("\red [src] has been hit by [I].")
		var/armor = run_armor_check(zone, "melee", "Your armor has protected your [parse_zone(zone)].", "Your armor has softened hit to your [parse_zone(zone)].", I.armour_penetration)

		apply_damage(throw_damage, dtype, zone, armor, is_sharp(I), has_edge(I), I)

		I.throwing = 0		//it hit, so stop moving

		if(ismob(I.thrower))
			var/mob/M = I.thrower
			if(M)
				attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a [I], thrown by [key_name(M)]</font>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [key_name(src)] with a thrown [I]</font>")
				if(!istype(src,/mob/living/simple_animal/mouse))
					msg_admin_attack("[key_name_admin(src)] was hit by a [I], thrown by [key_name_admin(M)]")

		// Begin BS12 momentum-transfer code.
		if(I.throw_source && speed >= 15)
			var/obj/item/weapon/W = I
			var/momentum = speed/2
			var/dir = get_dir(I.throw_source, src)

			visible_message("\red [src] staggers under the impact!","\red You stagger under the impact!")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!W || !src) return

			if(W.sharp) //Projectile is suitable for pinning.
				//Handles embedding for non-humans and simple_animals.
				I.loc = src
				embedded += I

				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message("<span class='warning'>[src] is pinned to the wall by [I]!</span>","<span class='warning'>You are pinned to the wall by [I]!</span>")
					src.anchored = 1
					src.pinned += I

/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == I_HARM)
		if(M.damtype == "brute")
			step_away(src,M,15)
		switch(M.damtype)
			if("brute")
				Paralyse(1)
				take_overall_damage(rand(M.force/2, M.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			if("fire")
				take_overall_damage(0, rand(M.force/2, M.force))
				playsound(src, 'sound/items/Welder.ogg', 50, 1)
			if("tox")
				M.mech_toxin_damage(src)
			else
				return
		updatehealth()
		M.occupant_message("<span class='danger'>You hit [src].</span>")
		visible_message("<span class='danger'>[src] has been hit by [M.name].</span>", \
						"<span class='userdanger'>[src] has been hit by [M.name].</span>")
		attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked by \the [M] controlled by [key_name(M.occupant)] (INTENT: [uppertext(M.occupant.a_intent)])</font>")
		M.occupant.attack_log += text("\[[time_stamp()]\] <font color='red'>Attacked [src] with \the [M] (INTENT: [uppertext(M.occupant.a_intent)])</font>")
		msg_admin_attack("[key_name_admin(M.occupant)] attacked [key_name_admin(src)] with \the [M] (INTENT: [uppertext(M.occupant.a_intent)])")

	else

		step_away(src,M)
		add_logs(M.occupant, src, "pushed", object=M, admin=0)
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

/mob/living/proc/grabbedby(mob/living/carbon/user,var/supress_message = 0)
	if(user == src || anchored)
		return 0
	if(!(status_flags & CANPUSH))
		return 0

	for(var/obj/item/weapon/grab/G in src.grabbed_by)
		if(G.assailant == user)
			to_chat(user, "<span class='notice'>You already grabbed [src].</span>")
			return

	add_logs(user, src, "grabbed", addition="passively")

	var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(user, src)
	if(buckled)
		to_chat(user, "<span class='notice'>You cannot grab [src], \he is buckled in!</span>")
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

/mob/living/incapacitated()
	if(stat || paralysis || stunned || weakened || restrained())
		return 1
