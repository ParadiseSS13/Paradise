
/obj/item/clothing/head/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	item_state = "hardhat0_yellow"
	var/brightness_on = 4 //luminosity when on
	var/on = FALSE
	item_color = "yellow" //Determines used sprites: hardhat[on]_[color] and hardhat[on]_[color]2 (lying down sprite)
	armor = list(melee = 15, bullet = 5, laser = 20, energy = 10, bomb = 20, bio = 10, rad = 20)
	flags_inv = 0
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	burn_state = FIRE_PROOF
	species_fit = list("Grey")
	sprite_sheets = list(
		"Grey" = 'icons/mob/species/grey/head.dmi'
	)

/obj/item/clothing/head/hardhat/attack_self(mob/user)
	on = !on
	icon_state = "hardhat[on]_[item_color]"
	item_state = "hardhat[on]_[item_color]"
	if(on)
		set_light(brightness_on)
	else
		set_light(0)

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/hardhat/extinguish_light()
	if(on)
		on = FALSE
		set_light(0)
		icon_state = "hardhat0_[item_color]"
		item_state = "hardhat0_[item_color]"
		visible_message("<span class='danger'>[src]'s light fades and turns off.</span>")

/obj/item/clothing/head/hardhat/orange
	icon_state = "hardhat0_orange"
	item_state = "hardhat0_orange"
	item_color = "orange"

/obj/item/clothing/head/hardhat/red
	icon_state = "hardhat0_red"
	item_state = "hardhat0_red"
	item_color = "red"
	name = "firefighter helmet"
	flags = STOPSPRESSUREDMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/hardhat/white
	icon_state = "hardhat0_white"
	item_state = "hardhat0_white"
	item_color = "white"
	flags = STOPSPRESSUREDMAGE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT


/obj/item/clothing/head/hardhat/dblue
	icon_state = "hardhat0_dblue"
	item_state = "hardhat0_dblue"
	item_color = "dblue"

/obj/item/clothing/head/hardhat/atmos
	icon_state = "hardhat0_atmos"
	item_state = "hardhat0_atmos"
	item_color = "atmos"
	name = "atmospheric technician's firefighting helmet"
	desc = "A firefighter's helmet, able to keep the user cool in any situation."
	flags = STOPSPRESSUREDMAGE
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	species_fit = list("Grey")
	sprite_sheets = list(
		"Grey" = 'icons/mob/species/grey/helmet.dmi'
		)