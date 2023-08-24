/obj/effect/mob_spawn/human/ghost_bar
	name = "ghastly rejuvinator"
	mob_name = "ghost bar occupant"
	permanent = TRUE
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/closet.dmi'
	icon_state = "coffin"
	important_info = "Don't randomly attack people in the ghost bar, stay inside the ghost bar. You will still be able to roll for ghost roles."
	description = "Relax, get a beer, watch the station destroy itself and burst into flames."
	flavour_text = "You are a ghost bar occupant. You've gotten sick of being dead and decided to meet up with some of your fellow haunting brothers. Take a seat, grab a beer, and chat it out."
	outfit = /datum/outfit/ghost_bar_occupant
	assignedrole = "Ghost bar occupant"
	allow_species_pick = TRUE

/obj/effect/mob_spawn/human/ghost_bar/create(ckey, flavour = TRUE, name)
	. = ..()
	playsound(src, 'sound/machines/wooden_closet_open.ogg', 50)

/obj/structure/ghost_bar_cryopod
	name = "returning sarcophagus"
	desc = "Returns you back to the world of the dead."
	icon_state = "coffin_open"
	icon = 'icons/obj/closet.dmi'

/obj/structure/ghost_bar_cryopod/MouseDrop_T(mob/living/carbon/human/mob_to_delete, mob/living/user)
	if(!istype(mob_to_delete) || !istype(user) || !Adjacent(user))
		return
	if(mob_to_delete.client)
		if(alert(mob_to_delete ,"Would you like to return to the relm of spirits? (This will delete your current character, but you can rejoin later)",,"Yes","No") == "No")
			return
	mob_to_delete.visible_message("<span class='notice'>[mob_to_delete.name] climbs into [src]...</span>")
	playsound(src, 'sound/machines/wooden_closet_close.ogg', 50)
	qdel(mob_to_delete)

/datum/outfit/ghost_bar_occupant
	name = "Ghost bar occupant"
	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	gloves = /obj/item/clothing/gloves/chameleon
	back = /obj/item/storage/backpack/chameleon
	belt = /obj/item/storage/belt/chameleon
	r_pocket = /obj/item/clothing/mask/cigarette/cigar
	l_pocket = /obj/item/storage/box/matches
	id = /obj/item/card/id/syndicate/ghost_bar
	mask = /obj/item/clothing/mask/chameleon
	glasses = /obj/item/clothing/glasses/chameleon
	head = /obj/item/clothing/head/chameleon

/datum/outfit/ghost_bar_occupant/post_equip(mob/living/carbon/human/H)
	H.job = "Ghost bar occupant" // ensures they show up right in player panel for admins
	ADD_TRAIT(H, TRAIT_PACIFISM, GHOST_ROLE)
	ADD_TRAIT(H, TRAIT_RESPAWNABLE, GHOST_ROLE)
