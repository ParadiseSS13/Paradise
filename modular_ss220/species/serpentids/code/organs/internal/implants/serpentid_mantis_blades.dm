// ============ Органы внешние ============
/obj/item/kitchen/knife/combat/serpentblade
	name = "serpentid mantis blade"
	icon = 'modular_ss220/species/serpentids/icons/organs.dmi'
	icon_state = "left_blade"
	lefthand_file = null
	righthand_file = null
	desc = "Biological melee weapon. Sharp and durable. It can cut off some heads, or maybe not..."
	origin_tech = null
	force = 11
	armour_penetration_flat = 20
	new_attack_chain = TRUE
	var/obj/item/organ/internal/cyberimp/chest/serpentid_blades/parent_blade_implant

/obj/item/kitchen/knife/combat/serpentblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/forces_doors_open/serpentid_blades, time_to_open = 8 SECONDS)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)
	AddComponent(/datum/component/double_attack)

/obj/item/kitchen/knife/combat/serpentblade/equipped(mob/user, slot, initial)
	. = ..()
	var/mob/living/carbon/human/owner = loc
	if(ishuman(owner))
		if(IS_CHANGELING(owner) && force == 11)
			force = 8
			armour_penetration_flat = 10

/obj/item/kitchen/knife/combat/serpentblade/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(H.invisibility == INVISIBILITY_LEVEL_TWO || H.alpha != 255)
		var/obj/item/organ/internal/kidneys/serpentid/kidneys= H.get_int_organ(/obj/item/organ/internal/kidneys/serpentid)
		H.reset_visibility()
		kidneys.switch_mode(force_off = TRUE)

/// subtype for mantis blades
/datum/component/forces_doors_open/serpentid_blades/on_interact(datum/source, mob/user, atom/target)
	if(check_intent(user))
		return

	if(try_to_open_firedoor(target))
		return ITEM_INTERACT_COMPLETE

	if(try_to_force_open_airlock(user, target))
		return ITEM_INTERACT_COMPLETE
