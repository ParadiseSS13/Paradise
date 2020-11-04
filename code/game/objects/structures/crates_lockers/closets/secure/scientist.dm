/obj/structure/closet/secure_closet/scientist
	name = "scientist's locker"
	req_access = list(ACCESS_TOX_STORAGE)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_broken = "secureresbroken"
	icon_off = "secureresoff"

/obj/structure/closet/secure_closet/scientist/New()
	..()
	new /obj/item/storage/backpack/science(src)
	new /obj/item/storage/backpack/satchel_tox(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/under/rank/scientist/skirt(src)
	//new /obj/item/clothing/suit/labcoat/science(src)
	new /obj/item/clothing/suit/storage/labcoat/science(src)
	new /obj/item/clothing/shoes/white(src)
//		new /obj/item/cartridge/signal/toxins(src)
	new /obj/item/radio/headset/headset_sci(src)
	new /obj/item/tank/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/shoes/sandal/white(src)

/obj/structure/closet/secure_closet/roboticist
	name = "roboticist's locker"
	req_access = list(ACCESS_ROBOTICS)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_broken = "secureresbroken"
	icon_off = "secureresoff"

/obj/structure/closet/secure_closet/roboticist/New()
	..()
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
	new /obj/item/reagent_containers/food/drinks/oilcan(src)
	new /obj/item/reagent_containers/food/drinks/oilcan(src)

/obj/structure/closet/secure_closet/RD
	name = "research director's locker"
	req_access = list(ACCESS_RD)
	icon_state = "rdsecure1"
	icon_closed = "rdsecure"
	icon_locked = "rdsecure1"
	icon_opened = "rdsecureopen"
	icon_broken = "rdsecurebroken"
	icon_off = "rdsecureoff"

/obj/structure/closet/secure_closet/RD/New()
	..()
	new /obj/item/clothing/suit/bio_suit/scientist(src)
	new /obj/item/clothing/head/bio_hood/scientist(src)
	new /obj/item/clothing/under/rank/research_director(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/mantle/labcoat(src)
	new /obj/item/cartridge/rd(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/radio/headset/heads/rd(src)
	new /obj/item/tank/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/suit/armor/reactive/teleport(src)
	new /obj/item/flash(src)
	new /obj/item/laser_pointer(src)
	new /obj/item/door_remote/research_director(src)
	new /obj/item/reagent_containers/food/drinks/mug/rd(src)
	new /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic(src)
	new /obj/item/clothing/accessory/medal/science(src)

/obj/structure/closet/secure_closet/research_reagents
	name = "research chemical storage closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "rchemical1"
	icon_closed = "rchemical"
	icon_locked = "rchemical1"
	icon_opened = "medicalopen"
	icon_broken = "rchemicalbroken"
	icon_off = "rchemicaloff"
	req_access = list(ACCESS_TOX_STORAGE)

/obj/structure/closet/secure_closet/research_reagents/New()
	..()
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
