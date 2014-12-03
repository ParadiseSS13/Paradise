/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	embed = 1
	sharp = 1

/*	on_hit(var/atom/target, var/blocked = 0)
		if (..(target, blocked))
			var/mob/living/L = target
			shake_camera(L, 3, 2)
			return 1
		return 0 */

/obj/item/projectile/bullet/weakbullet
	damage = 5
	stun = 5
	weaken = 5

/obj/item/projectile/bullet/slug
	name = "slug"


/obj/item/projectile/bullet/rubberbullet  //  Back to insta-stun bullets.
	damage = 5
	stun = 5
	weaken = 5
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/c38 //replacement for detective's ammo
	damage = 15
	stun = 5
	weaken = 5
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/weakbullet/booze
	embed = 0
	on_hit(var/atom/target, var/blocked = 0)
		if(..(target, blocked))
			var/mob/living/M = target
			M.dizziness += 20
			M:slurring += 20
			M.confused += 20
			M.eye_blurry += 20
			M.drowsyness += 20
			for(var/datum/reagent/ethanol/A in M.reagents.reagent_list)
				M.paralysis += 2
				M.dizziness += 10
				M:slurring += 10
				M.confused += 10
				M.eye_blurry += 10
				M.drowsyness += 10
				A.volume += 5 //Because we can


/obj/item/projectile/bullet/midbullet12
	damage = 20
	stun = 5
	weaken = 5

/obj/item/projectile/bullet/midbullet9
	damage = 25

/obj/item/projectile/bullet/midbullet45
	damage = 25
	stun = 1
	weaken = 1

/obj/item/projectile/bullet/midbullet10 //Only used with the Stechkin Pistol - RobRichards
	damage = 30

/obj/item/projectile/bullet/buck
	name = "pellet"
	damage = 15

/obj/item/projectile/bullet/blank
	name = "blankshot"
	nodamage = 1

/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 20
	damage_type = OXY


/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 40
	damage_type = TOX


/obj/item/projectile/bullet/burstbullet//I think this one needs something for the on hit
	name = "exploding bullet"
	damage = 20
	embed = 0
	edge = 1

/obj/item/projectile/bullet/stunshot
	name = "stunshot"
	damage = 5
	stun = 5
	weaken = 5
	stutter = 5
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/stunslug
	name = "stunslug"
	damage = 5
	stun = 5
	weaken = 5
	stutter = 5
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/a762
	damage = 35


/obj/item/projectile/bullet/incendiary

/obj/item/projectile/bullet/incendiary/on_hit(var/atom/target, var/blocked = 0)
	..()
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/item/projectile/bullet/incendiary/shell
	name = "incendiary slug"
	damage = 20

/obj/item/projectile/bullet/incendiary/shell/Move()
	..()
	var/turf/location = get_turf(src)
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



/obj/item/projectile/bullet/mime
	damage = 20

/obj/item/projectile/bullet/mime/on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon))
				var/mob/living/carbon/M = target
				M.silent = max(M.silent, 10)

/*


/obj/item/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 6

	New()
		..()
		flags |= NOREACT
		create_reagents(50)

	on_hit(var/atom/target, var/blocked = 0, var/hit_zone)
		if(istype(target, /mob/living/carbon))
			var/mob/living/carbon/M = target
			if(M.can_inject(null,0,hit_zone)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				reagents.trans_to(M, reagents.total_volume)
				return 1
			else
				target.visible_message("<span class='danger'>The [name] was deflected!</span>", \
									   "<span class='userdanger'>You were protected against the [name]!</span>")
		flags &= ~NOREACT
		reagents.handle_reactions()
		return 1
*/
/obj/item/projectile/bullet/dart/metalfoam
	New()
		..()
		reagents.add_reagent("aluminium", 15)
		reagents.add_reagent("foaming_agent", 5)
		reagents.add_reagent("pacid", 5)

//This one is for future syringe guns update
/obj/item/projectile/bullet/dart/syringe
	name = "syringe"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "syringeproj"

/obj/item/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	weaken = 5

/obj/item/projectile/bullet/neurotoxin/on_hit(var/atom/target, var/blocked = 0)
	if(isalien(target))
		return 0
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(prob(H.getarmor(def_zone, "melee")))
			H.visible_message("\red The [src.name] splatters uselessly on the armor!")
			return 0
	..() // Execute the rest of the code.
