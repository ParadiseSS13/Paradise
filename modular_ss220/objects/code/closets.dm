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

/obj/structure/closet/secure_closet/hos/populate_contents()
	. = ..()
	new /obj/item/clothing/gloves/combat(src)
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/speed_loader_d44(src)
