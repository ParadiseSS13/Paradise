/obj/structure/closet/secure_closet/cargotech
	name = "cargo technician's locker"
	req_access = list(ACCESS_CARGO)
	icon_state = "cargo"

/obj/structure/closet/secure_closet/cargotech/populate_contents()
	new /obj/item/clothing/under/rank/cargo/tech(src)
	new /obj/item/clothing/under/rank/cargo/tech/skirt(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/head/soft/cargo(src)
	new /obj/item/storage/bag/mail(src)

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	closed_door_sprite = "mixed"

/obj/structure/closet/wardrobe/miner/populate_contents()
	new /obj/item/clothing/under/rank/cargo/miner(src)
	new /obj/item/clothing/under/rank/cargo/miner(src)
	new /obj/item/clothing/under/rank/cargo/miner/skirt(src)
	new /obj/item/clothing/under/rank/cargo/miner/skirt(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/suit/jacket/bomber/mining(src)
	new /obj/item/clothing/suit/jacket/bomber/mining(src)
	new /obj/item/clothing/suit/hooded/wintercoat/miner(src)
	new /obj/item/clothing/suit/hooded/wintercoat/miner(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/storage/backpack/duffel(src)
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/storage/backpack/satchel_explorer(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "mining"
	opened_door_sprite = "cargo"
	req_access = list(ACCESS_MINING)

/obj/structure/closet/secure_closet/miner/populate_contents()
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe/mini(src)
	new /obj/item/radio/headset/headset_cargo/mining(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/bag/plants(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/gun/energy/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/survivalcapsule(src)

/obj/structure/closet/secure_closet/explorer
	name = "explorer's locker"
	req_access = list(ACCESS_EXPEDITION)
	icon_state = "explorer"
	opened_door_sprite = "cargo"

/obj/structure/closet/secure_closet/explorer/populate_contents()
	new /obj/item/radio/headset/headset_cargo/expedition(src)
	new /obj/item/gun/energy/kinetic_accelerator/pistol(src)
	new /obj/item/clothing/suit/hooded/explorer(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/beacon(src)
	new /obj/item/storage/box/relay_kit(src)
	new /obj/item/gps(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/expedition(src)
	new /obj/item/clothing/glasses/meson(src)

/obj/structure/closet/secure_closet/smith
	name = "smith's locker"
	req_access = list(ACCESS_SMITH)
	icon_state = "cargo"
	opened_door_sprite = "cargo"
	closed_door_sprite = "smith"

/obj/structure/closet/secure_closet/smith/populate_contents()
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/storage/bag/garment/smith(src)
	new /obj/item/eftpos(src)
	new /obj/item/pickaxe/drill(src)
	new /obj/item/rcs(src)

/obj/structure/closet/secure_closet/quartermaster
	name = "quartermaster's locker"
	req_access = list(ACCESS_QM)
	icon_state = "qm"
	opened_door_sprite = "cargo"

/obj/structure/closet/secure_closet/quartermaster/populate_contents()
	new /obj/item/radio/headset/heads/qm(src)
	new /obj/item/door_remote/quartermaster(src)
	new /obj/item/autosurgeon/organ/one_use/meson_eyes(src)
	new /obj/item/storage/bag/garment/quartermaster(src)
	new /obj/item/clothing/accessory/medal/supply(src)
	new /obj/item/clothing/accessory/medal/supply(src)
	new /obj/item/clothing/suit/pimpcoat/tan(src)
	new /obj/item/rcs(src)
	new /obj/item/dest_tagger(src)
	new /obj/item/reagent_containers/drinks/mug/qm(src)
	new /obj/item/flash(src)
	new /obj/item/cartridge/qm(src)
	new /obj/item/storage/bag/mail(src)
	new /obj/item/melee/knuckleduster/nanotrasen(src)
	new /obj/item/gun/energy/gun/mini(src)

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
