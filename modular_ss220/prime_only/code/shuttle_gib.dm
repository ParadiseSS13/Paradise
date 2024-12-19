#define SHUTTLE_ROADKILL_TELEPORTATION_RANGE 24

/obj/docking_port/mobile/roadkill(list/L0, list/L1, dir)
	for(var/i in 1 to length(L0))
		var/turf/T0 = L0[i]
		var/turf/T1 = L1[i]
		if(!T0 || !T1)
			continue

		for(var/atom/movable/AM in T1)
			if(AM.pulledby)
				AM.pulledby.stop_pulling()
			if(AM.flags_2 & IMMUNE_TO_SHUTTLECRUSH_2)
				if(istype(AM, /obj/machinery/atmospherics/supermatter_crystal))
					var/obj/machinery/atmospherics/supermatter_crystal/bakoom = AM
					addtimer(CALLBACK(bakoom, TYPE_PROC_REF(/obj/machinery/atmospherics/supermatter_crystal, explode), bakoom.combined_gas, bakoom.power, bakoom.gasmix_power_ratio), 1 SECONDS)
				continue
			// Your mech will not save you.
			if(ismecha(AM))
				var/obj/mecha/mech = AM
				if(mech.occupant)
					INVOKE_ASYNC(mech, TYPE_PROC_REF(/obj/mecha, get_out_and_die))
					continue // It's required to avoid qdeling of mech in case of space turf. Non space turf are handled by get_out_and_die() proc
			if(ismob(AM))
				var/mob/M = AM
				if(M.buckled)
					M.buckled.unbuckle_mob(M, force = TRUE)
				if(isliving(AM))
					if(roadkill_living(AM))
						continue
			else if(lance_docking) //corrupt the child, destroy them all
				if(!AM.simulated)
					continue
				if(istype(AM, /mob/dead))
					continue
				if(istype(AM, /obj/item/organ))
					continue
				if(istype(AM, /obj/effect/landmark))
					continue
				if(istype(AM, /obj/docking_port))
					continue
				qdel(AM, force = TRUE)

			// Move unanchored atoms
			if(!AM.anchored && !ismob(AM))
				step(AM, dir)
			else
				if(AM.simulated) // Don't qdel lighting overlays, they are static
					qdel(AM)

/obj/docking_port/mobile/proc/roadkill_living(mob/living/target)
	if(target.incorporeal_move || target.status_flags & GODMODE)
		return TRUE	// Calls 'continue'
	target.stop_pulling()
	if(isspaceturf(get_turf(target)))
		target.visible_message(
			span_warning("[target] иcчезает в спышке блюспейс излучения в тот момент, когда шаттл материализуется в нашем пространстве!"),
			span_userdanger("Вы чувствуете, будто вас сейчас стошнит. Блюспейс прыжок шаттла телепортировал вас в другое место!")
		)
		do_teleport(target, get_turf(target), SHUTTLE_ROADKILL_TELEPORTATION_RANGE, sound_in = 'sound/effects/phasein.ogg')
		return TRUE // Calls 'continue' to avoid qdeling of mob
	else
		target.visible_message(
			span_warning("Тело [target] разрывается на куски от приземлившегося шаттла!"),
			span_userdanger("Вы чувствуете, как ваше тело раздавило огромным весом прилетевшего шаттла!")
		)
		target.gib()

/obj/mecha/get_out_and_die()
	var/mob/living/pilot = occupant
	if(isspaceturf(get_turf(src)))
		pilot.visible_message(
			span_warning("[src] иcчезает в спышке блюспейс излучения в тот момент, когда шаттл материализуется в нашем пространстве!"),
			span_userdanger("Вы чувствуете, будто вас сейчас стошнит. Блюспейс прыжок шаттла телепортировал вас в другое место!")
		)
		do_teleport(src, get_turf(src), SHUTTLE_ROADKILL_TELEPORTATION_RANGE, sound_in = 'sound/effects/phasein.ogg')
	else
		pilot.visible_message(
			span_warning("Тело [pilot] разрывается на куски от приземлившегося шаттла!"),
			span_userdanger("Вы чувствуете, как ваше тело раздавило огромным весом прилетевшего шаттла!")
		)
		go_out(TRUE)
		if(iscarbon(pilot))
			pilot.gib()
		qdel(src)

#undef SHUTTLE_ROADKILL_TELEPORTATION_RANGE
