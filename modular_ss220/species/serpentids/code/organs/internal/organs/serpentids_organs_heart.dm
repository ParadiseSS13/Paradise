/obj/item/organ/internal/heart/serpentid
	name = "double heart"
	icon = 'modular_ss220/species/serpentids/icons/organs.dmi'
	icon_state = "heart_on"
	dead_icon = "heart"
	base_icon_state = "heart"
	desc = "A pair of hearts."

/obj/item/organ/internal/heart/serpentid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/organ_decay, 0.5, BASIC_RECOVER_VALUE)
	AddComponent(/datum/component/organ_toxin_damage, 0.03)
	AddComponent(/datum/component/defib_heart_hunger)
