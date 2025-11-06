/obj/item/organ/internal/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	origin_tech = "biotech=5"
	slot = "parasite_egg"

/obj/item/organ/internal/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, "<span class='warning'>You found an unknown alien organism in [owner]'s [parent_organ]!</span>")

/obj/item/organ/internal/body_egg/insert(mob/living/carbon/M, special = 0)
	..()
	ADD_TRAIT(owner, TRAIT_XENO_HOST, TRAIT_GENERIC)
	ADD_TRAIT(owner, TRAIT_XENO_IMMUNE, "xeno immune")
	owner.med_hud_set_status()
	INVOKE_ASYNC(src, PROC_REF(AddInfectionImages), owner)

/obj/item/organ/internal/body_egg/remove(mob/living/carbon/M, special = 0)
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_XENO_HOST, TRAIT_GENERIC)
		REMOVE_TRAIT(owner, TRAIT_XENO_IMMUNE, "xeno immune")
		owner.med_hud_set_status()
		INVOKE_ASYNC(src, PROC_REF(RemoveInfectionImages), owner)
	. = ..()

/obj/item/organ/internal/body_egg/on_life()
	SHOULD_CALL_PARENT(TRUE)
	..()
	if(!(src in owner.internal_organs)) // I can only presume this is here for a reason, so not touching it.
		remove(owner)
		return
	egg_process()

/obj/item/organ/internal/body_egg/dead_process()
	SHOULD_CALL_PARENT(TRUE)
	..()
	if(!(src in owner.internal_organs)) // I can only presume this is here for a reason, so not touching it.
		remove(owner)
		return
	egg_process()

/obj/item/organ/internal/body_egg/proc/egg_process()
	return

/obj/item/organ/internal/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/internal/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/internal/body_egg/proc/RemoveInfectionImages()
	return
