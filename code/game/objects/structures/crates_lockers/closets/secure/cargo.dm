/obj/structure/closet/secure_closet/cargotech
	name = "cargo technician's locker"
	req_access = list(ACCESS_CARGO)
	icon_state = "cargo"
	open_door_sprite = "mining_door"

/obj/structure/closet/secure_closet/cargotech/populate_contents()
	new /obj/item/clothing/under/rank/cargotech(src)
	new /obj/item/clothing/under/rank/cargotech/skirt(src)
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
	new /obj/item/clothing/under/rank/cargo(src)
	new /obj/item/clothing/under/rank/cargo/skirt(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/door_remote/quartermaster(src)
	new /obj/item/organ/internal/eyes/cybernetic/meson(src)
