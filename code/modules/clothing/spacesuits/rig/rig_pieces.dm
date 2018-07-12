/*
 * Defines the helmets, gloves and shoes for rigs.
 */

/obj/item/clothing/head/helmet/space/new_rig
	name = "helmet"
	flags =  BLOCKHAIR | THICKMATERIAL | NODROP
	flags_inv = 		 HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK
	body_parts_covered = HEAD
	heat_protection =    HEAD
	cold_protection =    HEAD
	var/brightness_on = 4
	var/on = 0
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/species/tajaran/helmet.dmi',
		"Skrell" = 'icons/mob/species/skrell/helmet.dmi',
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi'
		)
	species_restricted = null
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

	flash_protect = 2

/obj/item/clothing/head/helmet/space/new_rig/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot turn the light on while in this [user.loc].</span>")//To prevent some lighting anomalities.

		return
	toggle_light(user)

/obj/item/clothing/head/helmet/space/new_rig/proc/toggle_light(mob/user)
	if(flags & AIRTIGHT) //Could also check for STOPSPRESSUREDMAGE, but one is enough, both get toggled when the seal gets toggled.

		on = !on
		icon_state = "[item_color][on]"

		if(on)
			set_light(brightness_on)
		else
			set_light(0)
	else
		to_chat(user, "<span class='warning'>You cannot turn the light on while the suit isn't sealed.</span>")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

/obj/item/clothing/gloves/rig
	name = "gauntlets"
	flags = THICKMATERIAL | NODROP
	body_parts_covered = HANDS
	heat_protection =    HANDS
	cold_protection =    HANDS
	species_restricted = null
	gender = PLURAL

/obj/item/clothing/shoes/magboots/rig
	name = "boots"
	flags = NODROP
	body_parts_covered = FEET
	cold_protection = FEET
	heat_protection = FEET
	species_restricted = null
	gender = PLURAL

/obj/item/clothing/shoes/magboots/rig/attack_self(mob/user)
	if(flags & AIRTIGHT) //Could also check for STOPSPRESSUREDMAGE, but one is enough, both get toggled when the seal gets toggled.
		..(user)
	else
		to_chat(user, "<span class='warning'>You cannot activate mag-pulse traction system while the suit is not sealed.</span>")

/obj/item/clothing/suit/space/new_rig
	name = "chestpiece"
	allowed = list(/obj/item/flashlight,/obj/item/tank)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv =          HIDEJUMPSUIT|HIDETAIL
	flags =              STOPSPRESSUREDMAGE | THICKMATERIAL | AIRTIGHT | NODROP
	slowdown = 0
	breach_threshold = 20
	resilience = 0.2
	can_breach = 1
	var/obj/item/rig/holder
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/species/unathi/suit.dmi'
		)

//TODO: move this to modules
/obj/item/clothing/head/helmet/space/new_rig/proc/prevent_track()
	return 0

/obj/item/clothing/gloves/rig/Touch(var/atom/A, var/proximity)

	if(!A || !proximity)
		return 0

	var/mob/living/carbon/human/H = loc
	if(!istype(H) || !H.back)
		return 0

	var/obj/item/rig/suit = H.back
	if(!suit || !istype(suit) || !suit.installed_modules.len)
		return 0

	for(var/obj/item/rig_module/module in suit.installed_modules)
		if(module.active && module.activates_on_touch)
			if(module.engage(A))
				return 1

	return 0

//Rig pieces for non-spacesuit based rigs

/obj/item/clothing/head/lightrig
	name = "mask"
	body_parts_covered = HEAD
	heat_protection =    HEAD
	cold_protection =    HEAD
	flags =              THICKMATERIAL|AIRTIGHT

/obj/item/clothing/suit/lightrig
	name = "suit"
	allowed = list(/obj/item/flashlight)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv =          HIDEJUMPSUIT
	flags =              THICKMATERIAL

/obj/item/clothing/shoes/lightrig
	name = "boots"
	body_parts_covered = FEET
	cold_protection = FEET
	heat_protection = FEET
	species_restricted = null
	gender = PLURAL

/obj/item/clothing/gloves/lightrig
	name = "gloves"
	flags = THICKMATERIAL
	body_parts_covered = HANDS
	heat_protection =    HANDS
	cold_protection =    HANDS
	species_restricted = null
	gender = PLURAL
