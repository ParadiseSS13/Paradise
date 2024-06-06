/datum/spell/touch/paradox_spell/space_distortion
	name = "Space Distortion"
	desc = "Warps space around you to let you pass through an object."
	action_icon_state = "space_distortion"
	base_cooldown = 30 SECONDS
	hand_path = /obj/item/melee/touch_attack/space_distortion

/obj/item/melee/touch_attack/space_distortion
	name = "reality tear"
	desc = "Looks like the absence of space, vaguely resembling a hand. Everything seems to bend around it. If you look through it, you can see behind objects ahead of you."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"
	color = COLOR_BLUE_LIGHT
	flags = ABSTRACT | DROPDEL
	catchphrase = null
	w_class = WEIGHT_CLASS_HUGE

/obj/item/melee/touch_attack/space_distortion/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	var/turf/target_turf = get_turf(target)
	if(user.pulling)
		user.pulling.forceMove(target_turf)
	do_sparks(rand(1, 2), FALSE, target_turf)
