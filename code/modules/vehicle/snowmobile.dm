/obj/vehicle/snowmobile
	name = "red snowmobile"
	desc = "Wheeeeeeeeeeee."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "snowmobile"

/obj/vehicle/snowmobile/buckle_mob()
	. = ..()
	riding_datum = new/datum/riding/snowmobile

/obj/vehicle/snowmobile/blue
	name = "blue snowmobile"
	icon_state = "bluesnowmobile"

/obj/item/key/snowmobile
	name = "snowmobile key"
	desc = "A keyring with a small steel key, and tag with a red cross on it; clearly it's not implying you're going to the hospital for this..."
	icon_state = "keydoc" //get a better icon, sometime.
