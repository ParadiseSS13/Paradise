/obj/effect/decal/cleanable
	var/list/random_icon_states = list()
	var/bloodiness = 0 //0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints
	var/mergeable_decal = TRUE //when two of these are on a same tile or do we need to merge them into just one?
	plane = FLOOR_PLANE //prevents Ambient Occlusion effects around it ; Set to GAME_PLANE in Initialize() if on a wall
	var/gravity_check = TRUE //for blood n vomit in zero G

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
/obj/effect/decal/cleanable/blood/Crossed(atom/movable/O)
	..()
	if(!off_floor && ishuman(O))
		var/mob/living/carbon/human/H = O
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
			if(blood_DNA && blood_DNA.len)
				S.add_blood(H.blood_DNA, basecolor)
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
	if(loc && isturf(loc))
		for(var/obj/effect/decal/cleanable/C in loc)
			if(C != src && C.type == type && !QDELETED(C))
				if(replace_decal(C))
					qdel(src)
					return TRUE
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
	return ..()
