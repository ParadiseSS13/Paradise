	//Captain's space suit, not hardsuits because no flashlight!
/obj/item/clothing/head/helmet/space/capspace
	name = "captain's space helmet"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "A special helmet designed for only the most fashionable of military figureheads."
	flags_inv = HIDEFACE
	permeability_coefficient = 0.01
	armor = list(melee = 40, bullet = 50, laser = 50, energy = 25, bomb = 50, bio = 100, rad = 50)
	species_restricted = list("exclude", "Diona", "Wryn")
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/helmet.dmi',
		"Drask" = 'icons/mob/species/drask/helmet.dmi'
		)
/obj/item/clothing/head/helmet/space/capspace/equipped(var/mob/living/carbon/human/user, var/slot)
	if(ishuman(user) && slot == slot_head)
		if(user.species.name == "Vox")
			if(flags & BLOCKHAIR)
				flags &= ~BLOCKHAIR
		else
			if((initial(flags) & BLOCKHAIR) && !(flags & BLOCKHAIR))
				flags |= BLOCKHAIR

/obj/item/clothing/suit/space/captain
	name = "captain's space suit"
	desc = "A bulky, heavy-duty piece of exclusive Nanotrasen armor. YOU are in charge!"
	icon_state = "caparmor"
	item_state = "capspacesuit"
	w_class = 4
	allowed = list(/obj/item/weapon/tank, /obj/item/device/flashlight,/obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs)
	armor = list(melee = 40, bullet = 50, laser = 50, energy = 25, bomb = 50, bio = 100, rad = 50)
	species_restricted = list("exclude", "Diona", "Wryn")
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Drask" = 'icons/mob/species/drask/suit.dmi'
		)


	//Deathsquad space suit, not hardsuits because no flashlight!
/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1
	vision_flags = SEE_MOBS
	see_darkness = 0
	HUDType = MEDHUD
	strip_delay = 130

/obj/item/clothing/suit/space/deathsquad
	name = "deathsquad suit"
	desc = "A heavily armored, advanced space suit that protects against most forms of damage."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank,/obj/item/weapon/kitchen/knife/combat)
	armor = list(melee = 80, bullet = 80, laser = 50, energy = 50, bomb = 100, bio = 100, rad = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	unacidable = 1
	strip_delay = 130

	//NEW SWAT suit
/obj/item/clothing/suit/space/swat
	name = "SWAT armor"
	desc = "Space-proof tactical SWAT armor."
	icon_state = "heavy"
	item_state = "swat_suit"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank,/obj/item/weapon/kitchen/knife/combat)
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 30, bomb = 50, bio = 90, rad = 20)
	strip_delay = 120

/obj/item/clothing/head/helmet/space/deathsquad/beret
	name = "officer's beret"
	desc = "An armored beret commonly used by special operations officers."
	icon_state = "beret_officer"
	armor = list(melee = 65, bullet = 55, laser = 35, energy = 20, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/suit/space/deathsquad/officer
	name = "officer jacket"
	desc = "An armored jacket used in special operations."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	flags_inv = 0
	slowdown = 0
	w_class = 3

//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags = HEADCOVERSEYES | BLOCKHAIR | STOPSPRESSUREDMAGE

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	flags = STOPSPRESSUREDMAGE
	flags_size = ONESIZEFITSALL
	allowed = list(/obj/item) //for stuffing exta special presents


//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list(melee = 30, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)
	flags = HEADCOVERSEYES | BLOCKHAIR | STOPSPRESSUREDMAGE
	strip_delay = 40
	put_on_delay = 20

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = 3
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	slowdown = 0
	armor = list(melee = 30, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)
	strip_delay = 40
	put_on_delay = 20

//Paramedic EVA suit
/obj/item/clothing/head/helmet/space/eva/paramedic
	name = "Paramedic EVA helmet"
	desc = "A paramedic EVA helmet. Used in the recovery of bodies from space."
	icon_state = "paramedic-eva-helmet"
	item_state = "paramedic-eva-helmet"

/obj/item/clothing/suit/space/eva/paramedic
	name = "Paramedic EVA suit"
	icon_state = "paramedic-eva"
	item_state = "paramedic-eva"
	desc = "A paramedic EVA suit. Used in the recovery of bodies from space."

/obj/item/clothing/suit/space/eva
	name = "EVA suit"
	icon_state = "spacenew"
	item_state = "s_suit"
	desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20)

/obj/item/clothing/head/helmet/space/eva
	name = "EVA helmet"
	icon_state = "spacenew"
	item_state = "s_helmet"
	desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20)
	flash_protect = 0

//Mime's Hardsuit
/obj/item/clothing/head/helmet/space/eva/mime
	name = "mime eva helmet"
//	icon = 'spaceciv.dmi'
	desc = "An eva helmet specifically designed for the mime."
	icon_state = "spacemimehelmet"
	item_state = "spacemimehelmet"

/obj/item/clothing/suit/space/eva/mime
	name = "mime eva suit"
//	icon = 'spaceciv.dmi'
	desc = "An EVA suit specifically designed for the mime."
	icon_state = "spacemime_suit"
	item_state = "spacemime_items"

/obj/item/clothing/head/helmet/space/eva/clown
	name = "clown eva helmet"
//	icon = 'spaceciv.dmi'
	desc = "An EVA helmet specifically designed for the clown. SPESSHONK!"
	icon_state = "clownhelmet"
	item_state = "clownhelmet"

/obj/item/clothing/suit/space/eva/clown
	name = "clown eva suit"
//	icon = 'spaceciv.dmi'
	desc = "An EVA suit specifically designed for the clown. SPESSHONK!"
	icon_state = "spaceclown_suit"
	item_state = "spaceclown_items"

/obj/item/clothing/head/helmet/space/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	armor = list(melee = 20, bullet = 40, laser = 30, energy = 25, bomb = 100, bio = 100, rad = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1
	strip_delay = 130

/obj/item/clothing/suit/space/freedom
	name = "eagle suit"
	desc = "An advanced, light suit, fabricated from a mixture of synthetic feathers and space-resistant material. A gun holster appears to be integrated into the suit and the wings appear to be stuck in 'freedom' mode."
	icon_state = "freedom"
	item_state = "freedom"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	armor = list(melee = 20, bullet = 40, laser = 30, energy = 25, bomb = 100, bio = 100, rad = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1
	strip_delay = 130