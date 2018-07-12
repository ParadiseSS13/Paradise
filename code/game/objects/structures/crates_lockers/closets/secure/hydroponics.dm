/obj/structure/closet/secure_closet/hydroponics
	name = "botanist's locker"
	req_access = list(access_hydroponics)
	icon_state = "hydrosecure1"
	icon_closed = "hydrosecure"
	icon_locked = "hydrosecure1"
	icon_opened = "hydrosecureopen"
	icon_broken = "hydrosecurebroken"
	icon_off = "hydrosecureoff"


/obj/structure/closet/secure_closet/hydroponics/New()
	..()
	switch(rand(1,2))
		if(1)
			new /obj/item/clothing/suit/apron(src)
		if(2)
			new /obj/item/clothing/suit/apron/overalls(src)
	new /obj/item/storage/bag/plants/portaseeder(src)
	new /obj/item/clothing/under/rank/hydroponics(src)
	new /obj/item/plant_analyzer(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/clothing/mask/bandana/botany(src)
	new /obj/item/cultivator(src)
	new /obj/item/hatchet(src)
	new /obj/item/storage/box/disks_plantgene(src)