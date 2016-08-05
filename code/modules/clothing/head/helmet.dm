/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmetmaterials"
	flags = HEADCOVERSEYES | HEADBANGPROTECT
	item_state = "helmetmaterials"
	armor = list(melee = 30, bullet = 25, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	burn_state = FIRE_PROOF
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/helmet.dmi',
		"Drask" = 'icons/mob/species/drask/helmet.dmi'
		)

/obj/item/clothing/head/helmet/attack_self(mob/user)
	if(can_toggle && !user.incapacitated())
		if(world.time > cooldown + toggle_cooldown)
			cooldown = world.time
			up = !up
			flags ^= visor_flags
			flags_inv ^= visor_flags_inv
			icon_state = "[initial(icon_state)][up ? "up" : ""]"
			to_chat(user, "[up ? alt_toggle_message : toggle_message] \the [src]")

			user.update_inv_head()

			if(active_sound)
				while(up)
					playsound(src.loc, "[active_sound]", 100, 0, 4)
					sleep(15)


/obj/item/clothing/head/helmet/visor
	name = "visor helmet"
	desc = "A helmet with a built-in visor. It doesn't seem to do anything, but it sure looks cool!"
	icon_state = "helmetgoggles"

/obj/item/clothing/head/helmet/thermal
	name = "thermal visor helmet"
	desc = "A helmet with a built-in thermal scanning visor."
	icon_state = "helmetthermals"
	vision_flags = SEE_MOBS

/obj/item/clothing/head/helmet/meson
	name = "meson visor helmet"
	desc = "A helmet with a built-in meson scanning visor."
	icon_state = "helmetmesons"
	vision_flags = SEE_TURFS

/obj/item/clothing/head/helmet/material
	name = "material visor helmet"
	desc = "A helmet with a built-in material scanning visor."
	icon_state = "helmetmaterials"
	vision_flags = SEE_OBJS

/obj/item/clothing/head/helmet/night
	name = "night-vision helmet"
	desc = "A helmet with a built-in pair of night vision goggles."
	icon_state = "helmetNVG"
	see_darkness = 0

/obj/item/clothing/head/helmet/alt
	name = "bulletproof helmet"
	desc = "A bulletproof helmet that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "swat"
	item_state = "swat-alt"
	armor = list(melee = 15, bullet = 40, laser = 10, energy = 10, bomb = 40, bio = 0, rad = 0)
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/helmet.dmi',
		"Drask" = 'icons/mob/species/drask/helmet.dmi'
		)

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH | HEADBANGPROTECT
	armor = list(melee = 41, bullet = 15, laser = 5, energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	strip_delay = 80

/obj/item/clothing/head/helmet/riot/knight
	name = "medieval helmet"
	desc = "A classic metal helmet."
	icon_state = "knight_green"
	item_state = "knight_green"
	flags = BLOCKHAIR|HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/head/helmet/justice
	name = "helmet of justice"
	desc = "WEEEEOOO. WEEEEEOOO. WEEEEOOOO."
	icon_state = "justice"
	toggle_message = "You turn off the lights on"
	alt_toggle_message = "You turn on the lights on"
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	can_toggle = 1
	toggle_cooldown = 20
	active_sound = 'sound/items/WEEOO1.ogg'

/obj/item/clothing/head/helmet/justice/escape
	name = "alarm helmet"
	desc = "WEEEEOOO. WEEEEEOOO. STOP THAT MONKEY. WEEEOOOO."
	icon_state = "justice2"
	toggle_message = "You turn off the light on"
	alt_toggle_message = "You turn on the light on"


/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "They're often used by highly trained Swat Members."
	icon_state = "swat"
	flags = HEADCOVERSEYES
	item_state = "swat"
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 30, bomb = 50, bio = 90, rad = 20)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi',
		"Drask" = 'icons/mob/species/drask/helmet.dmi'
		)

/obj/item/clothing/head/helmet/swat/syndicate
	name = "blood-red helmet"
	desc = "An extremely robust, space-worthy helmet without a visor to allow for goggle usage underneath. Property of Gorlex Marauders."
	icon_state = "helmetsyndi"
	item_state = "helmet"

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags = HEADCOVERSEYES
	item_state = "thunderdome"
	armor = list(melee = 40, bullet = 30, laser = 25, energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	flags = HEADCOVERSEYES
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"
	strip_delay = 100

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = HEADCOVERSEYES | BLOCKHAIR
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

obj/item/clothing/head/helmet/redtaghelm
	name = "red laser tag helmet"
	desc = "They have chosen their own end."
	icon_state = "redtaghelm"
	flags = HEADCOVERSEYES
	item_state = "redtaghelm"
	armor = list(melee = 15, bullet = 10, laser = 20, energy = 10, bomb = 20, bio = 0, rad = 0)
	// Offer about the same protection as a hardhat.
	flags_inv = HIDEEARS|HIDEEYES

obj/item/clothing/head/helmet/bluetaghelm
	name = "blue laser tag helmet"
	desc = "They'll need more men."
	icon_state = "bluetaghelm"
	flags = HEADCOVERSEYES
	item_state = "bluetaghelm"
	armor = list(melee = 15, bullet = 10, laser = 20, energy = 10, bomb = 20, bio = 0, rad = 0)
	// Offer about the same protection as a hardhat.
	flags_inv = HIDEEARS|HIDEEYES

obj/item/clothing/head/blob
	name = "blob hat"
	desc = "A collectible hat handed out at the latest Blob Family Reunion."
	icon_state = "blobhat"
	item_state = "blobhat"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

/obj/item/clothing/head/helmet/riot/knight/blue
	icon_state = "knight_blue"
	item_state = "knight_blue"

/obj/item/clothing/head/helmet/riot/knight/yellow
	icon_state = "knight_yellow"
	item_state = "knight_yellow"

/obj/item/clothing/head/helmet/riot/knight/red
	icon_state = "knight_red"
	item_state = "knight_red"

/obj/item/clothing/head/helmet/riot/knight/templar
	name = "crusader helmet"
	desc = "Deus Vult."
	icon_state = "knight_templar"
	item_state = "knight_templar"


//Commander
/obj/item/clothing/head/helmet/ert/command
	name = "emergency response team commander helmet"
	desc = "An in-atmosphere helmet worn by the commander of a NanoTrasen Emergency Response Team. Has blue highlights."
	icon_state = "erthelmet_cmd"

//Security
/obj/item/clothing/head/helmet/ert/security
	name = "emergency response team security helmet"
	desc = "An in-atmosphere helmet worn by security members of the NanoTrasen Emergency Response Team. Has red highlights."
	icon_state = "erthelmet_sec"

//Engineer
/obj/item/clothing/head/helmet/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "An in-atmosphere helmet worn by engineering members of the NanoTrasen Emergency Response Team. Has orange highlights."
	icon_state = "erthelmet_eng"

//Medical
/obj/item/clothing/head/helmet/ert/medical
	name = "emergency response team medical helmet"
	desc = "A set of armor worn by medical members of the NanoTrasen Emergency Response Team. Has red and white highlights."
	icon_state = "erthelmet_med"

//Medical
/obj/item/clothing/head/helmet/ert/janitor
	name = "emergency response team janitor helmet"
	desc = "A set of armor worn by janitorial members of the NanoTrasen Emergency Response Team. Has red and white highlights."
	icon_state = "erthelmet_jan"
