/obj/item/weapon/gun/energy/shuriken
	name = "energy shuriken"
	desc = "A stunning shuriken made of energy."
	icon_state = "shuriken"
	item_state = null
	icon = 'icons/obj/ninjaobjects.dmi'
	fire_sound = 'sound/weapons/Genhit.ogg'
	cell_type = "/obj/item/weapon/stock_parts/cell/infinite"
	projectile_type = "/obj/item/projectile/energy/shuriken"
	charge_cost = 0
	silenced = 1

/obj/item/weapon/gun/energy/shuriken/update_icon()
	qdel(src)
	return

/obj/item/weapon/gun/energy/shuriken/dropped()
	qdel(src)
	return

/obj/item/weapon/gun/energy/shuriken/proc/throw()
	qdel(src)
	return