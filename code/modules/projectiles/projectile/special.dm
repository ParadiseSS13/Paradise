/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	alwayslog = TRUE
	damage_type = BURN
	nodamage = 1
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion
	flag = "energy"

/obj/item/projectile/ion/on_hit(var/atom/target, var/blocked = 0)
	..()
	empulse(target, 1, 1, 1, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/item/projectile/ion/weak

/obj/item/projectile/ion/weak/on_hit(atom/target, blocked = 0)
	..()
	empulse(target, 0, 0, 1, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	alwayslog = TRUE
	flag = "bullet"

/obj/item/projectile/bullet/gyro/on_hit(var/atom/target, var/blocked = 0)
	..()
	explosion(target, -1, 0, 2, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/item/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	alwayslog = TRUE
	damage = 60
	flag = "bullet"

/obj/item/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 2, 1, 0, flame_range = 3, cause = "[type] fired by [key_name(firer)]")
	return 1

/obj/item/projectile/temp
	name = "temperature beam"
	icon_state = "temp_4"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 300
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

/obj/item/projectile/temp/New(loc, shot_temp)
	..()
	if(!isnull(shot_temp))
		temperature = shot_temp
	switch(temperature)
		if(501 to INFINITY)
			name = "searing beam"	//if emagged
			icon_state = "temp_8"
		if(400 to 500)
			name = "burning beam"	//temp at which mobs start taking HEAT_DAMAGE_LEVEL_2
			icon_state = "temp_7"
		if(360 to 400)
			name = "hot beam"		//temp at which mobs start taking HEAT_DAMAGE_LEVEL_1
			icon_state = "temp_6"
		if(335 to 360)
			name = "warm beam"		//temp at which players get notified of their high body temp
			icon_state = "temp_5"
		if(295 to 335)
			name = "ambient beam"
			icon_state = "temp_4"
		if(260 to 295)
			name = "cool beam"		//temp at which players get notified of their low body temp
			icon_state = "temp_3"
		if(200 to 260)
			name = "cold beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_1
			icon_state = "temp_2"
		if(120 to 260)
			name = "ice beam"		//temp at which mobs start taking COLD_DAMAGE_LEVEL_2
			icon_state = "temp_1"
		if(-INFINITY to 120)
			name = "freeze beam"	//temp at which mobs start taking COLD_DAMAGE_LEVEL_3
			icon_state = "temp_0"
		else
			name = "temperature beam"//failsafe
			icon_state = "temp_4"


/obj/item/projectile/temp/on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
	..()
	if(isliving(target))
		var/mob/living/M = target
		M.bodytemperature = temperature
		if(temperature > 500)//emagged
			M.adjust_fire_stacks(0.5)
			M.IgniteMob()
			playsound(M.loc, 'sound/effects/bamf.ogg', 50, 0)
	return 1

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

/obj/item/projectile/meteor/Bump(atom/A, yes)
	if(yes)
		return
	if(A == firer)
		loc = A.loc
		return
	playsound(loc, 'sound/effects/meteorimpact.ogg', 40, 1)
	for(var/mob/M in urange(10, src))
		if(!M.stat)
			shake_camera(M, 3, 1)
	qdel(src)

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	flag = "energy"

/obj/item/projectile/energy/floramut/on_hit(var/atom/target, var/blocked = 0)
	..()
	var/mob/living/M = target
	if(ishuman(target))
		var/mob/living/carbon/human/H = M
		if(IS_PLANT in H.dna.species.species_traits)
			if(prob(15))
				M.apply_effect((rand(30,80)),IRRADIATE)
				M.Weaken(5)
				M.visible_message("<span class='warning'>[M] writhes in pain as [M.p_their()] vacuoles boil.</span>", "<span class='userdanger'>You writhe in pain as your vacuoles boil!</span>", "<span class='italics'>You hear the crunching of leaves.</span>")
				if(prob(80))
					randmutb(M)
					domutcheck(M,null)
				else
					randmutg(M)
					domutcheck(M,null)
			else
				M.adjustFireLoss(rand(5,15))
				M.show_message("<span class='warning'>The radiation beam singes you!</span>")
	else if(iscarbon(target))
		M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else
		return 1

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

/obj/item/projectile/energy/florayield/on_hit(var/atom/target, var/blocked = 0)
	..()
	var/mob/M = target
	if(ishuman(target)) //These rays make plantmen fat.
		var/mob/living/carbon/human/H = M
		if(IS_PLANT in H.dna.species.species_traits)
			H.set_nutrition(min(H.nutrition+30, NUTRITION_LEVEL_FULL))
	else if(iscarbon(target))
		M.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else
		return 1


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustBrainLoss(20)
		M.AdjustHallucinate(20)

/obj/item/projectile/clown
	name = "snap-pop"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"

/obj/item/projectile/clown/Bump(atom/A as mob|obj|turf|area)
	do_sparks(3, 1, src)
	new /obj/effect/decal/cleanable/ash(loc)
	visible_message("<span class='warning'>The [name] explodes!</span>","<span class='warning'>You hear a snap!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/obj/item/projectile/beam/wormhole
	name = "bluespace beam"
	icon_state = "spark"
	hitsound = "sparks"
	damage = 0
	var/obj/item/gun/energy/wormhole_projector/gun
	color = "#33CCFF"
	nodamage = TRUE

/obj/item/projectile/beam/wormhole/orange
	name = "orange bluespace beam"
	color = "#FF6600"

/obj/item/projectile/beam/wormhole/New(var/obj/item/ammo_casing/energy/wormhole/casing)
	if(casing)
		gun = casing.gun

/obj/item/projectile/beam/wormhole/on_hit(atom/target)
	if(ismob(target))
		if(is_teleport_allowed(target.z))
			var/turf/portal_destination = pick(orange(6, src))
			do_teleport(target, portal_destination)
		return ..()
	if(!gun)
		qdel(src)
	gun.create_portal(src)

/obj/item/projectile/bullet/frag12
	name ="explosive slug"
	damage = 25
	weaken = 5
	alwayslog = TRUE

/obj/item/projectile/bullet/frag12/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 1)
	return 1

/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 5
	range = 3
	dismemberment = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser

/obj/item/projectile/plasma/on_hit(atom/target)
	. = ..()
	if(ismineralturf(target))
		forcedodge = 1
		var/turf/simulated/mineral/M = target
		M.gets_drilled(firer)
	else
		forcedodge = 0

/obj/item/projectile/plasma/adv
	damage = 7
	range = 5

/obj/item/projectile/plasma/adv/mech
	damage = 10
	range = 9

/obj/item/projectile/energy/teleport
	name = "teleportation burst"
	icon_state = "bluespace"
	damage = 0
	nodamage = 1
	alwayslog = TRUE
	var/teleport_target = null

/obj/item/projectile/energy/teleport/New(loc, tele_target)
	..(loc)
	if(tele_target)
		teleport_target = tele_target

/obj/item/projectile/energy/teleport/on_hit(var/atom/target, var/blocked = 0)
	if(isliving(target))
		if(teleport_target)
			do_teleport(target, teleport_target, 0)//teleport what's in the tile to the beacon
		else
			do_teleport(target, target, 15) //Otherwise it just warps you off somewhere.
	add_attack_logs(firer, target, "Shot with a [type] [teleport_target ? "(Destination: [teleport_target])" : ""]")

/obj/item/projectile/snowball
	name = "snowball"
	icon_state = "snowball"
	hitsound = 'sound/items/dodgeball.ogg'
	damage = 4
	damage_type = BURN

/obj/item/projectile/snowball/on_hit(atom/target)	//chilling
	. = ..()
	if(istype(target, /mob/living))
		var/mob/living/M = target
		M.bodytemperature = max(0, M.bodytemperature - 50)	//each hit will drop your body temp, so don't get surrounded!
		M.ExtinguishMob()	//bright side, they counter being on fire!

/obj/item/projectile/ornament
	name = "ornament"
	icon_state = "ornament-1"
	hitsound = 'sound/effects/glasshit.ogg'
	damage = 7
	damage_type = BRUTE

/obj/item/projectile/ornament/New()
	icon_state = pick("ornament-1", "ornament-2")
	..()

/obj/item/projectile/ornament/on_hit(atom/target)	//knockback
	..()
	if(istype(target, /turf))
		return 0
	var/obj/T = target
	var/throwdir = get_dir(firer,target)
	T.throw_at(get_edge_target_turf(target, throwdir),10,10)
	return 1

/obj/item/projectile/mimic
	name = "googly-eyed gun"
	hitsound = 'sound/weapons/genhit1.ogg'
	damage = 0
	nodamage = 1
	damage_type = BURN
	flag = "melee"
	var/obj/item/gun/stored_gun

/obj/item/projectile/mimic/New(loc, mimic_type)
	..(loc)
	if(mimic_type)
		stored_gun = new mimic_type(src)
		icon = stored_gun.icon
		icon_state = stored_gun.icon_state
		overlays = stored_gun.overlays
		SpinAnimation(20, -1)

/obj/item/projectile/mimic/on_hit(atom/target)
	..()
	var/turf/T = get_turf(src)
	var/obj/item/gun/G = stored_gun
	stored_gun = null
	G.forceMove(T)
	var/mob/living/simple_animal/hostile/mimic/copy/ranged/R = new /mob/living/simple_animal/hostile/mimic/copy/ranged(T, G, firer)
	if(ismob(target))
		R.target = target
