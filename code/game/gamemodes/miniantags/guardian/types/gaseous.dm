//Gaseous
/mob/living/simple_animal/hostile/guardian/gaseous
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_transfer = 0.7
	range = 7
	playstyle_string = "As a <b>gaseous</b> type, you have only light damage resistance, but you can expel gas in an area. In addition, your punches cause sparks, and you make your summoner heat resistant."
	magic_fluff_string = "..And draw the Atmospheric Technician, flooding the area with gas!"
	tech_fluff_string = "Boot sequence complete. Atmospheric modules activated. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of spewing out many gases."
	/// Moles of gas being expelled.
	var/moles_of_gas = null
	///Linda flag for the expelled gas because we need to use special flags for it that are not readable in game well.
	var/linda_flags = null
	/// Possible gases to expel, with how much moles they create.
	var/static/list/possible_gases = list(
		"Oxygen" = 50,
		"Nitrogen" = 750, //overpressurizing is hard!.
		"N2O" = 15,
		"CO2" = 50,
		"Plasma" = 5,
		"Agent B" = 5
	)

/mob/living/simple_animal/hostile/guardian/gaseous/Initialize(mapload, mob/living/host)
	. = ..()
	if(!summoner)
		return
	ADD_TRAIT(summoner, TRAIT_RESISTHEAT, "guardian")

/mob/living/simple_animal/hostile/guardian/gaseous/AttackingTarget(atom/attacked_target)
	. = ..()
	if(!isliving(target))
		return
	do_sparks(1, TRUE, target)

/mob/living/simple_animal/hostile/guardian/gaseous/Life(seconds, times_fired)
	. = ..()
	if(!moles_of_gas || loc == summoner)
		return
	var/turf/simulated/target_turf = get_turf(src)
	if(istype(target_turf))
		target_turf.atmos_spawn_air(linda_flags, moles_of_gas)

/mob/living/simple_animal/hostile/guardian/gaseous/ToggleMode()
	var/picked_gas = tgui_input_list(src, "Select a gas to expel.", "Gas Producer", possible_gases)
	if(!picked_gas)
		moles_of_gas = null
		to_chat(src, "<span class='notice'>You stopped expelling gas.</span>")
		return
	if(!picked_gas)
		return
	to_chat(src, "<span class='bolddanger'>You are now expelling [picked_gas].</span>")
	investigate_log("set their gas type to [picked_gas].", INVESTIGATE_ATMOS)
	moles_of_gas = possible_gases[picked_gas]
	switch(picked_gas)
		if("Oxygen")
			linda_flags = LINDA_SPAWN_OXYGEN | LINDA_SPAWN_20C
		if("Nitrogen")
			linda_flags = LINDA_SPAWN_NITROGEN | LINDA_SPAWN_20C
		if("N2O")
			linda_flags = LINDA_SPAWN_N2O | LINDA_SPAWN_20C
		if("CO2")
			linda_flags = LINDA_SPAWN_CO2 | LINDA_SPAWN_20C
		if("Plasma")
			linda_flags = LINDA_SPAWN_TOXINS | LINDA_SPAWN_20C
		if("Agent B")
			linda_flags = LINDA_SPAWN_AGENT_B | LINDA_SPAWN_20C

/mob/living/simple_animal/hostile/guardian/gaseous/experience_pressure_difference(flow_x, flow_y)
	return // Immune to gas flow.

/mob/living/simple_animal/hostile/guardian/gaseous/death(gibbed)
	if(summoner)
		REMOVE_TRAIT(summoner, TRAIT_RESISTHEAT, "guardian")
	return ..()
