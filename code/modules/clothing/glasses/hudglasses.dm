/obj/item/clothing/glasses/hud
	name = "\improper HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags_cover = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	prescription_upgradable = TRUE
	/// The visual icons granted by wearing these glasses.
	var/hud_types = null
	/// Whether we want this hud be able to override id card access requirement to alter security records
	var/hud_access_override = FALSE
	/// Used for debug huds at examine.dm, gives us all rights for records
	var/hud_debug = FALSE

/obj/item/clothing/glasses/hud/Initialize(mapload)
	. = ..()
	if(!islist(hud_types) && hud_types)
		hud_types = list(hud_types)

/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot != ITEM_SLOT_EYES)
		return
	for(var/new_hud in hud_types)
		var/datum/atom_hud/H = GLOB.huds[new_hud]
		H.add_hud_to(user)

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	..()
	if(istype(user) && user.glasses != src)
		return
	for(var/new_hud in hud_types)
		var/datum/atom_hud/H = GLOB.huds[new_hud]
		H.remove_hud_from(user)

/obj/item/clothing/glasses/hud/emp_act(severity)
	if(!emagged)
		emagged = TRUE
		desc = desc + " The display flickers slightly."

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	hud_types = DATA_HUD_MEDICAL_ADVANCED

/obj/item/clothing/glasses/hud/health/night
	name = "night vision health scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	origin_tech = "magnets=4;biotech=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/health/sunglasses
	name = "medical HUDSunglasses"
	desc = "Sunglasses with a medical HUD."
	icon_state = "sunhudmed"
	inhand_icon_state = "sunglasses"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH
	hide_examine = TRUE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	origin_tech = "magnets=2;engineering=2"
	hud_types = DATA_HUD_DIAGNOSTIC_BASIC

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "night vision diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	origin_tech = "magnets=4;powerstorage=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/diagnostic/sunglasses
	name = "diagnostic sunglasses"
	desc = "Sunglasses with a diagnostic HUD."
	icon_state = "sunhuddiag"
	inhand_icon_state = "sunglasses"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	origin_tech = "magnets=3;combat=2"
	var/global/list/jobs[0]
	hud_types = DATA_HUD_SECURITY_ADVANCED

/obj/item/clothing/glasses/hud/security/night
	name = "night vision security HUD"
	desc = "An advanced heads-up display which provides id data and vision in complete darkness."
	icon_state = "securityhudnight"
	origin_tech = "magnets=4;combat=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	inhand_icon_state = "sunglasses"
	origin_tech = "magnets=3;combat=3;engineering=3"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	hide_examine = TRUE
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/security/sunglasses/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/security/sunglasses/prescription
	prescription = TRUE

/obj/item/clothing/glasses/hud/hydroponic
	name = "hydroponic HUD"
	desc = "A heads-up display capable of analyzing the health and status of plants growing in hydro trays and soil."
	icon_state = "hydroponichud"
	hud_types = DATA_HUD_HYDROPONIC

/obj/item/clothing/glasses/hud/hydroponic/night
	name = "night vision hydroponic HUD"
	desc = "A hydroponic HUD fitted with a light amplifier."
	icon_state = "hydroponichudnight"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/skills
	name = "skills HUD"
	desc = "A heads-up display capable of showing the employment history records of NT crew members."
	icon_state = "skill"
	hud_types = DATA_HUD_SECURITY_BASIC

/obj/item/clothing/glasses/hud/skills/sunglasses
	name = "skills HUD sunglasses"
	desc = "Sunglasses with a build-in skills HUD, showing the employment history of nearby NT crew members."
	icon_state = "sunhudskill"
	inhand_icon_state = "sunglasses"
	see_in_dark = 1 // None of these three can be converted to booleans. Do not try it.
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/janitor
	name = "janitor HUD"
	desc = "A heads-up display that scans for messes and alerts the user. Good for finding puddles hiding under catwalks."
	icon_state = "janihud"
	hud_types = DATA_HUD_JANITOR

/obj/item/clothing/glasses/hud/janitor/sunglasses
	name = "janitor HUD sunglasses"
	desc = "Sunglasses with a build-in filth scanner, scans for messes and alerts the user."
	icon_state = "sunhudjani"
	inhand_icon_state = "sunglasses"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH
	hide_examine = TRUE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	flags_cover = GLASSESCOVERSEYES

/obj/item/clothing/glasses/hud/janitor/night
	name = "night vision janitor HUD"
	desc = "A janitorial filth scanner fitted with a light amplifier."
	icon_state = "nvjanihud"
	origin_tech = "magnets=4;biotech=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/eyes.dmi'
	flags_cover = GLASSESCOVERSEYES
