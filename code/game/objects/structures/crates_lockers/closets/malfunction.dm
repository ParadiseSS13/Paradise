
/obj/structure/closet/malf/suits
	desc = "It's a storage unit for operational gear."
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/structure/closet/malf/suits/New()
	..()
	new /obj/item/tank/jetpack/void(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/effect/nasavoidsuitspawner(src)
	new /obj/item/crowbar(src)
	new /obj/item/stock_parts/cell(src)
	new /obj/item/multitool(src)
