#define TOWEL_WATER_ABSORBED (1 << 0)
#define TOWEL_WATER_SPREAD (1 << 1)
#define TOWEL_GRIME_ABSORBED (1 << 2)
#define TOWEL_GRIME_SPREAD (1 << 3)
#define TOWEL_CLEANED_TARGET (1 << 4)

/obj/item/clothing/neck/towel
	name = "plain towel"
	desc = "Larger than a rag, smaller than a beach towel."
	icon_state = "towel"
	inhand_icon_state = "towel"
	/// Tracks how wet the towel is. Wet towels dampen their targets instead of drying them.
	var/wetlevel = 0
	/// Tracks how much yuck the towel has on it. Grime levels higher than 1 can be spread.
	var/grimelevel = 0
	/// A list of stuff we can towel off.
	var/list/obj/effect/decal/cleanable/grime_sources = list(
		/obj/effect/decal/cleanable/blood/drip,
		/obj/effect/decal/cleanable/blood/tracks,
		/obj/effect/decal/cleanable/blood/splatter,
		/obj/effect/decal/cleanable/blood/xeno/splatter,
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/flour,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/liquid_fuel,
		/obj/effect/decal/cleanable/paint_splat,
		/obj/effect/decal/cleanable/pie_smudge,
		/obj/effect/decal/cleanable/tar,
		/obj/effect/decal/cleanable/tomato_smudge,
		/obj/effect/decal/cleanable/plant_smudge,
		/obj/effect/decal/cleanable/egg_smudge,
		/obj/effect/decal/cleanable/vomit,
	)

/// Display warnings for towel grime and wetness levels that would transfer.
/obj/item/clothing/neck/towel/examine()
	. = ..()

	switch(wetlevel)
		if(0) . += SPAN_NOTICE("It looks dry.")
		if(1 to 4) . += SPAN_NOTICE("It looks damp.")
		if(5) . += SPAN_WARN("It looks sopping wet.")

	switch(grimelevel)
		if(0) . += SPAN_NOTICE("It looks clean.")
		if(1) . += SPAN_NOTICE("It looks a bit grimy.")
		if(2 to 5) . += SPAN_WARN("It looks filthy.")

/obj/item/clothing/neck/towel/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	var/toweling_result = NONE

	if(iscarbon(target) || issimulatedturf(target))
		toweling_result |= exchange_water(target, user, modifiers)
	toweling_result |= exchange_grime(target, user, modifiers)

	var/user_message = ""
	var/target_message = ""

	if(toweling_result & TOWEL_GRIME_SPREAD)
		user_message += "You smear [src]'s grime all over [target == user ? "you" : target]."
		target_message += "[user] smears the grimy [src] all over you."
	else if(toweling_result & TOWEL_CLEANED_TARGET)
		user_message += "You wipe [target == user ? "yourself" : target] clean with [src]."
		target_message += "[user] wipes you clean with [src]."
	else if(toweling_result & TOWEL_GRIME_ABSORBED)
		user_message += "You absorb some of the grime with [src]."
		target_message += "[user] mops up some of the grime on you with [src]."
	else
		user_message += "You pat [target == user ? "yourself" : target] with [src]."
		target_message += "[user] pats you with [src]."

	if(toweling_result & TOWEL_WATER_SPREAD)
		user_message += " It dampens [target == user ? "you" : target.p_them()]."
		target_message += " It dampens you."
	else if(toweling_result & TOWEL_WATER_ABSORBED)
		user_message += " It dries [target == user ? "you" : target.p_them()]."
		target_message += " It dries you."

	update_icon()

	to_chat(user, SPAN_NOTICE(user_message))
	if(target != user && ismob(target))
		to_chat(target, SPAN_NOTICE(target_message))
	return ITEM_INTERACT_COMPLETE

/obj/item/clothing/neck/towel/proc/exchange_grime(atom/target, mob/living/user, list/modifiers)
	var/toweling_result = NONE
	// the grimiest decal will transfer to the towel. calculate this before griming up the toweling target
	var/obj/effect/decal/cleanable/grimiest_decal = null
	for(var/obj/effect/decal/cleanable/target_decal in target)
		if(!(target_decal.type in grime_sources))
			// we can't pick this up, it's glass shards or some other not-really-towelable mess
			continue
		if(!grimiest_decal || target_decal.amount > grimiest_decal.amount)
			grimiest_decal = target_decal
	var/target_grime_level = grimiest_decal ? grimiest_decal.amount : length(target.blood_DNA)

	// if the towel is grimy, add grime to the target. do this before adding more grime to the towel
	if(grimelevel > 1)
		for(var/obj/effect/decal/cleanable/towel_decal in src)
			if(towel_decal.amount < 1)
				continue
			if(istype(towel_decal, /obj/effect/decal/cleanable/blood))
				var/obj/effect/decal/cleanable/blood/towel_blood_decal = towel_decal
				target.add_blood(towel_blood_decal.blood_DNA, towel_blood_decal.basecolor)
				if(istype(target, /turf/simulated))
					var/turf/simulated/target_turf = target
					for(var/obj/effect/decal/cleanable/blood/turf_decal in target_turf)
						turf_decal.amount = 1
			else if(istype(target, /turf/simulated))
				var/obj/effect/decal/cleanable/turf_decal = new towel_decal.type(target)
				turf_decal.amount = 1
			target.germ_level += 20 * grimelevel
			towel_decal.amount -= 1
		grimelevel -= 1
		toweling_result |= TOWEL_GRIME_SPREAD

	// if the grimiest decal (above) is grimier than the towel, add it to the towel.
	if(target_grime_level > grimelevel)
		if(!grimiest_decal)
			add_blood(target.blood_DNA, target.blood_color)
		else if(istype(grimiest_decal, /obj/effect/decal/cleanable/blood))
			var/obj/effect/decal/cleanable/blood/grimiest_blood_decal = grimiest_decal
			add_blood(grimiest_blood_decal.blood_DNA, grimiest_blood_decal.basecolor)

			grimiest_blood_decal.bloodiness = 0
			grimiest_blood_decal.amount = 0
		else
			new grimiest_decal.type(src)
		toweling_result |= TOWEL_GRIME_ABSORBED

		// if the towel wasn't dirty before we started, clean the target
		if(can_clean())
			for(var/obj/effect/decal/cleanable/target_decal in target)
				qdel(target_decal)
			target.clean_blood()
			toweling_result |= TOWEL_CLEANED_TARGET
		grimelevel = min(max(grimelevel + 1, target_grime_level - 1), 5)
	return toweling_result

/obj/item/clothing/neck/towel/proc/exchange_water(atom/target, mob/living/user, list/modifiers)
	if(!iscarbon(target))
		if(issimulatedturf(target))
			var/turf/simulated/T = target
			// dry a turf that's wetter than the towel
			if(T.wet == TURF_WET_WATER && wetlevel < 5)
				T.MakeDry()
				wetlevel += 1
				return TOWEL_WATER_ABSORBED

			// wet a dry turf with a sopping wet towel
			else if(wetlevel > 4 && T.wet == NONE)
				T.MakeSlippery()
				wetlevel -= 1
				return TOWEL_WATER_SPREAD

		// it's not a mob or a turf so its wetness is irrelevant
		return NONE

	var/mob/living/carbon/toweling_target = target
	// towel sopping wet, target dryish. wet the target
	if(wetlevel > 4 && toweling_target.wetlevel < 2)
		toweling_target.wetlevel = max(toweling_target.wetlevel + 1, 1)
		wetlevel -= 1
		return TOWEL_WATER_SPREAD

	// towel drier than creature. dries target
	else if(wetlevel < toweling_target.wetlevel)
		toweling_target.wetlevel = max(toweling_target.wetlevel - 2, 0)
		wetlevel += 1
		return TOWEL_WATER_ABSORBED

	return NONE

/obj/item/clothing/neck/towel/add_blood(list/blood_dna, b_color)
	. = ..()
	var/obj/effect/decal/cleanable/blood/blood_container = new(src)
	blood_container.transfer_blood_dna(blood_dna)
	blood_container.basecolor = b_color

/obj/item/clothing/neck/towel/water_act(volume, temperature, source, method)
	. = ..()
	if(volume < 10)
		return
	wetlevel = min(wetlevel + 1, 5)
	if(temperature > VIRUS_DISINFECTION_TEMP || volume > 99)
		grimelevel = max(grimelevel - 1, 0)
		for(var/obj/effect/decal/cleanable/towel_decal in src)
			towel_decal.amount -= 1
			if(towel_decal.amount < 1)
				qdel(towel_decal)

/obj/item/clothing/neck/towel/can_clean()
	return !grimelevel

/obj/item/clothing/neck/towel/cleaning_act(mob/user, atom/cleaner, cleanspeed, text_verb, text_description, text_targetname, skip_do_after)
	if(..())
		grimelevel = 0

/obj/item/clothing/neck/towel/machine_wash(obj/machinery/washing_machine/source)
	. = ..()
	wetlevel = 0
	grimelevel = source.bloody_mess ? 5 : 0

/obj/item/clothing/neck/towel/beach
	name = "balmy beach towel"
	desc = "A fluffy towel large enough for beachgoers."
	icon_state = "towel_palm"
	inhand_icon_state = "beach_towel"
	worn_icon_state = "towel_palm"

/obj/item/clothing/neck/towel/beach/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	// place beach towel on ground
	if(issimulatedturf(target))
		var/turf/simulated/T = target
		if(!T.density)
			user.drop_item_to_ground(src)
			forceMove(T)
	return ..()

/obj/item/clothing/neck/towel/beach/Moved()
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/clothing/neck/towel/beach/update_icon_state()
	. = ..()
	icon_state = isturf(loc) ? initial(icon_state) : "[initial(icon_state)]_roll"

/obj/item/clothing/neck/towel/beach/lava_waves
	name = "lava waves beach towel"
	icon_state = "towel_lavawaves"
	worn_icon_state = "towel_lavawaves"

/obj/item/clothing/neck/towel/beach/water_waves
	name = "ocean waves beach towel"
	icon_state = "towel_waterwaves"
	worn_icon_state = "towel_waterwaves"

/obj/item/clothing/neck/towel/beach/striped_green
	name = "striped green beach towel"
	icon_state = "towel_striped_green"
	worn_icon_state = "towel_striped_green"

/obj/item/clothing/neck/towel/beach/striped_red
	name = "striped red beach towel"
	icon_state = "towel_striped_red"
	worn_icon_state = "towel_striped_red"

/obj/item/clothing/neck/towel/beach/striped_blue
	name = "striped blue beach towel"
	icon_state = "towel_striped_blue"
	worn_icon_state = "towel_striped_blue"

/obj/item/clothing/neck/towel/beach/ian
	name = "ian motif beach towel"
	icon_state = "towel_ian"
	worn_icon_state = "towel_ian"

/obj/item/clothing/neck/towel/beach/dolphin
	name = "dolphin motif beach towel"
	icon_state = "towel_dolphin"
	worn_icon_state = "towel_dolphin"

#undef TOWEL_WATER_ABSORBED
#undef TOWEL_WATER_SPREAD
#undef TOWEL_GRIME_ABSORBED
#undef TOWEL_GRIME_SPREAD
#undef TOWEL_CLEANED_TARGET
