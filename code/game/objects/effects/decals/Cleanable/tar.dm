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

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

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

/obj/effect/decal/cleanable/tar/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(isliving(entered))
		var/mob/living/L = entered
		playsound(L, 'sound/effects/attackblob.ogg', 50, TRUE)
		to_chat(L, "<span class='userdanger'>[src] sticks to you!</span>")

/obj/effect/decal/cleanable/tar/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/obj/item/weldingtool/fire_tool = used
	if(!fire_tool.get_heat() || !Adjacent(user))
		return ITEM_INTERACT_COMPLETE
	playsound(fire_tool, 'sound/items/welder.ogg', 50, TRUE)
	if(do_after(user, 3 SECONDS, FALSE, user))
		if(fire_tool.get_heat() && Adjacent(user))
			user.visible_message("<span class='danger'>[user] burns away [src] with [fire_tool]!</span>", "<span class='danger'>You burn away [src]!</span>")
			qdel(src)
			return ITEM_INTERACT_COMPLETE
