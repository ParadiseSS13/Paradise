/obj/effect/acid
	gender = PLURAL
	name = "acid"
	desc = "Burbling corrosive stuff."
	icon_state = "acid"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = ABOVE_NORMAL_TURF_LAYER
	var/turf/target


/obj/effect/acid/Initialize(mapload, acid_pwr, acid_amt)
	. = ..()

	target = get_turf(src)

	if(acid_amt)
		acid_level = min(acid_amt * acid_pwr, 12000) //capped so the acid effect doesn't last a half hour on the floor.

	//handle APCs and newscasters and stuff nicely
	pixel_x = target.pixel_x + rand(-4,4)
	pixel_y = target.pixel_y + rand(-4,4)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	START_PROCESSING(SSobj, src)

/obj/effect/acid/Destroy()
	STOP_PROCESSING(SSobj, src)
	target = null
	return ..()

/obj/effect/acid/process()
	. = 1
	if(!target)
		qdel(src)
		return 0

	if(prob(5))
		playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

	for(var/obj/O in target)
		if(prob(20) && !(resistance_flags & UNACIDABLE))
			if(O.acid_level < acid_level * 0.3)
				var/acid_used = min(acid_level * 0.05, 20)
				O.acid_act(10, acid_used)
				acid_level = max(0, acid_level - acid_used * 10)

	acid_level = max(acid_level - (5 + 2 * round(sqrt(acid_level))), 0)
	if(acid_level <= 0)
		qdel(src)
		return 0

/obj/effect/acid/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED
	if(!isliving(entered) && !isobj(entered))
		return
	if(isliving(entered))
		var/mob/living/L = entered
		if(HAS_TRAIT(L, TRAIT_FLYING))
			return
		if(L.m_intent != MOVE_INTENT_WALK && prob(40))
			var/acid_used = min(acid_level * 0.05, 20)
			if(L.acid_act(10, acid_used, "feet"))
				acid_level = max(0, acid_level - acid_used * 10)

//xenomorph corrosive acid
/obj/effect/acid/alien
	var/target_strength = 30

/obj/effect/acid/alien/Initialize(mapload, acid_pwr, acid_amt)
	. = ..()
	var/turf/cleanable_turf = get_turf(src)
	RegisterSignal(cleanable_turf, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(remove_acid))

/obj/effect/acid/alien/proc/remove_acid(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/acid/alien/process()
	. = ..()
	if(.)
		if(prob(45))
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)
		target_strength--
		if(target_strength <= 0)
			target.visible_message("<span class='warning'>[target] collapses under its own weight into a puddle of goop and undigested debris!</span>")
			target.acid_melt()
			qdel(src)
		else

			switch(target_strength)
				if(24)
					visible_message("<span class='warning'>[target] is holding up against the acid!</span>")
				if(16)
					visible_message("<span class='warning'>[target] is being melted by the acid!</span>")
				if(8)
					visible_message("<span class='warning'>[target] is struggling to withstand the acid!</span>")
				if(4)
					visible_message("<span class='warning'>[target] begins to crumble under the acid!</span>")
