/obj/item/projectile/homing
	name = "smart bullet"
	icon_state = "bullet"
	var/homing_active = TRUE

/obj/item/projectile/homing/pixel_move(trajectory_multiplier)
	. = ..()
	if(!homing_active)
		return

	var/turf/current_turf = get_turf(src)
	var/turf/target_turf = get_turf(original)
	if(current_turf == target_turf)
		homing_active = FALSE
		return

	if(!current_turf || !target_turf)
		return

	var/dx = target_turf.x - current_turf.x
	var/dy = target_turf.y - current_turf.y
	var/angle = ATAN2(dy, dx)
	set_angle(angle)

/obj/item/projectile/homing/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	armour_penetration_percentage = 100
	flag = MAGIC

/obj/item/projectile/homing/magic/toolbox
	name = "magic toolbox"
	icon = 'icons/obj/storage.dmi'
	icon_state = "toolbox_default"
	hitsound = 'sound/weapons/smash.ogg'
	damage = 30
	damage_type = BRUTE

/obj/item/projectile/homing/magic/toolbox/on_range()
	. = ..()
	new /obj/item/storage/toolbox(get_turf(src))

/obj/item/projectile/homing/magic/toolbox/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	var/obj/item/storage/toolbox/T = new /obj/item/storage/toolbox(get_turf(src))
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/E = pick(H.bodyparts)
		E.add_embedded_object(T)

/obj/item/projectile/homing/magic/homing_fireball
	name = "greater bolt of fireball"
	icon_state = "fireball"
	damage = 20
	damage_type = BRUTE
	nodamage = FALSE

	//explosion values
	var/exp_devastate = 0
	var/exp_heavy = 1
	var/exp_light = 3
	var/exp_flash = 4
	var/exp_fire = 3

/obj/item/projectile/homing/magic/homing_fireball/Range()
	var/turf/T1 = get_step(src,turn(dir, -45))
	var/turf/T2 = get_step(src,turn(dir, 45))
	var/turf/T3 = get_step(src,dir)
	var/mob/living/L = locate(/mob/living) in T1 //if there's a mob alive in our front right diagonal, we hit it.
	if(L && L.stat != DEAD)
		Bump(L) //Magic Bullet #teachthecontroversy
		return
	L = locate(/mob/living) in T2
	if(L && L.stat != DEAD)
		Bump(L)
		return
	L = locate(/mob/living) in T3
	if(L && L.stat != DEAD)
		Bump(L)
		return
	..()

/obj/item/projectile/homing/magic/homing_fireball/on_hit(mob/living/target)
	. = ..()
	explosion(get_turf(target), exp_devastate, exp_heavy, exp_light, exp_flash, 0, flame_range = exp_fire)
	if(istype(target)) //multiple flavors of pain
		target.adjustFireLoss(10) // does 20 brute, and 10 burn + explosion. Pretty brutal.
