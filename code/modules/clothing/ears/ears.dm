/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	flags = EARBANGPROTECT
	strip_delay = 15
	put_on_delay = 25
	resistance_flags = FLAMMABLE

/obj/item/clothing/ears/earmuffs/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/earhealing)

/obj/item/clothing/ears/earmuffs/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user) && ((slot == slot_l_ear) || (slot == slot_r_ear)))
		ADD_TRAIT(user, TRAIT_DEAF, CLOTHING_TRAIT)

/obj/item/clothing/ears/earmuffs/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_DEAF, CLOTHING_TRAIT)
