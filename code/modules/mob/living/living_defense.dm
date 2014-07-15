
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
	var/absorb = 0
	if(prob(armor))
		absorb += 1
	if(prob(armor))
		absorb += 1
	if(absorb >= 2)
		if(absorb_text)
			show_message("[absorb_text]")
		else
			show_message("\red Your armor absorbs the blow!")
		return 2
	if(absorb == 1)
		if(absorb_text)
			show_message("[soften_text]",4)
		else
			show_message("\red Your armor softens the blow!")
		return 1
	return 0


//if null is passed for def_zone, then this should return something appropriate for all zones (e.g. area effect damage)
/mob/living/proc/getarmor(var/def_zone, var/type)
	return 0


/mob/living/bullet_act(var/obj/item/projectile/P, var/def_zone)
	var/obj/item/weapon/cloaking_device/C = locate((/obj/item/weapon/cloaking_device) in src)
	if(C && C.active)
		C.attack_self(src)//Should shut it off
		update_icons()
		src << "\blue Your [C.name] was disrupted!"
		Stun(2)

	flash_weak_pain()
/*
	if(istype(equipped(),/obj/item/device/assembly/signaler))
		var/obj/item/device/assembly/signaler/signaler = equipped()
		if(signaler.deadman && prob(80))
			src.visible_message("\red [src] triggers their deadman's switch!")
			signaler.signal()
*/
	var/absorb = run_armor_check(def_zone, P.flag)
	var/proj_sharp = is_sharp(P)
	var/proj_edge = has_edge(P)
	if ((proj_sharp || proj_edge) && prob(getarmor(def_zone, P.flag)))
		proj_sharp = 0
		proj_edge = 0

	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, absorb, 0, P, sharp=proj_sharp, edge=proj_edge)
	P.on_hit(src, absorb, def_zone)
	if(istype(P, /obj/item/projectile/beam/lightning))
		if(P.damage >= 200)
			src.dust()
	return absorb

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM as mob|obj,var/speed = 5)//Standardization and logging -Sieve
	if(istype(AM,/obj/))
		var/obj/O = AM
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
			if (W.hitsound && W.throwforce > 0)
				playsound(loc, W.hitsound, 30, 1, -1)

		//run to-hit check here

		var/throw_damage = O.throwforce*(speed/5)

		var/zone
		if (istype(O.thrower, /mob/living))
			var/mob/living/L = O.thrower
			zone = check_zone(L.zone_sel.selecting)
		else
			zone = ran_zone("chest",75)	//Hits a random part of the body, geared towards the chest

		//def_zone = get_zone_with_miss_chance(zone, src, 15*AM.throwing_dist_travelled)
		if (O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			zone = get_zone_with_miss_chance(zone, src, min(15*(distance-2), 0))
		else
			zone = get_zone_with_miss_chance(zone, src, 15)

		if(!zone)
			visible_message("\blue \The [O] misses [src] narrowly!")
			return

		O.throwing = 0		//it hit, so stop moving

		if (istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			if (H.check_shields(throw_damage, "[O]"))
				return

		src.visible_message("\red [src] has been hit by [O].")
		var/armor = run_armor_check(zone, "melee", "Your armor has protected your [zone].", "Your armor has softened the hit to your [zone].")

		if(armor < 2)
			apply_damage(throw_damage, dtype, zone, armor, is_sharp(O), has_edge(O), O)

		if(!O.fingerprintslast)
			return

		var/client/assailant = directory[ckey(O.fingerprintslast)]
		if(assailant && assailant.mob && istype(assailant.mob,/mob))
			var/mob/M = assailant.mob

			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a thrown [O], last touched by [M.name] ([assailant.ckey])</font>")
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O]</font>")
			if(src.ckey)
				msg_admin_attack("[src.name] ([src.ckey]) was hit by a thrown [O], last touched by [M.name] ([assailant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")
			if(!iscarbon(M))
				src.LAssailant = null
			else
				src.LAssailant = M

			// Begin BS12 momentum-transfer code.

			if(speed >= 15)
				var/obj/item/weapon/W = O
				var/momentum = speed/2
				var/dir = get_dir(M,src)	//TODO: store the location of the thrower and move this out of the fingerprintslast block

				visible_message("\red [src] staggers under the impact!","\red You stagger under the impact!")
				src.throw_at(get_edge_target_turf(src,dir),1,momentum)

				if(!W || !src) return

				if(istype(W.loc,/mob/living) && W.sharp) //Projectile is embedded and suitable for pinning.

					if(!istype(src,/mob/living/carbon/human)) //Handles embedding for non-humans and simple_animals.
						O.loc = src
						src.embedded += O

					var/turf/T = near_wall(dir,2)

					if(T)
						src.loc = T
						visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='warning'>You are pinned to the wall by [O]!</span>")
						src.anchored = 1
						src.pinned += O

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

//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0)
		on_fire = 1
		update_fire()

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
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

	var/oxy=0
	var/turf/T=loc
	if(istype(T))
		if(istype(T,/turf/space))
			ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
			return 1
		var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
		if(G)
			oxy=G.oxygen
	if(oxy < 10 || fire_stacks <= 0)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return 1
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)

/mob/living/fire_act()
	adjust_fire_stacks(5)
	if(fire_stacks > 9 && !on_fire)
		IgniteMob()

//Mobs on Fire end
