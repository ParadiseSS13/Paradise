/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magpulse = 0
	species_restricted = null
	action_button_name = "Toggle the magboots"
//	flags = NOSLIP //disabled by default
	icon_action_button = "action_magboots"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/shoes.dmi'
		)

	attack_self(mob/user)
		if(magpulse)
			flags &= ~NOSLIP
			slowdown = SHOES_SLOWDOWN
			magpulse = 0
			icon_state = "magboots0"
			user << "You disable the mag-pulse traction system."
		else
			flags |= NOSLIP
			slowdown = 2
			magpulse = 1
			icon_state = "magboots1"
			user << "You enable the mag-pulse traction system."
		user.update_inv_shoes()	//so our mob-overlays update
		user.update_gravity(user.mob_has_gravity())

	examine()
		set src in view()
		..()
		var/state = "disabled"
		if(src.flags&NOSLIP)
			state = "enabled"
		usr << "Its mag-pulse traction system appears to be [state]."

/obj/item/clothing/shoes/magboots/negates_gravity()
	return flags & NOSLIP