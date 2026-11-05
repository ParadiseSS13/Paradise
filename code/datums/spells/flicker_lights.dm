/datum/spell/aoe/flicker_lights
	name = "Flicker Lights"
	desc = "You will trigger a large amount of lights around you to flicker."

	base_cooldown = 300
	clothes_req = FALSE
	aoe_range = 14
	/// Is this ability granted from a xenobiology organ? Causes user to spark.
	var/from_organ = FALSE

/datum/spell/aoe/flicker_lights/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/targeting = new()
	targeting.range = aoe_range
	return targeting

/datum/spell/aoe/flicker_lights/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/obj/machinery/light/L in T)
			L.forced_flicker()
	if(from_organ)
		do_sparks(3, FALSE, user)
