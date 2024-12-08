/datum/hallucination_manager/stealing_traitor
	trigger_time = 0.5 SECONDS
	initial_hallucination = /obj/effect/hallucination/no_delete/stealing_traitor
	/// The target high risk item
	var/obj/item/target

/datum/hallucination_manager/stealing_traitor/spawn_hallucination()
	for(var/obj/item/risky_thing as anything in GLOB.high_risk_items)
		if(get_dist(owner, risky_thing) <= 5)
			if(ishuman(risky_thing.loc) && risky_thing.loc == owner)
				target = risky_thing
				break
			else if(isturf(risky_thing.loc))
				target = risky_thing
				break

	if(!target)
		qdel(src)
		return
	return ..()

/datum/hallucination_manager/stealing_traitor/get_spawn_location()
	var/list/turfs = list()
	for(var/turf/possibility as anything in RANGE_TURFS(1, target))
		if(is_blocked_turf(possibility))
			continue
		turfs |= possibility
	if(!length(turfs))
		return pick(RANGE_TURFS(1, target)) // Might spawn on a wall, but that's that
	return pick(turfs)

/datum/hallucination_manager/stealing_traitor/on_spawn()
	var/turf/spawn_turf = get_turf(initial_hallucination)
	initial_hallucination.dir = get_dir(initial_hallucination, owner)
	new/obj/effect/temp_visual/teleport_abductor/syndi_teleporter(spawn_turf)
	playsound(spawn_turf, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/datum/hallucination_manager/stealing_traitor/on_trigger()
	if(ishuman(target.loc) && target.loc == owner)
		owner.Weaken(5 SECONDS)
		var/image/override_image = image(target.icon, target, target.icon_state)
		override_image.override = TRUE
		images += override_image
		owner.client.images += override_image


/obj/effect/hallucination/no_delete/stealing_traitor
	hallucination_icon = 'icons/mob/simple_human.dmi'
	hallucination_icon_state = "syndicate_stormtrooper"
