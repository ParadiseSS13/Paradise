/datum/species/human_doll
	name = "Doll"
	name_plural = "Dolls"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	eyes_icon = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	nojumpsuit = TRUE
	no_equip = ITEM_SLOT_OUTER_SUIT | ITEM_SLOT_GLOVES | ITEM_SLOT_SHOES | ITEM_SLOT_JUMPSUIT | ITEM_SLOT_SUIT_STORE | ITEM_SLOT_NECK | ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_EYES | ITEM_SLOT_BELT

	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/doll, "descriptor" = "chest"),
		"groin" =  list("path" = /obj/item/organ/external/groin/doll, "descriptor" = "groin"),
		"head" =   list("path" = /obj/item/organ/external/head/doll, "descriptor" = "head"),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/doll, "descriptor" = "left arm"),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/doll, "descriptor" = "right arm"),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/doll, "descriptor" = "left leg"),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/doll, "descriptor" = "right leg"),
		"l_hand" = list("path" = /obj/item/organ/external/hand/doll, "descriptor" = "left hand"),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/doll, "descriptor" = "right hand"),
		"l_foot" = list("path" = /obj/item/organ/external/foot/doll, "descriptor" = "left foot"),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/doll, "descriptor" = "right foot")
		)
