/obj/structure/displaycase/hos
	start_showpiece_type = /obj/item/gun/projectile/revolver/reclinable/anaconda

/obj/structure/closet/secure_closet/hos/populate_contents()
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/speed_loader_d44(src)
