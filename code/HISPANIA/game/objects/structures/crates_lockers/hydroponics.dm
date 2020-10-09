/obj/structure/closet/secure_closet/beekeeper
	name = "beekeeper locker"
	req_access = list(ACCESS_HYDROPONICS)
	icon_state = "beesecure1"
	icon_closed = "beesecure"
	icon_locked = "beesecure1"
	icon_opened = "beesecureopen"
	icon_broken = "beesecurebroken"
	icon_off = "beesecureoff"

/obj/structure/closet/secure_closet/beekeeper/New()
	..()
	switch(rand(1,2))
		if(1)
			new /obj/item/clothing/suit/apron(src)
		if(2)
			new /obj/item/clothing/suit/apron/overalls(src)
	new /obj/item/storage/bag/plants/portaseeder(src)
	new /obj/item/clothing/suit/beekeeper_suit(src)
	new /obj/item/plant_analyzer(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/clothing/head/beekeeper_head(src)
	new /obj/item/melee/flyswatter(src)
	new /obj/item/honey_frame(src)
	new /obj/item/honey_frame(src)
	new /obj/item/honey_frame(src)
	new /obj/item/queen_bee/bought(src)
