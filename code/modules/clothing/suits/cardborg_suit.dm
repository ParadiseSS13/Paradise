/*
CONTENTS:
1. Cardborg Helmets
2. Cardborg Suits
3. Disguise code
*/

/*
 / Cardborg Helmets.
*/
/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	// Extended description, currently shared with all the sub-types. Easy to add indvidual ones later if someone decides that.
	var/extended_desc = "For reasons unknown to robotics experts across the galaxy, putting on a costume fashioned out of cardboard with some knobbly bits stuck on, \
	some buttons drawn on in pen, and moving in a stereotypical 'robotic' fashion causes the wearer to be percieved as being an actual robot by other robots, \
	cyborgs, and AI systems. The mechanism behind this is not understood, but they may use contextual information and other clues in order to see through the ruse. \
	The wearer may also hallucinate themselves as being a robot as well."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE		// Robots don't wear masks or ear accessories (yet!).
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH		// Robots don't wear masks or glasses (yet!).
	var/list/available_disguises = list("Standard") 	// All the sprites you can disguise as. A disguise will be randomly chosen from the list.
	species_disguise = "High-tech robot"				// You appear to be this when examined instead of your mob's actual species.
	dog_fashion = /datum/dog_fashion/head/cardborg 		// How this looks on Ian.
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'	// Greys have big heads and are smelly.
	"Vox" = 'icons/mob/clothing/species/grey/head.dmi'	// Vox beaks stick out the normal helmets, and the grey helmets fit perfectly.
	)

/obj/item/clothing/head/cardborg/examine_more(mob/user)	// Handles item extended descriptions.
    . = ..()
    . += extended_desc									// If an extended_desc is added to a subtype, this will handle it.

/obj/item/clothing/head/cardborg/security
	name = "red cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted red."
	icon_state = "cardborg_h_security"
	item_state = "cardborg_h_security"
	available_disguises = list("secborg", "Security", "securityrobot", "bloodhound", "Standard-Secy", "Noble-SEC", "Cricket-SEC", "heavySec")
	species_disguise = "High-tech security robot"
	dog_fashion = /datum/dog_fashion/head/cardborg/security

/obj/item/clothing/head/cardborg/engineering
	name = "orange cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted orange."
	icon_state = "cardborg_h_engineering"
	item_state = "cardborg_h_engineering"
	available_disguises = list("Engineering", "engineerrobot", "landmate", "Standard-Engi", "Noble-ENG", "Cricket-ENGI")
	species_disguise = "High-tech engineering robot"
	dog_fashion = /datum/dog_fashion/head/cardborg/engineering

/obj/item/clothing/head/cardborg/mining
	name = "brown cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted brown."
	icon_state = "cardborg_h_mining"
	item_state = "cardborg_h_mining"
	available_disguises = list("Miner_old", "droid-miner", "Miner", "Standard-Mine", "Noble-DIG", "Cricket-MINE", "lavaland", "squatminer", "coffinMiner")
	species_disguise = "High-tech mining robot"
	dog_fashion = /datum/dog_fashion/head/cardborg/mining

/obj/item/clothing/head/cardborg/service
	name = "green cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted green."
	icon_state = "cardborg_h_service"
	item_state = "cardborg_h_service"
	available_disguises = list("Service", "toiletbot", "Brobot", "maximillion", "Service2", "Standard-Serv", "Noble-SRV", "Cricket-SERV")
	species_disguise = "High-tech service robot"
	dog_fashion = /datum/dog_fashion/head/cardborg/service
/obj/item/clothing/head/cardborg/medical
	name = "blue cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted blue."
	icon_state = "cardborg_h_medical"
	item_state = "cardborg_h_medical"
	available_disguises = list("Medbot", "surgeon", "droid-medical", "medicalrobot", "Standard-Medi", "Noble-MED", "Cricket-MEDI", "qualified_doctor")
	species_disguise = "High-tech medical robot"
	dog_fashion = /datum/dog_fashion/head/cardborg/medical

/obj/item/clothing/head/cardborg/janitor
	name = "purple cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted purple."
	icon_state = "cardborg_h_janitor"
	item_state = "cardborg_h_janitor"
	available_disguises = list("JanBot2", "janitorrobot", "mopgearrex", "Standard-Jani", "Noble-CLN", "Cricket-JANI", "custodiborg")
	species_disguise = "High-tech janitor robot"
	dog_fashion = /datum/dog_fashion/head/cardborg/janitor

/obj/item/clothing/head/cardborg/xeno
	name = "white cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted white."
	icon_state = "cardborg_h_xeno"
	item_state = "cardborg_h_xeno"
	available_disguises = list("xenoborg-state-a")
	species_disguise = "High-tech alien-hunting robot"
	dog_fashion = /datum/dog_fashion/head/cardborg/xeno

/obj/item/clothing/head/cardborg/deathbot
	name = "black cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted black."
	icon_state = "cardborg_h_deathbot"
	item_state = "cardborg_h_deathbot"
	available_disguises = list("nano_bloodhound", "syndie_bloodhound", "syndi-medi", "syndi-engi", "ertgamma")
	species_disguise = "High-tech killer robot"
	dog_fashion = /datum/dog_fashion/head/cardborg/deathbot

/*
 / Cardborg Suits.
*/
/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them."
	// Extended description, currently shared with all the sub-types. Easy to add indvidual ones later if someone decides that.
	var/extended_desc = "For reasons unknown to robotics experts across the galaxy, putting on a costume fashioned out of cardboard with some knobbly bits stuck on, \
	some buttons drawn on in pen, and moving in a stereotypical 'robotic' fashion causes the wearer to be percieved as being an actual robot by other robots, \
	cyborgs, and AI systems. The mechanism behind this is not understood, but they may use contextual information and other clues in order to see through the ruse. \
	The wearer may also hallucinate themselves as being a robot as well."
	icon_state = "cardborg"
	item_state = "cardborg"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO		// Robots don't wear clothes (yet)!
	flags_inv = HIDEJUMPSUIT							// Robots don't wear jumpsuits (yet)!
	species_disguise = "High-tech robot"				// You appear to be this when examined instead of your mob's actual species.
	dog_fashion = /datum/dog_fashion/back				// How this looks on Ian. Doesn't need to be defined for the subtypes.

/obj/item/clothing/suit/cardborg/examine_more(mob/user)	// Handles item extended descriptions.
    . = ..()
    . += extended_desc									// If an extended_desc is added to a subtype, this will handle it.
/obj/item/clothing/suit/cardborg/security
	name = "red cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted red."
	icon_state = "cardborg_security"
	item_state = "cardborg_security"
	species_disguise = "High-tech security robot"

/obj/item/clothing/suit/cardborg/engineering
	name = "orange cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted orange."
	icon_state = "cardborg_engineering"
	item_state = "cardborg_engineering"
	species_disguise = "High-tech engineering robot"

/obj/item/clothing/suit/cardborg/mining
	name = "brown cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted brown."
	icon_state = "cardborg_mining"
	item_state = "cardborg_mining"
	species_disguise = "High-tech mining robot"

/obj/item/clothing/suit/cardborg/service
	name = "green cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted green."
	icon_state = "cardborg_service"
	item_state = "cardborg_service"
	species_disguise = "High-tech service robot"

/obj/item/clothing/suit/cardborg/medical
	name = "cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted blue."
	icon_state = "cardborg_medical"
	item_state = "cardborg_medical"
	species_disguise = "High-tech medical robot"

/obj/item/clothing/suit/cardborg/janitor
	name = "purple cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted purple."
	icon_state = "cardborg_janitor"
	item_state = "cardborg_janitor"
	species_disguise = "High-tech janitor robot"

/obj/item/clothing/suit/cardborg/xeno
	name = "black cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted white."
	icon_state = "cardborg_xeno"
	item_state = "cardborg_xeno"
	species_disguise = "High-tech alien-hunting robot"

/obj/item/clothing/suit/cardborg/deathbot
	name = "black cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted black."
	icon_state = "cardborg_deathbot"
	item_state = "cardborg_deathbot"
	species_disguise = "High-tech killer robot"

/*
 / Disguise code.
*/
/obj/item/clothing/head/cardborg/equipped(mob/living/user, slot)	// Attempt to disguise when you put on the helmet.
	..()
	if(ishuman(user) && slot == SLOT_HUD_HEAD)
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit/cardborg))
			var/obj/item/clothing/suit/cardborg/CB = H.wear_suit
			CB.apply_borg_disguise(user, src)

/obj/item/clothing/head/cardborg/dropped(mob/living/user)			// You stop being a robot if you remove your helmet.
	..()
	user.remove_alt_appearance("borg_disguise_variant")

/obj/item/clothing/suit/cardborg/equipped(mob/living/user, slot)	// Attempt to disguise when you put on the suit.
	..()
	if(slot == SLOT_HUD_OUTER_SUIT)
		apply_borg_disguise(user)

/obj/item/clothing/suit/cardborg/dropped(mob/living/user)			// You stop being a robot if you remove your suit.
	..()
	user.remove_alt_appearance("borg_disguise_variant")

/obj/item/clothing/suit/cardborg/proc/apply_borg_disguise(mob/living/carbon/human/H, obj/item/clothing/head/cardborg/borghead)
	if(!istype(H))
		return
	if(!borghead)
		borghead = H.head									// This actually stops the disguise from applying just from having it in your hands AGHHHH!
	if(istype(borghead, /obj/item/clothing/head/cardborg))	// Why is this done this way? because equipped() is called BEFORE THE ITEM IS IN THE SLOT WHYYYY!
		var/borg_disguise_variant
		var/disguise_eyes
		borg_disguise_variant = pick(borghead.available_disguises)
		switch(borg_disguise_variant)	// We need to know what glowy bits to stick on.
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
			if("qualified_doctor")
				disguise_eyes = "eyes-qualified_doctor"
			if("custodiborg")
				disguise_eyes = "eyes-custodiborg"
			if("heavySec")
				disguise_eyes = "eyes-heavySec"
			if("squatminer")
				disguise_eyes = "eyes-squatminer"
		var/image/I = image(icon = 'icons/mob/robots.dmi' , icon_state = borg_disguise_variant, loc = H)	// Now you're a robot!
		I.override = 1
		if(disguise_eyes)
			I.overlays += image(icon = 'icons/mob/robots.dmi' , icon_state = disguise_eyes)	// Gotta look realistic, have some glowy bits!
		H.add_alt_appearance("[borg_disguise_variant]", I, GLOB.silicon_mob_list+H)	// You look like a robot to robots (including yourself because you're totally a robot)!
	return
