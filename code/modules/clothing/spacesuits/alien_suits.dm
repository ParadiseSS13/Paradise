//Skrell space gear. Sleek like a wetsuit.
/obj/item/clothing/head/helmet/space/skrell
	name = "skrellian helmet"
	desc = "Smoothly contoured and polished to a shine. Still looks like a fishbowl."
	species_restricted = list("Skrell","Human")

/obj/item/clothing/head/helmet/space/skrell/white
	icon_state = "skrell_helmet_white"
	item_state = "skrell_helmet_white"
	item_color = "skrell_helmet_white"

/obj/item/clothing/head/helmet/space/skrell/black
	icon_state = "skrell_helmet_black"
	item_state = "skrell_helmet_black"
	item_color = "skrell_helmet_black"

/obj/item/clothing/suit/space/skrell
	name = "skrellian hardsuit"
	desc = "Seems like a wetsuit with reinforced plating seamlessly attached to it. Very chic."
	species_restricted = list("Skrell","Human")

/obj/item/clothing/suit/space/skrell/white
	icon_state = "skrell_suit_white"
	item_state = "skrell_suit_white"
	item_color = "skrell_suit_white"

/obj/item/clothing/suit/space/skrell/black
	icon_state = "skrell_suit_black"
	item_state = "skrell_suit_black"
	item_color = "skrell_suit_black"

//Unathi space gear. Huge and restrictive.
/obj/item/clothing/head/helmet/space/unathi
	icon = 'icons/obj/clothing/species/unathi/hats.dmi'
	species_restricted = list("Unathi")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi'
		)

/obj/item/clothing/head/helmet/space/unathi/helmet_cheap
	name = "NT breacher helmet"
	desc = "Hey! Watch it with that thing! It's a knock-off of an Unathi battle-helm, and that spike could put someone's eye out."
	icon_state = "unathi_helm_cheap"
	item_state = "unathi_helm_cheap"
	item_color = "unathi_helm_cheap"

/obj/item/clothing/suit/space/unathi
	icon = 'icons/obj/clothing/species/unathi/suits.dmi'
	species_restricted = list("Unathi")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi'
		)

/obj/item/clothing/suit/space/unathi/rig_cheap
	name = "NT breacher chassis"
	desc = "A cheap NT knock-off of a Unathi battle-rig. Looks like a fish, moves like a fish, steers like a cow."
	icon_state = "rig-unathi-cheap"
	item_state = "rig-unathi-cheap"

/obj/item/clothing/head/helmet/space/unathi/breacher
	name = "breacher helm"
	desc = "Weathered, ancient and battle-scarred. The helmet is too."
	icon_state = "unathi_breacher"
	item_state = "unathi_breacher"
	item_color = "unathi_breacher"

/obj/item/clothing/suit/space/unathi/breacher
	name = "breacher chassis"
	desc = "Huge, bulky and absurdly heavy. It must be like wearing a tank."
	icon_state = "unathi_breacher"
	item_state = "unathi_breacher"
	item_color = "unathi_breacher"

// Vox space gear (vaccuum suit, low pressure armour)
// Can't be equipped by any other species due to bone structure and vox cybernetics.
/obj/item/clothing/suit/space/vox
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/saber,/obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 35, BULLET = 35, LASER = 20, ENERGY = 10, BOMB = 20, RAD = 20, FIRE = 200, ACID = 285)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	icon = 'icons/obj/clothing/species/vox/suits.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/head/helmet/space/vox
	armor = list(MELEE = 35, BULLET = 35, LASER = 20, ENERGY = 10, BOMB = 20, RAD = 20, FIRE = 200, ACID = 285)
	flags = STOPSPRESSUREDMAGE
	flags_cover = HEADCOVERSEYES
	icon = 'icons/obj/clothing/species/vox/hats.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet."

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."

/obj/item/clothing/under/vox
	has_sensor = FALSE
	icon = 'icons/obj/clothing/species/vox/uniforms.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/misc.dmi'
		)

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"
	item_color = "vox-casual-1"
	item_state = "vox-casual-1"
	body_parts_covered = LEGS

/obj/item/clothing/under/vox/vox_robes
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"
	item_color = "vox-casual-2"
	item_state = "vox-casual-2"
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/misc.dmi')

/obj/item/clothing/gloves/color/yellow/vox
	name = "insulated gauntlets"
	desc = "These bizarre gauntlets seem to be fitted for... bird claws?"
	icon_state = "gloves-vox"
	item_state = "gloves-vox"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	item_color = "gloves-vox"
	icon = 'icons/obj/clothing/species/vox/gloves.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi')

/obj/item/clothing/shoes/magboots/vox
	name = "vox magclaws"
	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	item_state = "boots-vox"
	icon_state = "boots-vox"
	icon = 'icons/obj/clothing/species/vox/shoes.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/feet.dmi')

/obj/item/clothing/shoes/magboots/vox/attack_self(mob/user)
	if(magpulse)
		flags &= ~NOSLIP
		magpulse = FALSE
		flags |= NODROP
		to_chat(user, "You relax your deathgrip on the flooring.")
	else
		//make sure these can only be used when equipped.
		if(!ishuman(user))
			return
		var/mob/living/carbon/human/H = user
		if(H.shoes != src)
			to_chat(user, "<span class='warning>You will have to put on [src] before you can do that.</span>")
			return

		flags |= NOSLIP
		magpulse = TRUE
		flags &= ~NODROP	//kinda hard to take off magclaws when you are gripping them tightly.
		to_chat(user, "You dig your claws deeply into the flooring, bracing yourself.")
		to_chat(user, "It would be hard to take off [src] without relaxing your grip first.")

//In case they somehow come off while enabled.
/obj/item/clothing/shoes/magboots/vox/dropped(mob/user as mob)
	..()
	if(magpulse)
		user.visible_message("[src] go limp as they are removed from [usr]'s feet.", "[src] go limp as they are removed from your feet.")
		flags &= ~NOSLIP
		magpulse = FALSE
		flags &= ~NODROP

/obj/item/clothing/shoes/magboots/vox/examine(mob/user)
	. = ..()
	if(magpulse)
		. += "It would be hard to take these off without relaxing your grip first."//theoretically this message should only be seen by the wearer when the claws are equipped.
