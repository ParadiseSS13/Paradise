/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmetmaterials"
	w_class = WEIGHT_CLASS_NORMAL
	flags = HEADBANGPROTECT
	flags_cover = HEADCOVERSEYES
	item_state = "helmetmaterials"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/helmet
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi'
		)

/obj/item/clothing/head/helmet/attack_self(mob/user)
	if(can_toggle && !user.incapacitated())
		if(world.time > cooldown + toggle_cooldown)
			cooldown = world.time
			up = !up
			flags ^= visor_flags
			flags_inv ^= visor_flags_inv
			to_chat(user, "[up ? alt_toggle_message : toggle_message] \the [src]")
			update_icon(UPDATE_ICON_STATE)
			user.update_inv_head()

			if(active_sound)
				while(up)
					playsound(src.loc, "[active_sound]", 100, 0, 4)
					sleep(15)
			if(toggle_sound)
				playsound(src.loc, "[toggle_sound]", 100, 0, 4)

/obj/item/clothing/head/helmet/visor
	name = "visor helmet"
	desc = "A helmet with a built-in visor. It doesn't seem to do anything, but it sure looks cool!"
	icon_state = "helmetgoggles"

/obj/item/clothing/head/helmet/thermal
	name = "thermal visor helmet"
	desc = "A helmet with a built-in thermal scanning visor."
	icon_state = "helmetthermals"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/head/helmet/meson
	name = "meson visor helmet"
	desc = "A helmet with a built-in meson scanning visor."
	icon_state = "helmetmesons"

/obj/item/clothing/head/helmet/meson/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == slot_head)
		ADD_TRAIT(user, TRAIT_MESON_VISION, "meson_helmet[UID()]")

/obj/item/clothing/head/helmet/meson/dropped(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_MESON_VISION, "meson_helmet[UID()]")

/obj/item/clothing/head/helmet/material
	name = "material visor helmet"
	desc = "A helmet with a built-in material scanning visor."
	icon_state = "helmetmaterials"
	vision_flags = SEE_OBJS

/obj/item/clothing/head/helmet/night
	name = "night-vision helmet"
	desc = "A helmet with a built-in pair of night vision goggles."
	icon_state = "helmetNVG"
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these

/obj/item/clothing/head/helmet/alt
	name = "bulletproof helmet"
	desc = "A bulletproof helmet that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "bulletproof"
	item_state = "bulletproof"
	armor = list(MELEE = 10, BULLET = 50, LASER = 5, ENERGY = 5, BOMB = 45, RAD = 0, FIRE = 50, ACID = 50)
	dog_fashion = null

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	armor = list(MELEE = 50, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 200, ACID = 200)
	flags_inv = HIDEEARS
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/riot/knight
	name = "medieval helmet"
	desc = "A classic metal helmet."
	icon_state = "knight_green"
	item_state = "knight_green"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	dog_fashion = null

/obj/item/clothing/head/helmet/justice
	name = "helmet of justice"
	desc = "WEEEEOOO. WEEEEEOOO. WEEEEOOOO."
	icon_state = "justice"
	toggle_message = "You turn off the lights on"
	alt_toggle_message = "You turn on the lights on"
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	can_toggle = 1
	toggle_cooldown = 20
	active_sound = 'sound/items/weeoo1.ogg'
	dog_fashion = null

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
	item_state = "swat"

	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 50, RAD = 10, FIRE = 50, ACID = 50)
	flags = BLOCKHAIR

	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/swat/syndicate
	name = "blood-red helmet"
	desc = "An extremely robust, space-worthy helmet without a visor to allow for goggle usage underneath. Property of Gorlex Marauders."
	icon_state = "helmetsyndi"
	item_state = "helmet"

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	flags = null
	item_state = "thunderdome"
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = 450, ACID = 450)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	flags = null
	armor = list(MELEE = 15, BULLET = 0, LASER = 15, ENERGY = 5, BOMB = 5, RAD = 0, FIRE = INFINITY, ACID = 50)
	resistance_flags = FIRE_PROOF
	icon_state = "roman"
	item_state = "roman"
	strip_delay = 100
	dog_fashion = /datum/dog_fashion/head/roman

/obj/item/clothing/head/helmet/roman/fake
	desc = "An ancient helmet made of plastic and leather."
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/roman/legionaire/fake
	desc = "An ancient helmet made of plastic and leather. Has a red crest on top of it."
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = BLOCKHAIR
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	toggle_message = "You attach the face shield to the"
	alt_toggle_message = "You remove the face shield from the"
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	can_toggle = 1
	toggle_cooldown = 20
	toggle_sound = 'sound/items/zippoclose.ogg'
	dog_fashion = null

/obj/item/clothing/head/helmet/redtaghelm
	name = "red laser tag helmet"
	desc = "They have chosen their own end."
	icon_state = "redtaghelm"
	flags = null
	item_state = "redtaghelm"
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 0, ACID = 50)
	// Offer about the same protection as a hardhat.
	flags_inv = HIDEEARS|HIDEEYES
	dog_fashion = null

/obj/item/clothing/head/helmet/bluetaghelm
	name = "blue laser tag helmet"
	desc = "They'll need more men."
	icon_state = "bluetaghelm"
	flags = null
	item_state = "bluetaghelm"
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 0, ACID = 50)
	// Offer about the same protection as a hardhat.
	flags_inv = HIDEEARS|HIDEEYES
	dog_fashion = null

/obj/item/clothing/head/blob
	name = "blob hat"
	desc = "A collectable hat handed out at the latest Blob Family Reunion."
	icon_state = "blobhat"
	item_state = "blobhat"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi'
		)

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
	armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, RAD = 0, FIRE = 200, ACID = 200)

/obj/item/clothing/head/helmet/skull
	name = "skull helmet"
	desc = "An intimidating tribal helmet, it doesn't look very comfortable."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(MELEE = 25, BULLET = 15, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	icon_state = "skull"
	item_state = "skull"
	strip_delay = 100

/obj/item/clothing/head/helmet/durathread
	name = "durathread helmet"
	desc = "A helmet made from durathread and leather."
	icon_state = "durathread"
	item_state = "durathread"
	resistance_flags = FLAMMABLE
	armor = list(MELEE = 10, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 35, ACID = 50)
	strip_delay = 60

/obj/item/clothing/head/helmet/street_judge
	name = "judge's helmet"
	desc = "Commonly used security headgear for the more theatrically inclined. Wear this in hostage situations to make everything worse."
	icon_state = "streetjudge_hat"

//Commander
/obj/item/clothing/head/helmet/ert/command
	name = "emergency response team commander helmet"
	desc = "An in-atmosphere helmet worn by the commander of a Nanotrasen Emergency Response Team. Has blue highlights."
	icon_state = "erthelmet_cmd"

//Security
/obj/item/clothing/head/helmet/ert/security
	name = "emergency response team security helmet"
	desc = "An in-atmosphere helmet worn by security members of the Nanotrasen Emergency Response Team. Has red highlights."
	icon_state = "erthelmet_sec"

/obj/item/clothing/head/helmet/ert/security/paranormal
	name = "paranormal emergency response team helmet"
	desc = "An in-atmosphere helmet worn by paranormal members of the Nanotrasen Emergency Response Team. Has crusader sigils."
	icon_state = "knight_templar"
	item_state = "knight_templar"

//Engineer
/obj/item/clothing/head/helmet/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "An in-atmosphere helmet worn by engineering members of the Nanotrasen Emergency Response Team. Has orange highlights."
	icon_state = "erthelmet_eng"

//Medical
/obj/item/clothing/head/helmet/ert/medical
	name = "emergency response team medical helmet"
	desc = "A set of armor worn by medical members of the Nanotrasen Emergency Response Team. Has red and white highlights."
	icon_state = "erthelmet_med"

//Janitorial
/obj/item/clothing/head/helmet/ert/janitor
	name = "emergency response team janitor helmet"
	desc = "A set of armor worn by janitorial members of the Nanotrasen Emergency Response Team. Has red and white highlights."
	icon_state = "erthelmet_jan"
