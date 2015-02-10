/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "muzzle"
	flags = MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi'
		)
/obj/item/clothing/mask/muzzle/gag
	name = "gag"
	desc = "Stick this in their mouth to stop the noise."
	icon_state = "gag"
	w_class = 1

//Monkeys can not take the muzzle off of themself! Call PETA!
/obj/item/clothing/mask/muzzle/attack_paw(mob/user as mob)
	if (src == user.wear_mask)
		return
	else
		..()
	return


/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = 1
	flags = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 25, rad = 0)
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi'
		)
/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE

//scarves (fit in in mask slot)

/obj/item/clothing/mask/bluescarf
	name = "blue neck scarf"
	desc = "A blue neck scarf."
	icon_state = "blueneckscarf"
	item_state = "blueneckscarf"
	flags = MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/redscarf
	name = "red scarf"
	desc = "A red and white checkered neck scarf."
	icon_state = "redwhite_scarf"
	item_state = "redwhite_scarf"
	flags = MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/greenscarf
	name = "green scarf"
	desc = "A green neck scarf."
	icon_state = "green_scarf"
	item_state = "green_scarf"
	flags = MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/ninjascarf
	name = "ninja scarf"
	desc = "A stealthy, dark scarf."
	icon_state = "ninja_scarf"
	item_state = "ninja_scarf"
	flags = MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90
	siemens_coefficient = 0

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = 2
	siemens_coefficient = 0.9


/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = 2
	siemens_coefficient = 0.9
	var/voicechange = 0
	var/temporaryname = " the Horse"
	var/originalname = ""



/obj/item/clothing/mask/horsehead/equipped(mob/user, slot)
	if(!canremove)	//cursed masks only
		originalname = user.real_name
		if(!user.real_name || user.real_name == "Unknown")
			user.real_name = "A Horse With No Name" //it felt good to be out of the rain
		else
			user.real_name = "[user.name][temporaryname]"
		..()

/obj/item/clothing/mask/horsehead/dropped() //this really shouldn't happen, but call it extreme caution
	if(!canremove)
		goodbye_horses(loc)
	..()

/obj/item/clothing/mask/horsehead/Destroy()
	if(!canremove)
		goodbye_horses(loc)
	..()

/obj/item/clothing/mask/horsehead/proc/goodbye_horses(mob/user) //I'm flying over you
	if(!ismob(user))
		return
	if(user.real_name == "[originalname][temporaryname]" || user.real_name == "A Horse With No Name") //if it's somehow changed while the mask is on it doesn't revert
		user.real_name = originalname

/obj/item/clothing/mask/fawkes
	name = "Guy Fawkes mask"
	desc = "A mask designed to help you remember a specific date."
	icon_state = "fawkes"
	item_state = "fawkes"
	flags_inv = HIDEFACE
	w_class = 2

/obj/item/clothing/mask/gas/clown_hat/pennywise
	name = "Pennywise Mask"
	desc = "It's the eater of worlds, and of children."
	icon_state = "pennywise_mask"
	item_state = "pennywise_mask"
	species_fit = list("Vox")
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS | BLOCKHAIR
