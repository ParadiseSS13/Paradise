/obj/structure/closet/secure_closet/hydroponics
	name = "botanist's locker"
	req_access = list(ACCESS_HYDROPONICS)
	icon_state = "hydro"

/obj/structure/closet/secure_closet/hydroponics/populate_contents()
	switch(rand(1,2))
		if(1)
			new /obj/item/clothing/suit/apron(src)
		if(2)
			new /obj/item/clothing/suit/apron/overalls(src)
	new /obj/item/storage/bag/plants/portaseeder(src)
	new /obj/item/clothing/under/rank/civilian/hydroponics(src)
	new /obj/item/clothing/under/rank/civilian/hydroponics/alt(src)
	new /obj/item/clothing/head/soft/hydroponics
	new /obj/item/clothing/head/soft/hydroponics_alt
	new /obj/item/plant_analyzer(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/clothing/mask/bandana/botany(src)
	new /obj/item/cultivator(src)
	new /obj/item/hatchet(src)
	new /obj/item/storage/box/disks_plantgene(src)
	new /obj/item/clothing/glasses/hud/hydroponic(src)
