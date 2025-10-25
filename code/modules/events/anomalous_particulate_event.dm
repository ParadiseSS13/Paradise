/datum/event/anomalous_particulate_event

/datum/event/anomalous_particulate_event/start()
	var/particulate_to_activate = 2
	if(GLOB.anomaly_smash_track.smashes)
		for(var/obj/effect/anomalous_particulate/particulate_chosen in GLOB.anomaly_smash_track.smashes)
			if(particulate_to_activate)
				if(particulate_chosen.being_drained)
					continue
				new /obj/effect/visible_anomalous_particulate(particulate_chosen.drop_location())
				GLOB.anomaly_smash_track.num_drained++
				qdel(particulate_chosen)
				particulate_to_activate--
				continue
			break
	var/location_sanity = 0
	while(particulate_to_activate && location_sanity < 100)
		var/turf/chosen_location = get_safe_random_station_turf_equal_weight()

		// We don't want them close to each other - at least 1 tile of separation
		var/list/nearby_things = range(1, chosen_location)
		var/obj/effect/anomalous_particulate/what_if_i_have_one = locate() in nearby_things
		var/obj/effect/visible_anomalous_particulate/what_if_i_had_one_but_its_used = locate() in nearby_things
		if(what_if_i_have_one || what_if_i_had_one_but_its_used)
			location_sanity++
			continue

		new /obj/effect/visible_anomalous_particulate(chosen_location)
		particulate_to_activate--

