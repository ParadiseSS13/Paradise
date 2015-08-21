/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"


	on_hit(var/atom/target, var/blocked = 0)
		empulse(target, 1, 1)
		return 1


/obj/item/projectile/ion/weak

/obj/item/projectile/ion/weak/on_hit(atom/target, blocked = 0)
	empulse(target, 0, 0)
	return 1

/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"
	sharp = 1
	edge = 1

	on_hit(var/atom/target, var/blocked = 0)
		explosion(target, -1, 0, 2)
		return 1

/obj/item/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60
	flag = "bullet"

/obj/item/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 2, 1, 0, flame_range = 3)
	return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 300

	on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
		if(istype(target, /mob/living))
			var/mob/M = target
			M.bodytemperature = temperature
		return 1

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "smallf"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return

		sleep(-1) //Might not be important enough for a sleep(-1) but the sleep/spawn itself is necessary thanks to explosions and metoerhits

		if(src)//Do not add to this if() statement, otherwise the meteor won't delete them
			if(A)

				A.ex_act(2)
				playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)

				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))\
						shake_camera(M, 3, 1)
				qdel(src)
				return 1
		else
			return 0

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/living/M = target
		if(ishuman(target))
			var/mob/living/carbon/human/H = M
			if((H.species.flags & IS_PLANT) && (M.nutrition < 500))
				if(prob(15))
					M.apply_effect((rand(30,80)),IRRADIATE)
					M.Weaken(5)
					for (var/mob/V in viewers(src))
						V.show_message("\red [M] writhes in pain as \his vacuoles boil.", 3, "\red You hear the crunching of leaves.", 2)
				if(prob(35))
				//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
				//		V.show_message("\red [M] is mutated by the radiation beam.", 3, "\red You hear the snapping of twigs.", 2)
					if(prob(80))
						randmutb(M)
						domutcheck(M,null)
					else
						randmutg(M)
						domutcheck(M,null)
				else
					M.adjustFireLoss(rand(5,15))
					M.show_message("\red The radiation beam singes you!")
				//	for (var/mob/V in viewers(src))
				//		V.show_message("\red [M] is singed by the radiation beam.", 3, "\red You hear the crackle of burning leaves.", 2)
		else if(istype(target, /mob/living/carbon/))
		//	for (var/mob/V in viewers(src))
		//		V.show_message("The radiation beam dissipates harmlessly through [M]", 3)
			M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		else
			return 1

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/target, var/blocked = 0)
		var/mob/M = target
		if(ishuman(target)) //These rays make plantmen fat.
			var/mob/living/carbon/human/H = M
			if((H.species.flags & IS_PLANT) && (M.nutrition < 500))
				M.nutrition += 30
		else if (istype(target, /mob/living/carbon/))
			M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
		else
			return 1


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

	on_hit(var/atom/target, var/blocked = 0)
		if(ishuman(target))
			var/mob/living/carbon/human/M = target
			M.adjustBrainLoss(20)
			M.hallucination += 20

/obj/item/projectile/clown
	name = "snap-pop"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"

	Bump(atom/A as mob|obj|turf|area)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		new /obj/effect/decal/cleanable/ash(src.loc)
		src.visible_message("\red The [src.name] explodes!","\red You hear a snap!")
		playsound(src, 'sound/effects/snap.ogg', 50, 1)
		qdel(src)

/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 10
	damage_type = BRUTE
	flag = "bomb"
	range = 3

obj/item/projectile/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
		damage *= 4
	..()

/obj/item/projectile/kinetic/Range()
	range--
	if(range <= 0)
		new /obj/item/effect/kinetic_blast(src.loc)
		qdel(src)

/obj/item/projectile/kinetic/on_hit(atom/target)
	. = ..()
	var/turf/target_turf= get_turf(target)
	if(istype(target_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = target_turf
		M.gets_drilled(firer)
	new /obj/item/effect/kinetic_blast(target_turf)

/obj/item/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = 4.1

/obj/item/effect/kinetic_blast/New()
	spawn(4)
		qdel(src)

/obj/item/projectile/bullet/frag12
	name ="explosive slug"
	damage = 25
	weaken = 5

/obj/item/projectile/bullet/frag12/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 1)
	return 1

/obj/item/projectile/energy/teleport
	name = "teleportation burst"
	icon_state = "bluespace"
	damage = 0
	nodamage = 1

/obj/item/projectile/energy/teleport/on_hit(var/atom/target, var/blocked = 0)
	if(isliving(target))
		var/obj/item/device/radio/beacon/teletarget = null
		for(var/obj/machinery/computer/teleporter/com in machines)
			if(com.target)
				teletarget = com.target
		if(teletarget)
			do_teleport(target, teletarget, 0)//teleport what's in the tile to the beacon
		else
			do_teleport(target, target, 15) //Otherwise it just warps you off somewhere.

/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 5
	range = 3

/obj/item/projectile/plasma/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	if(environment)
		var/pressure = environment.return_pressure()
		if(pressure < 30)
			name = "full strength plasma blast"
			damage *= 3
	..()

/obj/item/projectile/plasma/on_hit(atom/target)
	. = ..()
	if(istype(target, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = target
		M.gets_drilled(firer)
		range = max(range - 1, 1)
		return -1

/obj/item/projectile/plasma/adv
	range = 5

/obj/item/projectile/plasma/adv/mech
	damage = 10
	range = 6
