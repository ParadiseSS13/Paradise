/obj/effect/decal/cleanable
	anchored = TRUE
	var/list/random_icon_states = list()
	var/bloodiness = 0 //0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints
	var/mergeable_decal = TRUE //when two of these are on a same tile or do we need to merge them into just one?

/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/C) // Returns true if we should give up in favor of the pre-existing decal
	if(mergeable_decal)
		return TRUE

//Add "bloodiness" of this blood's type, to the human's shoes
//This is on /cleanable because fuck this ancient mess
/obj/effect/decal/cleanable/blood/Crossed(atom/movable/O)
	..()
	if(!off_floor && ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/organ/external/l_foot = H.get_organ("l_foot")
		var/obj/item/organ/external/r_foot = H.get_organ("r_foot")
		var/hasfeet = TRUE
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
			if(!H.feet_blood_DNA)
				H.feet_blood_DNA = list()
			H.blood_state = blood_state
			H.feet_blood_DNA |= blood_DNA.Copy()
			H.feet_blood_color = basecolor
			update_icon()
			H.update_inv_shoes()

/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	return FALSE

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
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)

/obj/effect/decal/cleanable/Destroy()
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()
