/obj/item/clothing/shoes/atmta/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magboot_state = "magboots"
	var/magpulse = 0
	var/slowdown_active = 2
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	put_on_delay = 70
	species_restricted = null

/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(src.magpulse)
		src.flags &= ~NOSLIP
		src.slowdown = SHOES_SLOWDOWN
	else
		src.flags |= NOSLIP
		src.slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, "You [magpulse ? "enable" : "disable"] the mag-pulse traction system.")
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.mob_has_gravity())

/obj/item/clothing/shoes/magboots/negates_gravity()
	return flags & NOSLIP

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..(user)
	to_chat(user, "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"].")

/obj/item/clothing/shoes/atmta/magboots/doom
	desc = "Reverse-DOOMED magnetic boots that have a heavy magnetic pull. However, you are not allowed to jump 2 times in a row. The small painting on it reads 'WJ Armor'."
	name = "Praetor Boots"
	icon_state = "doomboots0"
	magboot_state = "doomboots"
	slowdown_active = SHOES_SLOWDOWN
