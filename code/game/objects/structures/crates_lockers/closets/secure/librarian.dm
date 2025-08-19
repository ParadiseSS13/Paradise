/obj/structure/closet/secure_closet/librarian
	name = "librarian's locker"
	req_access = list(ACCESS_LIBRARY)
	icon_state = "librarian"
	opened_door_sprite = "clown_opened"
	closed_door_sprite = "librarian_closed"


/obj/structure/closet/secure_closet/librarian/populate_contents()
	new /obj/item/storage/bag/garment/librarian(src)
	new /obj/item/videocam/advanced
	new /obj/item/barcodescanner
	new /obj/item/laser_pointer
	new /obj/item/radio/headset/headset_service
	new /obj/item/storage/bag/books
