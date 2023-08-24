/obj/structure/closet/secure_closet/scientist
	name = "scientist's locker"
	req_access = list(ACCESS_TOX_STORAGE)
	icon_state = "res"

/obj/structure/closet/secure_closet/scientist/populate_contents()
	new /obj/item/storage/backpack/science(src)
	new /obj/item/storage/backpack/science(src)
	new /obj/item/storage/backpack/satchel_tox(src)
	new /obj/item/storage/backpack/satchel_tox(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist/skirt(src)
	new /obj/item/clothing/under/rank/scientist/skirt(src)
	new /obj/item/clothing/suit/storage/labcoat/science(src)
	new /obj/item/clothing/suit/storage/labcoat/science(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/tank/internals/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/shoes/sandal/white(src)
	new /obj/item/clothing/shoes/sandal/white(src)

/obj/structure/closet/secure_closet/roboticist
	name = "roboticist's locker"
	req_access = list(ACCESS_ROBOTICS)
	icon_state = "res"

/obj/structure/closet/secure_closet/roboticist/populate_contents()
	new /obj/item/storage/backpack(src)
	new /obj/item/storage/backpack(src)
	new /obj/item/storage/backpack/satchel_norm(src)
	new /obj/item/storage/backpack/satchel_norm(src)
	new /obj/item/storage/backpack/duffel(src)
	new /obj/item/storage/backpack/duffel(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/radio/headset/headset_sci(src)

/obj/structure/closet/secure_closet/RD
	name = "research director's locker"
	req_access = list(ACCESS_RD)
	icon_state = "rd"

/obj/structure/closet/secure_closet/RD/populate_contents()
	new /obj/item/cartridge/rd(src)
	new /obj/item/radio/headset/heads/rd(src)
	new /obj/item/tank/internals/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/suit/armor/reactive/teleport(src) //avoid to put in garmentbag
	new /obj/item/flash(src)
	new /obj/item/laser_pointer(src)
	new /obj/item/door_remote/research_director(src)
	new /obj/item/reagent_containers/food/drinks/mug/rd(src)
	new /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic(src)
	new /obj/item/clothing/accessory/medal/science(src)
	new /obj/item/megaphone(src)	//added here deleted on maps
	new /obj/item/storage/garmentbag/RD(src)
	new /obj/item/t_scanner/experimental(src)

/obj/structure/closet/secure_closet/research_reagents
	name = "research chemical storage closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "res"
	custom_door_overlay = "rchemical"
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
