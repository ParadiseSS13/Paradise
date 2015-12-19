/mob/living/carbon/human/gib()
	death(1)
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

		playsound(src.loc, 'sound/effects/gib.ogg', 100, 1, 10)

	for(var/obj/item/organ/I in internal_organs)
		if(istype(loc,/turf))
			I.removed()
			spawn()
				I.throw_at(get_edge_target_turf(src,pick(alldirs)),rand(1,3),5)

	for(var/obj/item/organ/external/E in src.organs)
		if(istype(E, /obj/item/organ/external/chest))
			continue
		// Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			// Override the current limb status and don't cause an explosion
			E.droplimb(DROPLIMB_EDGE)

	if(!isSynthetic())
		flick("gibbed-h", animation)
		hgibs(loc, viruses, dna)
	else
		new /obj/effect/decal/cleanable/blood/gibs/robot(src.loc)
		var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/human/dust()
	death(1)
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("dust-h", animation)
	new /obj/effect/decal/remains/human(loc)

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/human/melt()
	death(1)
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
	//new /obj/effect/decal/remains/human(loc)

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)	return
	if(healths)		healths.icon_state = "health5"

	if(!gibbed)
		emote("deathgasp") //let the world KNOW WE ARE DEAD

	stat = DEAD
	dizziness = 0
	jitteriness = 0

	//Handle species-specific deaths.
	if(species) species.handle_death(src)

	//Handle brain slugs.
	var/obj/item/organ/external/head = get_organ("head")
	var/mob/living/simple_animal/borer/B

	if(istype(head))
		for(var/I in head.implants)
			if(istype(I,/mob/living/simple_animal/borer))
				B = I
	if(B)
		if(!B.ckey && ckey && B.controlling)
			B.ckey = ckey
			B.controlling = 0
		if(B.host_brain.ckey)
			ckey = B.host_brain.ckey
			B.host_brain.ckey = null
			B.host_brain.name = "host brain"
			B.host_brain.real_name = "host brain"

		verbs -= /mob/living/carbon/proc/release_control

	callHook("death", list(src, gibbed))

	if(ticker && ticker.mode)
		if(istype(ticker.mode,/datum/game_mode/heist))
			vox_kills++ //Bad vox. Shouldn't be killing humans.

	if(ishuman(LAssailant))
		var/mob/living/carbon/human/H=LAssailant
		if(H.mind)
			H.mind.kills += "[name] ([ckey])"

	if(!gibbed)
		update_canmove()
		if(client) blind.layer = 0

	timeofdeath = worldtime2text()
	med_hud_set_health()
	med_hud_set_status()
	if(mind)	mind.store_memory("Time of death: [timeofdeath]", 0)
	if(ticker && ticker.mode)
//		log_to_dd("k")
		sql_report_death(src)
		ticker.mode.check_win()		//Calls the rounds wincheck, mainly for wizard, malf, and changeling now

	if(wearing_rig)
		wearing_rig.notify_ai("<span class='danger'>Warning: user death event. Mobility control passed to integrated intelligence system.</span>")

	return ..(gibbed)

/mob/living/carbon/human/proc/makeSkeleton()
	if(SKELETON in src.mutations)	return

	if(f_style)
		f_style = "Shaved"
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(SKELETON)
	mutations.Add(NOCLONE)
	status_flags |= DISFIGURED
	update_body(0)
	update_mutantrace()
	return

/mob/living/carbon/human/proc/ChangeToHusk()
	if(HUSK in mutations)	return

	if(f_style)
		f_style = "Shaved"		//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(HUSK)
	status_flags |= DISFIGURED	//makes them unknown without fucking up other stuff like admintools
	update_body(0)
	update_mutantrace()
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= NOCLONE
	return
