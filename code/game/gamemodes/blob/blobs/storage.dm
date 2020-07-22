/obj/structure/blob/storage
	name = "storage blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	max_integrity = 30
	fire_resist = 2
	point_return = 12

/obj/structure/blob/storage/obj_destruction(damage_flag)
	if(overmind)
		overmind.max_blob_points -= 50
	..()

/obj/structure/blob/storage/proc/update_max_blob_points(var/new_point_increase)
	if(overmind)
		overmind.max_blob_points += new_point_increase