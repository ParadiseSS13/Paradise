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
	armour_penetration_flat = 30
	tool_behaviour = TOOL_SAW
	new_attack_chain = TRUE

/obj/item/kitchen/knife/combat/serpentblade/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_FORCES_OPEN_DOORS_ITEM, ROUNDSTART_TRAIT)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)
	AddComponent(/datum/component/double_attack)
