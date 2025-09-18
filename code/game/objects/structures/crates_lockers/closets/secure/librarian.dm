/obj/structure/closet/secure_closet/librarian
	name = "librarian's locker"
	req_access = list(ACCESS_LIBRARY)
	icon_state = "librarian"
	opened_door_sprite = "clown"
	closed_door_sprite = "librarian"


/obj/structure/closet/secure_closet/librarian/populate_contents()
	new /obj/item/storage/bag/garment/librarian(src)
	new /obj/item/videocam/advanced(src)
	new /obj/item/barcodescanner(src)
	new /obj/item/laser_pointer(src)
	new /obj/item/radio/headset/headset_service(src)
	new /obj/item/storage/bag/books(src)
