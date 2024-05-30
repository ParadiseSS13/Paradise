/obj/item/clothing/glasses/hud
	name = "\improper HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	prescription_upgradable = TRUE
	/// The visual icons granted by wearing these glasses.
	var/hud_types = null
	/// List of things added to examine text, like security or medical records.
	var/list/examine_extensions = null

/obj/item/clothing/glasses/hud/Initialize(mapload)
	. = ..()
	if(!islist(hud_types) && hud_types)
		hud_types = list(hud_types)

/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot != SLOT_HUD_GLASSES)
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
	origin_tech = "magnets=3;biotech=2"
	hud_types = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = list(EXAMINE_HUD_MEDICAL_READ)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/health/night
	name = "night vision health scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	item_state = "glasses"
	origin_tech = "magnets=4;biotech=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/health/sunglasses
	name = "medical HUDSunglasses"
	desc = "Sunglasses with a medical HUD."
	icon_state = "sunhudmed"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	origin_tech = "magnets=2;engineering=2"
	hud_types = DATA_HUD_DIAGNOSTIC_BASIC

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "night vision diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	item_state = "glasses"
	origin_tech = "magnets=4;powerstorage=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/diagnostic/sunglasses
	name = "diagnostic sunglasses"
	desc = "Sunglasses with a diagnostic HUD."
	icon_state = "sunhuddiag"
	item_state = "glasses"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	origin_tech = "magnets=3;combat=2"
	var/global/list/jobs[0]
	hud_types = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = list(EXAMINE_HUD_SECURITY_READ)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)


/obj/item/clothing/glasses/hud/security/sunglasses/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	item_state = "jensenshades"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/security/night
	name = "night vision security HUD"
	desc = "An advanced heads-up display which provides id data and vision in complete darkness."
	icon_state = "securityhudnight"
	origin_tech = "magnets=4;combat=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	origin_tech = "magnets=3;combat=3;engineering=3"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH
	prescription_upgradable = TRUE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/security/sunglasses/prescription
	prescription = TRUE

/obj/item/clothing/glasses/hud/hydroponic
	name = "hydroponic HUD"
	desc = "A heads-up display capable of analyzing the health and status of plants growing in hydro trays and soil."
	icon_state = "hydroponichud"
	hud_types = DATA_HUD_HYDROPONIC

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/hydroponic/night
	name = "night vision hydroponic HUD"
	desc = "A hydroponic HUD fitted with a light amplifier."
	icon_state = "hydroponichudnight"
	item_state = "glasses"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/skills
	name = "skills HUD"
	desc = "A heads-up display capable of showing the employment history records of NT crew members."
	icon_state = "skill"
	item_state = "glasses"
	hud_types = DATA_HUD_SECURITY_BASIC
	examine_extensions = list(EXAMINE_HUD_SKILLS)
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey"  = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/skills/sunglasses
	name = "skills HUD sunglasses"
	desc = "Sunglasses with a build-in skills HUD, showing the employment history of nearby NT crew members."
	icon_state = "sunhudskill"
	see_in_dark = 1 // None of these three can be converted to booleans. Do not try it.
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH
	prescription_upgradable = TRUE
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey"  = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/janitor
	name = "janitor HUD"
	desc = "A heads-up display that scans for messes and alerts the user. Good for finding puddles hiding under catwalks."
	icon_state = "janihud"
	hud_types = DATA_HUD_JANITOR

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/janitor/sunglasses
	name = "janitor HUD sunglasses"
	desc = "Sunglasses with a build-in filth scanner, scans for messes and alerts the user."
	icon_state = "sunhudjani"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = FLASH_PROTECTION_FLASH

/obj/item/clothing/glasses/hud/janitor/night
	name = "night vision janitor HUD"
	desc = "A janitorial filth scanner fitted with a light amplifier."
	icon_state = "nvjanihud"
	origin_tech = "magnets=4;biotech=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
