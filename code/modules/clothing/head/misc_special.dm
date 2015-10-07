/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH
	item_state = "welding"
	materials = list(MAT_METAL=1750, MAT_GLASS=400)
	var/up = 0
	flash_protect = 2
	tint = 2
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	action_button_name = "flip welding helmet"
	siemens_coefficient = 0.9
	loose = 4
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi'
		)

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

/obj/item/clothing/head/welding/attack_self()
	toggle()

/obj/item/clothing/head/welding/proc/toggle()
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		if(src.up)
			src.up = !src.up
			src.flags |= (HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv |= (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			icon_state = initial(icon_state)
			usr << "You flip the [src] down to protect your eyes."
			flash_protect = 2
			tint = 2
		else
			src.up = !src.up
			src.flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv &= ~(HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			icon_state = "[initial(icon_state)]up"
			usr << "You push the [src] up out of your face."
			flash_protect = 0
			tint = 0
		usr.update_inv_head()	//so our mob-overlays update


/*
 * Cakehat
 */
/obj/item/clothing/head/cakehat
	name = "cake-hat"
	desc = "It's tasty looking!"
	icon_state = "cake0"
	flags = HEADCOVERSEYES
	var/onfire = 0.0
	var/status = 0
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage
	var/processing = 0 //I dont think this is used anywhere.
	loose = 60

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_objects.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"
		processing_objects.Add(src)
	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
	return


/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = "ushankadown"
	flags_inv = HIDEEARS
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	loose = 1 // too warm, your head doesn't want to leave

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		user << "You raise the ear flaps on the ushanka."
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		user << "You lower the ear flaps on the ushanka."

/*
 * Pumpkin head
 */
/obj/item/clothing/head/hardhat/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"//Could stand to be renamed
	item_state = "hardhat0_pumpkin"
	item_color = "pumpkin"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH | BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

	action_button_name = "Toggle Pumpkin Light"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	brightness_on = 2 //luminosity when on
	loose = 80


/obj/item/clothing/head/hardhat/reindeer
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose."
	icon_state = "hardhat0_reindeer"
	item_state = "hardhat0_reindeer"
	item_color = "reindeer"
	flags_inv = 0
	action_button_name = "Toggle Nose Light"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	brightness_on = 1 //luminosity when on


/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	var/icon/mob
	siemens_coefficient = 1.5
	loose = 33

/obj/item/clothing/head/kitty/update_icon(var/mob/living/carbon/human/user)
	if(!istype(user)) return
	mob = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty")
//		mob2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty2") - Commented out because it seemingly does nothing.
	mob.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)
//		mob2.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD) - Commented out because it seemingly does nothing.

	var/icon/earbit = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner")
//		var/icon/earbit2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner2") - Commented out because it seemingly does nothing.
	mob.Blend(earbit, ICON_OVERLAY)
//		mob2.Blend(earbit2, ICON_OVERLAY) - Commented out because it seemingly does nothing.

	icon_override = mob

/obj/item/clothing/head/kitty/equipped(var/mob/M, slot)
	. = ..()
	if(ishuman(M) && slot == slot_head)
		update_icon(M)


/obj/item/clothing/head/kitty/mouse
	name = "mouse ears"
	desc = "A pair of mouse ears. Squeak!"
	icon_state = "mousey"

/obj/item/clothing/head/kitty/mouse/update_icon(var/mob/living/carbon/human/user)
	if(!istype(user)) return
	mob = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "mousey")
	mob.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)

	var/icon/earbit = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "mouseyinner")
	mob.Blend(earbit, ICON_OVERLAY)

	icon_override = mob