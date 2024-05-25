/obj/effect/decal/cleanable/tar
	gender = PLURAL
	name = "tar"
	desc = "A sticky substance."
	icon_state = "tar2"
	density = FALSE
	opacity = FALSE
	var/turf/simulated/target
	var/old_slowdown

/obj/effect/decal/cleanable/tar/New(turf/simulated/loc)
	if(loc.has_tar) // Check if the turf already has tar.
		qdel(src)
		return
	loc.has_tar = TRUE
	target = loc
	old_slowdown = target.slowdown // Store the original slowdown value
	target.slowdown += 10 // Apply the slowdown effect to the turf
	RegisterSignal(target, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(remove_tar))


	if(prob(50))
		icon_state = "tar3"
	..()

/obj/effect/decal/cleanable/tar/proc/remove_tar(datum/source)
	SIGNAL_HANDLER
	if(target) // Check if the target turf is valid
		target.slowdown = old_slowdown
		target.has_tar = FALSE
		qdel(src)

/obj/effect/decal/cleanable/tar/Crossed(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/L = AM
		playsound(L, 'sound/effects/attackblob.ogg', 50, TRUE)
		to_chat(L, "<span class='userdanger'>[src] sticks to you!</span>")

/obj/effect/decal/cleanable/tar/attackby(obj/item/P, mob/living/user, params)
	if(P.get_heat())
		if(!Adjacent(user)) // To prevent issues as a result of telepathically lighting tar.
			return
		playsound(P, 'sound/items/welder.ogg', 50, TRUE)
		if(do_after(user, 3 SECONDS, FALSE, user))
			user.visible_message("<span class='danger'>[user] burns away [src] with [P]!</span>", "<span class='danger'>You burn away [src]!</span>")
			remove_tar()

