/*
CONTENTS:
1. Cardborg Helmets
2. Cardborg Suits
3. Disguise code
*/

/*
 * Cardborg Helmets.
*/
/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon = 'icons/obj/clothing/head/cardborg.dmi'
	icon_state = "cardborg_h"
	inhand_icon_state = "cardborg_h"
	worn_icon = 'icons/mob/clothing/head/cardborg.dmi'
	dog_fashion = /datum/dog_fashion/head/cardborg
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEEARS
	flags_cover = HEADCOVERSEYES
	/// You appear to be this when examined instead of your mob's actual species. Also used to verify the helmet and suit are in a matching set.
	species_disguise = "High-tech robot"
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/head/cardborg.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head/cardborg.dmi',
	)
	/// All the borg skins that this can disguise you as.
	var/list/available_disguises = list("Standard")

/obj/item/clothing/head/cardborg/examine_more(mob/user)
	. = ..()
	. += "For reasons unknown to robotics experts across the galaxy, putting on a costume fashioned out of cardboard with some knobbly bits stuck on, \
	some buttons drawn on in pen, and moving in a stereotypical 'robotic' fashion causes the wearer to be perceived as being an actual robot by other robots, \
	cyborgs, and AI systems. The mechanism behind this is not understood, but it is not foolproof, as they may use contextual information and other clues in order to see through the ruse."
	. += ""
	. += "The wearer may also hallucinate themselves as being a robot as well."

/obj/item/clothing/head/cardborg/security
	name = "red cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted red."
	icon_state = "cardborg_h_security"
	dog_fashion = /datum/dog_fashion/head/cardborg/security
	available_disguises = list("secborg", "Security", "securityrobot", "bloodhound", "Standard-Secy", "Noble-SEC", "Cricket-SEC", "heavySec")
	species_disguise = "High-tech security robot"

/obj/item/clothing/head/cardborg/engineering
	name = "orange cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted orange."
	icon_state = "cardborg_h_engineering"
	dog_fashion = /datum/dog_fashion/head/cardborg/engineering
	available_disguises = list("Engineering", "engineerrobot", "landmate", "Standard-Engi", "Noble-ENG", "Cricket-ENGI")
	species_disguise = "High-tech engineering robot"

/obj/item/clothing/head/cardborg/mining
	name = "brown cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted brown."
	icon_state = "cardborg_h_mining"
	dog_fashion = /datum/dog_fashion/head/cardborg/mining
	available_disguises = list("Miner_old", "droid-miner", "Miner", "Standard-Mine", "Noble-DIG", "Cricket-MINE", "lavaland", "squatminer", "coffinMiner")
	species_disguise = "High-tech mining robot"

/obj/item/clothing/head/cardborg/service
	name = "green cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted green."
	icon_state = "cardborg_h_service"
	dog_fashion = /datum/dog_fashion/head/cardborg/service
	available_disguises = list("Service", "toiletbot", "Brobot", "maximillion", "Service2", "Standard-Serv", "Noble-SRV", "Cricket-SERV")
	species_disguise = "High-tech service robot"

/obj/item/clothing/head/cardborg/medical
	name = "blue cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted blue."
	icon_state = "cardborg_h_medical"
	dog_fashion = /datum/dog_fashion/head/cardborg/medical
	available_disguises = list("Medbot", "surgeon", "droid-medical", "medicalrobot", "Standard-Medi", "Noble-MED", "Cricket-MEDI", "qualified_doctor")
	species_disguise = "High-tech medical robot"

/obj/item/clothing/head/cardborg/janitor
	name = "purple cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted purple."
	icon_state = "cardborg_h_janitor"
	dog_fashion = /datum/dog_fashion/head/cardborg/janitor
	available_disguises = list("JanBot2", "janitorrobot", "mopgearrex", "Standard-Jani", "Noble-CLN", "Cricket-JANI", "custodiborg")
	species_disguise = "High-tech janitor robot"

/obj/item/clothing/head/cardborg/xeno
	name = "white cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted white."
	icon_state = "cardborg_h_xeno"
	dog_fashion = /datum/dog_fashion/head/cardborg/xeno
	available_disguises = list("xenoborg-state-a")
	species_disguise = "High-tech alien-hunting robot"

/obj/item/clothing/head/cardborg/deathbot
	name = "black cardborg helmet"
	desc = "A helmet made out of a box. This one has been spray-painted black."
	icon_state = "cardborg_h_deathbot"
	dog_fashion = /datum/dog_fashion/head/cardborg/deathbot
	available_disguises = list("nano_bloodhound", "syndie_bloodhound", "syndi-medi", "syndi-engi", "ertgamma", "spidersyndi", "syndieheavy")
	species_disguise = "High-tech killer robot"

/*
 * Cardborg Suits.
*/
/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them."
	icon = 'icons/obj/clothing/suits/cardborg.dmi'
	icon_state = "cardborg"
	inhand_icon_state = "cardborg"
	worn_icon = 'icons/mob/clothing/suits/cardborg.dmi'
	dog_fashion = /datum/dog_fashion/back
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags_inv = HIDEJUMPSUIT
	species_disguise = "High-tech robot"

/obj/item/clothing/suit/cardborg/examine_more(mob/user)
	. = ..()
	. += "For reasons unknown to robotics experts across the galaxy, putting on a costume fashioned out of cardboard with some knobbly bits stuck on, \
	some buttons drawn on in pen, and moving in a stereotypical 'robotic' fashion causes the wearer to be perceived as being an actual robot by other robots, \
	cyborgs, and AI systems. The mechanism behind this is not understood, but it is not foolproof, as they may use contextual information and other clues in order to see through the ruse."
	. += ""
	. += "The wearer may also hallucinate themselves as being a robot as well."

/obj/item/clothing/suit/cardborg/security
	name = "red cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted red."
	icon_state = "cardborg_security"
	species_disguise = "High-tech security robot"

/obj/item/clothing/suit/cardborg/engineering
	name = "orange cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted orange."
	icon_state = "cardborg_engineering"
	species_disguise = "High-tech engineering robot"

/obj/item/clothing/suit/cardborg/mining
	name = "brown cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted brown."
	icon_state = "cardborg_mining"
	species_disguise = "High-tech mining robot"

/obj/item/clothing/suit/cardborg/service
	name = "green cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted green."
	icon_state = "cardborg_service"
	species_disguise = "High-tech service robot"

/obj/item/clothing/suit/cardborg/medical
	name = "blue cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted blue."
	icon_state = "cardborg_medical"
	species_disguise = "High-tech medical robot"

/obj/item/clothing/suit/cardborg/janitor
	name = "purple cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted purple."
	icon_state = "cardborg_janitor"
	species_disguise = "High-tech janitor robot"

/obj/item/clothing/suit/cardborg/xeno
	name = "white cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted white."
	icon_state = "cardborg_xeno"
	species_disguise = "High-tech alien-hunting robot"

/obj/item/clothing/suit/cardborg/deathbot
	name = "black cardborg suit"
	desc = "A full-body suit made out of ordinary cardboard boxes with various holes cut into them. This one has been spray-painted black."
	icon_state = "cardborg_deathbot"
	species_disguise = "High-tech killer robot"

/*
 * Disguise code.
*/
/obj/item/clothing/head/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && slot == ITEM_SLOT_HEAD)
		var/mob/living/carbon/human/H = user
		if(!istype(H.wear_suit, /obj/item/clothing/suit/cardborg))
			return
		var/obj/item/clothing/suit/cardborg/CB = H.wear_suit
		CB.apply_borg_disguise(user, src)

/obj/item/clothing/head/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("selected_borg_disguise")

/obj/item/clothing/suit/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && slot == ITEM_SLOT_OUTER_SUIT)
		var/mob/living/carbon/human/H = user
		if(!istype(H.head, /obj/item/clothing/head/cardborg))
			return
		var/obj/item/clothing/head/cardborg/head = H.head
		apply_borg_disguise(user, head)

/obj/item/clothing/suit/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("selected_borg_disguise")

/obj/item/clothing/suit/cardborg/proc/apply_borg_disguise(mob/living/carbon/human/H, obj/item/clothing/head/cardborg/borghead)
	if(!istype(H) || !istype(borghead))
		return
	if(species_disguise != borghead.species_disguise)	// Ensure the head and body are the same colour.
		to_chat(H, "<span class='warning'>The colours of the cardborg helmet and suit do not match, the disguise is not convincing enough to work!</span>")
		return
	var/selected_borg_disguise = pick(borghead.available_disguises)
	var/selected_borg_eyes
	var/list/borgs_with_shared_eyes = list("Cricket", "Standard")	// Some borg eyes are used by multiple different sprites. These cases require special handling.
	var/list/skin_to_truncate = splittext(selected_borg_disguise, "-")
	var/truncated_skin = trim(skin_to_truncate[1])	// Slice off the suffix of the skin variant's name so it matches the name of the eyes it is supposed to pair with.
	if(truncated_skin in borgs_with_shared_eyes)
		selected_borg_eyes = truncated_skin
	else
		selected_borg_eyes = selected_borg_disguise	// Otherwise the eyes are already bespoke for the skin so we just match them.
	var/image/I = image(icon = 'icons/mob/robots.dmi' , icon_state = selected_borg_disguise, loc = H)	// Now you're a robot!
	I.override = TRUE
	I.overlays += image(icon = 'icons/mob/robots.dmi', icon_state = "eyes-[selected_borg_eyes]")	// Gotta look realistic! Check to see if the borg type has eyes - if yes, apply them.
	H.add_alt_appearance("selected_borg_disguise", I, GLOB.silicon_mob_list + H)	// You look like a robot to robots (including yourself because you're totally a robot)!
