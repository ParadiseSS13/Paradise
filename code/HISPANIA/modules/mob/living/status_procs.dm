/mob/living/proc/add_quirk(quirktype, spawn_effects) //separate proc due to the way these ones are handled
	if(HAS_TRAIT(src, quirktype))
		return
	var/datum/quirk/T = quirktype
	var/qname = initial(T.name)
	if(!SSquirks || !SSquirks.quirks[qname])
		return
	new quirktype (src, spawn_effects)
	return TRUE

/mob/living/proc/remove_quirk(quirktype)
	for(var/datum/quirk/Q in roundstart_quirks)
		if(Q.type == quirktype)
			qdel(Q)
			return TRUE
	return FALSE

/mob/living/proc/has_quirk(quirktype)
	for(var/datum/quirk/Q in roundstart_quirks)
		if(Q.type == quirktype)
			return TRUE
	return FALSE
