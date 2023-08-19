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
