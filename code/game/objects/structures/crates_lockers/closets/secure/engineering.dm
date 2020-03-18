/obj/structure/closet/secure_closet/engineering_chief
	name = "chief engineer's locker"
	req_access = list(ACCESS_CE)
	icon_state = "securece1"
	icon_closed = "securece"
	icon_locked = "securece1"
	icon_opened = "secureceopen"
	icon_broken = "securecebroken"
	icon_off = "secureceoff"

/obj/structure/closet/secure_closet/engineering_chief/New()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/industrial(src)
	else
		new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/storage/backpack/duffel/engineering(src)
	new /obj/item/clothing/head/beret/ce(src)
	new /obj/item/areaeditor/blueprints(src)
	new /obj/item/storage/box/permits(src)
	new /obj/item/clothing/under/rank/chief_engineer(src)
	new /obj/item/clothing/under/rank/chief_engineer/skirt(src)
	new /obj/item/clothing/suit/mantle/chief_engineer(src)
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/glasses/welding/superior(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/tank/jetpack/suit(src)
	new /obj/item/cartridge/ce(src)
	new /obj/item/radio/headset/heads/ce(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/multitool(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/flash(src)
	new /obj/item/clothing/head/beret/eng(src)
	new /obj/item/door_remote/chief_engineer(src)
	new /obj/item/rpd(src)
	new /obj/item/reagent_containers/food/drinks/mug/ce(src)
	new /obj/item/organ/internal/cyberimp/eyes/meson(src)
	new /obj/item/clothing/accessory/medal/engineering(src)
	new /obj/item/holosign_creator/atmos(src)


/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "secureengelec1"
	icon_closed = "secureengelec"
	icon_locked = "secureengelec1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengelecbroken"
	icon_off = "secureengelecoff"

/obj/structure/closet/secure_closet/engineering_electrical/New()
	..()
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/apc_electronics(src)
	new /obj/item/apc_electronics(src)
	new /obj/item/apc_electronics(src)
	new /obj/item/multitool(src)
	new /obj/item/multitool(src)
	new /obj/item/multitool(src)
	new /obj/item/clothing/head/beret/eng


/obj/structure/closet/secure_closet/engineering_welding
	name = "welding supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "secureengweld1"
	icon_closed = "secureengweld"
	icon_locked = "secureengweld1"
	icon_opened = "toolclosetopen"
	icon_broken = "secureengweldbroken"
	icon_off = "secureengweldoff"

/obj/structure/closet/secure_closet/engineering_welding/New()
	..()
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/weldingtool/largetank(src)


/obj/structure/closet/secure_closet/engineering_personal
	name = "engineer's locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "secureeng1"
	icon_closed = "secureeng"
	icon_locked = "secureeng1"
	icon_opened = "secureengopen"
	icon_broken = "secureengbroken"
	icon_off = "secureengoff"

/obj/structure/closet/secure_closet/engineering_personal/New()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/industrial(src)
	else
		new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/storage/backpack/duffel/engineering(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/under/rank/engineer/skirt(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/cartridge/engineering(src)
	new /obj/item/clothing/head/beret/eng(src)


/obj/structure/closet/secure_closet/atmos_personal
	name = "technician's locker"
	req_access = list(ACCESS_ATMOSPHERICS)
	icon_state = "secureatm1"
	icon_closed = "secureatm"
	icon_locked = "secureatm1"
	icon_opened = "secureatmopen"
	icon_broken = "secureatmbroken"
	icon_off = "secureatmoff"

/obj/structure/closet/secure_closet/atmos_personal/New()
	..()
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/cartridge/atmos(src)
	new /obj/item/storage/toolbox/mechanical(src)
	if(prob(50))
		new /obj/item/storage/backpack/industrial(src)
	else
		new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/storage/backpack/duffel/atmos(src)
	new /obj/item/extinguisher(src)
	new /obj/item/grenade/gas/oxygen(src)
	new /obj/item/grenade/gas/oxygen(src)
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/emergency_oxygen/engi(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/watertank/atmos(src)
	new /obj/item/clothing/suit/fire/atmos(src)
	new /obj/item/clothing/head/hardhat/atmos(src)
	new /obj/item/rpd(src)
	new /obj/item/destTagger(src)
