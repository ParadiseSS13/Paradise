/obj/item/clothing/glasses/hud
	name = "\improper HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	var/HUDType = null //Hudtype is defined on glasses.dm
	prescription_upgradable = 1
	var/list/icon/current = list() //the current hud icons


/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	if(HUDType && slot == slot_glasses)
		var/datum/atom_hud/H = huds[HUDType]
		H.add_hud_to(user)

/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user)
	..()
	if(HUDType && istype(user) && user.glasses == src)
		var/datum/atom_hud/H = huds[HUDType]
		H.remove_hud_from(user)

/obj/item/clothing/glasses/hud/emp_act(severity)
	if(emagged == 0)
		emagged = 1
		desc = desc + " The display flickers slightly."

/obj/item/clothing/glasses/hud/health
	name = "\improper Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/health/health_advanced
	name = "\improper Advanced Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status.  Includes anti-flash filter."
	icon_state = "advmedhud"
	flash_protect = 1

/obj/item/clothing/glasses/hud/health/night
	name = "\improper Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	item_state = "glasses"
	darkness_view = 8
	see_darkness = 0
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/diagnostic
	name = "Diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	HUDType = DATA_HUD_DIAGNOSTIC
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "Night Vision Diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	item_state = "glasses"
	darkness_view = 8
	see_darkness = 0
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/security
	name = "\improper Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	var/global/list/jobs[0]
	HUDType = DATA_HUD_SECURITY_ADVANCED
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/security/chameleon
	name = "Chameleon Security HUD"
	desc = "A stolen security HUD integrated with Syndicate chameleon technology. Toggle to disguise the HUD. Provides flash protection."
	flash_protect = 1

/obj/item/clothing/glasses/hud/security/chameleon/attack_self(mob/user)
	chameleon(user)

/obj/item/clothing/glasses/hud/security/sunglasses/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	item_state = "jensenshades"
	vision_flags = SEE_MOBS
	invisa_view = 2

/obj/item/clothing/glasses/hud/security/night
	name = "\improper Night Vision Security HUD"
	desc = "An advanced heads-up display which provides id data and vision in complete darkness."
	icon_state = "securityhudnight"
	darkness_view = 8
	see_darkness = 0
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	darkness_view = 1
	flash_protect = 1
	tint = 1
	prescription_upgradable = 1

/obj/item/clothing/glasses/hud/security/sunglasses/prescription
	prescription = 1

/obj/item/clothing/glasses/hud/hydroponic
	name = "Hydroponic HUD"
	desc = "A heads-up display capable of analyzing the health and status of plants growing in hydro trays and soil."
	icon_state = "hydroponichud"
	HUDType = DATA_HUD_HYDROPONIC
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/hydroponic/night
	name = "Night Vision Hydroponic HUD"
	desc = "A hydroponic HUD fitted with a light amplifier."
	icon_state = "hydroponichudnight"
	item_state = "glasses"
	darkness_view = 8
	see_darkness = 0
	prescription_upgradable = 0