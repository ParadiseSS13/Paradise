

/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 25)
	strip_delay = 12
	burn_state = LAVA_PROOF
	unacidable = TRUE
	blockTracking = TRUE //Roughly the only unique thing about this helmet.
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE

	darkness_view = 8
	helmet_goggles_invis_view = SEE_INVISIBLE_MINIMUM
	actions_types = list(/datum/action/item_action/toggle_mode)
	var/mode = 0

/obj/item/clothing/head/helmet/space/space_ninja/attack_self(mob/living/carbon/user)
	toggle_modes(user)

/obj/item/clothing/head/helmet/space/space_ninja/proc/toggle_modes(mob/living/carbon/user)
	switch(mode)
		if(0)
			mode = 1
			darkness_view = 0
			vision_flags = SEE_MOBS
			helmet_goggles_invis_view = SEE_INVISIBLE_LIVING
			to_chat(user, "Switched mode to <B>Thermal Scanner</B>.")
		if(1)
			mode = 2
			darkness_view = 0
			vision_flags = SEE_TURFS
			helmet_goggles_invis_view = SEE_INVISIBLE_MINIMUM
			to_chat(user, "Switched mode to <B>Meson Scanner</B>.")
		if(2)
			mode = 0
			darkness_view = 8
			vision_flags = 0
			helmet_goggles_invis_view = SEE_INVISIBLE_MINIMUM
			to_chat(user, "Switched mode to <B>Night Vision</B>.")

	user.update_sight()