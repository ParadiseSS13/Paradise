/obj/item/weapon/species_enhancement
	name = "Species enhancer"
	desc = "You shouldn't see this."
	icon = 'icons/obj/hypo.dmi'
	item_state = "syringe_0"
	icon_state = "lepopen"
	var/used = null
	var/list/species = null

/obj/item/weapon/species_enhancement/update_icon()
	if(used)
		icon_state = "lepopen0"
	else
		icon_state = "lepopen"

/obj/item/weapon/species_enhancement/attack(mob/M, mob/user)
	if(!M || !user)
		return

	if(!ishuman(M) || !ishuman(user))
		return

	if(used)
		return

	if(!species.Find(M.get_species()))
		to_chat(user, "<span class='warning'>You failed to inject [M], as they are incompatible with this genetic modifier.</span>")
		return

	if(M == user)
		user.visible_message("<span class='danger'>[user] injects \himself with [src]!</span>")
		injected(user)
	else
		user.visible_message("<span class='danger'>[user] is trying to inject [M] with [src]!</span>")
		if(do_mob(user,M,30))
			user.visible_message("<span class='danger'>[user] injects [M] with [src].</span>")
			injected(M)
		else
			to_chat(user, "<span class='warning'>You failed to inject [M].</span>")

/obj/item/weapon/species_enhancement/proc/injected(var/mob/living/carbon/human/target)
	used = 1
	update_icon()
	name = "used " + name
