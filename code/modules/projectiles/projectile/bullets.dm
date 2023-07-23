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
	stamina = 40

/obj/item/projectile/bullet/weakbullet/booze

/obj/item/projectile/bullet/weakbullet/booze/on_hit(atom/target, blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.AdjustDizzy(40 SECONDS)
		M.AdjustSlur(40 SECONDS)
		M.AdjustConfused(40 SECONDS)
		M.AdjustEyeBlurry(40 SECONDS)
		M.AdjustDrowsy(40 SECONDS)
		for(var/datum/reagent/consumable/ethanol/A in M.reagents.reagent_list)
			M.AdjustParalysis(4 SECONDS)
			M.AdjustDizzy(20 SECONDS)
			M.AdjustSlur(20 SECONDS)
			M.AdjustConfused(20 SECONDS)
			M.AdjustEyeBlurry(20 SECONDS)
			M.AdjustDrowsy(20 SECONDS)
			A.volume += 5 //Because we can

/obj/item/projectile/bullet/weakbullet2
	name = "rubber bullet"
	damage = 5
	stamina = 35
	icon_state = "bullet-r"

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

/obj/item/projectile/bullet/incendiary/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(4)
		M.IgniteMob()

/obj/item/projectile/bullet/incendiary/firebullet
	damage = 10

/obj/item/projectile/bullet/armourpiercing
	damage = 17
	armour_penetration_flat = 10

/obj/item/projectile/bullet/armourpiercing/wt550
	damage = 15
	armour_penetration_percentage = 50
	armour_penetration_flat = 25

/obj/item/projectile/bullet/pellet
	name = "pellet"
	damage = 12.5
	tile_dropoff = 0.75
	tile_dropoff_s = 1.25
	armour_penetration_flat = -20

/obj/item/projectile/bullet/pellet/rubber
	name = "rubber pellet"
	damage = 3
	stamina = 12.5
	icon_state = "bullet-r"
	armour_penetration_flat = -10

/obj/item/projectile/bullet/pellet/rubber/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(H.getStaminaLoss() >= 60)
		H.KnockDown(8 SECONDS)

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
		M.AdjustSilence(4 SECONDS)	// HELP MIME KILLING ME IN MAINT

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
	armour_penetration_flat = -40

/obj/item/projectile/bullet/midbullet3/ap
	damage = 27
	armour_penetration_flat = 40

/obj/item/projectile/bullet/midbullet3/fire/on_hit(atom/target, blocked = 0)
	if(..(target, blocked))
		var/mob/living/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/item/projectile/bullet/midbullet3/overgrown
	icon = 'icons/obj/ammo.dmi'
	item_state = "peashooter_bullet"
	icon_state = "peashooter_bullet"
	damage = 25

/obj/item/projectile/bullet/heavybullet
	damage = 35

/obj/item/projectile/bullet/stunshot //taser slugs for shotguns, nothing special
	name = "stunshot"
	damage = 5
	weaken = 10 SECONDS
	stutter = 10 SECONDS
	jitter = 40 SECONDS
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
	knockdown = 8 SECONDS
	hitsound = 'sound/effects/meteorimpact.ogg'

/obj/item/projectile/bullet/meteorshot/on_hit(atom/target, blocked = 0)
	..()
	if(ismovable(target))
		var/atom/movable/M = target
		if(M.move_resist < INFINITY)
			var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
			M.throw_at(throw_target, 3, 2)

/obj/item/projectile/bullet/meteorshot/New()
	..()
	SpinAnimation()

/obj/item/projectile/bullet/mime
	damage = 40
	var/special_effects = TRUE

/obj/item/projectile/bullet/mime/on_hit(atom/target, blocked = 0)
	..(target, blocked)
	if(special_effects)
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.Silence(20 SECONDS)
		else if(istype(target, /obj/mecha/combat/honker))
			var/obj/mecha/chassis = target
			chassis.occupant_message("A mimetech anti-honk bullet has hit \the [chassis]!")
			chassis.use_power(chassis.get_charge() / 2)
			for(var/obj/item/mecha_parts/mecha_equipment/weapon/honker in chassis.equipment)
				honker.set_ready_state(0)

/obj/item/projectile/bullet/mime/nonlethal
	damage = 0 /// We deal no normal damage...
	stamina = 40 /// ...Rather a large amount of stamina damage. Used in the mime mecha

/obj/item/projectile/bullet/mime/fake
	damage = 0
	nodamage = TRUE
	special_effects = FALSE
	log_override = TRUE

/obj/item/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6
	var/piercing = FALSE

/obj/item/projectile/bullet/dart/New()
	..()
	create_reagents(50)
	reagents.set_reacting(FALSE)

/obj/item/projectile/bullet/dart/on_hit(atom/target, blocked = 0, hit_zone)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != INFINITY)
			if(M.can_inject(null, FALSE, hit_zone, piercing)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				reagents.trans_to(M, reagents.total_volume)
				return 1
			else
				blocked = INFINITY
				target.visible_message("<span class='danger'>[src] was deflected!</span>", \
									"<span class='userdanger'>You were protected against [src]!</span>")
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
	stamina = 40
	knockdown = 10 SECONDS

/obj/item/projectile/bullet/neurotoxin/on_hit(atom/target, blocked = 0)
	if(isalien(target))
		knockdown = 0
		nodamage = TRUE
	. = ..() // Execute the rest of the code.

/obj/item/projectile/bullet/cap
	name = "cap"
	damage = 0
	nodamage = 1

/obj/item/projectile/bullet/cap/fire()
	loc = null
	qdel(src)
