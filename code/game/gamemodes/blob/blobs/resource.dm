/obj/structure/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	obj_integrity = 30
	max_integrity = 30
	fire_resist = 2
	point_return = 12
	var/mob/camera/blob/overmind = null
	var/resource_delay = 0

/obj/structure/blob/resource/update_icon()
	if(obj_integrity <= 0)
		qdel(src)

/obj/structure/blob/resource/run_action()
	if(resource_delay > world.time)
		return
	flick("blob_resource_glow", src)
	resource_delay = world.time + 40 // 4 seconds
	if(overmind)
		overmind.add_points(1)
