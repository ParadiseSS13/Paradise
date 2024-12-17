/datum/controller/subsystem/ticker/any_admin_spawned_mobs(biohazard)
	switch(biohazard)
		if(BIOHAZARD_TERROR_SPIDERS)
			for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in GLOB.ts_spiderlist)
				if(S.admin_spawned)
					return TRUE
	return ..()

/datum/controller/subsystem/ticker/biohazard_count(biohazard)
	switch(biohazard)
		if(BIOHAZARD_TERROR_SPIDERS)
			var/spiders = 0
			for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in GLOB.ts_spiderlist)
				if(S.ckey)
					spiders++
			return spiders
	return ..()

/datum/controller/subsystem/ticker/biohazard_active_threat(biohazard)
	var/modular_count = biohazard_count(biohazard)
	switch(biohazard)
		if(BIOHAZARD_TERROR_SPIDERS)
			return modular_count >= 3
	return ..()
