//Generic combat hardsuit helmet - should never get used
/obj/item/clothing/head/helmet/space/hardsuit/combat
	name = "combat hardsuit helmet"
	desc = "A dual-mode generic combat helmet designed for work in special operations. It is in EVA mode. Not the property of Gorlex Marauders."
	alt_desc = "A dual-mode generic combat helmet designed for work in special operations. It is in combat mode. Not the property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 15, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	on = TRUE
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)

/obj/item/clothing/head/helmet/space/hardsuit/combat/update_icon()
	icon_state = "hardsuit[on]-[item_color]"

/obj/item/clothing/head/helmet/space/hardsuit/combat/New()
	..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit))
		suit = loc

/obj/item/clothing/head/helmet/space/hardsuit/combat/attack_self(mob/user) //Toggle Helmet
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot toggle your helmet while in this [user.loc]!</span>" )
		return
	on = !on
	if(on)
		to_chat(user, "<span class='notice'>You switch your hardsuit to EVA mode, sacrificing speed for space protection.</span>")
		name = initial(name)
		desc = initial(desc)
		set_light(brightness_on)
		flags |= visor_flags
		flags_cover |= HEADCOVERSEYES | HEADCOVERSMOUTH
		flags_inv |= visor_flags_inv
		cold_protection |= HEAD
	else
		to_chat(user, "<span class='notice'>You switch your hardsuit to combat mode and can now run at full speed.</span>")
		name = "[initial(name)] (combat)"
		desc = alt_desc
		set_light(0)
		flags &= ~visor_flags
		flags_cover &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
		flags_inv &= ~visor_flags_inv
		cold_protection &= ~HEAD
	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	toggle_hardsuit_mode(user)
	user.update_inv_head()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/hardsuit/combat/proc/toggle_hardsuit_mode(mob/user) //Helmet Toggles Suit Mode
	if(suit)
		if(on)
			suit.name = initial(suit.name)
			suit.desc= initial(suit.desc)
			suit.slowdown = 1
			suit.flags |= STOPSPRESSUREDMAGE
			suit.cold_protection |= UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
		else
			suit.name = "[initial(suit.name)] (combat)"
			suit.desc = suit.alt_desc
			suit.slowdown = 0
			suit.flags &= ~STOPSPRESSUREDMAGE
			suit.cold_protection &= ~(UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS)

		suit.update_icon()
		user.update_inv_wear_suit()
		user.update_inv_w_uniform()

//Syndicate hardsuits helmets
/obj/item/clothing/head/helmet/space/hardsuit/combat/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 15, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDETAIL
	visor_flags = STOPSPRESSUREDMAGE

//Elite Syndicate hardsuit helmets
/obj/item/clothing/head/helmet/space/hardsuit/combat/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An dual-mode elite version of the syndicate helmet, with improved armour and fire shielding. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndielite"
	item_color = "syndielite"
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 25, "bomb" = 55, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

//Syndicate Strike Team hardsuits
/obj/item/clothing/head/helmet/space/hardsuit/combat/syndi/elite/sst
	armor = list(melee = 70, bullet = 70, laser = 50, energy = 40, bomb = 80, bio = 100, rad = 100, fire = 100, acid = 100) //Almost as good as DS gear, but unlike DS can switch to combat for mobility
	icon_state = "hardsuit0-sst"
	item_color = "sst"

/obj/item/clothing/head/helmet/space/hardsuit/combat/syndi/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle. It is in EVA mode."
	alt_desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle. It is in combat mode."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	sprite_sheets = null

/obj/item/clothing/head/helmet/space/hardsuit/combat/syndi/freedom/update_icon()
	return
