// 5 seconds
#define TRACKS_CRUSTIFY_TIME   50
#define ALWAYS_IN_GRAVITY 2

// color-dir-dry
GLOBAL_LIST_EMPTY(fluidtrack_cache)

// Footprints, tire trails...
/obj/effect/decal/cleanable/blood/tracks
	icon = 'icons/effects/fluidtracks.dmi'
	name = "wet tracks"
	dryname = "dried tracks"
	desc = "Whoops..."
	drydesc = "Whoops..."
	icon_state = "wheels1"
	random_icon_states = null
	amount = 0
	gravity_check = ALWAYS_IN_GRAVITY

/// Subtype of tracks used for decorating maps.
/obj/effect/decal/cleanable/blood/tracks/mapped
	desc = "Your instincts say you shouldn't be following these."
	drydesc = "Your instincts say you shouldn't be following these."
	icon = 'icons/effects/blood.dmi'
	icon_state = "tracks"

//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	icon = 'icons/effects/fluidtracks.dmi'
	icon_state = null
	desc = "You REALLY shouldn't follow these.."
	random_icon_states = null
	var/entered_dirs = 0
	var/exited_dirs = 0
	var/base_alpha = BLOODY_FOOTPRINT_BASE_ALPHA
	gravity_check = ALWAYS_IN_GRAVITY

/obj/effect/decal/cleanable/blood/footprints/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_atom_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/cleanable/blood/footprints/on_atom_entered(datum/source, mob/living/carbon/human/H, ...)
	if(!istype(H))
		return

	var/obj/item/clothing/shoes/S = H.shoes
	var/obj/item/organ/external/l_foot = H.get_organ("l_foot")
	var/obj/item/organ/external/r_foot = H.get_organ("r_foot")
	var/hasfeet = TRUE
	if(!l_foot && !r_foot)
		hasfeet = FALSE
	if(S && S.bloody_shoes[blood_state] && S.blood_color == basecolor)
		S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
		S.bloody_shoes[BLOOD_BASE_ALPHA] = base_alpha
		if(!S.blood_DNA)
			S.blood_DNA = list()
		S.blood_DNA |= blood_DNA.Copy()
		if(!(entered_dirs & H.dir))
			entered_dirs |= H.dir
			update_icon()
	else if(hasfeet && H.bloody_feet[blood_state] && H.feet_blood_color == basecolor)//Or feet //This will need to be changed.
		H.bloody_feet[blood_state] = max(H.bloody_feet[blood_state] - BLOOD_LOSS_PER_STEP, 0)
		H.bloody_feet[BLOOD_BASE_ALPHA] = base_alpha
		if(!H.feet_blood_DNA)
			H.feet_blood_DNA = list()
		H.feet_blood_DNA |= blood_DNA.Copy()
		if(!(entered_dirs & H.dir))
			entered_dirs |= H.dir
			update_icon()

// TODO: I think this is a 1:1 copy-paste of on_atom_entered above
/obj/effect/decal/cleanable/blood/footprints/proc/on_atom_exited(datum/source, mob/living/carbon/human/H, ...)
	if(!istype(H))
		return

	var/obj/item/clothing/shoes/S = H.shoes
	var/obj/item/organ/external/l_foot = H.get_organ("l_foot")
	var/obj/item/organ/external/r_foot = H.get_organ("r_foot")
	var/hasfeet = TRUE
	if(!l_foot && !r_foot)
		hasfeet = FALSE
	if(S && S.bloody_shoes[blood_state] && S.blood_color == basecolor)
		S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
		if(!S.blood_DNA)
			S.blood_DNA = list()
		S.blood_DNA |= blood_DNA.Copy()
		if(!(exited_dirs & H.dir))
			exited_dirs |= H.dir
			update_icon()
	else if(hasfeet && H.bloody_feet[blood_state] && H.feet_blood_color == basecolor)//Or feet
		H.bloody_feet[blood_state] = max(H.bloody_feet[blood_state] - BLOOD_LOSS_PER_STEP, 0)
		if(!H.feet_blood_DNA)
			H.feet_blood_DNA = list()
		H.feet_blood_DNA |= blood_DNA.Copy()
		if(!(exited_dirs & H.dir))
			exited_dirs |= H.dir
			update_icon()


/obj/effect/decal/cleanable/blood/footprints/update_overlays()
	. = ..()

	for(var/Ddir in GLOB.cardinal)
		if(entered_dirs & Ddir)
			var/image/I
			if(GLOB.fluidtrack_cache["entered-[blood_state]-[Ddir]"])
				I = GLOB.fluidtrack_cache["entered-[blood_state]-[Ddir]"]
			else
				I = image(icon,"[blood_state]1",dir = Ddir)
				GLOB.fluidtrack_cache["entered-[blood_state]-[Ddir]"] = I
			if(I)
				I.color = basecolor
				. += I
		if(exited_dirs & Ddir)
			var/image/I
			if(GLOB.fluidtrack_cache["exited-[blood_state]-[Ddir]"])
				I = GLOB.fluidtrack_cache["exited-[blood_state]-[Ddir]"]
			else
				I = image(icon,"[blood_state]2",dir = Ddir)
				GLOB.fluidtrack_cache["exited-[blood_state]-[Ddir]"] = I
			if(I)
				I.color = basecolor
				. += I

	alpha = base_alpha + bloodiness

/obj/effect/decal/cleanable/blood/footprints/should_be_off_floor()
	return FALSE

/proc/createFootprintsFrom(atom/movable/A, dir, turf/T)
	var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		FP.blood_state = H.blood_state
		FP.bloodiness = H.bloody_feet[H.blood_state] - BLOOD_LOSS_IN_SPREAD
		FP.basecolor = H.feet_blood_color
		FP.base_alpha = H.bloody_feet[BLOOD_BASE_ALPHA]
		if(H.blood_DNA)
			FP.blood_DNA = H.blood_DNA.Copy()
	else if(istype(A, /obj/item/clothing/shoes))
		var/obj/item/clothing/shoes/S = A
		FP.blood_state = S.blood_state
		FP.bloodiness = S.bloody_shoes[S.blood_state] - BLOOD_LOSS_IN_SPREAD
		FP.basecolor = S.blood_color
		FP.base_alpha = S.bloody_shoes[BLOOD_BASE_ALPHA]
		if(S.blood_DNA)
			FP.blood_DNA = S.blood_DNA.Copy()
	FP.entered_dirs |= dir
	FP.update_icon()

	return FP

/obj/effect/decal/cleanable/blood/footprints/replace_decal(obj/effect/decal/cleanable/blood/footprints/C)
	if(blood_state != C.blood_state) //We only replace footprints of the same type as us
		return
	..()

/obj/effect/decal/cleanable/blood/footprints/can_bloodcrawl_in()
	if(basecolor == COLOR_BLOOD_MACHINE)
		return FALSE
	return TRUE

#undef ALWAYS_IN_GRAVITY

#undef TRACKS_CRUSTIFY_TIME
