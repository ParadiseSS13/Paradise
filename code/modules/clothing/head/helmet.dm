/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "A mass-produced protective helmet used by security personnel across the sector. Provides light protection against most sources of damage."
	icon_state = "helmetmaterials"
	w_class = WEIGHT_CLASS_NORMAL
	flags = HEADBANGPROTECT
	flags_cover = HEADCOVERSEYES
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	flags_inv = HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/helmet
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/helmet.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi'
		)
	permeability_coefficient = 0.4

/obj/item/clothing/head/helmet/attack_self__legacy__attackchain(mob/user)
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
					playsound(src.loc, "[active_sound]", 100, FALSE, 4)
					sleep(15)
			if(toggle_sound)
				playsound(src.loc, "[toggle_sound]", 100, FALSE, 4)

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
	if(slot == ITEM_SLOT_HEAD)
		ADD_TRAIT(user, TRAIT_MESON_VISION, "meson_helmet[UID()]")

/obj/item/clothing/head/helmet/meson/dropped(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_MESON_VISION, "meson_helmet[UID()]")

/obj/item/clothing/head/helmet/material
	name = "material visor helmet"
	desc = "A helmet with a built-in material scanning visor."
	vision_flags = SEE_OBJS | SEE_TURFS

/obj/item/clothing/head/helmet/night
	name = "night-vision helmet"
	desc = "A helmet with a built-in pair of night vision goggles."
	icon_state = "helmetNVG"
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these

/obj/item/clothing/head/helmet/alt
	name = "bulletproof helmet"
	desc = "A durable combat helmet reinforced with strike plates and cushioning to protect against high-velocity kinetic impacts and the concussive force of explosions. Does little to stop energy weapons or melee hits."
	icon_state = "bulletproof"
	armor = list(MELEE = 10, BULLET = 50, LASER = 5, ENERGY = 5, BOMB = 45, RAD = 0, FIRE = 50, ACID = 50)
	dog_fashion = null

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "A large, bulky helmet reinforced with impact plates and shock-absorbing gel to protect against melee attacks. The helmet is treated with a fire and acid-resistant surface coating, and the attached plexiglass visor should prevent things from jumping on your face."
	icon_state = "riot"
	armor = list(MELEE = 50, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 200, ACID = 200)
	flags_inv = HIDEEARS
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 80
	dog_fashion = null
	permeability_coefficient = 0.01

/obj/item/clothing/head/helmet/riot/knight
	name = "medieval helmet"
	desc = "A majestic knightly helm made of steel. Protects well against melee attacks, but don't try taking a bullet with it."
	icon_state = "knight_green"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	dog_fashion = null

/obj/item/clothing/head/helmet/justice
	name = "helmet of justice"
	desc = "A standard Security helmet with a pair of police lights crudely screwed to the sides. Any hearing loss caused by this contraption is not service related."
	icon_state = "justice"
	toggle_message = "You turn off the lights"
	alt_toggle_message = "You turn on the lights"
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	can_toggle = 1
	toggle_cooldown = 20
	active_sound = 'sound/items/weeoo1.ogg'
	dog_fashion = null

/obj/item/clothing/head/helmet/justice/escape
	name = "alarm helmet"
	desc = "WEEEEOOO. WEEEEEOOO. STOP THAT MONKEY. WEEEOOOO."
	icon_state = "justice2"
	toggle_message = "You turn off the light"
	alt_toggle_message = "You turn on the light"

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "A menacing black combat helmet used by police assault units. Provides moderate protection against all threats."
	icon_state = "swat"
	inhand_icon_state = "swat_hel"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 50, RAD = 10, FIRE = 50, ACID = 50)
	flags = BLOCKHAIR
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/swat/syndicate
	name = "blood-red helmet"
	desc = "An extremely robust, space-worthy helmet without a visor to allow for goggle usage underneath. Property of Gorlex Marauders."
	icon_state = "helmetsyndi"

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	icon_state = "thunderdome"
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = 450, ACID = 450)
	flags = null
	flags_2 = RAD_PROTECT_CONTENTS_2
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/roman
	name = "legionnaire helmet"
	desc = "A lovingly-crafted helmet based off examples used by Roman legionnaires. Provides light protection against melee and laser impacts. It's also completely fireproof!"
	flags = null
	armor = list(MELEE = 15, BULLET = 0, LASER = 15, ENERGY = 5, BOMB = 5, RAD = 0, FIRE = INFINITY, ACID = 50)
	resistance_flags = FIRE_PROOF
	icon_state = "roman"
	strip_delay = 100
	dog_fashion = /datum/dog_fashion/head/roman

/obj/item/clothing/head/helmet/roman/fake
	desc = "A shoddily-crafted cosplay helmet made of plastic. Protects against jack and shit, if you're lucky."
	armor = null

/obj/item/clothing/head/helmet/roman/legionaire
	name = "centurion helmet"
	desc = "A lovingly-crafted helmet based off those used by Roman centurions. Provides light protection against melee and laser impacts, is completely fireproof, and has a fancy crest on top!"
	icon_state = "roman_c"

/obj/item/clothing/head/helmet/roman/legionaire/fake
	desc = "A shoddily-crafted cosplay helmet made of plastic. This particular specimen has what appears to be the head of a broom crudely taped to the top."
	armor = null

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = BLOCKHAIR
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
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 0, ACID = 50)
	// Offer about the same protection as a hardhat.
	dog_fashion = null

/obj/item/clothing/head/helmet/bluetaghelm
	name = "blue laser tag helmet"
	desc = "They'll need more men."
	icon_state = "bluetaghelm"
	flags = null
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 0, ACID = 50)
	// Offer about the same protection as a hardhat.
	dog_fashion = null

/obj/item/clothing/head/blob
	name = "blob hat"
	desc = "A collectable hat handed out at the latest Blob Family Reunion."
	icon_state = "blobhat"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/helmet.dmi')

/obj/item/clothing/head/helmet/riot/knight/blue
	icon_state = "knight_blue"

/obj/item/clothing/head/helmet/riot/knight/yellow
	icon_state = "knight_yellow"

/obj/item/clothing/head/helmet/riot/knight/red
	icon_state = "knight_red"

/obj/item/clothing/head/helmet/riot/knight/templar
	name = "crusader helmet"
	desc = "A cheap metal helmet that looks straight out of a poorly-funded documentary about the crusades. Might stop a crude melee weapon. The asbestos-lined padding <b>does</b> provide great protection from fire and acid, however..."
	icon_state = "knight_templar"
	armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, RAD = 0, FIRE = 200, ACID = 200)

/obj/item/clothing/head/helmet/skull
	name = "skull helmet"
	desc = "An intimidating tribal helmet, it looks sick as hell."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(MELEE = 25, BULLET = 15, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	icon_state = "skull"
	strip_delay = 100
	sprite_sheets = list("Grey" = 'icons/mob/clothing/species/grey/head.dmi')

/obj/item/clothing/head/helmet/durathread
	name = "durathread helmet"
	desc = "A helmet made from durathread and leather."
	icon_state = "durathread"
	armor = list(MELEE = 10, BULLET = 5, LASER = 20, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 35, ACID = 50)
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi'
	)


/obj/item/clothing/head/helmet/street_judge
	name = "judge's helmet"
	desc = "Commonly used security headgear for the more theatrically inclined. Wear this in hostage situations to make everything worse."
	icon_state = "streetjudge_hat"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/head.dmi'
	)

// Replica
/obj/item/clothing/head/helmet/fake
	name = "replica helmet"
	desc = "A replica of a mass-produced protective helmet used by security personnel across the sector. Made of cheap plastic and provides no protection."
	armor = null
	cold_protection = FALSE
	heat_protection = FALSE

//Commander
/obj/item/clothing/head/helmet/ert/command
	name = "emergency response team commander helmet"
	desc = "A mid-quality combat helmet produced by Citadel Armories. The visor is made of toughened plastic and the radio antenna is entirely decorative. This one has chipped blue Command stripes."
	icon_state = "erthelmet_cmd"

//Security
/obj/item/clothing/head/helmet/ert/security
	name = "emergency response team security helmet"
	desc = "A mid-quality combat helmet produced by Citadel Armories. The visor is made of toughened plastic and the radio antenna is entirely decorative. This one has chipped red Security stripes."
	icon_state = "erthelmet_sec"

/obj/item/clothing/head/helmet/ert/security/paranormal
	name = "paranormal emergency response team helmet"
	desc = "An antique steel helmet that looks straight out of a poorly-funded documentary about the Crusades. Where the hell did they even find this?"
	icon_state = "knight_templar"

//Engineer
/obj/item/clothing/head/helmet/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "A mid-quality combat helmet produced by Citadel Armories. The visor is made of toughened plastic and the radio antenna is entirely decorative. This one has chipped orange Engineering stripes."
	icon_state = "erthelmet_eng"

//Medical
/obj/item/clothing/head/helmet/ert/medical
	name = "emergency response team medical helmet"
	desc = "A mid-quality combat helmet produced by Citadel Armories. The visor is made of toughened plastic and the radio antenna is entirely decorative. This one has chipped white Medical stripes."
	icon_state = "erthelmet_med"

//Janitorial
/obj/item/clothing/head/helmet/ert/janitor
	name = "emergency response team janitor helmet"
	desc = "A mid-quality combat helmet produced by Citadel Armories. The visor is made of toughened plastic and the radio antenna is entirely decorative. This one has chipped purple Janitorial stripes."
	icon_state = "erthelmet_jan"

//Federation
/obj/item/clothing/head/helmet/federation/marine
	name = "\improper Federation marine combat helmet"
	desc = "A powered combat helmet used by the Trans-Solar Marine Corps. Provides excellent protection in all areas, while a modern OCULUS array augments the wearer's vision."
	icon_state = "fedhelmet_marine"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/head.dmi'
	)
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	flash_protect = FLASH_PROTECTION_WELDER
	armor = list(MELEE = 40, BULLET = 45, LASER = 45, ENERGY = 40, BOMB = 100, RAD = 25, FIRE = INFINITY, ACID = 100)
	strip_delay = 130

/obj/item/clothing/head/helmet/federation/marine/export
	name = "\improper Federation marine combat helmet (E)"
	desc = "An export-grade combat helmet commonly given or sold to allies of the Trans-Solar Federation. The OCULUS system has been removed, and its protection is generally inferior to its in-service counterpart."
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/head.dmi'
	)
	flags = BLOCKHAIR
	see_in_dark = 0
	lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	flash_protect = FLASH_PROTECTION_NONE
	armor = list(MELEE = 30, BULLET = 35, LASER = 35, ENERGY = 30, BOMB = 50, RAD = 0, FIRE = 100, ACID = 50)

/obj/item/clothing/head/helmet/federation/marine/officer
	name = "\improper Federation marine officer's combat helmet"
	desc = "A powered combat helmet used by officers of the Trans-Solar Marine Corps. Provides excellent protection in all areas, while a next-gen OCULUS array augments the wearer's vision."
	icon_state = "fedhelmet_marine_officer"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/head.dmi'
	)
	vision_flags = SEE_MOBS
	armor = list(MELEE = 40, BULLET = 45, LASER = 45, ENERGY = 40, BOMB = 100, RAD = 25, FIRE = INFINITY, ACID = 100)
