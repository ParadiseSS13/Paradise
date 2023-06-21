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
	/// Gas being expelled.
	var/expelled_gas = null
	/// Possible gases to expel, with how much moles they create.
	var/static/list/possible_gases = list(
		LINDA_SPAWN_OXYGEN = 50,
		LINDA_SPAWN_NITROGEN = 750, //overpressurizing is hard!.
		LINDA_SPAWN_N2O = 15,
		LINDA_SPAWN_CO2 = 50,
		LINDA_SPAWN_TOXINS = 3,
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

/mob/living/simple_animal/hostile/guardian/gaseous/Recall(forced)
	expelled_gas = null
	. = ..()

/mob/living/simple_animal/hostile/guardian/gaseous/Life(seconds, times_fired)
	. = ..()
	if(!expelled_gas)
		return
	var/turf/simulated/target_turf = get_turf(src)
	if(istype(target_turf))
		target_turf.atmos_spawn_air((possible_gases[expelled_gas] | LINDA_SPAWN_20C), possible_gases[expelled_gas][expelled_gas])
		target_turf.air_update_turf()

/mob/living/simple_animal/hostile/guardian/gaseous/ToggleMode()
	var/list/gases = list("None")
	for(var/gas as anything in possible_gases)
		gases[gas] = gas
	var/picked_gas = input("Select a gas to expel.", "Gas Producer") in gases
	if(picked_gas == "None")
		expelled_gas = null
		to_chat(src, "<span class='notice'>You stopped expelling gas.</span>")
		return
	var/gas_type = gases[picked_gas]
	if(!picked_gas || !gas_type)
		return
	to_chat(src, "<span class='bolddanger'>You are now expelling [picked_gas]</span>.")
	investigate_log("set their gas type to [picked_gas].", "atmos")
	expelled_gas = gas_type

/mob/living/simple_animal/hostile/guardian/gaseous/death(gibbed)
	if(summoner)
		REMOVE_TRAIT(summoner, TRAIT_RESISTHEAT, "guardian")
	return ..()
