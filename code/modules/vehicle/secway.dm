/obj/vehicle/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	max_integrity = 100
	armor = list("melee" = 20, "bullet" = 15, "laser" = 10, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)
	key_type = /obj/item/key/security
	integrity_failure = 50
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 1


/obj/item/key/security
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"