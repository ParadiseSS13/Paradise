
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
/mob/living/proc/run_armor_check(var/def_zone = null, var/attack_flag = "melee", var/absorb_text = null, var/soften_text = null)
	var/armor = getarmor(def_zone, attack_flag)

	if(armor >= 100)
		if(absorb_text)
			src << "<span class='userdanger'>[absorb_text]</span>"
		else
			src << "<span class='userdanger'>Your armor absorbs the blow!</span>"
	else if(armor > 0)
		if(soften_text)
			src << "<span class='userdanger'>[soften_text]</span>"
		else
			src << "<span class='userdanger'>Your armor softens the blow!</span>"
	return armor

//if null is passed for def_zone, then this should return something appropriate for all zones (e.g. area effect damage)
/mob/living/proc/getarmor(var/def_zone, var/type)
	return 0


/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)
	flash_weak_pain()

	//Being hit while using a cloaking device
	var/obj/item/weapon/cloaking_device/C = locate((/obj/item/weapon/cloaking_device) in src)
	if(C && C.active)
		C.attack_self(src)//Should shut it off
		update_icons()
		src << "\blue Your [C.name] was disrupted!"
		Stun(2)

/*
	//Being hit while using a deadman switch
	if(istype(equipped(),/obj/item/device/assembly/signaler))
		var/obj/item/device/assembly/signaler/signaler = equipped()
		if(signaler.deadman && prob(80))
			src.visible_message("\red [src] triggers their deadman's switch!")
			signaler.signal()
*/

/*
	//Stun Beams -- These were commented out, making appropriate changes here. - Dave
	if(istype(P, /obj/item/projectile/beam/stun) || istype(P, /obj/item/projectile/bullet/stunshot))
		stun_effect_act(0, P.agony, def_zone, P)
		src <<"\red You have been hit by [P]!"
		del P
		return

	if(istype(P, /obj/item/projectile/energy/electrode) || istype(P, /obj/item/projectile/bullet/stunshot))
		stun_effect_act(0, P.agony, def_zone, P)
		src <<"\red You have been hit by [P]!"
		del P
		return
*/

	//Armor
	var/armor = run_armor_check(def_zone, P.flag)
	var/proj_sharp = is_sharp(P)
	var/proj_edge = has_edge(P)
	if ((proj_sharp || proj_edge) && prob(getarmor(def_zone, P.flag)))
		proj_sharp = 0
		proj_edge = 0

	if(istype(P, /obj/item/projectile/beam/lightning)) //Stupid snowflake lightning gun.
		if(P.damage >= 200)
			src.dust()

	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, armor)
	return P.on_hit(src, armor, def_zone)

//Handles the effects of "stun" weapons
/mob/living/proc/stun_effect_act(var/stun_amount, var/agony_amount, var/def_zone, var/used_weapon=null)
	flash_pain()

	if (stun_amount)
		Stun(stun_amount)
		Weaken(stun_amount)
		apply_effect(STUTTER, stun_amount)
		apply_effect(EYE_BLUR, stun_amount)

	if (agony_amount)
		apply_damage(agony_amount, HALLOSS, def_zone, 0, used_weapon)
		apply_effect(STUTTER, agony_amount/10)
		apply_effect(EYE_BLUR, agony_amount/10)

/mob/living/proc/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM as mob|obj,var/speed = 5)//Standardization and logging -Sieve
	if(istype(AM,/obj/))
		var/obj/O = AM
		var/zone = ran_zone("chest", 65)//Hits a random part of the body, geared towards the chest
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
			if (W.hitsound && W.throwforce > 0)
				playsound(loc, W.hitsound, 30, 1, -1)

		//run to-hit check here

		var/throw_damage = O.throwforce*(speed/5)

		//var/miss_chance = 15
		//if (O.throw_source)
			//var/distance = get_dist(O.throw_source, loc)
			//miss_chance = min(15*(distance-2), 0)
		/*
		if (prob(miss_chance))
			visible_message("\blue \The [O] misses [src] narrowly!")
			return
		*/
		src.visible_message("\red [src] has been hit by [O].")
		var/armor = run_armor_check(zone, "melee")

		apply_damage(throw_damage, dtype, zone, armor, is_sharp(O), has_edge(O), O)

		O.throwing = 0		//it hit, so stop moving

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a [O], thrown by [M.name] ([assailant.ckey])</font>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O]</font>")
				if(!istype(src,/mob/living/simple_animal/mouse))
					msg_admin_attack("[src.name] ([src.ckey]) was hit by a [O], thrown by [M.name] ([assailant.ckey])[isAntag(M) ? "(ANTAG)" : ""] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

		// Begin BS12 momentum-transfer code.
		if(O.throw_source && speed >= 15)
			var/obj/item/weapon/W = O
			var/momentum = speed/2
			var/dir = get_dir(O.throw_source, src)

			visible_message("\red [src] staggers under the impact!","\red You stagger under the impact!")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!W || !src) return

			if(W.sharp) //Projectile is suitable for pinning.
				//Handles embedding for non-humans and simple_animals.
				O.loc = src
				src.embedded += O

				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='warning'>You are pinned to the wall by [O]!</span>")
					src.anchored = 1
					src.pinned += O

/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == "harm")
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
		add_logs(M.occupant, src, "attacked", object=M, addition="(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
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
		src.AddLuminosity(3)
		update_fire()

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		src.AddLuminosity(-3)
		update_fire()

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
    fire_stacks = Clamp(fire_stacks + add_fire_stacks, min = -20, max = 20)

/mob/living/proc/handle_fire()
	if(fire_stacks < 0)
		fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return 1
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.oxygen < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)

/mob/living/fire_act()
	adjust_fire_stacks(0.5)
	IgniteMob()

//Mobs on Fire end

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

	add_logs(user, src, "grabbed", addition="passively")

	var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(user, src)
	if(buckled)
		user << "<span class='notice'>You cannot grab [src], \he is buckled in!</span>"
	if(!G)	//the grab will delete itself in New if src is anchored
		return 0
	user.put_in_active_hand(G)
	G.synch()
	LAssailant = user

	playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	if(!supress_message)
		visible_message("<span class='warning'>[user] has grabbed [src] passively!</span>")
