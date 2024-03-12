/obj/structure/closet/walllocker
	icon = 'modular_ss220/aesthetics/wallcloset/icons/wallclosets.dmi'

/obj/structure/closet/walllocker/firelocker
	icon_state = "firecloset"
	icon_closed = "firecloset"
	icon_opened = "firecloset_open"

/obj/structure/closet/walllocker/firelocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/firelocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/firelocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/firelocker/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker/firelocker/populate_contents()
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/clothing/head/hardhat/red(src)

/obj/structure/closet/walllocker/medlocker
	icon_state = "medcloset"
	icon_closed = "medcloset"
	icon_opened = "medcloset_open"

/obj/structure/closet/walllocker/medlocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/medlocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/medlocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/medlocker/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker/medlocker/populate_contents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
