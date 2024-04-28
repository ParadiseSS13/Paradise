/datum/spell/touch/paradox_spell/space_distortion
	name = "Space Distorition"
	desc = "Warps space around you to let you pass into an object."
	action_icon_state = "space_distortion"
	base_cooldown = 10 SECONDS
	hand_path = /obj/item/melee/touch_attack/space_distortion

/obj/item/melee/touch_attack/space_distortion
	name = "reality tear"
	desc = "Looks like the absence of space molded into a hand. Everything seems to bend around it. If you place this in front of something, you can stare right past it."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"
	color = COLOR_BLUE_LIGHT
	flags = ABSTRACT | DROPDEL
	catchphrase = null
	w_class = WEIGHT_CLASS_HUGE

/obj/item/melee/touch_attack/space_distortion/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	var/turf/target_turf = get_turf(target)
	user.forceMove(target_turf)
	if(user.pulling)
		user.pulling.forceMove(target_turf)
	do_sparks(rand(1, 2), FALSE, target_turf)
