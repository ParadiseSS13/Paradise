/obj/structure/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	max_integrity = 60
	point_return = 12
	COOLDOWN_DECLARE(resource_delay)

/obj/structure/blob/resource/run_action()
	if(!COOLDOWN_FINISHED(src, resource_delay))
		return
	flick("blob_resource_glow", src)
	COOLDOWN_START(src, resource_delay, 4 SECONDS)
	if(overmind)
		overmind.add_points(1)
