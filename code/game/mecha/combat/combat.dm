/obj/mecha/combat
	force = 30
	var/maxsize = 2
	maint_access = 0
	armor = list(MELEE = 30, BULLET = 30, LASER = 15, ENERGY = 20, BOMB = 20, RAD = 0, FIRE = 100)
	destruction_sleep_duration = 4 SECONDS

/obj/mecha/combat/moved_inside(mob/living/carbon/human/H)
	if(..())
		H.add_mousepointer(MP_MECHA_PRIORITY, 'icons/mouse_icons/mecha_mouse.dmi')
		return TRUE

/obj/mecha/combat/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user as mob)
	if(..())
		occupant.add_mousepointer(MP_MECHA_PRIORITY, 'icons/mouse_icons/mecha_mouse.dmi')
		return TRUE

/obj/mecha/combat/go_out()
	if(occupant)
		occupant.remove_mousepointer(MP_MECHA_PRIORITY)
	..()
