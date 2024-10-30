/obj/mecha/combat
	force = 30
	var/maxsize = 2
	internal_damage_threshold = 50
	maint_access = 0
	armor = list(melee = 30, bullet = 30, laser = 15, energy = 20, bomb = 20, rad = 0, fire = 100)
	destruction_sleep_duration = 4 SECONDS

/obj/mecha/combat/moved_inside(mob/living/carbon/human/H as mob)
	if(..())
		if(H.client)
			H.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0

/obj/mecha/combat/mmi_moved_inside(obj/item/mmi/mmi_as_oc as obj, mob/user as mob)
	if(..())
		if(occupant.client)
			occupant.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0


/obj/mecha/combat/go_out()
	if(occupant && occupant.client)
		occupant.client.mouse_pointer_icon = initial(occupant.client.mouse_pointer_icon)
	..()
