/obj/item/arrowhead
	name = "bizarre arrowhead"
	desc = "A bizarre piece of debris from space, fated to find its way to your station. It may be able to grant powers to the worthy, but you have a terrible feeling of what will happen to the unworthy."
	icon = 'icons/obj/bizarre_debris.dmi'
	icon_state = "arrowhead"
	w_class = 1
	new_attack_chain = TRUE

/obj/item/arrowhead/Initialize(mapload)
	START_PROCESSING(SSobj, src)
	set_light(2, 4, "#ffd04f")

/obj/item/arrowhead/proc/has_stand(mob/living/user)
	for(var/datum/action/stand/manifest/manifest in user.actions)
		return TRUE
	return FALSE

/obj/item/arrowhead/activate_self(mob/user)
	if(..())
		return
	if(has_stand(user))
		to_chat(user, "Your abilities have already been awoken by the arrowhead!")
		return
	if(prob(0)) // Set to 50 later
		to_chat(user, "Your soul is deemed unworthy by the arrowhead, you die on the spot!")
		user.death(FALSE)
	else
		var/datum/action/stand/manifest/manifest = new(user)
		manifest.Grant(user)
		to_chat(user, "You feel new abilities awakening within yourself!")
		qdel(src)

/obj/item/arrowhead/process()
	. = ..()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 40,"#ffd04f", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)

/obj/item/arrowhead/Destroy()
	remove_filter("ray")
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	return ..()
