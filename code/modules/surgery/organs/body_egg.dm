/obj/item/organ/internal/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	origin_tech = "biotech=5"
	parent_organ = "chest"
	slot = "parasite_egg"

/obj/item/organ/internal/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, "<span class='warning'>You found an unknown alien organism in [owner]'s [parent_organ]!</span>")

/obj/item/organ/internal/body_egg/insert(var/mob/living/carbon/M, special = 0)
	..()
	owner.status_flags |= XENO_HOST
	START_PROCESSING(SSobj, src)
	owner.med_hud_set_status()
	spawn(0)
		AddInfectionImages(owner)

/obj/item/organ/internal/body_egg/remove(var/mob/living/carbon/M, special = 0)
	STOP_PROCESSING(SSobj, src)
	if(owner)
		owner.status_flags &= ~(XENO_HOST)
		owner.med_hud_set_status()
		spawn(0)
			RemoveInfectionImages(owner)
	. = ..()

/obj/item/organ/internal/body_egg/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
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
