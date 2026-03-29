//added by cael from old bs12
//not sure if there's an immediate place for secure wall lockers, but i'm sure the players will think of something

/obj/structure/closet/walllocker
	desc = "A wall mounted storage locker."
	name = "wall locker"
	icon = 'icons/obj/walllocker.dmi'
	icon_state = null
	door_anim_time = 0
	enable_door_overlay = FALSE
	density = FALSE
	anchored = TRUE
	icon_closed = null
	icon_opened = null

/obj/structure/closet/walllocker/close()
	. = ..()
	density = FALSE //It's a locker in a wall, you aren't going to be walking into it.

/obj/structure/closet/walllocker/emerglocker
	name = "emergency locker"
	desc = "A wall mounted locker with emergency supplies."
	icon_state = "emerg"
	icon_closed = "emerg"
	icon_opened = "emerg_open"

/obj/structure/closet/walllocker/emerglocker/populate_contents()
	switch(pickweight(list("small" = 55, "aid" = 25, "tank" = 10, "both" = 10)))
		if("small")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/clothing/mask/breath(src)
		if("aid")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/storage/toolbox/emergency(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/storage/firstaid/o2(src)
		if("tank")
			new /obj/item/tank/internals/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/tank/internals/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
		if("both")
			new /obj/item/storage/toolbox/emergency(src)
			new /obj/item/tank/internals/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/storage/firstaid/o2(src)


MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/walllocker/emerglocker, 32, 32)
