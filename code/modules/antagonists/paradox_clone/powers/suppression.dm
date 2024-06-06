/datum/spell/touch/paradox_spell/suppression
	name = "Suppression"
	desc = "After touching a victim, all their radio devices start to jam for a while and no machine will track them."
	action_icon_state = "suppression"
	base_cooldown = 40 SECONDS
	hand_path = /obj/item/melee/touch_attack/paradox/sup

/obj/item/melee/touch_attack/paradox/sup
	name = "paradox jam hand"
	desc = "Transparent eerie aura. Jams radio devices."
	color = COLOR_HALF_TRANSPARENT_BLACK

/obj/item/melee/touch_attack/paradox/sup/afterattack(mob/living/target, mob/living/carbon/user)
	. = ..()

	if(is_paradox_clone(target))
		attached_spell.revert_cast()
		to_chat(user, "<span class='warning'>Useless. [target.name] is from our kin.</span>")
		return

	var/obj/item/jammer/dummy/D = new(target)
	GLOB.active_jammers += D
	QDEL_IN(D, 20 SECONDS)

	playsound(get_turf(target), 'sound/effects/paradox_jam.ogg', 60, TRUE)

/obj/item/jammer/dummy
	name = "YOU'RE NOT SUPPOSED TO SEE THIS"
	desc = "It's a bug, if you see this!"
	range = 1
	active = TRUE
	invisibility = SEE_INVISIBLE_LIVING
