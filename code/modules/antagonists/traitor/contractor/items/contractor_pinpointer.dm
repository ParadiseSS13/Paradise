/obj/item/pinpointer/crew/contractor
	name = "contractor pinpointer"
	desc = "A handheld tracking device that points to crew without needing suit sensors at the cost of accuracy."
	icon_state = "pinoff_contractor"
	icon_off = "pinoff_contractor"
	icon_null = "pinonnull_contractor"
	icon_direct = "pinondirect_contractor"
	icon_close = "pinonclose_contractor"
	icon_medium = "pinonmedium_contractor"
	icon_far = "pinonfar_contractor"
	/// The minimum range for the pinpointer to function properly.
	var/min_range = 20
	/// The first person to have used the item. If this is set already, no one else can use it.
	var/mob/owner = null

/obj/item/pinpointer/crew/contractor/point_at(atom/target)
	if(target && trackable(target))
		// Calc dir
		var/turf/T = get_turf(target)
		var/turf/L = get_turf(src)
		dir = get_dir(L, T)
		// Calc dist
		var/dist = get_dist(L, T)
		if(ISINRANGE(dist, -1, min_range))
			icon_state = icon_direct
		else if(ISINRANGE(dist, min_range + 1, min_range + 8))
			icon_state = icon_close
		else if(ISINRANGE(dist, min_range + 9, min_range + 16))
			icon_state = icon_medium
		else if(ISINRANGE(dist, min_range + 16, INFINITY))
			icon_state = icon_far
	else
		icon_state = icon_null

/obj/item/pinpointer/crew/contractor/trackable(mob/living/carbon/human/H)
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(H)
	return here && there && there.z == here.z

/obj/item/pinpointer/crew/contractor/attack_self__legacy__attackchain(mob/living/user)
	if(owner)
		if(owner != user.mind.current)
			to_chat(user, "<span class='warning'>[src] refuses to do anything.</span>")
			return
	else
		owner = user.mind.current
		to_chat(user, "<span class='notice'>[src] now recognizes you as its sole user.</span>")
	return ..()
