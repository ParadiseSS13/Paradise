/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/ears.dmi'
	clothing_traits = list(TRAIT_DEAF)
	flags = EARBANGPROTECT
	strip_delay = 15
	put_on_delay = 25
	resistance_flags = FLAMMABLE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)

/obj/item/clothing/ears/earmuffs/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/earhealing)
