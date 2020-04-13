/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	flag = "bullet"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect

/obj/item/projectile/bullet/weakbullet //beanbag, heavy stamina damage
	name = "beanbag slug"
	damage = 5
	stamina = 80

/obj/item/projectile/bullet/weakbullet/booze

/obj/item/projectile/bullet/weakbullet/booze/on_hit(atom/target, blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.AdjustDizzy(20)
		M.AdjustSlur(20)
		M.AdjustConfused(20)
		M.AdjustEyeBlurry(20)
		M.AdjustDrowsy(20)
		for(var/datum/reagent/consumable/ethanol/A in M.reagents.reagent_list)
			M.AdjustParalysis(2)
			M.AdjustDizzy(10)
			M.AdjustSlur(10)
			M.AdjustConfused(10)
			M.AdjustEyeBlurry(10)
			M.AdjustDrowsy(10)
			A.volume += 5 //Because we can

/obj/item/projectile/bullet/weakbullet2  //detective revolver instastuns, but multiple shots are better for keeping punks down
	name = "rubber bullet"
	damage = 5
	weaken = 3
	stamina = 60
	icon_state = "bullet-r"

/obj/item/projectile/bullet/weakbullet2/invisible //finger gun bullets
	name = "invisible bullet"
	damage = 0
	icon_state = null
	hitsound_wall = null

/obj/item/projectile/bullet/weakbullet2/invisible/fake
	weaken = 0
	stamina = 0
	nodamage = 1
	log_override = TRUE

/obj/item/projectile/bullet/weakbullet3
	damage = 20

/obj/item/projectile/bullet/weakbullet4
	name = "rubber bullet"
	damage = 5
	stamina = 30
	icon_state = "bullet-r"

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
	damage = 12.5
	tile_dropoff = 0.75
	tile_dropoff_s = 1.25

/obj/item/projectile/bullet/pellet/rubber
	name = "rubber pellet"
	damage = 3
	stamina = 25
	icon_state = "bullet-r"

/obj/item/projectile/bullet/pellet/weak
	tile_dropoff = 0.55		//Come on it does 6 damage don't be like that.
	damage = 6

/obj/item/projectile/bullet/pellet/weak/New()
	range = rand(1, 8)
	..()

/obj/item/projectile/bullet/pellet/weak/on_range()
 	do_sparks(1, 1, src)
 	..()

/obj/item/projectile/bullet/pellet/overload
	damage = 3

/obj/item/projectile/bullet/pellet/overload/New()
	range = rand(1, 10)
	..()

/obj/item/projectile/bullet/pellet/assassination
	damage = 12
	tile_dropoff = 1	// slightly less damage and greater damage falloff compared to normal buckshot

/obj/item/projectile/bullet/pellet/assassination/on_hit(atom/target, blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.AdjustSilence(2)	// HELP MIME KILLING ME IN MAINT

/obj/item/projectile/bullet/pellet/overload/on_hit(atom/target, blocked = 0)
 	..()
 	explosion(target, 0, 0, 2)

/obj/item/projectile/bullet/pellet/overload/on_range()
 	explosion(src, 0, 0, 2)
 	do_sparks(3, 3, src)
 	..()

/obj/item/projectile/bullet/midbullet
	damage = 20
	stamina = 65 //two rounds from the c20r knocks people down

/obj/item/projectile/bullet/midbullet_r
	damage = 5
	stamina = 75 //Still two rounds to knock people down

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

/obj/item/projectile/bullet/stunshot//taser slugs for shotguns, nothing special
	name = "stunshot"
	damage = 5
	stun = 5
	weaken = 5
	stutter = 5
	jitter = 20
	range = 7
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
		M.Silence(10)
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
	var/piercing = FALSE

/obj/item/projectile/bullet/dart/New()
	..()
	create_reagents(50)
	reagents.set_reacting(FALSE)

/obj/item/projectile/bullet/dart/on_hit(var/atom/target, var/blocked = 0, var/hit_zone)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100)
			if(M.can_inject(null, FALSE, hit_zone, piercing)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.trans_to(M, reagents.total_volume)
				return 1
			else
				blocked = 100
				target.visible_message("<span class='danger'>The [name] was deflected!</span>", \
									"<span class='userdanger'>You were protected against the [name]!</span>")
	..(target, blocked, hit_zone)
	reagents.set_reacting(TRUE)
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

/obj/item/projectile/bullet/cap/fire()
	loc = null
	qdel(src)
