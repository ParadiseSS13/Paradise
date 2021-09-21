	//Captain's space suit, not hardsuits because no flashlight!
/obj/item/clothing/head/helmet/space/capspace
	name = "captain's space helmet"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "A special helmet designed for only the most fashionable of military figureheads."
	flags_inv = HIDEFACE
	permeability_coefficient = 0.01
	armor = list(MELEE = 40, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 100, RAD = 50, FIRE = 100, ACID = 100)
	species_restricted = list("exclude", "Wryn")

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi'
		)

/obj/item/clothing/head/helmet/space/capspace/equipped(mob/living/carbon/human/user, slot)
	if(ishuman(user) && slot == slot_head)
		if(isvox(user))
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
	w_class = WEIGHT_CLASS_BULKY
	allowed = list(/obj/item/tank/internals, /obj/item/flashlight,/obj/item/gun/energy, /obj/item/gun/projectile, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton,/obj/item/restraints/handcuffs)
	armor = list(MELEE = 40, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 100, RAD = 50, FIRE = 100, ACID = 100)
	species_restricted = list("exclude", "Wryn")

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

	//Deathsquad space suit, not hardsuits because no flashlight!
/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
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
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
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
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 50, BIO = 90, RAD = 20, FIRE = 100, ACID = 100)
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	species_restricted = list("exclude", "Wryn")

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/head/helmet/space/deathsquad/beret
	name = "officer beret"
	desc = "An armored beret commonly used by special operations officers."
	icon_state = "beret_officer"
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	flags =  STOPSPRESSUREDMAGE | THICKMATERIAL

/obj/item/clothing/head/helmet/space/deathsquad/beret/solgov
	name = "\improper Trans-Solar Federation commander's beret"
	desc = "A camouflaged beret adorned with the star of the Trans-Solar Federation, worn by generals of the Trans-Solar Federation."
	icon_state = "solgovceliteberet"

/obj/item/clothing/suit/space/deathsquad/officer
	name = "officer jacket"
	desc = "An armored jacket used in special operations."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	flags_inv = 0
	slowdown = 0
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/space/deathsquad/officer/solgov
	name = "\improper Trans-Solar Federation commander's jacket"
	icon_state = "solgovcommander"
	item_state = "solgovcommander"


//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"

	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/Grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/Drask/helmet.dmi'
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
	armor = list(MELEE = 30, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 60, ACID = 75)
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
	armor = list(MELEE = 30, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 60, ACID = 75)
	strip_delay = 40
	put_on_delay = 20

//Paramedic EVA suit
/obj/item/clothing/head/helmet/space/eva/paramedic
	name = "paramedic EVA helmet"
	desc = "A brand new paramedic EVA helmet. It seems to mold to your head shape. Used for retrieving bodies in space."
	icon_state = "paramedic-eva-helmet"
	item_state = "paramedic-eva-helmet"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20, fire = 50, acid = 65)
	species_restricted = list("exclude", "Wryn")

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/helmet.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		)
	sprite_sheets_obj = list(
		"Vox" = 'icons/obj/clothing/species/vox/hats.dmi'
		)

/obj/item/clothing/suit/space/eva/paramedic
	name = "paramedic EVA suit"
	icon_state = "paramedic-eva"
	item_state = "paramedic-eva"
	desc = "A brand new paramedic EVA suit. The nitrile seems a bit too thin to be space proof. Used for retrieving bodies in space."
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20, fire = 50, acid = 65)
	species_restricted = list("exclude", "Wryn")

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/suit.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		)
	sprite_sheets_obj = list(
		"Vox" = 'icons/obj/clothing/species/vox/suits.dmi'
		)

/obj/item/clothing/suit/space/eva
	name = "EVA suit"
	icon_state = "spacenew"
	item_state = "s_suit"
	desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20, fire = 50, acid = 65)
	species_restricted = list("exclude", "Wryn")

	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
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
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi'
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
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi')
	sprite_sheets_obj = null

/obj/item/clothing/suit/space/eva/mime
	name = "mime EVA suit"
//	icon = 'spaceciv.dmi'
	desc = ". . ."
	icon_state = "spacemime_suit"
	item_state = "spacemime_items"
	species_restricted = list("exclude","Wryn")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi')
	sprite_sheets_obj = null

/obj/item/clothing/head/helmet/space/eva/clown
	name = "clown EVA helmet"
//	icon = 'spaceciv.dmi'
	desc = "An EVA helmet specifically designed for the clown. SPESSHONK!"
	icon_state = "clownhelmet"
	item_state = "clownhelmet"
	species_restricted = list("exclude","Wryn")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi')
	sprite_sheets_obj = null

/obj/item/clothing/suit/space/eva/clown
	name = "clown EVA suit"
//	icon = 'spaceciv.dmi'
	desc = "An EVA suit specifically designed for the clown. SPESSHONK!"
	icon_state = "spaceclown_suit"
	item_state = "spaceclown_items"
	species_restricted = list("exclude","Wryn")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi')
	sprite_sheets_obj = null
