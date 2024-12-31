/datum/hallucination_manager/stealing_traitor
	trigger_time = 1 SECONDS
	initial_hallucination = /obj/effect/hallucination/no_delete/stealing_traitor
	severity = HALLUCINATE_MAJOR
	/// The target high risk item
	var/obj/item/target
	/// Override image on our risk item
	var/image/override_image

/datum/hallucination_manager/stealing_traitor/Destroy(force, ...)
	owner.client?.images -= override_image
	return ..()

/datum/hallucination_manager/stealing_traitor/spawn_hallucination()
	for(var/id in shuffle(GLOB.high_risk_items))
		var/obj/item/risky_thing = locateUID(id)
		if(!istype(risky_thing))
			continue
		if(get_dist(owner, risky_thing) > 5)
			continue

		if(ishuman(risky_thing.loc) && risky_thing.loc == owner)
			target = risky_thing
			break
		else if(isturf(risky_thing.loc))
			target = risky_thing
			break

	if(!target)
		reroll_ourself()
		qdel(src)
		return
	return ..()

/datum/hallucination_manager/stealing_traitor/get_spawn_location()
	var/list/turfs = list()
	for(var/turf/possibility as anything in view(1, target))
		if(is_blocked_turf(possibility))
			continue
		turfs |= possibility
	if(!length(turfs))
		var/turf/target_turf = get_turf(target)
		return pick(RANGE_TURFS(1, target_turf)) // Might spawn on a wall, but that's that
	return pick(turfs)

/datum/hallucination_manager/stealing_traitor/on_spawn()
	var/turf/spawn_turf = get_turf(initial_hallucination)
	initial_hallucination.dir = get_dir(initial_hallucination, owner)
	new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(spawn_turf)
	playsound(spawn_turf, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/datum/hallucination_manager/stealing_traitor/on_trigger()
	if(ishuman(target.loc) && target.loc == owner)
		owner.unEquip(target)
		owner.Weaken(5 SECONDS)
		owner.Jitter(5 SECONDS)
		owner.AdjustStuttering(10 SECONDS)
		owner.playsound_local(get_turf(owner), 'sound/weapons/contractorbatonhit.ogg', 75, TRUE, -1)
	hide_item()
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(on_second_trigger)), 2 SECONDS, TIMER_DELETE_ME)

/datum/hallucination_manager/stealing_traitor/proc/hide_item()
	override_image = image(loc = target)
	override_image.override = TRUE
	images += override_image
	owner.client.images += override_image

/datum/hallucination_manager/stealing_traitor/proc/on_second_trigger()
	playsound(get_turf(initial_hallucination), "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	qdel(initial_hallucination)
	QDEL_IN(src, 10 SECONDS) // This is when the image override is actually removed

/obj/effect/hallucination/no_delete/stealing_traitor
	hallucination_icon = 'icons/mob/simple_human.dmi'
	hallucination_icon_state = "syndicate_stormtrooper"
	layer = MOB_LAYER
