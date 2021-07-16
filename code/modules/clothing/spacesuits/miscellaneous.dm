	//Deathsquad space suit, not hardsuits because no flashlight!
/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these
	see_in_dark = 8
	HUDType = MEDHUD
	strip_delay = 130

/obj/item/clothing/suit/space/deathsquad
	name = "deathsquad suit"
	desc = "A heavily armored, advanced space suit that protects against most forms of damage."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/tank/internals,/obj/item/kitchen/knife/combat)
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	strip_delay = 130
	dog_fashion = /datum/dog_fashion/back/deathsquad

	//NEW SWAT suit
/obj/item/clothing/suit/space/swat
	name = "SWAT armor"
	desc = "Space-proof tactical SWAT armor."
	icon_state = "heavy"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/tank/internals,/obj/item/kitchen/knife/combat)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30,"energy" = 30, "bomb" = 50, "bio" = 90, "rad" = 20, "fire" = 100, "acid" = 100)
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	species_restricted = list("exclude", "Wryn")

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/head/helmet/space/deathsquad/beret
	name = "officer beret"
	desc = "An armored beret commonly used by special operations officers."
	icon_state = "beret_officer"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	flags =  STOPSPRESSUREDMAGE | THICKMATERIAL

/obj/item/clothing/suit/space/deathsquad/officer
	name = "officer jacket"
	desc = "An armored jacket used in special operations."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	flags_inv = 0
	slowdown = 0
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_NORMAL

//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"

	sprite_sheets = list(
		"Grey" = 'icons/mob/species/Grey/head.dmi',
		"Drask" = 'icons/mob/species/Drask/helmet.dmi'
		)
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE
	flags_cover = HEADCOVERSEYES
	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/head/helmet/space/santahat/attack_self(mob/user as mob)
	if(src.icon_state == "santahat")
		src.icon_state = "santahat_beard"
		src.item_state = "santahat_beard"
		to_chat(user, "Santa's beard expands out from the hat!")
	else
		src.icon_state = "santahat"
		src.item_state = "santahat"
		to_chat(user, "The beard slinks back into the hat...")

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	flags = STOPSPRESSUREDMAGE
	allowed = list(/obj/item) //for stuffing extra special presents

//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list("melee" = 30, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 60, "acid" = 75)
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE
	flags_cover = HEADCOVERSEYES
	strip_delay = 40
	put_on_delay = 20

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/tank/internals)
	slowdown = 0
	armor = list("melee" = 30, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 60, "acid" = 75)
	strip_delay = 40
	put_on_delay = 20

/obj/item/clothing/suit/space/eva
	name = "EVA suit"
	icon_state = "spacenew"
	item_state = "s_suit"
	desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20, fire = 50, acid = 65)
	species_restricted = list("exclude", "Wryn")

	sprite_sheets = list(
		"Tajaran" = 'icons/mob/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/species/unathi/suit.dmi',
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/suit.dmi',
		)
	sprite_sheets_obj = list(
		"Tajaran" = 'icons/obj/clothing/species/tajaran/suits.dmi',
		"Unathi" = 'icons/obj/clothing/species/unathi/suits.dmi',
		"Vox" = 'icons/obj/clothing/species/vox/suits.dmi',
		"Vulpkanin" = 'icons/obj/clothing/species/vulpkanin/suits.dmi'
		)

/obj/item/clothing/head/helmet/space/eva
	name = "EVA helmet"
	icon_state = "spacenew"
	item_state = "s_helmet"
	desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20, fire = 50, acid = 65)
	flash_protect = 0
	species_restricted = list("exclude", "Wryn")
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi',
		"Vox" = 'icons/mob/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/helmet.dmi',
		"Grey" = 'icons/mob/species/grey/helmet.dmi'
		)
	sprite_sheets_obj = list(
		"Vox" = 'icons/obj/clothing/species/vox/hats.dmi',
		"Vulpkanin" = 'icons/obj/clothing/species/vulpkanin/hats.dmi'
		)

//Mime's Hardsuit
/obj/item/clothing/head/helmet/space/eva/mime
	name = "mime EVA helmet"
//	icon = 'spaceciv.dmi'
	desc = ". . ."
	icon_state = "spacemimehelmet"
	item_state = "spacemimehelmet"
	species_restricted = list("exclude","Wryn")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/helmet.dmi')
	sprite_sheets_obj = null

/obj/item/clothing/suit/space/eva/mime
	name = "mime EVA suit"
//	icon = 'spaceciv.dmi'
	desc = ". . ."
	icon_state = "spacemime_suit"
	item_state = "spacemime_items"
	species_restricted = list("exclude","Wryn")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi')
	sprite_sheets_obj = null

/obj/item/clothing/head/helmet/space/eva/clown
	name = "clown EVA helmet"
//	icon = 'spaceciv.dmi'
	desc = "An EVA helmet specifically designed for the clown. SPESSHONK!"
	icon_state = "clownhelmet"
	item_state = "clownhelmet"
	species_restricted = list("exclude","Wryn")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/helmet.dmi')
	sprite_sheets_obj = null

/obj/item/clothing/suit/space/eva/clown
	name = "clown EVA suit"
//	icon = 'spaceciv.dmi'
	desc = "An EVA suit specifically designed for the clown. SPESSHONK!"
	icon_state = "spaceclown_suit"
	item_state = "spaceclown_items"
	species_restricted = list("exclude","Wryn")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi')
	sprite_sheets_obj = null
