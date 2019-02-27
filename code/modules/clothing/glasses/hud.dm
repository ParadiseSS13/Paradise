/obj/item/clothing/glasses/hud
	name = "\improper HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = null //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	var/HUDType = null //Hudtype is defined on glasses.dm
	prescription_upgradable = 1
	var/list/icon/current = list() //the current hud icons


/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot)
	..()
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
	origin_tech = "magnets=3;biotech=2"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
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
	origin_tech = "magnets=4;biotech=4;plasmatech=4;engineering=5"
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM //don't render darkness while wearing these
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/diagnostic
	name = "Diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	origin_tech = "magnets=2;engineering=2"
	HUDType = DATA_HUD_DIAGNOSTIC
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "Night Vision Diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	item_state = "glasses"
	origin_tech = "magnets=4;powerstorage=4;plasmatech=4;engineering=5"
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM //don't render darkness while wearing these
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/security
	name = "\improper Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	origin_tech = "magnets=3;combat=2"
	var/global/list/jobs[0]
	HUDType = DATA_HUD_SECURITY_ADVANCED
	var/read_only = FALSE
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
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

/obj/item/clothing/glasses/hud/security/night
	name = "\improper Night Vision Security HUD"
	desc = "An advanced heads-up display which provides id data and vision in complete darkness."
	icon_state = "securityhudnight"
	origin_tech = "magnets=4;combat=4;plasmatech=4;engineering=5"
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM //don't render darkness while wearing these
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/security/sunglasses/read_only
	read_only = TRUE

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	origin_tech = "magnets=3;combat=3;engineering=3"
	darkness_view = 1
	flash_protect = 1
	tint = 1
	prescription_upgradable = 1
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/security/sunglasses/prescription
	prescription = 1

/obj/item/clothing/glasses/hud/hydroponic
	name = "Hydroponic HUD"
	desc = "A heads-up display capable of analyzing the health and status of plants growing in hydro trays and soil."
	icon_state = "hydroponichud"
	HUDType = DATA_HUD_HYDROPONIC
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/hydroponic/night
	name = "Night Vision Hydroponic HUD"
	desc = "A hydroponic HUD fitted with a light amplifier."
	icon_state = "hydroponichudnight"
	item_state = "glasses"
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM //don't render darkness while wearing these
	prescription_upgradable = 0

/obj/item/clothing/glasses/hud/security/tajblind
	name = "sleek veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an in-built security HUD."
	icon_state = "tajblind_sec"
	item_state = "tajblind_sec"
	flags_cover = GLASSESCOVERSEYES
	actions_types = list(/datum/action/item_action/toggle)
	up = 0

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

/obj/item/clothing/glasses/hud/health/tajblind/attack_self()
	toggle_veil()
