/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Soviet Hats
 *		Pumpkin head
 *		Kitty ears
 *		Cardborg Disguise
 *		Head Mirror
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	item_state = "welding"
	materials = list(MAT_METAL=1750, MAT_GLASS=400)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = FLASH_PROTECTION_WELDER
	can_toggle = TRUE
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = INFINITY, ACID = 75)
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	resistance_flags = FIRE_PROOF

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi'
		)

/obj/item/clothing/head/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/head/welding/flamedecal
	name = "flame decal welding helmet"
	desc = "A welding helmet adorned with flame decals, and several cryptic slogans of varying degrees of legibility."
	icon_state = "welding_redflame"

/obj/item/clothing/head/welding/flamedecal/blue
	name = "blue flame decal welding helmet"
	desc = "A welding helmet with blue flame decals on it."
	icon_state = "welding_blueflame"

/obj/item/clothing/head/welding/white
	name = "white decal welding helmet"
	desc = "A white welding helmet with a character written across it."
	icon_state = "welding_white"

/*
 * Cakehat
 */
/obj/item/clothing/head/cakehat
	name = "cake-hat"
	desc = "It's tasty looking!"
	icon_state = "cake0"
	flags_cover = HEADCOVERSEYES
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	var/onfire = FALSE
	var/status = 0
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		STOP_PROCESSING(SSobj, src)
		return

	var/turf/location = loc
	if(ismob(location))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if(isturf(location))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/cakehat/attack_self(mob/user)
	if(status > 1)
		return
	onfire = !onfire
	if(onfire)
		force = 3
		damtype = BURN
		icon_state = "cake1"
		START_PROCESSING(SSobj, src)
	else
		force = null
		damtype = BRUTE
		icon_state = "cake0"


/*
 * Soviet Hats
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = "ushankadown"
	flags_inv = HIDEEARS
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head/ushanka
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
	"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
	)

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(icon_state == "ushankadown")
		icon_state = "ushankaup"
		item_state = "ushankaup"
		to_chat(user, "You raise the ear flaps on the ushanka.")
	else
		icon_state = "ushankadown"
		item_state = "ushankadown"
		to_chat(user, "You lower the ear flaps on the ushanka.")

/obj/item/clothing/head/sovietsidecap
	name = "\improper Soviet side cap"
	desc = "A simple military cap with a Soviet star on the front. What it lacks in protection it makes up for in revolutionary spirit."
	icon_state = "sovietsidecap"

/obj/item/clothing/head/sovietofficerhat
	name = "\improper Soviet officer hat"
	desc = "A military officer hat designed to stand out so the conscripts know who is in charge."
	icon_state = "sovietofficerhat"

/obj/item/clothing/head/sovietadmiralhat
	name = "\improper Soviet admiral hat"
	desc = "This hat clearly belongs to someone very important."
	icon_state = "sovietadmiralhat"

/*
 * Pumpkin head
 */
/obj/item/clothing/head/hardhat/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"//Could stand to be renamed
	item_state = "hardhat0_pumpkin"
	item_color = "pumpkin"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	dog_fashion = null
	light_color = "#fff2bf"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	brightness_on = 2 //luminosity when on

/obj/item/clothing/head/hardhat/pumpkinhead/blumpkin
	name = "carved blumpkin"
	desc = "A very blue jack o' lantern! Believed to ward off vengeful chemists."
	icon_state = "hardhat0_blumpkin"
	item_state = "hardhat0_blumpkin"
	item_color = "blumpkin"
	light_color = "#76ff8e"


/obj/item/clothing/head/hardhat/reindeer
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose."
	icon_state = "hardhat0_reindeer"
	item_state = "hardhat0_reindeer"
	item_color = "reindeer"
	flags_inv = 0
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	brightness_on = 1 //luminosity when on
	dog_fashion = /datum/dog_fashion/head/reindeer


/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	var/icon/mob
	dog_fashion = /datum/dog_fashion/head/kitty

/obj/item/clothing/head/kitty/update_icon(updates=ALL, mob/living/carbon/human/user)
	..()
	if(!istype(user))
		return
	var/obj/item/organ/external/head/head_organ = user.get_organ("head")

	mob = new/icon("icon" = 'icons/mob/clothing/head.dmi', "icon_state" = icon_state)
	mob.Blend(head_organ.hair_colour, ICON_ADD)

	var/icon/earbit = new/icon("icon" = 'icons/mob/clothing/head.dmi', "icon_state" = "[icon_state]inner")
	mob.Blend(earbit, ICON_OVERLAY)

	icon_override = mob

/obj/item/clothing/head/kitty/equipped(mob/M, slot)
	. = ..()
	if(ishuman(M) && slot == SLOT_HUD_HEAD)
		update_icon(NONE, M)

/obj/item/clothing/head/kitty/mouse
	name = "mouse ears"
	desc = "A pair of mouse ears. Squeak!"
	icon_state = "mousey"

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES
	species_disguise = "High-tech robot"
	dog_fashion = /datum/dog_fashion/head/cardborg
	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)


/obj/item/clothing/head/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && slot == SLOT_HUD_HEAD)
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit/cardborg))
			var/obj/item/clothing/suit/cardborg/CB = H.wear_suit
			CB.disguise(user, src)

/obj/item/clothing/head/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

/*
 * Head Mirror
 */
/obj/item/clothing/head/headmirror
	name = "head mirror"
	desc = "A band of rubber with a very reflective looking mirror attached to the front of it. One of the early signs of medical budget cuts."
	icon_state = "head_mirror"
	item_state = "head_mirror"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

