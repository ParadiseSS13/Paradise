/obj/item/storage/fancy/cigarettes/cigpack_xeno
	name = "\improper Xeno Filtered packet"
	desc = "Loaded with 100% pure slime. And also nicotine."
	icon = 'icons/hispania/obj/items.dmi'
	icon_state = "slime"

/obj/item/storage/fancy/heart_box
	name = "heart-shaped box"
	desc = "A heart-shaped box for holding tiny chocolates."
	icon = 'icons/hispania/obj/food/containers.dmi'
	item_state = "chocolatebox"
	icon_state = "chocolatebox8"
	icon_type = "chocolate"
	lefthand_file = 'icons/hispania/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/items_righthand.dmi'
	storage_slots = 8
	can_hold = list(/obj/item/reagent_containers/food/snacks/tinychocolate)

/obj/item/storage/fancy/heart_box/New()
	..()
	for(var/i = 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/tinychocolate(src)

/obj/item/storage/fancy/flare_box
	name = "flare box"
	desc = "A pack of six flares."
	icon = 'icons/hispania/obj/food/containers.dmi'
	icon_state = "flarebox6"
	icon_type = "flare"
	item_state = "flarebox"
	lefthand_file = 'icons/hispania/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/items_righthand.dmi'
	storage_slots = 6
	throwforce = 2
	slot_flags = SLOT_BELT
	can_hold = list(/obj/item/flashlight/flare)

/obj/item/storage/fancy/flare_box/full/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/flashlight/flare(src)
	return
