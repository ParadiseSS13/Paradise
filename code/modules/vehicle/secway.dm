/obj/vehicle/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	max_integrity = 100
	armor = list(MELEE = 20, BULLET = 15, LASER = 10, ENERGY = 0, BOMB = 30, RAD = 0, FIRE = 60, ACID = 60)
	key_type = /obj/item/key/security
	integrity_failure = 50
	generic_pixel_y = 4
	vehicle_move_delay = 1


/obj/item/key/security
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"
