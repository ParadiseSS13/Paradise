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
	new /obj/item/storage/bag/mail(src)

/obj/structure/closet/secure_closet/quartermaster
	name = "quartermaster's locker"
	req_access = list(ACCESS_QM)
	icon_state = "qm"
	open_door_sprite = "mining_door"

/obj/structure/closet/secure_closet/quartermaster/populate_contents()
	new /obj/item/radio/headset/heads/qm(src)
	new /obj/item/door_remote/quartermaster(src)
	new /obj/item/organ/internal/eyes/cybernetic/meson(src)
	new /obj/item/storage/bag/garment/quartermaster(src)
	new /obj/item/clothing/accessory/medal/supply(src)
	new /obj/item/rcs(src)
	new /obj/item/destTagger(src)
	new /obj/item/reagent_containers/drinks/mug/qm(src)
	new /obj/item/flash(src)
	new /obj/item/cartridge/qm(src)
	new /obj/item/storage/bag/mail(src)
	new /obj/item/melee/knuckleduster/nanotrasen(src)

/// used in mining outpost
/obj/structure/closet/secure_closet/quartermaster/lavaland
	name = "quartermaster's secondary locker"

/obj/structure/closet/secure_closet/quartermaster/lavaland/populate_contents()
	new /obj/item/fulton_core(src)
	new /obj/item/extraction_pack(src)
	new /obj/item/gps/mining(src)
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/clothing/suit/hooded/explorer(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/book/manual/wiki/sop_supply(src)
	new /obj/item/folder/yellow(src)
	new /obj/item/fan(src)
