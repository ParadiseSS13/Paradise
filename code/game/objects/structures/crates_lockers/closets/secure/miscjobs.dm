/obj/structure/closet/secure_closet/clown
	name = "clown's locker"
	req_access = list()
	icon_state = "clownsecure1"
	icon_closed = "clownsecure"
	icon_locked = "clownsecure1"
	icon_opened = "clownsecureopen"
	icon_broken = "clownsecurebroken"
	icon_off = "clownsecureoff"

/obj/structure/closet/secure_closet/clown/New()
	..()
	new /obj/item/weapon/storage/backpack/clown(src)
	new /obj/item/clothing/under/rank/clown(src)
	new /obj/item/clothing/shoes/clown_shoes(src)
	new /obj/item/device/radio/headset/headset_service(src)
	new /obj/item/clothing/mask/gas/clown_hat(src)
	new /obj/item/weapon/bikehorn(src)
	new /obj/item/weapon/reagent_containers/spray/waterflower(src)
	new /obj/item/toy/crayon/rainbow(src)
	new /obj/item/seeds/bananaseed(src)



/obj/structure/closet/secure_closet/mime
	name = "mime's locker"
	req_access = list()
	icon_state = "mimesecure1"
	icon_closed = "mimesecure"
	icon_locked = "mimesecure1"
	icon_opened = "mimesecureopen"
	icon_broken = "mimesecurebroken"
	icon_off = "mimesecureoff"

/obj/structure/closet/secure_closet/mime/New()
	..()
	new /obj/item/clothing/head/beret(src)
	new /obj/item/clothing/mask/gas/mime(src)
	new /obj/item/device/radio/headset/headset_service(src)
	new /obj/item/clothing/under/mime(src)
	new /obj/item/clothing/suit/suspenders(src)
	new /obj/item/clothing/gloves/color/white(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/weapon/storage/backpack/mime(src)
	new /obj/item/toy/crayon/mime(src)
	new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(src)
	new /obj/item/weapon/cane(src)