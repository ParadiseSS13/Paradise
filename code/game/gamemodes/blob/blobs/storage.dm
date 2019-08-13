/obj/structure/blob/storage
	name = "storage blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	max_integrity = 30
	fire_resist = 2
	point_return = 12
	var/mob/camera/blob/overmind = null

/obj/structure/blob/storage/Destroy()
	. = ..()
	overmind.max_blob_points -= 50

/obj/structure/blob/storage/proc/update_max_blob_points(var/new_point_increase)
	if(overmind)
		overmind.max_blob_points += new_point_increase