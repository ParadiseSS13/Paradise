#define ALWAYS_IN_GRAVITY 2

/obj/effect/decal/cleanable
	///when Initialized() its icon_state will be chosen from this list
	var/list/random_icon_states = list()
	///0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints
	var/bloodiness = 0
	///when another of the same type is made on the same tile will they merge --- YES=TRUE; NO=FLASE
	var/mergeable_decal = TRUE
	///prevents Ambient Occlusion effects around it ; Set to GAME_PLANE in Initialize() if on a wall
	///for blood n vomit in zero G --- IN GRAVITY=TRUE; NO GRAVITY=FALSE
	var/gravity_check = TRUE
	hud_possible = list(JANI_HUD)

/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/C) // Returns true if we should give up in favor of the pre-existing decal
	if(mergeable_decal)
		return TRUE

/obj/effect/decal/cleanable/cleaning_act(mob/user, atom/cleaner, cleanspeed = 5 SECONDS, text_verb = "scrub out", text_description = " with [cleaner].")
	if(issimulatedturf(loc))
		var/turf/simulated/T = get_turf(src)
		T.cleaning_act(user, cleaner, cleanspeed = cleanspeed, text_verb = text_verb, text_description = text_description, text_targetname = name) //Strings are deliberately "A = A" to avoid overrides
		return
	else
		..()

//Add "bloodiness" of this blood's type, to the human's shoes
//This is on /cleanable because fuck this ancient mess
/obj/effect/decal/cleanable/blood/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(!ishuman(entered))
		return

	if(!gravity_check && ishuman(entered))
		bloodyify_human(entered)

	if(!off_floor)
		var/mob/living/carbon/human/H = entered
		var/obj/item/organ/external/l_foot = H.get_organ("l_foot")
		var/obj/item/organ/external/r_foot = H.get_organ("r_foot")
		var/hasfeet = TRUE
		if(IS_HORIZONTAL(H) && !H.buckled) //Make people bloody if they're lying down and move into blood
			if(bloodiness > 0 && length(blood_DNA))
				H.add_blood(H.blood_DNA, basecolor)
		if(!l_foot && !r_foot)
			hasfeet = FALSE
		if(H.shoes && blood_state && bloodiness)
			var/obj/item/clothing/shoes/S = H.shoes
			var/add_blood = 0
			if(bloodiness >= BLOOD_GAIN_PER_STEP)
				add_blood = BLOOD_GAIN_PER_STEP
			else
				add_blood = bloodiness
			bloodiness -= add_blood
			S.bloody_shoes[blood_state] = min(MAX_SHOE_BLOODINESS, S.bloody_shoes[blood_state] + add_blood)
			S.bloody_shoes[BLOOD_BASE_ALPHA] = BLOODY_FOOTPRINT_BASE_ALPHA * (alpha/255)
			if(length(blood_DNA))
				S.add_blood(blood_DNA, basecolor)
			S.blood_state = blood_state
			S.blood_color = basecolor
			update_icon()
			H.update_inv_shoes()
		else if(hasfeet && blood_state && bloodiness)//Or feet
			var/add_blood = 0
			if(bloodiness >= BLOOD_GAIN_PER_STEP)
				add_blood = BLOOD_GAIN_PER_STEP
			else
				add_blood = bloodiness
			bloodiness -= add_blood
			H.bloody_feet[blood_state] = min(MAX_SHOE_BLOODINESS, H.bloody_feet[blood_state] + add_blood)
			H.bloody_feet[BLOOD_BASE_ALPHA] = BLOODY_FOOTPRINT_BASE_ALPHA * (alpha/255)
			if(!H.feet_blood_DNA)
				H.feet_blood_DNA = list()
			H.blood_state = blood_state
			H.feet_blood_DNA |= blood_DNA.Copy()
			H.feet_blood_color = basecolor
			update_icon()
			H.update_inv_shoes()

/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/is_cleanable()
	return TRUE

/obj/effect/decal/cleanable/Initialize(mapload)
	. = ..()
	prepare_huds()
	if(should_merge_decal(loc))
		return INITIALIZE_HINT_QDEL
	var/datum/atom_hud/data/janitor/jani_hud = GLOB.huds[DATA_HUD_JANITOR]
	jani_hud.add_to_hud(src)
	jani_hud_set_sign()
	if(random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	if(smoothing_flags)
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)
	if(iswallturf(loc) && plane == FLOOR_PLANE)
		plane = GAME_PLANE // so they can be seen above walls

/obj/effect/decal/cleanable/Destroy()
	if(smoothing_flags)
		QUEUE_SMOOTH_NEIGHBORS(src)
	var/datum/atom_hud/data/janitor/jani_hud = GLOB.huds[DATA_HUD_JANITOR]
	jani_hud.remove_from_hud(src)
	return ..()

/obj/effect/decal/cleanable/proc/should_merge_decal(turf/T)
	if(!T)
		T = loc
	if(isturf(T))
		for(var/obj/effect/decal/cleanable/C in T)
			if(C != src && C.type == type && !QDELETED(C))
				if(C.gravity_check && replace_decal(C))
					return TRUE
	return FALSE

/obj/effect/decal/cleanable/proc/check_gravity(turf/T)
	if(isnull(T))
		T = get_turf(src)
	if(gravity_check != ALWAYS_IN_GRAVITY)
		gravity_check = has_gravity(src, T)

#undef ALWAYS_IN_GRAVITY
