/obj/structure/closet/secure_closet/cargotech
	name = "cargo technician's locker"
	req_access = list(ACCESS_CARGO)
	icon_state = "cargo"
	open_door_sprite = "mining_door"

/obj/structure/closet/secure_closet/cargotech/populate_contents()
	new /obj/item/clothing/under/rank/cargo/tech(src)
	new /obj/item/clothing/under/rank/cargo/tech/skirt(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/head/soft(src)
//		new /obj/item/cartridge/quartermaster(src)


/obj/structure/closet/secure_closet/quartermaster
	name = "quartermaster's locker"
	req_access = list(ACCESS_QM)
	icon_state = "qm"
	open_door_sprite = "mining_door"

/obj/structure/closet/secure_closet/quartermaster/populate_contents()
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/door_remote/quartermaster(src)
	new /obj/item/organ/internal/eyes/cybernetic/meson(src)
	new /obj/item/storage/bag/garment/quartermaster(src)
	new /obj/item/clothing/accessory/medal/supply(src)
