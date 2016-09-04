/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	flag = "bullet"
	embed = 1
	sharp = 1
	hitsound_wall = "ricochet"

/obj/item/projectile/bullet/weakbullet //beanbag, heavy stamina damage
	damage = 5
	stamina = 80

/obj/item/projectile/bullet/weakbullet/rubber //beanbag that shells that don't embed
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/weakbullet/booze
	embed = 0

/obj/item/projectile/bullet/weakbullet/booze/on_hit(atom/target, blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.dizziness += 20
		M.slurring += 20
		M.confused += 20
		M.eye_blurry += 20
		M.drowsyness += 20
		for(var/datum/reagent/ethanol/A in M.reagents.reagent_list)
			M.AdjustParalysis(2)
			M.dizziness += 10
			M.slurring += 10
			M.confused += 10
			M.eye_blurry += 10
			M.drowsyness += 10
			A.volume += 5 //Because we can

/obj/item/projectile/bullet/weakbullet2  //detective revolver instastuns, but multiple shots are better for keeping punks down
	damage = 5
	weaken = 3
	stamina = 60

/obj/item/projectile/bullet/weakbullet2/rubber //detective's bullets that don't embed
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/weakbullet3
	damage = 20


/obj/item/projectile/bullet/toxinbullet
	damage = 15
	damage_type = TOX

/obj/item/projectile/bullet/incendiary

/obj/item/projectile/bullet/incendiary/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(4)
		M.IgniteMob()

/obj/item/projectile/bullet/incendiary/firebullet
	damage = 10

/obj/item/projectile/bullet/armourpiercing
	damage = 17
	armour_penetration = 10

/obj/item/projectile/bullet/pellet
	name = "pellet"
	damage = 15

/obj/item/projectile/bullet/pellet/weak
	damage = 6

/obj/item/projectile/bullet/pellet/weak/New()
	range = rand(8)

/obj/item/projectile/bullet/pellet/weak/on_range()
 	var/datum/effect/system/spark_spread/sparks = new /datum/effect/system/spark_spread
 	sparks.set_up(1, 1, src)
 	sparks.start()
 	..()

/obj/item/projectile/bullet/pellet/overload
	damage = 3

/obj/item/projectile/bullet/pellet/overload/New()
	range = rand(10)

/obj/item/projectile/bullet/pellet/overload/on_hit(atom/target, blocked = 0)
 	..()
 	explosion(target, 0, 0, 2)

/obj/item/projectile/bullet/pellet/overload/on_range()
 	explosion(src, 0, 0, 2)
 	var/datum/effect/system/spark_spread/sparks = new /datum/effect/system/spark_spread
 	sparks.set_up(3, 3, src)
 	sparks.start()
 	..()

/obj/item/projectile/bullet/midbullet
	damage = 20
	stamina = 65 //two rounds from the c20r knocks people down

/obj/item/projectile/bullet/midbullet2
	damage = 25

/obj/item/projectile/bullet/midbullet3
	damage = 30

/obj/item/projectile/bullet/midbullet3/hp
	damage = 40
	armour_penetration = -50

/obj/item/projectile/bullet/midbullet3/ap
	damage = 27
	armour_penetration = 40

/obj/item/projectile/bullet/midbullet3/fire/on_hit(atom/target, blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/item/projectile/bullet/heavybullet
	damage = 35

/obj/item/projectile/bullet/rpellet
	damage = 3
	stamina = 25

/obj/item/projectile/bullet/stunshot//taser slugs for shotguns, nothing special
	name = "stunshot"
	damage = 5
	stun = 5
	weaken = 5
	stutter = 5
	jitter = 20
	range = 7
	embed = 0
	sharp = 0
	icon_state = "spark"
	color = "#FFFF00"

/obj/item/projectile/bullet/incendiary/shell
	name = "incendiary slug"
	damage = 20

/obj/item/projectile/bullet/incendiary/shell/Move()
	..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)

/obj/item/projectile/bullet/incendiary/shell/dragonsbreath
	name = "dragonsbreath round"
	damage = 5

/obj/item/projectile/bullet/meteorshot
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "dust"
	damage = 30
	weaken = 8
	stun = 8
	hitsound = 'sound/effects/meteorimpact.ogg'

/obj/item/projectile/bullet/meteorshot/on_hit(var/atom/target, var/blocked = 0)
	..()
	if(istype(target, /atom/movable))
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.throw_at(throw_target, 3, 2)

/obj/item/projectile/bullet/meteorshot/New()
	..()
	SpinAnimation()

/obj/item/projectile/bullet/meteorshot/weak
	damage = 10
	weaken = 4
	stun = 4

/obj/item/projectile/bullet/honker
	damage = 0
	weaken = 5
	stun = 5
	forcedodge = 1
	nodamage = 1
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	hitsound = 'sound/items/bikehorn.ogg'
	icon = 'icons/obj/harvest.dmi'
	icon_state = "banana"
	range = 200

/obj/item/projectile/bullet/honker/New()
	..()
	SpinAnimation()

/obj/item/projectile/bullet/mime
	damage = 0
	stun = 5
	weaken = 5
	slur = 20
	stutter = 20

/obj/item/projectile/bullet/mime/on_hit(var/atom/target, var/blocked = 0)
	..(target, blocked)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.silent = max(M.silent, 10)
	else if(istype(target, /obj/mecha/combat/honker))
		var/obj/mecha/chassis = target
		chassis.occupant_message("A mimetech anti-honk bullet has hit \the [chassis]!")
		chassis.use_power(chassis.get_charge() / 2)
		for(var/obj/item/mecha_parts/mecha_equipment/weapon/honker in chassis.equipment)
			honker.set_ready_state(0)

/obj/item/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	embed = 0
	sharp = 0
	var/piercing = 0

/obj/item/projectile/bullet/dart/New()
	..()
	flags |= NOREACT
	create_reagents(50)

/obj/item/projectile/bullet/dart/on_hit(var/atom/target, var/blocked = 0, var/hit_zone)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100)
			if(M.can_inject(null,0,hit_zone)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.reaction(M, INGEST)
				reagents.trans_to(M, reagents.total_volume)
				return 1
			else
				blocked = 100
				target.visible_message("<span class='danger'>The [name] was deflected!</span>", \
									"<span class='userdanger'>You were protected against the [name]!</span>")
	..(target, blocked, hit_zone)
	flags &= ~NOREACT
	reagents.handle_reactions()
	return 1

/obj/item/projectile/bullet/dart/metalfoam

/obj/item/projectile/bullet/dart/metalfoam/New()
	..()
	reagents.add_reagent("aluminum", 15)
	reagents.add_reagent("fluorosurfactant", 5)
	reagents.add_reagent("sacid", 5)

//This one is for future syringe guns update
/obj/item/projectile/bullet/dart/syringe
	name = "syringe"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"

/obj/item/projectile/bullet/dart/syringe/tranquilizer
/obj/item/projectile/bullet/dart/syringe/tranquilizer/New()
	..()
	reagents.add_reagent("haloperidol", 15)

/obj/item/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/bullet/neurotoxin/on_hit(var/atom/target, var/blocked = 0)
	if(isalien(target))
		weaken = 0
		nodamage = 1
	. = ..() // Execute the rest of the code.

/obj/item/projectile/bullet/cap
	name = "cap"
	damage = 0
	nodamage = 1
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/cap/fire()
	loc = null
	qdel(src)
