/obj/effect/decal/cleanable
	anchored = TRUE
	var/list/random_icon_states = list()

/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/New()
	if(random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)
	..()

/obj/effect/decal/cleanable/Destroy()
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()