/obj/item/storage/csi_markers
	name = "crime scene markers box"
	desc = "A cardboard box for crime scene marker cards."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "cards"
	w_class = ITEM_SIZE_TINY
	/obj/item/storage/breifcase/crimekit/populate_contents()
	new /obj/item/csi_marker/n1(src)
	new /obj/item/csi_marker/n2(src)
	new /obj/item/csi_marker/n3(src)
	new /obj/item/csi_marker/n4(src)
	new /obj/item/csi_marker/n5(src)
	new /obj/item/csi_marker/n6(src)
	new /obj/item/csi_marker/n7(src)

/obj/item/storage/csi_markers/Initialize()
	. = ..()
	make_exact_fit()

/obj/item/csi_marker
	name = "crime scene marker"
	desc = "Plastic cards used to mark points of interests on the scene. Just like in the holoshows!"
	icon = 'icons/obj/forensics.dmi'
	icon_state = "card1"
	w_class = ITEM_SIZE_TINY
	randpixel = 1
	layer = ABOVE_HUMAN_LAYER  //so you can mark bodies
	var/number = 1

/obj/item/csi_marker/Initialize(mapload)
	. = ..()
	desc += " This one is marked with [number]."
	update_icon()

/obj/item/csi_marker/on_update_icon()
	icon_state = "card[clamp(number,1,7)]"

/obj/item/csi_marker/n1
	number = 1
/obj/item/csi_marker/n2
	number = 2
/obj/item/csi_marker/n3
	number = 3
/obj/item/csi_marker/n4
	number = 4
/obj/item/csi_marker/n5
	number = 5
/obj/item/csi_marker/n6
	number = 6
/obj/item/csi_marker/n7
	number = 7
