/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *		Cardborg Disguise
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
	flash_protect = 2
	tint = 2
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	action_button_name = "flip welding helmet"
	species_fit = list("Vox", "Unathi", "Tajaran", "Vulpkanin")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi',
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/helmet.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/helmet.dmi'
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
			to_chat(usr, "You flip the [src] down to protect your eyes.")
			flash_protect = 2
			tint = 2
		else
			src.up = !src.up
			src.flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv &= ~(HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			icon_state = "[initial(icon_state)]up"
			to_chat(usr, "You push the [src] up out of your face.")
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

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_objects.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if(istype(location, /turf))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if(src.onfire)
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

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		to_chat(user, "You raise the ear flaps on the ushanka.")
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		to_chat(user, "You lower the ear flaps on the ushanka.")

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
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	brightness_on = 2 //luminosity when on


/obj/item/clothing/head/hardhat/reindeer
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose."
	icon_state = "hardhat0_reindeer"
	item_state = "hardhat0_reindeer"
	item_color = "reindeer"
	flags_inv = 0
	action_button_name = "Toggle Nose Light"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	brightness_on = 1 //luminosity when on


/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	var/icon/mob

/obj/item/clothing/head/kitty/update_icon(var/mob/living/carbon/human/user)
	if(!istype(user)) return
	var/obj/item/organ/external/head/head_organ = user.get_organ("head")

	mob = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty")
//		mob2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty2") - Commented out because it seemingly does nothing.
	mob.Blend(rgb(head_organ.r_hair, head_organ.g_hair, head_organ.b_hair), ICON_ADD)
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
	var/obj/item/organ/external/head/head_organ = user.get_organ("head")
	mob = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "mousey")
	mob.Blend(rgb(head_organ.r_hair, head_organ.g_hair, head_organ.b_hair), ICON_ADD)

	var/icon/earbit = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "mouseyinner")
	mob.Blend(earbit, ICON_OVERLAY)

	icon_override = mob

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	species_disguise = "High-tech robot"

/obj/item/clothing/head/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && slot == slot_head)
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit/cardborg))
			var/obj/item/clothing/suit/cardborg/CB = H.wear_suit
			CB.disguise(user, src)

/obj/item/clothing/head/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")



/obj/item/clothing/head/collectable/petehat/special
	name = "super ultra rare Pete's hat!"
	desc = "It smells faintly of the caribbean."
	icon_state = "petehat"

	action_button_name = "RHUMBA!!"

	var/uses = 1
	var/mob/living/carbon/human/pete
	var/rhumba_duration = 55
	var/tick = 0

/obj/item/clothing/head/collectable/petehat/special/proc/rhumba(mob/living/carbon/human/M)
	if(M.head != src)
		to_chat(M,"You need to be wearing the hat to initiate your Rhumba powers.")
		return
	if(uses <= 0)
		to_chat(M,"You cannot start a Rhumba more than once!")
		return
	uses -= 1
	pete = M

	for(var/O in global_intercoms) //shamelessly copied from the bee briefcase
		var/obj/item/device/radio/intercom/I = O
		if(I.z != ZLEVEL_STATION)
			continue
		if(!I.on)
			continue
		playsound(I, 'sound/effects/cuban_pete.ogg' , 100)

	pete.drop_l_hand()
	pete.drop_r_hand()

	var/obj/item/toy/cuban_maraca/R = new(pete)
	var/obj/item/toy/cuban_maraca/L = new(pete)

	pete.put_in_l_hand(L)
	pete.put_in_r_hand(R)



	rhumba_proc()

/obj/item/clothing/head/collectable/petehat/special/proc/rhumba_proc()
	while(1)
		if(!check_rhumba_validity())
			to_chat(pete,"<span class='userdanger'>Your hat loses its memetic abilities!</span>")
			return
		for(var/mob/living/carbon/human/H in viewers(pete))
			if(H == pete) continue
			if(prob(50) && !H.stunned)
				H.Stun(10)
				H.visible_message("<span class='danger'>[H] begins to dance uncontrollably!</span>","<span class='userdanger'> You feel the sudden urge to dance!</span>")
		sleep(10)
		tick += 1


/obj/item/clothing/head/collectable/petehat/special/proc/check_rhumba_validity()
	if(pete.head != src)
		return 0
	if(pete.stat != CONSCIOUS)
		return 0
	if(tick >= rhumba_duration)
		return 0
	if(!istype(pete.l_hand,/obj/item/toy/cuban_maraca) || !istype(pete.r_hand,/obj/item/toy/cuban_maraca))
		return 0
	return 1


/obj/item/clothing/head/collectable/petehat/special/ui_action_click()
	rhumba(usr)


