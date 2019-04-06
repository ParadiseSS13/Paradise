/obj/structure/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	health = 30
	fire_resist = 2
	point_return = 12
	var/mob/camera/blob/overmind = null
	var/resource_delay = 0

/obj/structure/blob/resource/update_icon()
	if(health <= 0)
		qdel(src)

/obj/structure/blob/resource/run_action()

	if(resource_delay > world.time)
		return 0

	resource_delay = world.time + 40 // 4 seconds

	if(overmind)
		overmind.add_points(1)
	return 0

