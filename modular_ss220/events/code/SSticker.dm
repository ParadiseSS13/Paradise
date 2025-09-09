/datum/controller/subsystem/ticker
	/// Biohazards that were active at the moment a Deathsquad was sent; these should be
	/// credited with a "survived" result regardless of their later elimination.
	var/list/deathsquad_biohazards = list()

/// Snapshot currently active biohazards at the time of a Deathsquad call.
/// Those active will be credited with a survived result due to the call.
/datum/controller/subsystem/ticker/proc/mark_deathsquad_biohazards()
	if(length(deathsquad_biohazards))
		// How the hell is there a second Deathsquad? Just keep current snapshot.
		return
	for(var/biohazard in SSevents.biohazards_this_round)
		if(biohazard_active_threat(biohazard))
			deathsquad_biohazards += biohazard

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
