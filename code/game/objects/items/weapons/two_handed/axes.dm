/*
 * Fireaxe
 */
/// DEM AXES MAN, marker -Agouri
/obj/item/fireaxe
	base_icon_state = "fireaxe"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	sharp = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	toolspeed = 0.25
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/crowbar.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

	var/force_unwielded = 5
	var/force_wielded = 24
	new_attack_chain = TRUE

/obj/item/fireaxe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/forces_doors_open)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = MELEE_ATTACK, _parry_cooldown = (10 / 3) SECONDS, _requires_two_hands = TRUE) // 2.3333 seconds of cooldown for 30% uptime
	AddComponent(/datum/component/two_handed, force_unwielded = force_unwielded, force_wielded = force_wielded, icon_wielded = "[base_icon_state]1")

/obj/item/fireaxe/update_icon_state()  // Currently only here to fuck with the on-mob icons.
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/fireaxe/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return FINISH_ATTACK
	if(!HAS_TRAIT(src, TRAIT_WIELDED)) // Destroys windows and grilles in one hit.
		return ..()
	if(!istype(target, /obj/structure/window) && !istype(target, /obj/structure/grille))
		return ..()

	var/obj/structure/target_structure = target
	target_structure.obj_destruction("fireaxe")
	return FINISH_ATTACK

/// Blatant imitation of the fireaxe, but made out of bone.
/obj/item/fireaxe/boneaxe
	icon_state = "bone_axe0"
	base_icon_state = "bone_axe"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_wielded = 23
	needs_permit = TRUE

/obj/item/fireaxe/energized
	desc = "Someone with a love for fire axes decided to turn this one into a high-powered energy weapon. Seems excessive."
	force_wielded = 35
	armor_penetration_flat = 10
	armor_penetration_percentage = 30
	var/charge = 20
	var/max_charge = 20

/obj/item/fireaxe/energized/Initialize(mapload)
	. = ..()
	// only update the new args
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/two_handed, force_wielded = force_wielded, icon_wielded = "[base_icon_state]2")

/obj/item/fireaxe/energized/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/fireaxe/energized/process()
	charge = min(charge + 1, max_charge)

/obj/item/fireaxe/energized/after_attack(mob/living/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_WIELDED) || charge != max_charge)
		return

	if(!isliving(target))
		return

	charge = 0
	playsound(loc, 'sound/magic/lightningbolt.ogg', 5, 1)
	target.visible_message(
		SPAN_DANGER("[user] slams the charged axe into [target] with all [user.p_their()] might!"),
		SPAN_USERDANGER("[user] slams into you with incredible force!"),
		SPAN_HEAR("You hear a collossal impact!")
	)
	do_sparks(1, 1, src)
	target.KnockDown(8 SECONDS)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 5, 1)
	return FINISH_ATTACK
