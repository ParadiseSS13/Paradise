/obj/structure/closet/secure_closet/scientist
	name = "scientist's locker"
	req_access = list(ACCESS_TOX_STORAGE)
	icon_state = "science"
	opened_door_sprite = "white_secure"

/obj/structure/closet/secure_closet/scientist/populate_contents()
	new /obj/item/storage/backpack/science(src)
	new /obj/item/storage/backpack/satchel_tox(src)
	new /obj/item/clothing/under/rank/rnd/scientist(src)
	new /obj/item/clothing/under/rank/rnd/scientist/skirt(src)
	//new /obj/item/clothing/suit/labcoat/science(src)
	new /obj/item/clothing/suit/storage/labcoat/science(src)
	new /obj/item/clothing/shoes/white(src)
//		new /obj/item/cartridge/signal/toxins(src)
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/tank/internals/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/shoes/sandal/white(src)

/obj/structure/closet/secure_closet/roboticist
	name = "roboticist's locker"
	req_access = list(ACCESS_ROBOTICS)
	icon_state = "robotics"

/obj/structure/closet/secure_closet/roboticist/populate_contents()
	new /obj/item/mod/core/standard(src)
	new /obj/item/storage/backpack/robotics(src)
	new /obj/item/storage/backpack/robotics(src)
	new /obj/item/storage/backpack/satchel_robo(src)
	new /obj/item/storage/backpack/satchel_robo(src)
	new /obj/item/storage/backpack/duffel/robotics(src)
	new /obj/item/storage/backpack/duffel/robotics(src)
	new /obj/item/clothing/suit/storage/labcoat/roboblack(src)
	new /obj/item/clothing/suit/storage/labcoat/robowhite(src)
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/radio/headset/headset_sci(src)


/obj/structure/closet/secure_closet/rd
	name = "research director's locker"
	req_access = list(ACCESS_RD)
	icon_state = "rd"


/obj/structure/closet/secure_closet/rd/populate_contents()
	new /obj/item/storage/bag/garment/research_director(src)
	new /obj/item/clothing/suit/bio_suit/scientist(src)
	new /obj/item/clothing/head/bio_hood/scientist(src)
	new /obj/item/cartridge/rd(src)
	new /obj/item/radio/headset/heads/rd(src)
	new /obj/item/tank/internals/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/effect/spawner/reactive_armor(src)
	new /obj/item/flash(src)
	new /obj/item/laser_pointer(src)
	new /obj/item/door_remote/research_director(src)
	new /obj/item/reagent_containers/drinks/mug/rd(src)
	new /obj/item/clothing/accessory/medal/science(src)
	new /obj/item/gun/energy/gun/mini(src)
	new /obj/item/autosurgeon/organ/one_use/diagnostic_hud(src)

/obj/structure/closet/secure_closet/research_reagents
	name = "research chemical storage closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "med"
	closed_door_sprite = "rchemical"
	req_access = list(ACCESS_TOX_STORAGE)

/obj/structure/closet/secure_closet/research_reagents/populate_contents()
	new /obj/item/reagent_containers/glass/bottle/reagent/morphine(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/morphine(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/morphine(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/morphine(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/insulin(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/insulin(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/insulin(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/insulin(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/phenol(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/ammonia(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/oil(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acetone(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acid(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/diethylamine(src)
