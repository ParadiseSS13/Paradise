/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"
	reflectability = REFLECTABILITY_ENERGY

/obj/item/projectile/energy/electrode
	name = "electrode"
	color = "#FFFF00"
	nodamage = 1
	weaken = 10 SECONDS
	stutter = 10 SECONDS
	jitter = 40 SECONDS
	hitsound = 'sound/weapons/tase.ogg'
	range = 7
	//Damage will be handled on the MOB side, to prevent window shattering.

/obj/item/projectile/energy/electrode/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, 1, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK, 33)
		if(HAS_TRAIT(C, TRAIT_HULK))
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else if(C.status_flags & CANWEAKEN)
			spawn(5)
				C.Jitter(jitter)

/obj/item/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, 1, src)
	..()

/obj/item/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	irradiate = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	damage_type = TOX
	stamina = 60
	eyeblur = 20 SECONDS
	knockdown = 2 SECONDS
	slur = 10 SECONDS

/obj/item/projectile/energy/bolt/large
	damage = 20

#define BSG_BASE_DAMAGE 90

/obj/item/projectile/energy/bsg
	name = "orb of pure bluespace energy"
	icon_state = "bluespace"
	impact_effect_type = /obj/effect/temp_visual/bsg_kaboom
	damage = BSG_BASE_DAMAGE
	armor_penetration_flat = 50
	range = 9
	knockdown = 4 SECONDS //This is going to knock you off your feet
	eyeblur = 10 SECONDS
	speed = 2
	alwayslog = TRUE

/obj/item/ammo_casing/energy/bsg/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/energy/bsg/P = BB
	addtimer(CALLBACK(P, TYPE_PROC_REF(/obj/item/projectile/energy/bsg, make_chain), P, user), 1)

/obj/item/projectile/energy/bsg/proc/make_chain(obj/item/projectile/P, mob/user)
	P.chain = P.Beam(user, icon_state = "sm_arc_supercharged", icon = 'icons/effects/beam.dmi', time = 10 SECONDS, maxdistance = 30)

/obj/item/projectile/energy/bsg/on_hit(atom/target)
	. = ..()
	kaboom(target)
	qdel(src)

/obj/item/projectile/energy/bsg/on_range()
	kaboom()
	new /obj/effect/temp_visual/bsg_kaboom(loc)
	..()

/obj/item/projectile/energy/bsg/proc/kaboom(atom/target)
	// If a lens is modifying the damage of the projectile, the AOE should be impacted as well
	var/damage_multiplier = damage / BSG_BASE_DAMAGE
	playsound(src, 'sound/weapons/bsg_explode.ogg', 75, TRUE)
	for(var/mob/living/M in hearers(7, src)) //No stuning people with thermals through a wall.
		if(M == target)
			continue
		var/floored = FALSE
		if(HAS_TRAIT(M, TRAIT_BSG_IMMUNE))
			to_chat(M, "<span class='notice'>Your B.S.G deploys an energy shield to project you from [src]'s explosion.</span>")
			new /obj/effect/temp_visual/at_shield(get_turf(M), M)
			continue
		var/distance = (1 + get_dist(M, src))
		if(prob(min(400 / distance, 100))) //100% chance to hit with the blast up to 3 tiles, after that chance to hit is 80% at 4 tiles, 66.6% at 5, 57% at 6, and 50% at 7
			if(prob(min(200 / distance, 100)))//100% chance to upgraded to a stun as well at a direct hit, 100% at 1 tile, 66% at 2, 50% at 3, 40% at 4, 33% at 5, 28.5% at 6, and finaly 25% at 7. This is calculated after the first hit however.
				floored = TRUE
			M.apply_damage((rand(60, 80) * (1.1 - distance / 10)) * damage_multiplier, BURN) //reduced by 10% per tile
			add_attack_logs(firer, M, "Hit heavily by [src]")
			if(floored)
				to_chat(M, "<span class='userdanger'>You see a flash of briliant blue light as [src] explodes, knocking you to the ground and burning you!</span>")
				M.KnockDown(4 SECONDS)
			else
				to_chat(M, "<span class='userdanger'>You see a flash of briliant blue light as [src] explodes, burning you!</span>")
			if(immolate)
				M.adjust_fire_stacks(immolate)
				M.IgniteMob()
		else
			to_chat(M, "<span class='userdanger'>You feel the heat of the explosion of [src], but the blast mostly misses you.</span>")
			add_attack_logs(firer, M, "Hit lightly by [src]")
			M.apply_damage(rand(20, 25) * damage_multiplier, BURN)
		if(ROLE_BLOB in M.faction)
			M.apply_damage(rand(20, 25) * damage_multiplier, BURN) //Ensures it clears all blob spores on the screen without fail.

#undef BSG_BASE_DAMAGE

/obj/item/projectile/energy/weak_plasma
	name = "plasma bolt"
	icon_state = "plasma_light"
	damage = 12.5

/obj/item/projectile/homing/charged_plasma
	name = "charged plasma bolt"
	icon_state = "plasma_heavy"
	damage = 45
	damage_type = BURN
	flag = "energy"
	armor_penetration_flat = 10 // It can have a little armor pen, as a treat. Bigger than it looks, energy armor is often low.
	shield_buster = TRUE
	var/reached_target = FALSE

/obj/item/projectile/homing/charged_plasma/pixel_move(trajectory_multiplier)
	homing_active = FALSE
	if(isturf(original))
		return ..() //It gets weird if it is a turf. Turfs don't move anyway.
	if(reached_target || get_turf(original) == get_turf(src))
		reached_target = TRUE
		return ..()
	var/fake_Angle = Angle
	if(fake_Angle < 0)
		fake_Angle += 360
	if(abs(get_angle(get_turf(src), original) - fake_Angle) > 45)
		return ..()
	homing_active = TRUE
	..()


#define ARC_REVOLVER_BASE_DAMAGE 10

/obj/item/projectile/energy/arc_revolver
	name = "arc emitter"
	icon_state = "plasma_light"
	damage = ARC_REVOLVER_BASE_DAMAGE
	var/charge_number = null

/obj/item/projectile/energy/arc_revolver/on_hit(atom/target)
	. = ..()
	for(var/obj/effect/E in target)
		if(istype(E, /obj/effect/abstract/arc_revolver))
			var/obj/effect/abstract/arc_revolver/A = E
			A.charge_numbers += charge_number
			A.duration += 10 SECONDS
			qdel(src)
			return
	new /obj/effect/abstract/arc_revolver(target, charge_number, immolate, damage)
	qdel(src)


/obj/effect/abstract/arc_revolver
	name = "arc emitter"
	desc = "Emits arcs. What more do you want?"
	var/duration = 10 SECONDS
	var/list/charge_numbers = list()
	var/list/chains = list()
	var/successfulshocks = 0
	var/wait_for_three = 0
	var/our_immolate = 0
	var/damage_multiplier = 1

/obj/effect/abstract/arc_revolver/Initialize(mapload, charge_number, immolate, damage)
	. = ..()
	charge_numbers += charge_number
	START_PROCESSING(SSfastprocess, src)
	GLOB.arc_emitters += src
	our_immolate = immolate / 5
	damage_multiplier = damage / ARC_REVOLVER_BASE_DAMAGE
	build_chains()

/obj/effect/abstract/arc_revolver/proc/build_chains()
	for(var/obj/effect/abstract/arc_revolver/A in GLOB.arc_emitters)
		if(A == src)
			continue
		for(var/chain in chains)
			var/datum/beam/B = chain
			if(B.target == A.loc)
				continue
		for(var/num1 in A.charge_numbers)
			for(var/num2 in charge_numbers)
				if(num1 - num2 == -1) //Don't ABS it, we only want one chain made, not 2.
					var/dont = FALSE
					for(var/datum/beam/B as anything in chains)
						if(B.target == A.loc)
							dont = TRUE
							break
					if(!dont && (A.loc in view(7, loc)))
						chains += loc.Beam(A.loc, "lightning[rand(1, 12)]", 'icons/effects/effects.dmi', time = 10 SECONDS, maxdistance = 7, beam_type = /obj/effect/ebeam/chain)


/obj/effect/abstract/arc_revolver/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.arc_emitters -= src
	removechains()
	return ..()

/obj/effect/abstract/arc_revolver/process()// We want this to not be on crossed, or people fucking die when yeeted diagonally. We want this fast process to be faster, but not doing for loops every tick. Thus, every 3 fastproccesses
	duration -= 2 // 5 ticks per second, second is 10
	if(duration <= 0)
		qdel(src)
	wait_for_three++
	if(wait_for_three >= 3) //Every 0.6 seconds.
		wait_for_three = 0
		cleardeletedchains()
		build_chains()
		if(successfulshocks > 3)
			successfulshocks = 0
		if(shockallchains())
			successfulshocks++

/obj/effect/abstract/arc_revolver/proc/shockallchains()
	. = 0
	cleardeletedchains()
	if(length(chains))
		for(var/chain in chains)
			. += chainshock(chain)

/obj/effect/abstract/arc_revolver/proc/chainshock(datum/beam/B)
	. = 0
	var/list/turfs = list()
	for(var/obj/effect/ebeam/chainpart as anything in B.elements)
		if(chainpart && chainpart.x && chainpart.y && chainpart.z)
			var/turf/T1 = get_turf_pixel(chainpart)
			turfs |= T1
			if(T1 != get_turf(B.origin) && T1 != get_turf(B.target))
				for(var/turf/TU in circlerange(T1, 1))
					turfs |= TU
	for(var/turf/T as anything in turfs)
		for(var/mob/living/L in T)
			if(L.stat != DEAD)
				if(successfulshocks > 2)
					L.visible_message(
						"<span class='danger'>[L] was shocked by the lightning chain!</span>", \
						"<span class='userdanger'>You are shocked by the lightning chain!</span>", \
						"<span class='italics'>You hear a heavy electrical crack.</span>" \
					)
				var/damage = (2 - isliving(B.origin) + 2 - isliving(B.target)) * damage_multiplier //Damage is upped depending if the origin is a mob or not. Wall to wall hurts more than mob to wall, or mob to mob
				L.adjustFireLoss(damage) //time to die
				if(our_immolate)
					L.adjust_fire_stacks(our_immolate)
					L.IgniteMob()
				. = 1

/obj/effect/abstract/arc_revolver/proc/removechains()
	if(length(chains))
		for(var/chain in chains)
			qdel(chain)


/obj/effect/abstract/arc_revolver/proc/cleardeletedchains()
	if(length(chains))
		for(var/chain in chains)
			var/datum/cd = chain
			if(!chain || QDELETED(cd))
				chains -= chain

#undef ARC_REVOLVER_BASE_DAMAGE
