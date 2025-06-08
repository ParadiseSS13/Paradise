///Хитиновые конечности - прочее
/obj/item/organ/external/head/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/chest/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/groin/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/arm/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/arm/right/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/leg/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/hand/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/hand/right/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/leg/right/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/foot/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external/foot/right/doll
	icon_name = "empty"
	icobase = 'modular_ss220/species/eventdoll/icons/placeholder.dmi'
	ignores_icobase_updates = TRUE

/obj/item/organ/external
	var/ignores_icobase_updates = FALSE

/obj/item/organ/external/change_organ_icobase(new_icobase, owner_sensitive)
	if(ignores_icobase_updates)
		return
	return ..()
