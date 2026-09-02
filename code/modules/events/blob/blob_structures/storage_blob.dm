/obj/structure/blob/storage
	name = "storage blob"
	icon_state = "blob_resource"
	fire_resist = 2
	point_return = 12

/obj/structure/blob/storage/obj_destruction(damage_flag)
	if(overmind)
		overmind.max_blob_points -= 50
	..()

/obj/structure/blob/storage/proc/update_max_blob_points(new_point_increase)
	if(overmind)
		overmind.max_blob_points += new_point_increase
