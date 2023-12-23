/*
 / Cardborg Helmets.
*/
/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	var/list/disguises = list("Standard") 				// All the sprites you can disguise as. A disguise will be randomly chosen from the list.
	species_disguise = "High-tech security robot"		// You appear to be this when examined.
	dog_fashion = /datum/dog_fashion/head/cardborg 		// How this looks on Ian, all the cardborg disguises look the same on Ian because I cannot be bothered to change that.
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/cardborg/security
	name = "red cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted red."
	icon_state = "cardborg_h_security"
	item_state = "cardborg_h_security"
	disguises = list("secborg", "Security", "securityrobot", "bloodhound", "Standard-Secy", "Noble-SEC", "Cricket-SEC")
	species_disguise = "High-tech security robot"

/obj/item/clothing/head/cardborg/engineering
	name = "orange cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted orange."
	icon_state = "cardborg_h_engineering"
	item_state = "cardborg_h_engineering"
	disguises = list("Engineering", "engineerrobot", "landmate", "Standard-Engi", "Noble-ENG", "Cricket-ENGI")
	species_disguise = "High-tech engineering robot"

/obj/item/clothing/head/cardborg/mining
	name = "brown cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted brown."
	icon_state = "cardborg_h_mining"
	item_state = "cardborg_h_mining"
	disguises = list("Miner_old", "droid-miner", "Miner", "Standard-Mine", "Noble-DIG", "Cricket-MINE", "lavaland")
	species_disguise = "High-tech mining robot"

/obj/item/clothing/head/cardborg/service
	name = "green cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted green."
	icon_state = "cardborg_h_service"
	item_state = "cardborg_h_service"
	disguises = list("Service", "toiletbot", "Brobot", "maximillion", "Service2", "Standard-Serv", "Noble-SRV", "Cricket-SERV")
	species_disguise = "High-tech service robot"
/obj/item/clothing/head/cardborg/medical
	name = "blue cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted blue."
	icon_state = "cardborg_h_medical"
	item_state = "cardborg_h_medical"
	disguises = list("Medbot", "surgeon", "droid-medical", "medicalrobot", "Standard-Medi", "Noble-MED", "Cricket-MEDI")
	species_disguise = "High-tech medical robot"

/obj/item/clothing/head/cardborg/janitor
	name = "purple cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted purple."
	icon_state = "cardborg_h_janitor"
	item_state = "cardborg_h_janitor"
	disguises = list("JanBot2", "janitorrobot", "mopgearrex", "Standard-Jani", "Noble-CLN", "Cricket-JANI")
	species_disguise = "High-tech janitor robot"

/obj/item/clothing/head/cardborg/xeno
	name = "white cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted white."
	icon_state = "cardborg_h_xeno"
	item_state = "cardborg_h_xeno"
	disguises = list("xenoborg-state-a")
	species_disguise = "High-tech alien-hunting robot"

/obj/item/clothing/head/cardborg/deathbot
	name = "black cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted black."
	icon_state = "cardborg_h_deathbot"
	item_state = "cardborg_h_deathbot"
	disguises = list("nano_bloodhound", "syndie_bloodhound", "syndi-medi", "syndi-engi", "ertgamma")
	species_disguise = "High-tech killer robot"

/*
 / Cardborg Suits.
*/
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
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been spray-painted red."
	icon_state = "cardborg_security"
	item_state = "cardborg_security"
	species_disguise = "High-tech security robot"

/obj/item/clothing/suit/cardborg/engineering
	name = "orange cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been spray-painted orange."
	icon_state = "cardborg_engineering"
	item_state = "cardborg_engineering"
	species_disguise = "High-tech engineering robot"

/obj/item/clothing/suit/cardborg/mining
	name = "brown cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been spray-painted brown."
	icon_state = "cardborg_mining"
	item_state = "cardborg_mining"
	species_disguise = "High-tech mining robot"

/obj/item/clothing/suit/cardborg/service
	name = "green cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been spray-painted green."
	icon_state = "cardborg_service"
	item_state = "cardborg_service"
	species_disguise = "High-tech service robot"

/obj/item/clothing/suit/cardborg/medical
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been spray-painted blue."
	icon_state = "cardborg_medical"
	item_state = "cardborg_medical"
	species_disguise = "High-tech medical robot"

/obj/item/clothing/suit/cardborg/janitor
	name = "purple cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been spray-painted purple."
	icon_state = "cardborg_janitor"
	item_state = "cardborg_janitor"
	species_disguise = "High-tech janitor robot"

/obj/item/clothing/suit/cardborg/xeno
	name = "black cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been spray-painted white."
	icon_state = "cardborg_xeno"
	item_state = "cardborg_xeno"
	species_disguise = "High-tech alien-hunting robot"

/obj/item/clothing/suit/cardborg/deathbot
	name = "black cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides. This one has been spray-painted black."
	icon_state = "cardborg_deathbot"
	item_state = "cardborg_deathbot"
	species_disguise = "High-tech killer robot"

/*
 / Colouring code.
*/
// Pick a disguise type.
/obj/item/toy/crayon/spraycan/proc/attackby(user, /obj/item/clothing/head/cardborg || /obj/item/clothing/suit/cardborg )
	var/static/list/disguise_options = list(
		"Security" = image('icons/mob/robots.dmi', "security-radial"),
		"Engineering" = image('icons/mob/robots.dmi', "engi-radial"),
		"Mining" = image('icons/mob/robots.dmi', "mining-radial"),
		"Service" = image('icons/mob/robots.dmi', "serv-radial"),
		"Medical" = image('icons/mob/robots.dmi', "med-radial"),
		"Janitor" = image('icons/mob/robots.dmi', "jan-radial"),
		"Hunter" = image('icons/mob/robots.dmi', "xeno-radial"),
		"Death Bot" = image('icons/mob/robots.dmi', "syndie-bloodhound-preview")
		)
	var/selected_disguise = show_radial_menu(src, src, disguise_options, radius = 42, require_near = TRUE)



/*
 / Disguise code.
*/

/obj/item/clothing/head/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && slot == SLOT_HUD_HEAD)
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit/cardborg))
			var/obj/item/clothing/suit/cardborg/CB = H.wear_suit
			CB.disguise(user, src)

/obj/item/clothing/head/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("borg_disguise")  // You stop being a robot if you remove your helmet.

/obj/item/clothing/suit/cardborg/equipped(mob/living/user, slot)
	..()
	if(slot == SLOT_HUD_OUTER_SUIT)
		disguise(user)

/obj/item/clothing/suit/cardborg/dropped(mob/living/user) // You stop being a robot if you remove your suit.
	..()
	user.remove_alt_appearance("borg_disguise")

/obj/item/clothing/suit/cardborg/proc/disguise(mob/living/carbon/human/H, obj/item/clothing/head/cardborg/borghead) // The head determines what the disguise will be.
	if(istype(H))
		if(!borghead)
			borghead = H.head
		if(istype(borghead, /obj/item/clothing/head/cardborg)) //why is this done this way? because equipped() is called BEFORE THE ITEM IS IN THE SLOT WHYYYY.
			var/borg_disguise_variant
			var/disguise_eyes
			borg_disguise_variant = pick(borghead.disguises)
			switch(borg_disguise_variant) // We need to know what glowy bits to stick on.
				if("Standard", "Standard-Secy", "Standard-Engi", "Standard-Mine", "Standard-Serv", "Standard-Jani")
					disguise_eyes = "eyes-Standard"
				if("Cricket-SEC", "Cricket-ENGI", "Cricket-MINE", "Cricket-SERV", "Cricket-MEDI", "Cricket-Jani")
					disguise_eyes = "eyes-Cricket"
				if("ertgamma", "nano_bloodhound")
					disguise_eyes = "eyes-ertgamma"
				if("bloodhound")
					disguise_eyes = "eyes-bloodhound"
				if("syndie_bloodhound")
					disguise_eyes = "eyes-syndie_bloodhound"
				if("syndi-engi")
					disguise_eyes = "eyes-syndi-engi"
				if("lavaland")
					disguise_eyes = "eyes-lavaland"
				if("Miner")
					disguise_eyes = "eyes-Miner"
				if("droid-miner")
					disguise_eyes = "eyes-droid-miner"
				if("droid-medical")
					disguise_eyes = "eyes-droid-medical"
				if("landmate")
					disguise_eyes = "eyes-landmate"
				if("Engineering")
					disguise_eyes = "eyes-Engineering"
				if("surgeon")
					disguise_eyes = "eyes-surgeon"
				if("mopgearrex")
					disguise_eyes = "eyes-mopgearrex"
				if("toiletbot")
					disguise_eyes = "eyes-toiletbot"
			var/image/I = image(icon = 'icons/mob/robots.dmi' , icon_state = borg_disguise_variant, loc = H) // Now you're a robot!
			I.override = 1
			if(disguise_eyes)
				I.overlays += image(icon = 'icons/mob/robots.dmi' , icon_state = disguise_eyes) // Gotta look realistic, have some glowy bits!
			H.add_alt_appearance("borg_disguise", I, GLOB.silicon_mob_list+H) // You look like a robot to robots (including yourself because you're totally a robot)!
