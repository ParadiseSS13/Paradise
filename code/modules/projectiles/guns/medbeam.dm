/obj/item/gun/medbeam
	name = "Medical Beamgun"
	desc = "Delivers volatile medical nanites in a focused beam. Don't cross the beams!"
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
	w_class = WEIGHT_CLASS_NORMAL

	var/mob/living/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 8
	var/active = FALSE
	var/beam_UID = null

	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/medbeam/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/gun/medbeam/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/medbeam/handle_suicide()
	return

/obj/item/gun/medbeam/dropped(mob/user)
	..()
	LoseTarget()

/obj/item/gun/medbeam/equipped(mob/user, slot, initial)
	..()
	LoseTarget()

/obj/item/gun/medbeam/proc/LoseTarget()
	if(active)
		qdel(locateUID(beam_UID))
		beam_UID = null
		active = FALSE
		on_beam_release(current_target)
	current_target = null

/obj/item/gun/medbeam/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	add_fingerprint(user)

	if(current_target)
		LoseTarget()
	if(!isliving(target))
		return

	current_target = target
	active = TRUE
	var/datum/beam/current_beam = new(user,current_target,time=6000,beam_icon_state="medbeam",btype=/obj/effect/ebeam/medical)
	beam_UID = current_beam.UID()
	INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)

/obj/item/gun/medbeam/process()
	var/source = loc
	if(!ishuman(source) && !isrobot(source))
		LoseTarget()
		return

	if(!current_target)
		LoseTarget()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(get_dist(source,current_target)>max_range || !los_check(source,current_target))
		LoseTarget()
		to_chat(source, "<span class='warning'>You lose control of the beam!</span>")
		return

	if(current_target)
		on_beam_tick(current_target)

/obj/item/gun/medbeam/proc/los_check(mob/user,mob/target)
	var/turf/user_turf = user.loc
	var/datum/beam/current_beam = locateUID(beam_UID)
	if(!istype(user_turf))
		return FALSE
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE | PASSGLASS | PASSGRILLE | PASSFENCE //Grille/Glass so it can be used through common windows
	for(var/turf/turf in getline(user_turf,target))
		if(turf.density)
			qdel(dummy)
			return FALSE
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return FALSE
		for(var/obj/effect/ebeam/medical/B in turf)// Don't cross the str-beams!
			if(B.owner != current_beam)
				turf.visible_message("<span class='userdanger'>The medbeams cross and EXPLODE!</span>")
				explosion(B.loc,0,3,5,8)
				qdel(dummy)
				return FALSE
	qdel(dummy)
	return TRUE

/obj/item/gun/medbeam/proc/on_beam_hit(mob/living/target)
	return

/obj/item/gun/medbeam/proc/on_beam_tick(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustBruteLoss(-4, robotic = TRUE)
		H.adjustFireLoss(-4, robotic = TRUE)
		for(var/obj/item/organ/external/E in H.bodyparts)
			if(prob(10))
				E.mend_fracture()
	else
		target.adjustBruteLoss(-4)
		target.adjustFireLoss(-4)

/obj/item/gun/medbeam/proc/on_beam_release(mob/living/target)
	return

/obj/effect/ebeam/medical
	name = "medical beam"
