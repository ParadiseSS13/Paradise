/obj/item/clothing/glasses/hud
	name = "\improper HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	prescription_upgradable = 1
	/// The visual icons granted by wearing these glasses.
	var/HUDType = null
	/// List of things added to examine text, like security or medical records.
	var/list/examine_extensions = null


/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	..()
	if(HUDType && slot == slot_glasses)
		var/datum/atom_hud/H = GLOB.huds[HUDType]
		H.add_hud_to(user)

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	..()
	if(HUDType && istype(user) && user.glasses == src)
		var/datum/atom_hud/H = GLOB.huds[HUDType]
		H.remove_hud_from(user)

/obj/item/clothing/glasses/hud/emp_act(severity)
	if(emagged == 0)
		emagged = 1
		desc = desc + " The display flickers slightly."

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	origin_tech = "magnets=3;biotech=2"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = list(EXAMINE_HUD_MEDICAL)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/health/night
	name = "night vision health scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	item_state = "glasses"
	origin_tech = "magnets=4;biotech=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/health/sunglasses
	name = "medical HUDSunglasses"
	desc = "Sunglasses with a medical HUD."
	icon_state = "sunhudmed"
	see_in_dark = 1
	flash_protect = 1
	tint = 1

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	origin_tech = "magnets=2;engineering=2"
	HUDType = DATA_HUD_DIAGNOSTIC

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "night vision diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	item_state = "glasses"
	origin_tech = "magnets=4;powerstorage=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/diagnostic/sunglasses
	name = "diagnostic sunglasses"
	desc = "Sunglasses with a diagnostic HUD."
	icon_state = "sunhuddiag"
	item_state = "glasses"
	flash_protect = 1
	tint = 1

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	origin_tech = "magnets=3;combat=2"
	var/global/list/jobs[0]
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = list(EXAMINE_HUD_SECURITY_READ, EXAMINE_HUD_SECURITY_WRITE)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
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
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/security/sunglasses/read_only
	examine_extensions = list(EXAMINE_HUD_SECURITY_READ)

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	origin_tech = "magnets=3;combat=3;engineering=3"
	see_in_dark = 1
	flash_protect = 1
	tint = 1
	prescription_upgradable = 1

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/security/sunglasses/prescription
	prescription = 1

/obj/item/clothing/glasses/hud/hydroponic
	name = "hydroponic HUD"
	desc = "A heads-up display capable of analyzing the health and status of plants growing in hydro trays and soil."
	icon_state = "hydroponichud"
	HUDType = DATA_HUD_HYDROPONIC

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/hydroponic/night
	name = "night vision hydroponic HUD"
	desc = "A hydroponic HUD fitted with a light amplifier."
	icon_state = "hydroponichudnight"
	item_state = "glasses"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/security/tajblind
	name = "sleek veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an in-built security HUD."
	icon_state = "tajblind_sec"
	item_state = "tajblind_sec"
	flags_cover = GLASSESCOVERSEYES
	actions_types = list(/datum/action/item_action/toggle)
	up = 0

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/security/tajblind/attack_self()
	toggle_veil()

/obj/item/clothing/glasses/hud/health/tajblind
	name = "lightweight veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed medical HUD."
	icon_state = "tajblind_med"
	item_state = "tajblind_med"
	flags_cover = GLASSESCOVERSEYES
	actions_types = list(/datum/action/item_action/toggle)
	up = 0

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/health/tajblind/attack_self()
	toggle_veil()

/obj/item/clothing/glasses/hud/skills
	name = "skills HUD"
	desc = "A heads-up display capable of showing the employment history records of NT crew members."
	icon_state = "skill"
	item_state = "glasses"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = list(EXAMINE_HUD_SKILLS)
	sprite_sheets = list(
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey"  = 'icons/mob/species/grey/eyes.dmi',
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/skills/sunglasses
	name = "skills HUD sunglasses"
	desc = "Sunglasses with a build-in skills HUD, showing the employment history of nearby NT crew members."
	icon_state = "sunhudskill"
	see_in_dark = 1 // None of these three can be converted to booleans. Do not try it.
	flash_protect = 1
	tint = 1
	prescription_upgradable = TRUE
	sprite_sheets = list(
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey"  = 'icons/mob/species/grey/eyes.dmi',
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
	)
