/obj/effect/decal/cleanable/tar
	gender = PLURAL
	name = "tar"
	desc = "A sticky substance."
	icon_state = "tar2"
	/// The turf that the tar is sitting on
	var/turf/simulated/target

/obj/effect/decal/cleanable/tar/Initialize(mapload)
	. = ..()
	if(issimulatedturf(loc)) // Ensure the location is a simulated turf
		target = loc
		target.slowdown += 10 // Apply the slowdown effect to the turf
		if(prob(50))
			icon_state = "tar3"

/obj/effect/decal/cleanable/tar/Destroy()
	if(target)
		target.slowdown -= 10
	return ..()

/obj/effect/decal/cleanable/tar/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	target.slowdown -= 10
	target = loc
	target.slowdown += 10
	if(!issimulatedturf(target))  // We remove slowdown in Destroy(), so we run this check after adding the slowdown.
		qdel(src)

/obj/effect/decal/cleanable/tar/Crossed(atom/movable/movable_atom)
	if(isliving(movable_atom))
		var/mob/living/L = movable_atom
		playsound(L, 'sound/effects/attackblob.ogg', 50, TRUE)
		to_chat(L, "<span class='userdanger'>[src] sticks to you!</span>")

/obj/effect/decal/cleanable/tar/attackby(obj/item/welder, mob/living/user, params)
	if(!welder.get_heat() || !Adjacent(user))
		return
	playsound(welder, 'sound/items/welder.ogg', 50, TRUE)
	if(do_after(user, 3 SECONDS, FALSE, user))
		if(welder.get_heat() && Adjacent(user))
			user.visible_message("<span class='danger'>[user] burns away [src] with [welder]!</span>", "<span class='danger'>You burn away [src]!</span>")
			qdel(src)
