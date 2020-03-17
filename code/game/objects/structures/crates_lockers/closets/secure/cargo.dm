/obj/structure/closet/secure_closet/cargotech
	name = "cargo technician's locker"
	req_access = list(ACCESS_CARGO)
	icon_state = "securecargo1"
	icon_closed = "securecargo"
	icon_locked = "securecargo1"
	icon_opened = "securecargoopen"
	icon_broken = "securecargobroken"
	icon_off = "securecargooff"

/obj/structure/closet/secure_closet/cargotech/New()
	..()
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
	icon_state = "secureqm1"
	icon_closed = "secureqm"
	icon_locked = "secureqm1"
	icon_opened = "secureqmopen"
	icon_broken = "secureqmbroken"
	icon_off = "secureqmoff"

/obj/structure/closet/secure_closet/quartermaster/New()
	..()
	new /obj/item/clothing/under/rank/cargo(src)
	new /obj/item/clothing/under/rank/cargo/skirt(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/tank/emergency_oxygen(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/door_remote/quartermaster(src)
	new /obj/item/organ/internal/cyberimp/eyes/meson(src)
