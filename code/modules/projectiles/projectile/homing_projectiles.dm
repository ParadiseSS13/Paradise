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
	var/explosion_devastate = 0
	var/explosion_heavy = 1
	var/explosion_light = 3
	var/explosion_flash = 4
	var/explosion_fire = 3

/obj/item/projectile/homing/magic/homing_fireball/on_hit(mob/living/target)
	. = ..()
	explosion(get_turf(target), explosion_devastate, explosion_heavy, explosion_light, explosion_flash, 0, flame_range = explosion_fire)
	if(istype(target)) //multiple flavors of pain
		target.adjustFireLoss(10) // does 20 brute, and 10 burn + explosion. Pretty brutal.
