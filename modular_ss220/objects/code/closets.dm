/obj/structure/closet/secure_closet/expedition
	name = "expeditors locker"
	req_access = list(ACCESS_EXPEDITION)
	icon = 'modular_ss220/objects/icons/closets.dmi'
	icon_state = "explorer"
	icon_opened = "explorer_open"
	open_door_sprite = "explorer_door"

/obj/structure/closet/secure_closet/expedition/populate_contents()
	new /obj/item/gun/energy/laser/awaymission_aeg/rnd(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/paper/pamphlet/gateway(src)

/obj/structure/closet/secure_closet/blueshield/populate_contents()
	. = ..()
	new /obj/item/melee/baton/electrostaff/loaded(src)
	new /obj/item/screwdriver(src)
