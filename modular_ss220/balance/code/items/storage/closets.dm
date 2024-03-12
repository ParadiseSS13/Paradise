// Paramedic Closet
/obj/structure/closet/secure_closet/paramedic/populate_contents()
	. = ..()
	new /obj/item/grenade/jaunter_grenade(src)
	new /obj/item/grenade/jaunter_grenade(src)

// Blueshield Closet
/obj/structure/closet/secure_closet/blueshield/populate_contents()
	. = ..()
	new /obj/item/melee/baton/electrostaff/loaded(src)
	new /obj/item/screwdriver(src)
