/mob/living/carbon/human/gib()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	if(!ismachineperson(src))
		animation = new(loc)
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src

		playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/goonstation/effects/robogib.ogg', 50, 1)

	for(var/obj/item/organ/internal/I in internal_organs)
		if(isturf(loc))
			var/atom/movable/thing = I.remove(src)
			if(thing)
				thing.forceMove(get_turf(src))
				thing.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)

	for(var/obj/item/organ/external/E in bodyparts)
		if(istype(E, /obj/item/organ/external/chest))
			continue
		// Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			// Override the current limb status and don't cause an explosion
			E.droplimb(DROPLIMB_SHARP)

	for(var/mob/M in src)
		LAZYREMOVE(stomach_contents, M)
		M.forceMove(drop_location())
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")

	if(!ismachineperson(src))
		flick("gibbed-h", animation)
		hgibs(loc, dna)
	else
		new /obj/effect/decal/cleanable/blood/gibs/robot(loc)
		do_sparks(3, 1, src)
	QDEL_IN(animation, 15)
	QDEL_IN(src, 0)
	return TRUE

/mob/living/carbon/human/dust()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	dust_animation()
	QDEL_IN(src, 15)
	return TRUE

/mob/living/carbon/human/dust_animation()
	var/atom/movable/overlay/animation = null

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("dust-h", animation)
	new dna.species.remains_type(get_turf(src))
	QDEL_IN(animation, 15)
	return TRUE

/mob/living/carbon/human/melt()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("liquify", animation)
	QDEL_IN(src, 0)
	QDEL_IN(animation, 15)
	//new /obj/effect/decal/remains/human(loc)
	return TRUE

/mob/living/carbon/human/death(gibbed)
	if(can_die() && !gibbed && deathgasp_on_death)
		emote("deathgasp", force = TRUE) //let the world KNOW WE ARE DEAD

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	set_heartattack(FALSE)
	SSmobs.cubemonkeys -= src
	if(dna.species)
		//Handle species-specific deaths.
		dna.species.handle_death(gibbed, src)

	if(SSticker && SSticker.mode)
		SSblackbox.ReportDeath(src)

/mob/living/carbon/human/update_revive(updating)
	. = ..()
	if(. && healthdoll)
		// We're alive again, so re-build the entire healthdoll
		healthdoll.cached_healthdoll_overlays.Cut()
		update_health_hud()
	// Update healthdoll
	if(dna.species)
		dna.species.update_sight(src)

/mob/living/carbon/human/proc/makeSkeleton()
	if(HAS_TRAIT(src, TRAIT_SKELETONIZED))
		return
	var/obj/item/organ/external/head/H = get_organ("head")

	if(istype(H))
		H.disfigured = TRUE
		if(H.f_style)
			H.f_style = initial(H.f_style)
		if(H.h_style)
			H.h_style = initial(H.h_style)
		if(H.ha_style)
			H.ha_style = initial(H.ha_style)
		if(H.alt_head)
			H.alt_head = initial(H.alt_head)
			H.handle_alt_icon()
	m_styles = DEFAULT_MARKING_STYLES
	update_fhair()
	update_hair()
	update_head_accessory()
	update_markings()

	ADD_TRAIT(src, TRAIT_SKELETONIZED, "skeletonization")
	ADD_TRAIT(src, TRAIT_BADDNA, "skeletonization")
	update_body()
	update_mutantrace()

/mob/living/carbon/human/proc/become_husk(source)
	if(!HAS_TRAIT(src, TRAIT_HUSK))
		ADD_TRAIT(src, TRAIT_HUSK, source)
		var/obj/item/organ/external/head/H = bodyparts_by_name["head"]
		if(istype(H))
			H.disfigured = TRUE //makes them unknown without fucking up other stuff like admintools
			if(H.f_style)
				H.f_style = "Shaved" //we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
			if(H.h_style)
				H.h_style = "Bald"
		update_fhair()
		update_hair()
		update_body()
		update_mutantrace()
	else
		ADD_TRAIT(src, TRAIT_HUSK, source)

/mob/living/carbon/human/proc/Drain()
	become_husk(CHANGELING_DRAIN)
	ADD_TRAIT(src, TRAIT_BADDNA, CHANGELING_DRAIN)
	blood_volume = 0

/mob/living/carbon/human/proc/cure_husk(source)
	REMOVE_TRAIT(src, TRAIT_HUSK, source)
	if(!HAS_TRAIT(src, TRAIT_HUSK))
		var/obj/item/organ/external/head/H = bodyparts_by_name["head"]
		if(istype(H))
			H.disfigured = FALSE
		update_body()
		update_mutantrace()
		UpdateAppearance() // reset hair from DNA
