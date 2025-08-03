/obj/mecha/combat
	force = 30
	var/maxsize = 2
	maint_access = 0
	armor = list(melee = 30, bullet = 30, laser = 15, energy = 20, bomb = 20, rad = 0, fire = 100)
	destruction_sleep_duration = 4 SECONDS

/obj/mecha/combat/moved_inside(mob/living/carbon/human/H)
	if(..())
		H.add_mousepointer(MP_MECHA_PRIORITY, 'icons/mecha/mecha_mouse.dmi')
		return TRUE

/obj/mecha/combat/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user as mob)
	if(..())
		occupant.add_mousepointer(MP_MECHA_PRIORITY, 'icons/mecha/mecha_mouse.dmi')
		return TRUE

/obj/mecha/combat/go_out()
	if(occupant)
		occupant.remove_mousepointer(MP_MECHA_PRIORITY)
	..()
