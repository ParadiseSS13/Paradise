// can't die if you're not alive
/mob/proc/gib()
	return FALSE

/mob/proc/dust()
	return FALSE

/mob/proc/melt()
	return FALSE

/mob/proc/death(gibbed)
	return FALSE

/mob/proc/dust_animation()
	var/atom/movable/overlay/animation = null
	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	//	flick("dust-m", animation)
	new /obj/effect/decal/cleanable/ash(loc)
	QDEL_IN(animation, 15)
