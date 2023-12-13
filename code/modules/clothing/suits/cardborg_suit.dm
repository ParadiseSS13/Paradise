// Cardborg helmets
/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	species_disguise = "High-tech robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/cardborg/security
	name = "red cardborg helmet"
	desc = "A helmet made out of a box. This one has been coloured in with a red crayon."
	icon_state = "cardborg_h_security"
	item_state = "cardborg_h_security"
	species_disguise = "High-tech security robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/cardborg/engineering
	name = "orange cardborg helmet"
	desc = "A helmet made out of a box. This one has been coloured in with an orange crayon."
	icon_state = "cardborg_h_engineering"
	item_state = "cardborg_h_engineering"
	species_disguise = "High-tech engineering robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/cardborg/mining
	name = "brown cardborg helmet"
	desc = "A helmet made out of a box. This one has been scrawled over with multiple crayons, the end result looks brown."
	icon_state = "cardborg_h_mining"
	item_state = "cardborg_h_mining"
	species_disguise = "High-tech mining robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/cardborg/service
	name = "green cardborg helmet"
	desc = "A helmet made out of a box. This one has been coloured in with a green crayon."
	icon_state = "cardborg_h_service"
	item_state = "cardborg_h_service"
	species_disguise = "High-tech service robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)
/obj/item/clothing/head/cardborg/medical
	name = "blue cardborg helmet"
	desc = "A helmet made out of a box. This one has been coloured in with a blue crayon."
	icon_state = "cardborg_h_medical"
	item_state = "cardborg_h_medical"
	species_disguise = "High-tech medical robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/cardborg/custodial
	name = "purple cardborg helmet"
	desc = "A helmet made out of a box. This one has been coloured in with a purple crayon."
	icon_state = "cardborg_h_custodial"
	item_state = "cardborg_h_custodial"
	species_disguise = "High-tech custodial robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/cardborg/xeno
	name = "white cardborg helmet"
	desc = "A helmet made out of a box. This one has been coloured in with a white crayon."
	icon_state = "cardborg_h_xeno"
	item_state = "cardborg_h_xeno"
	species_disguise = "High-tech alien-hunting robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/cardborg/deathbot
	name = "black cardborg helmet"
	desc = "A helmet made out of a box. This one has been coloured in with a black crayon."
	icon_state = "cardborg_h_deathbot"
	item_state = "cardborg_h_deathbot"
	species_disguise = "High-tech killer robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)


// Cardborg Helmet disguise code
/obj/item/clothing/head/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && slot == SLOT_HUD_HEAD)
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit/cardborg))
			var/obj/item/clothing/suit/cardborg/CB = H.wear_suit
			CB.disguise(user, src)

/obj/item/clothing/head/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

//Cardborg suits
/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	item_state = "cardborg"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags_inv = HIDEJUMPSUIT
	species_disguise = "High-tech robot"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/cardborg/security
	name = "red cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been coloured in with a red crayon."
	icon_state = "cardborg_security"
	item_state = "cardborg_security"
	species_disguise = "High-tech security robot"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/cardborg/engineering
	name = "orange cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been coloured in with an orange crayon."
	icon_state = "cardborg_engineering"
	item_state = "cardborg_engineering"
	species_disguise = "High-tech engineering robot"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/cardborg/mining
	name = "brown cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been scrawled over with multiple crayons, the end result looks brown."
	icon_state = "cardborg_engineering"
	item_state = "cardborg_engineering"
	species_disguise = "High-tech mining robot"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/cardborg/service
	name = "green cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been coloured in with a green crayon."
	icon_state = "cardborg_service"
	item_state = "cardborg_service"
	species_disguise = "High-tech service robot"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/cardborg/medical
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been coloured in with a blue crayon."
	icon_state = "cardborg_medical"
	item_state = "cardborg_medical"
	species_disguise = "High-tech medical robot"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/cardborg/custodial
	name = "purple cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been coloured in with a purple crayon."
	icon_state = "cardborg_custodial"
	item_state = "cardborg_custodial"
	species_disguise = "High-tech custodial robot"
	dog_fashion = /datum/dog_fashion/back

	/obj/item/clothing/suit/cardborg/xeno
	name = "black cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been coloured in with a black crayon."
	icon_state = "cardborg_xeno"
	item_state = "cardborg_xeno"
	species_disguise = "High-tech alien-hunting robot"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/cardborg/deathbot
	name = "black cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been coloured in with a black crayon."
	icon_state = "cardborg_deathbot"
	item_state = "cardborg_deathbot"
	species_disguise = "High-tech killer robot"
	dog_fashion = /datum/dog_fashion/back

// Cardborg Suit disguise code
/obj/item/clothing/suit/cardborg/equipped(mob/living/user, slot)
	..()
	if(slot == SLOT_HUD_OUTER_SUIT)
		disguise(user)

/obj/item/clothing/suit/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

/obj/item/clothing/suit/cardborg/proc/disguise(mob/living/carbon/human/H, obj/item/clothing/head/cardborg/borghead)
	if(istype(H))
		if(!borghead)
			borghead = H.head
		if(istype(borghead, /obj/item/clothing/head/cardborg)) //why is this done this way? because equipped() is called BEFORE THE ITEM IS IN THE SLOT WHYYYY
			var/image/I = image(icon = 'icons/mob/robots.dmi' , icon_state = "robot", loc = H)
			I.override = 1
			I.overlays += image(icon = 'icons/mob/robots.dmi' , icon_state = "eyes-robot") //gotta look realistic
			H.add_alt_appearance("standard_borg_disguise", I, GLOB.silicon_mob_list+H) //you look like a robot to robots! (including yourself because you're totally a robot)
