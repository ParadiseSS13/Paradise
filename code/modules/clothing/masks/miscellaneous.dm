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

// Clumsy folks can't take the mask off themselves.
/obj/item/clothing/mask/muzzle/attack_hand(mob/user as mob)
	if(user.wear_mask == src && !user.IsAdvancedToolUser())
		return 0
	..()

/obj/item/clothing/mask/muzzle/gag
	name = "gag"
	desc = "Stick this in their mouth to stop the noise."
	icon_state = "gag"
	w_class = 1

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
	action_button_name = "Adjust Sterile Mask"
	ignore_maskadjust = 0
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi'
		)

/obj/item/clothing/mask/surgical/attack_self(var/mob/user)
	adjustmask(user)

/obj/item/clothing/mask/fakemoustache
	name = "completely real moustache"
	desc = "moustache is totally real."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE

/obj/item/clothing/mask/fakemoustache/verb/pontificate()
	set name = "Pontificate Evilly"
	set category = "Object"
	set desc = "Devise evil plans of evilness."

	usr.visible_message("<span class = 'danger'>\ [usr] twirls \his moustache and laughs [pick("fiendishly","maniacally","diabolically","evilly")]!</span>")

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
	if(flags & NODROP)	//cursed masks only
		originalname = user.real_name
		if(!user.real_name || user.real_name == "Unknown")
			user.real_name = "A Horse With No Name" //it felt good to be out of the rain
		else
			user.real_name = "[user.name][temporaryname]"
		..()

/obj/item/clothing/mask/horsehead/dropped() //this really shouldn't happen, but call it extreme caution
	if(flags & NODROP)
		goodbye_horses(loc)
	..()

/obj/item/clothing/mask/horsehead/Destroy()
	if(flags & NODROP)
		goodbye_horses(loc)
	return ..()

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

// Bandanas
/obj/item/clothing/mask/bandana
	name = "bandana"
	desc = "A colorful bandana."
	flags = MASKCOVERSMOUTH
	flags_inv = HIDEFACE
	w_class = 1
	slot_flags = SLOT_MASK
	ignore_maskadjust = 0
	adjusted_flags = SLOT_HEAD
	icon_state = "bandbotany"
	action_button_name = "Adjust Bandana"

/obj/item/clothing/mask/bandana/attack_self(var/mob/user)
	adjustmask(user)

obj/item/clothing/mask/bandana/red
	name = "red bandana"
	icon_state = "bandred"

obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	icon_state = "bandblue"

obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	icon_state = "bandgold"

obj/item/clothing/mask/bandana/green
	name = "green bandana"
	icon_state = "bandgreen"

/obj/item/clothing/mask/bandana/botany
	name = "botany bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "bandbotany"

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "It's a black bandana with a skull pattern."
	icon_state = "bandskull"

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	desc = "It's a black bandana."
	icon_state = "bandblack"