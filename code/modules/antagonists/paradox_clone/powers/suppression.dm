
/datum/spell/touch/paradox_spell/suppression
	name = "Suppression"
	desc = "After touching the victim, all their radio devices start to jam for a while."
	action_icon_state = "suppression"
	base_cooldown = 40 SECONDS
	hand_path = /obj/item/melee/touch_attack/paradox/sup

/obj/item/melee/touch_attack/paradox/sup
	name = "paradox jam hand"
	desc = "Transparent eerie aura. Jams radio devices."
	color = COLOR_HALF_TRANSPARENT_BLACK

/obj/item/melee/touch_attack/paradox/sup/afterattack(mob/living/target, mob/living/carbon/user)
	. = ..()
	var/obj/item/jammer/dummy/D = new(target)
	QDEL_IN(D, 20 SECONDS)

	playsound(get_turf(target), 'sound/effects/paradox_jam.ogg', 60, TRUE)

/obj/item/jammer/dummy
	desc = "It's a bug, if you see this!"
	range = 1
	active = TRUE
