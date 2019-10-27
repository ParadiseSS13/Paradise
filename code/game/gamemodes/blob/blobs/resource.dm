/obj/structure/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	max_integrity = 60
	point_return = 12
	var/resource_delay = 0

/obj/structure/blob/resource/run_action()
	if(resource_delay > world.time)
		return
	flick("blob_resource_glow", src)
	resource_delay = world.time + 40 // 4 seconds
	if(overmind)
		overmind.add_points(1)
