/obj/structure/closet/secure_closet/engineering_chief
	name = "chief engineer's locker"
	req_access = list(ACCESS_CE)
	icon_state = "ce"
	opened_door_sprite = "white_secure"

/obj/structure/closet/secure_closet/engineering_chief/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/industrial(src)
	else
		new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/storage/backpack/duffel/engineering(src)
	new /obj/item/areaeditor/blueprints/ce(src)
	new /obj/item/storage/box/permits(src)
	new /obj/item/storage/bag/garment/chief_engineer(src)
	new /obj/item/mod/module/jetpack/advanced(src)
	new /obj/item/cartridge/ce(src)
	new /obj/item/radio/headset/heads/ce(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/multitool(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/flash(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/clothing/glasses/meson/engine/atmos(src)
	new /obj/item/door_remote/chief_engineer(src)
	new /obj/item/rpd(src)
	new /obj/item/reagent_containers/drinks/mug/ce(src)
	new /obj/item/autosurgeon/organ/one_use/meson_eyes(src)
	new /obj/item/autosurgeon/organ/one_use/wire_interface(src)
	new /obj/item/clothing/accessory/medal/engineering(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/rcd/preloaded(src)
	new /obj/item/storage/bag/construction(src)
	new /obj/item/gun/energy/gun/mini(src)


/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	closed_door_sprite = "eng_elec"

/obj/structure/closet/secure_closet/engineering_electrical/populate_contents()
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
	icon_state = "eng"
	closed_door_sprite = "eng_weld"

/obj/structure/closet/secure_closet/engineering_welding/populate_contents()
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/weldingtool/largetank(src)


/obj/structure/closet/secure_closet/engineering_personal
	name = "engineer's locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	closed_door_sprite = "eng_secure"

/obj/structure/closet/secure_closet/engineering_personal/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/industrial(src)
	else
		new /obj/item/storage/backpack/satchel_eng(src)
	new /obj/item/storage/backpack/duffel/engineering(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/clothing/under/rank/engineering/engineer(src)
	new /obj/item/clothing/under/rank/engineering/engineer/skirt(src)
	new /obj/item/clothing/suit/storage/hazardvest/staff(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/cartridge/engineering(src)
	new /obj/item/clothing/head/beret/eng(src)
	new /obj/item/storage/bag/construction(src)


/obj/structure/closet/secure_closet/atmos_personal
	name = "technician's locker"
	req_access = list(ACCESS_ATMOSPHERICS)
	icon_state = "atmos"
	opened_door_sprite = "eng_secure"

/obj/structure/closet/secure_closet/atmos_personal/populate_contents()
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/cartridge/atmos(src)
	new /obj/item/storage/toolbox/mechanical(src)
	if(prob(50))
		new /obj/item/storage/backpack/industrial/atmos(src)
	else
		new /obj/item/storage/backpack/satchel_atmos(src)
	new /obj/item/storage/backpack/duffel/atmos(src)
	new /obj/item/extinguisher/atmospherics(src)
	new /obj/item/grenade/gas/oxygen(src)
	new /obj/item/grenade/gas/oxygen(src)
	new /obj/item/clothing/suit/storage/hazardvest/staff(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/watertank/atmos(src)
	new /obj/item/clothing/suit/fire/firefighter/atmos(src)
	new /obj/item/clothing/head/hardhat/atmos(src)
	new /obj/item/clothing/glasses/meson/engine/atmos(src)
	new /obj/item/rpd(src)
	new /obj/item/dest_tagger(src)
