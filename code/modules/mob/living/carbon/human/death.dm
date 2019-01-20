/mob/living/carbon/human/gib()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	if(!isSynthetic())
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
				thing.throw_at(get_edge_target_turf(src, pick(alldirs)), rand(1,3), 5)

	for(var/obj/item/organ/external/E in bodyparts)
		if(istype(E, /obj/item/organ/external/chest))
			continue
		// Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			// Override the current limb status and don't cause an explosion
			E.droplimb(DROPLIMB_SHARP)

	for(var/mob/M in src)
		if(M in stomach_contents)
			stomach_contents.Remove(M)
		M.forceMove(get_turf(src))
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")

	if(!isSynthetic())
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
		emote("deathgasp") //let the world KNOW WE ARE DEAD

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	set_heartattack(FALSE)

	if(dna.species)
		dna.species.handle_hud_icons(src)
		//Handle species-specific deaths.
		dna.species.handle_death(src)

	if(ishuman(LAssailant))
		var/mob/living/carbon/human/H=LAssailant
		if(H.mind)
			H.mind.kills += "[key_name(src)]"

	if(ticker && ticker.mode)
//		log_world("k")
		sql_report_death(src)

	if(wearing_rig)
		wearing_rig.notify_ai("<span class='danger'>Warning: user death event. Mobility control passed to integrated intelligence system.</span>")

/mob/living/carbon/human/update_revive()
	. = ..()
	if(. && healthdoll)
		// We're alive again, so re-build the entire healthdoll
		healthdoll.cached_healthdoll_overlays.Cut()
	// Update healthdoll
	if(dna.species)
		dna.species.update_sight(src)
		dna.species.handle_hud_icons(src)

/mob/living/carbon/human/proc/makeSkeleton()
	var/obj/item/organ/external/head/H = get_organ("head")
	if(SKELETON in src.mutations)
		return

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
	update_fhair(0)
	update_hair(0)
	update_head_accessory(0)
	update_markings(0)

	mutations.Add(SKELETON)
	mutations.Add(NOCLONE)
	update_body(0)
	update_mutantrace()
	return

/mob/living/carbon/human/proc/ChangeToHusk()
	var/obj/item/organ/external/head/H = bodyparts_by_name["head"]
	if(HUSK in mutations)
		return

	if(istype(H))
		H.disfigured = TRUE //makes them unknown without fucking up other stuff like admintools
		if(H.f_style)
			H.f_style = "Shaved"		//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
		if(H.h_style)
			H.h_style = "Bald"
	update_fhair(0)
	update_hair(0)

	mutations.Add(HUSK)
	update_body(0)
	update_mutantrace()
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= NOCLONE
	return

/mob/living/carbon/human/proc/cure_husk()
	mutations.Remove(HUSK)
	var/obj/item/organ/external/head/H = bodyparts_by_name["head"]
	if(istype(H))
		H.disfigured = FALSE
	update_body(0)
	update_mutantrace(0)
	UpdateAppearance() // reset hair from DNA
