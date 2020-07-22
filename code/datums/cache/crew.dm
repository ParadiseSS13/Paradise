GLOBAL_DATUM_INIT(crew_repository, /datum/repository/crew, new())

/datum/repository/crew/New()
	cache_data = list()
	..()

/datum/repository/crew/proc/health_data(turf/T)
	var/list/crewmembers = list()
	if(!T)
		return crewmembers

	var/z_level = "[T.z]"
	var/datum/cache_entry/cache_entry = cache_data[z_level]
	if(!cache_entry)
		cache_entry = new/datum/cache_entry
		cache_data[z_level] = cache_entry

	if(world.time < cache_entry.timestamp)
		return cache_entry.data

	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		var/obj/item/clothing/under/C = H.w_uniform
		if(!C || C.sensor_mode == SUIT_SENSOR_OFF || !C.has_sensor)
			continue
		var/turf/pos = get_turf(C)
		if(!T || pos.z != T.z)
			continue
		var/list/crewmemberData = list("dead"=0, "oxy"=-1, "tox"=-1, "fire"=-1, "brute"=-1, "area"="", "x"=-1, "y"=-1, "ref" = "\ref[H]")

		crewmemberData["sensor_type"] = C.sensor_mode
		crewmemberData["name"] = H.get_authentification_name(if_no_id="Unknown")
		crewmemberData["rank"] = H.get_authentification_rank(if_no_id="Unknown", if_no_job="No Job")
		crewmemberData["assignment"] = H.get_assignment(if_no_id="Unknown", if_no_job="No Job")

		if(C.sensor_mode >= SUIT_SENSOR_BINARY)
			crewmemberData["dead"] = H.stat > UNCONSCIOUS

		if(C.sensor_mode >= SUIT_SENSOR_VITAL)
			crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
			crewmemberData["tox"] = round(H.getToxLoss(), 1)
			crewmemberData["fire"] = round(H.getFireLoss(), 1)
			crewmemberData["brute"] = round(H.getBruteLoss(), 1)

		if(C.sensor_mode >= SUIT_SENSOR_TRACKING)
			var/area/A = get_area(H)
			crewmemberData["area"] = sanitize(A.name)
			crewmemberData["x"] = pos.x
			crewmemberData["y"] = pos.y

		crewmembers[++crewmembers.len] = crewmemberData

	crewmembers = sortByKey(crewmembers, "name")
	cache_entry.timestamp = world.time + 5 SECONDS
	cache_entry.data = crewmembers

	return crewmembers
