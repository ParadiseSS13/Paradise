/obj/machinery/abductor/pad
	name = "Alien Telepad"
	desc = "Use this to transport to and from the nearby space station."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	anchored = TRUE
	var/turf/teleport_target

/obj/machinery/abductor/pad/proc/Warp(mob/living/target)
	if(target.buckled || target.has_status_effect(STATUS_EFFECT_ABDUCTOR_COOLDOWN))
		return FALSE
	target.forceMove(get_turf(src))
	target.apply_status_effect(STATUS_EFFECT_ABDUCTOR_COOLDOWN)
	return TRUE

/obj/machinery/abductor/pad/proc/Send()
	if(teleport_target == null)
		teleport_target = SSmapping.teleportlocs[pick(SSmapping.teleportlocs)]
	flick("alien-pad", src)
	for(var/mob/living/target in loc)
		target.forceMove(teleport_target)
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
		to_chat(target, "<span class='warning'>The instability of the warp leaves you disoriented!</span>")
		target.Stun(6 SECONDS)

/obj/machinery/abductor/pad/proc/Retrieve(mob/living/target)
	flick("alien-pad", src)
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
	return Warp(target)

/obj/machinery/abductor/pad/proc/MobToLoc(place,mob/living/target)
	new/obj/effect/temp_visual/teleport_abductor(place)
	sleep(80)
	flick("alien-pad", src)
	target.forceMove(place)
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
	target.apply_status_effect(STATUS_EFFECT_ABDUCTOR_COOLDOWN)

/obj/machinery/abductor/pad/proc/PadToLoc(place)
	new/obj/effect/temp_visual/teleport_abductor(place)
	sleep(80)
	flick("alien-pad", src)
	for(var/mob/living/target in src.loc)
		target.forceMove(place)
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
		target.apply_status_effect(STATUS_EFFECT_ABDUCTOR_COOLDOWN)

/obj/effect/temp_visual/teleport_abductor
	name = "Huh"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "teleport"
	duration = 80

/obj/effect/temp_visual/teleport_abductor/Initialize(mapload)
	. = ..()
	do_sparks(10, 0, loc)
