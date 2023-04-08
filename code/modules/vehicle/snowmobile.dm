/obj/vehicle/snowmobile
	name = "red snowmobile"
	desc = "Wheeeeeeeeeeee."
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "snowmobile"
	move_speed = 0
	key_type = /obj/item/key/snowmobile
	generic_pixel_x = 0
	generic_pixel_y = 4

/obj/vehicle/snowmobile/blue
	name = "blue snowmobile"
	icon_state = "bluesnowmobile"

/obj/vehicle/snowmobile/key/Initialize(mapload)
	. = ..()
	inserted_key = new /obj/item/key/snowmobile(null)

/obj/vehicle/snowmobile/blue/key/Initialize(mapload)
	. = ..()
	inserted_key = new /obj/item/key/snowmobile(null)

/obj/item/key/snowmobile
	name = "snowmobile key"
	desc = "A keyring with a small steel key, and tag with a red cross on it; clearly it's not implying you're going to the hospital for this..."
	icon_state = "keydoc" //get a better icon, sometime.
