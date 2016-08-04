/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = CONDUCT
	hitsound = "swing_hit"
	force = 8.0
	throw_speed = 2
	throw_range = 4
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	burn_state = FLAMMABLE
	burntime = 20

/obj/item/weapon/storage/briefcase/New()
	..()