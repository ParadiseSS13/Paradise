/obj/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"
	is_reflectable = TRUE

/obj/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = 1
	stun = 5
	weaken = 5
	stutter = 5
	jitter = 20
	hitsound = 'sound/weapons/tase.ogg'
	range = 7
	//Damage will be handled on the MOB side, to prevent window shattering.

/obj/projectile/energy/electrode/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, 1, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(HULK in C.mutations)
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else if(C.status_flags & CANWEAKEN)
			spawn(5)
				C.do_jitter_animation(jitter)

/obj/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, 1, src)
	..()

/obj/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	irradiate = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/projectile/energy/dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5
	range = 7

/obj/projectile/energy/shuriken
	name = "shuriken"
	icon_state = "toxin"
	damage = 10
	damage_type = TOX
	weaken = 5
	stutter = 5

/obj/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	damage_type = TOX
	nodamage = 0
	weaken = 5
	stutter = 5

/obj/projectile/energy/bolt/large
	damage = 20

/obj/projectile/energy/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	var/chain

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/projectile/energy/shock_revolver/P = BB
	spawn(1)
		P.chain = P.Beam(user,icon_state="purple_lightning",icon = 'icons/effects/effects.dmi',time=1000, maxdistance = 30)

/obj/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		tesla_zap(src, 3, 10000)
	qdel(chain)

/obj/projectile/energy/toxplasma
	name = "plasma bolt"
	icon_state = "energy"
	damage = 20
	damage_type = TOX
	irradiate = 20
