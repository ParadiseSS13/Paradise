/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magboot_state = "magboots"
	var/magpulse = 0
	var/slowdown_active = 2
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	put_on_delay = 70
	burn_state = FIRE_PROOF

/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		flags &= ~NOSLIP
		slowdown = SHOES_SLOWDOWN
	else
		flags |= NOSLIP
		slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, "You [magpulse ? "enable" : "disable"] the mag-pulse traction system.")
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.mob_has_gravity())
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/shoes/magboots/negates_gravity()
	return flags & NOSLIP

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..(user)
	to_chat(user, "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"].")


/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"
	origin_tech = "magnets=2;syndicate=3"

obj/item/clothing/shoes/magboots/syndie/advance //For the Syndicate Strike Team
	desc = "Reverse-engineered magboots that appear to be based on an advanced model, as they have a lighter magnetic pull. Property of Gorlex Marauders."
	name = "advanced blood-red magboots"
	slowdown_active = SHOES_SLOWDOWN