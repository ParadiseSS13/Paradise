/mob/living/carbon/human/Life(seconds, times_fired)
	set invisibility = 0
	if(notransform)
		return

	. = ..()

	if(QDELETED(src))
		return FALSE

	life_tick++

	voice = GetVoice()

	if(.) //not dead

		if(check_mutations)
			domutcheck(src)
			update_mutations()
			check_mutations = FALSE

		handle_pain()
		handle_heartbeat()
		dna.species.handle_life(src)
		if(!client)
			dna.species.handle_npc(src)

	if(stat != DEAD)
		//Stuff jammed in your limbs hurts
		handle_embedded_objects()

	if(stat == DEAD)
		handle_decay()

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()
	pulse = handle_pulse(times_fired)

	var/datum/antagonist/vampire/V = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(V)
		V.handle_vampire()
		if(life_tick == 1)
			regenerate_icons() // Make sure the inventory updates

	if(player_ghosted > 0 && stat == CONSCIOUS && job && !restrained())
		handle_ghosted()
	if(player_logged > 0 && stat != DEAD && job)
		handle_ssd()

	if(stat != DEAD)
		return TRUE

/mob/living/carbon/human/proc/handle_ghosted()
	if(key)
		player_ghosted = 0
	else
		player_ghosted++
		if(player_ghosted % 150 == 0)
			force_cryo_human(src)

/mob/living/carbon/human/proc/handle_ssd()
	player_logged++
	if(istype(loc, /obj/machinery/cryopod))
		return
	if(GLOB.configuration.afk.ssd_auto_cryo_minutes && (player_logged >= (GLOB.configuration.afk.ssd_auto_cryo_minutes * 30)) && player_logged % 30 == 0)
		var/turf/T = get_turf(src)
		if(!is_station_level(T.z))
			return
		var/area/A = get_area(src)
		cryo_ssd(src)
		if(A.fast_despawn)
			force_cryo_human(src)

/mob/living/carbon/human/calculate_affecting_pressure(pressure)
	..()
	var/pressure_difference = abs( pressure - ONE_ATMOSPHERE )

	var/pressure_adjustment_coefficient = 1	//Determins how much the clothing you are wearing protects you in percent.
	if(wear_suit && (wear_suit.flags & STOPSPRESSUREDMAGE) && head && (head.flags & STOPSPRESSUREDMAGE)) // Complete set of pressure-proof suit worn, assume fully sealed.
		pressure_adjustment_coefficient = 0
	pressure_adjustment_coefficient = max(pressure_adjustment_coefficient,0) //So it isn't less than 0
	pressure_difference = pressure_difference * pressure_adjustment_coefficient
	if(pressure > ONE_ATMOSPHERE)
		return ONE_ATMOSPHERE + pressure_difference
	else
		return ONE_ATMOSPHERE - pressure_difference


/mob/living/carbon/human/handle_disabilities()
	//Vision //god knows why this is here
	var/obj/item/organ/vision
	if(dna.species.vision_organ)
		vision = get_int_organ(dna.species.vision_organ)

	if(!dna.species.vision_organ) // Presumably if a species has no vision organs, they see via some other means.
		SetEyeBlind(0)
		SetEyeBlurry(0)

	else if(!vision || vision.is_broken())   // Vision organs cut out or broken? Permablind.
		EyeBlind(4 SECONDS)

	if(getBrainLoss() >= 60 && stat != DEAD)
		if(prob(3))
			var/list/crazysay = list("IM A [pick("PONY","LIZARD","taJaran","kitty","Vulpakin","drASK","BIRDIE","voxxie","race car","combat meCH","SPESSSHIP")] [pick("NEEEEEEIIIIIIIIIGH","sKREEEEEE","MEOW","NYA~","rawr","Barkbark","Hissssss","vROOOOOM","pewpew","choo Choo")]!",
							"without oxigen blob don't evoluate?",
							"CAPTAINS A COMDOM",
							"[pick("", "that damn traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!",
							"can u give me [pick("telikesis","halk","eppilapse")]?",
							"THe saiyans screwed",
							"Bi is THE BEST OF BOTH WORLDS",
							"I WANNA PET TEH monkeyS",
							"stop grifing me!!!!",
							"SOTP IT!",
							"HALPZ SITCULITY",
							"VOXES caN't LOVE",
							"my dad own this station",
							"the CHef put [pick("PROTEIN", "toiret waTer", "RiPPleing TendIes", "Einzymes","HORRY WALTER","nuTriments","ReActive MutAngen","TeSLium","sKrektonium")] in my [pick("wiSh soup","Bullito","rAingurber","sOilent GREEn","KoI Susishes","yaya")]!",
							"the monkey have TASER ARMS!",
							"qM blew my points on [pick("cOMbat Shtogun","inSuLated gloves","LOTS MASSHEEN!")]",
							"EI'NATH!",
							"WAKE UP SHEEPLES!",
							"et wus my [pick("wittle brother!!","fiancee","friend staying over","entiRe orphanage","love interest","wife","husband","liTTle kids","sentient cAT","accidentally")]!",
							"FUS RO DAH",
							"fuckin tangerines!!!",
							"stAT ME",
							"my FACE",
							"rOLl it eaSy!",
							"waaaaaagh!!!",
							"red wonz go fasta",
							"FOR TEH EMPRAH",
							"HAZ A SECURE DAY!!!!",
							"dem dwarfs man, dem dwarfs",
							"SPESS MAHREENS",
							"hwee did eet fhor khayosss",
							"lifelike texture",
							"luv can bloooom",
							"PACKETS!!!",
							"[pick("WHERE MY","aYE need","giv me my","bath me inn.")] [pick("dermaline","alKkyZine","dylOvene","inAprovaline","biCaridine","Hyperzine","kELotane","lePorazine","bAcch Salts","tricord","clOnexazone","hydroChloric Acid","chlORine Hydrate","paRoxetine")]!",
							"mALPRACTICEBAY",
							"I HavE A pe H dee iN ENTerpriSE resOUrCE pLaNNIN",
							"h-h-HalP MaINT",
							"dey come, dey COME! DEY COME!!!",
							"THE END IS NIGH!",
							"I FOT AND DIED FOR MUH [pick("RITES","FREEDOM","payCHECK","cARGO points","teCH Level","doG","mAPLe syrup","fluffy fWiends","gATEway LoOt")]",
							"KILL DEM [pick("mainTnacE cHickinNS","kiRA CulwnNES","FLOOR CLUWNEs","MIME ASSASSIN","BOMBING TAJARAN","cC offiser","morPhlings","slinglings")]!",
							"I CAN FORCE YOU TO SAY WHATEREVE!!?!?!")
			if(prob(66))
				say(pick(crazysay))
			else
				emote("drool")

/mob/living/carbon/human/handle_mutations_and_radiation()
	for(var/mutation_type in active_mutations)
		var/datum/mutation/mutation = GLOB.dna_mutations[mutation_type]
		mutation.on_life(src)

	if(!ignore_gene_stability && gene_stability < GENETIC_DAMAGE_STAGE_1)
		var/instability = DEFAULT_GENE_STABILITY - gene_stability
		if(prob(instability * 0.1))
			adjustFireLoss(min(5, instability * 0.67))
			to_chat(src, "<span class='danger'>You feel like your skin is burning and bubbling off!</span>")
		if(gene_stability < GENETIC_DAMAGE_STAGE_2)
			if(prob(instability * 0.83))
				adjustCloneLoss(min(4, instability * 0.05))
				to_chat(src, "<span class='danger'>You feel as if your body is warping.</span>")
			if(prob(instability * 0.1))
				adjustToxLoss(min(5, instability * 0.67))
				to_chat(src, "<span class='danger'>You feel weak and nauseous.</span>")
			if(gene_stability < GENETIC_DAMAGE_STAGE_3 && prob(1))
				to_chat(src, "<span class='biggerdanger'>You feel incredibly sick... Something isn't right!</span>")
				spawn(300)
					if(gene_stability < GENETIC_DAMAGE_STAGE_3)
						gib()

	if(!dna || !dna.species.handle_mutations_and_radiation(src))
		..()

/mob/living/carbon/human/breathe()
	if(!dna.species.breathe(src))
		..()

/mob/living/carbon/human/check_breath(datum/gas_mixture/breath)

	var/obj/item/organ/internal/L = get_organ_slot("lungs")

	if(!L || L && (L.status & ORGAN_DEAD))
		if(health >= HEALTH_THRESHOLD_CRIT)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS + 1)
		else if(!HAS_TRAIT(src, TRAIT_NOCRITDAMAGE))
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)

		if(dna.species)
			var/datum/species/S = dna.species

			if(S.breathid == "o2")
				throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
			else if(S.breathid == "tox")
				throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
			else if(S.breathid == "co2")
				throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
			else if(S.breathid == "n2")
				throw_alert("not_enough_nitro", /obj/screen/alert/not_enough_nitro)

		return FALSE
	else
		if(istype(L, /obj/item/organ/internal/lungs))
			var/obj/item/organ/internal/lungs/lun = L
			lun.check_breath(breath, src)

// USED IN DEATHWHISPERS
/mob/living/carbon/human/proc/isInCrit()
	// Health is in deep shit and we're not already dead
	return health <= HEALTH_THRESHOLD_CRIT && stat != DEAD


/mob/living/carbon/human/get_breath_from_internal(volume_needed) //making this call the parent would be far too complicated
	if(internal)
		var/null_internals = 0      //internals are invalid, therefore turn them off
		var/skip_contents_check = 0 //rigsuit snowflake, oxygen tanks aren't stored inside the mob, so the 'contents.Find' check has to be skipped.

		if(!get_organ_slot("breathing_tube"))
			if(!(wear_mask && wear_mask.flags & AIRTIGHT)) //if NOT (wear_mask AND wear_mask.flags CONTAIN AIRTIGHT)
				if(!(head && head.flags & AIRTIGHT)) //if NOT (head AND head.flags CONTAIN AIRTIGHT)
					null_internals = 1 //not wearing a mask or suitable helmet

		if(!contents.Find(internal) && (!skip_contents_check)) //if internal NOT IN contents AND skip_contents_check IS false
			null_internals = 1 //not a rigsuit and your oxygen is gone

		if(null_internals) //something wants internals gone
			internal = null //so do it
			update_action_buttons_icon()

	if(internal) //check for hud updates every time this is called
		return internal.remove_air_volume(volume_needed) //returns the valid air

	return null

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/loc_temp = get_temperature(environment)
//	to_chat(world, "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Thermal protection: [get_thermal_protection()] - Fire protection: [thermal_protection + add_fire_protection(loc_temp)] - Heat capacity: [environment_heat_capacity] - Location: [loc] - src: [src]")

	//Body temperature is adjusted in two steps. Firstly your body tries to stabilize itself a bit.
	if(stat != DEAD)
		stabilize_temperature_from_calories()

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < bodytemperature)
			//Place is colder than we are
			var/thermal_protection = get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += min((1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR), BODYTEMP_COOLING_MAX)
		else
			//Place is hotter than we are
			var/thermal_protection = get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += min((1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > dna.species.heat_level_1)
		//Body temperature is too hot.
		if(status_flags & GODMODE)	return 1	//godmode
		var/mult = dna.species.heatmod * physiology.heat_mod

		if(bodytemperature >= dna.species.heat_level_1 && bodytemperature <= dna.species.heat_level_2)
			throw_alert("temp", /obj/screen/alert/hot, 1)
			take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_1, updating_health = TRUE, used_weapon = "High Body Temperature")
		if(bodytemperature > dna.species.heat_level_2 && bodytemperature <= dna.species.heat_level_3)
			throw_alert("temp", /obj/screen/alert/hot, 2)
			take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_2, updating_health = TRUE, used_weapon = "High Body Temperature")
		if(bodytemperature > dna.species.heat_level_3 && bodytemperature < INFINITY)
			throw_alert("temp", /obj/screen/alert/hot, 3)
			if(on_fire)
				take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_3, updating_health = TRUE, used_weapon = "Fire")
			else
				take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_2, updating_health = TRUE, used_weapon = "High Body Temperature")

	else if(bodytemperature < dna.species.cold_level_1)
		if(status_flags & GODMODE)
			return TRUE
		if(stat == DEAD)
			return TRUE

		if(!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell) && !(HAS_TRAIT(src, TRAIT_RESISTCOLD)))
			var/mult = dna.species.coldmod * physiology.cold_mod
			if(bodytemperature >= dna.species.cold_level_2 && bodytemperature <= dna.species.cold_level_1)
				throw_alert("temp", /obj/screen/alert/cold, 1)
				take_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_1, updating_health = TRUE, used_weapon = "Low Body Temperature")
			if(bodytemperature >= dna.species.cold_level_3 && bodytemperature < dna.species.cold_level_2)
				throw_alert("temp", /obj/screen/alert/cold, 2)
				take_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_2, updating_health = TRUE, used_weapon = "Low Body Temperature")
			if(bodytemperature > -INFINITY && bodytemperature < dna.species.cold_level_3)
				throw_alert("temp", /obj/screen/alert/cold, 3)
				take_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_3, updating_health = TRUE, used_weapon = "Low Body Temperature")
			else
				clear_alert("temp")
	else
		clear_alert("temp")

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	if(status_flags & GODMODE)	return 1	//godmode

	if(adjusted_pressure >= dna.species.hazard_high_pressure)
		if(!HAS_TRAIT(src, TRAIT_RESISTHIGHPRESSURE))
			var/pressure_damage = min(((adjusted_pressure / dna.species.hazard_high_pressure) - 1) * PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) * physiology.pressure_mod
			take_overall_damage(brute=pressure_damage, updating_health = TRUE, used_weapon = "High Pressure")
			throw_alert("pressure", /obj/screen/alert/highpressure, 2)
		else
			clear_alert("pressure")
	else if(adjusted_pressure >= dna.species.warning_high_pressure)
		throw_alert("pressure", /obj/screen/alert/highpressure, 1)
	else if(adjusted_pressure >= dna.species.warning_low_pressure)
		clear_alert("pressure")
	else if(adjusted_pressure >= dna.species.hazard_low_pressure)
		throw_alert("pressure", /obj/screen/alert/lowpressure, 1)
	else
		if(HAS_TRAIT(src, TRAIT_RESISTLOWPRESSURE))
			clear_alert("pressure")
		else
			take_overall_damage(brute = LOW_PRESSURE_DAMAGE * physiology.pressure_mod, updating_health = TRUE, used_weapon = "Low Pressure")
			throw_alert("pressure", /obj/screen/alert/lowpressure, 2)


///FIRE CODE
/mob/living/carbon/human/handle_fire()
	. = ..()
	if(!.)
		return
	if(HAS_TRAIT(src, TRAIT_NOFIRE))
		return
	var/thermal_protection = get_thermal_protection()

	if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
		return
	if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT)
		bodytemperature += 11
	else
		bodytemperature += (BODYTEMP_HEATING_MAX + (fire_stacks * 12))
		var/datum/antagonist/vampire/V = mind?.has_antag_datum(/datum/antagonist/vampire)
		if(V && !V.get_ability(/datum/vampire_passive/full) && stat != DEAD)
			V.bloodusable = max(V.bloodusable - 5, 0)

/mob/living/carbon/human/proc/get_thermal_protection()
	if(HAS_TRAIT(src, TRAIT_RESISTHEAT))
		return FIRE_IMMUNITY_MAX_TEMP_PROTECT

	var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			thermal_protection += (wear_suit.max_heat_protection_temperature*0.7)
	if(head)
		if(head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT)
			thermal_protection += (head.max_heat_protection_temperature*THERMAL_PROTECTION_HEAD)
	thermal_protection = round(thermal_protection)
	return thermal_protection

//END FIRE CODE

/mob/living/carbon/human/proc/stabilize_temperature_from_calories()
	var/body_temperature_difference = dna.species.body_temperature - bodytemperature

	if(bodytemperature <= dna.species.cold_level_1) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
		bodytemperature += max((body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
	if(bodytemperature >= dna.species.cold_level_1 && bodytemperature <= dna.species.heat_level_1)
		bodytemperature += body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR
	if(bodytemperature >= dna.species.heat_level_1) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
		//We totally need a sweat system cause it totally makes sense...~
		bodytemperature += min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers


	//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, UPPER_TORSO, LOWER_TORSO, etc. See setup.dm for the full list)
/mob/living/carbon/human/proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = 0
	//Handle normal clothing
	if(head)
		if(head.max_heat_protection_temperature && head.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= head.heat_protection
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature && wear_suit.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_suit.heat_protection
	if(w_uniform)
		if(w_uniform.max_heat_protection_temperature && w_uniform.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= w_uniform.heat_protection
	if(shoes)
		if(shoes.max_heat_protection_temperature && shoes.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= shoes.heat_protection
	if(gloves)
		if(gloves.max_heat_protection_temperature && gloves.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= gloves.heat_protection
	if(wear_mask)
		if(wear_mask.max_heat_protection_temperature && wear_mask.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_mask.heat_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.

	if(HAS_TRAIT(src, TRAIT_RESISTHEAT))
		return 1

	var/thermal_protection_flags = get_heat_protection_flags(temperature)

	var/thermal_protection = 0.0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & UPPER_TORSO)
			thermal_protection += THERMAL_PROTECTION_UPPER_TORSO
		if(thermal_protection_flags & LOWER_TORSO)
			thermal_protection += THERMAL_PROTECTION_LOWER_TORSO
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT


	return min(1,thermal_protection)

	//See proc/get_heat_protection_flags(temperature) for the description of this proc.
/mob/living/carbon/human/proc/get_cold_protection_flags(temperature)
	var/thermal_protection_flags = 0
	//Handle normal clothing

	if(head)
		if(head.min_cold_protection_temperature && head.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= head.cold_protection
	if(wear_suit)
		if(wear_suit.min_cold_protection_temperature && wear_suit.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_suit.cold_protection
	if(w_uniform)
		if(w_uniform.min_cold_protection_temperature && w_uniform.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= w_uniform.cold_protection
	if(shoes)
		if(shoes.min_cold_protection_temperature && shoes.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= shoes.cold_protection
	if(gloves)
		if(gloves.min_cold_protection_temperature && gloves.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= gloves.cold_protection
	if(wear_mask)
		if(wear_mask.min_cold_protection_temperature && wear_mask.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_mask.cold_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_cold_protection(temperature)

	if(HAS_TRAIT(src, TRAIT_RESISTCOLD))
		return 1 //Fully protected from the cold.

	temperature = max(temperature, TCMB) //There is an occasional bug where the temperature is miscalculated in areas with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	var/thermal_protection_flags = get_cold_protection_flags(temperature)

	var/thermal_protection = 0.0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & UPPER_TORSO)
			thermal_protection += THERMAL_PROTECTION_UPPER_TORSO
		if(thermal_protection_flags & LOWER_TORSO)
			thermal_protection += THERMAL_PROTECTION_LOWER_TORSO
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT

	return min(1,thermal_protection)


/mob/living/carbon/human/proc/get_covered_bodyparts()
	var/covered = 0

	if(head)
		covered |= head.body_parts_covered
	if(wear_suit)
		covered |= wear_suit.body_parts_covered
	if(w_uniform)
		covered |= w_uniform.body_parts_covered
	if(shoes)
		covered |= shoes.body_parts_covered
	if(gloves)
		covered |= gloves.body_parts_covered
	if(wear_mask)
		covered |= wear_mask.body_parts_covered

	return covered

/mob/living/carbon/human/handle_chemicals_in_body()
	..()

	if(status_flags & GODMODE)
		return 0	//godmode

	if(!HAS_TRAIT(src, TRAIT_NOHUNGER))
		if(HAS_TRAIT(src, TRAIT_FAT))
			if(overeatduration < 100)
				becomeSlim()
		else
			if(overeatduration > 500 && !HAS_TRAIT(src, TRAIT_NOFAT))
				becomeFat()

		// nutrition decrease
		if(nutrition > 0 && stat != DEAD)
			handle_nutrition_alerts()
			// THEY HUNGER
			var/hunger_rate = hunger_drain
			if(satiety > 0)
				satiety--
			if(satiety < 0)
				satiety++
				if(prob(round(-satiety/40)))
					Jitter(10 SECONDS)
				hunger_rate = 3 * hunger_drain
			hunger_rate *= physiology.hunger_mod
			adjust_nutrition(-hunger_rate)

		if(nutrition > NUTRITION_LEVEL_FULL)
			if(overeatduration < 600) //capped so people don't take forever to unfat
				overeatduration++

		else
			if(overeatduration > 1)
				if(HAS_TRAIT(src, TRAIT_SLOWDIGESTION))
					overeatduration -= 1 // Those with slow digestion trait, it takes longer to lose weight
				else
					overeatduration -= 2

		if(!ismachineperson(src) && !isLivingSSD(src) && nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA) //Gosh damn snowflakey IPCs
			var/datum/disease/D = new /datum/disease/critical/hypoglycemia
			ForceContractDisease(D)

		//metabolism change
		if(nutrition > NUTRITION_LEVEL_FAT)
			metabolism_efficiency = 1
		else if(nutrition > NUTRITION_LEVEL_FED && satiety > 80)
			if(metabolism_efficiency != 1.25)
				to_chat(src, "<span class='notice'>You feel vigorous.</span>")
				metabolism_efficiency = 1.25
		else if(nutrition < NUTRITION_LEVEL_STARVING + 50)
			if(metabolism_efficiency != 0.8)
				to_chat(src, "<span class='notice'>You feel sluggish.</span>")
			metabolism_efficiency = 0.8
		else
			if(metabolism_efficiency == 1.25)
				to_chat(src, "<span class='notice'>You no longer feel vigorous.</span>")
			metabolism_efficiency = 1



	if(NO_INTORGANS in dna.species.species_traits)
		return

	handle_trace_chems()

/mob/living/carbon/human/proc/has_booze() //checks if the human has ethanol or its subtypes inside
	for(var/A in reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/consumable/ethanol))
			return 1
	return 0

/mob/living/carbon/human/handle_critical_condition()
	if(status_flags & GODMODE)
		return 0

	var/guaranteed_death_threshold = health + (getOxyLoss() * 0.5) - (getFireLoss() * 0.67) - (getBruteLoss() * 0.67)

	if(getBrainLoss() >= 120 || (guaranteed_death_threshold) <= -500)
		death()
		return

	if(getBrainLoss() >= 100) // braindeath
		dna.species.handle_brain_death(src)

	if(!check_death_method())
		if(health <= HEALTH_THRESHOLD_DEAD)
			var/deathchance = min(99, ((getBrainLoss() * -5) + (health + (getOxyLoss() / 2))) * -0.01)
			if(prob(deathchance))
				death()
				return

		if(health <= HEALTH_THRESHOLD_CRIT)
			if(prob(5))
				emote(pick("faint", "collapse", "cry", "moan", "gasp", "shudder", "shiver"))
			SetStuttering(10 SECONDS)
			EyeBlurry(5)
			if(prob(7))
				AdjustConfused(4 SECONDS)
			if(prob(5))
				Paralyse(4 SECONDS)
			switch(health)
				if(-INFINITY to -100)
					adjustOxyLoss(1)
					if(prob(health * -0.1))
						if(ishuman(src))
							var/mob/living/carbon/human/H = src
							H.set_heartattack(TRUE)
					if(prob(health * -0.2))
						var/datum/disease/D = new /datum/disease/critical/heart_failure
						ForceContractDisease(D)
					Paralyse(10 SECONDS)
				if(-99 to -80)
					adjustOxyLoss(1)
					if(prob(4))
						to_chat(src, "<span class='userdanger'>Your chest hurts...</span>")
						Paralyse(4 SECONDS)
						var/datum/disease/D = new /datum/disease/critical/heart_failure
						ForceContractDisease(D)
				if(-79 to -50)
					adjustOxyLoss(1)
					if(prob(10))
						var/datum/disease/D = new /datum/disease/critical/shock
						ForceContractDisease(D)
					if(prob(health * -0.08))
						var/datum/disease/D = new /datum/disease/critical/heart_failure
						ForceContractDisease(D)
					if(prob(6))
						to_chat(src, "<span class='userdanger'>You feel [pick("horrible pain", "awful", "like shit", "absolutely awful", "like death", "like you are dying", "nothing", "warm", "sweaty", "tingly", "really, really bad", "horrible")]!</span>")
						Weaken(6 SECONDS)
					if(prob(3))
						Paralyse(4 SECONDS)
				if(-49 to 0)
					adjustOxyLoss(1)
					if(prob(3))
						var/datum/disease/D = new /datum/disease/critical/shock
						ForceContractDisease(D)
					if(prob(5))
						to_chat(src, "<span class='userdanger'>You feel [pick("terrible", "awful", "like shit", "sick", "numb", "cold", "sweaty", "tingly", "horrible")]!</span>")
						Weaken(6 SECONDS)

#define BODYPART_PAIN_REDUCTION 5

/mob/living/carbon/human/update_health_hud()
	if(!client)
		return
	if(dna.species.update_health_hud())
		return
	else
		var/shock_reduction = shock_reduction()
		if(healths)
			var/health_amount = get_perceived_trauma(shock_reduction)
			if(..(health_amount)) //not dead
				switch(health_hud_override)
					if(HEALTH_HUD_OVERRIDE_CRIT)
						healths.icon_state = "health6"
					if(HEALTH_HUD_OVERRIDE_DEAD)
						healths.icon_state = "health7"
					if(HEALTH_HUD_OVERRIDE_HEALTHY)
						healths.icon_state = "health0"

		if(healthdoll)
			if(stat == DEAD)
				healthdoll.icon_state = "healthdoll_DEAD"
				if(healthdoll.overlays.len)
					healthdoll.overlays.Cut()
			else
				var/list/new_overlays = list()
				var/list/cached_overlays = healthdoll.cached_healthdoll_overlays
				// Use the dead health doll as the base, since we have proper "healthy" overlays now
				healthdoll.icon_state = "healthdoll_DEAD"
				for(var/obj/item/organ/external/O in bodyparts)
					var/damage = O.get_damage()
					damage -= shock_reduction / BODYPART_PAIN_REDUCTION
					var/comparison = (O.max_damage/5)
					var/icon_num = 0
					if(damage > 0)
						icon_num = 1
					if(damage > (comparison))
						icon_num = 2
					if(damage > (comparison*2))
						icon_num = 3
					if(damage > (comparison*3))
						icon_num = 4
					if(damage > (comparison*4))
						icon_num = 5
					new_overlays += "[O.limb_name][icon_num]"
				healthdoll.overlays += (new_overlays - cached_overlays)
				healthdoll.overlays -= (cached_overlays - new_overlays)
				healthdoll.cached_healthdoll_overlays = new_overlays

#undef BODYPART_PAIN_REDUCTION

/mob/living/carbon/human/proc/handle_nutrition_alerts() //This is a terrible abuse of the alert system; something like this should be a HUD element
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return
	var/new_hunger
	switch(nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			new_hunger = "fat"
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			new_hunger = "full"
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			new_hunger = "well_fed"
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			new_hunger = "fed"
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			new_hunger = "hungry"
		else
			new_hunger = "starving"
	if(dna.species.hunger_type)
		new_hunger += "/[dna.species.hunger_type]"
	if(dna.species.hunger_level != new_hunger)
		dna.species.hunger_level = new_hunger
		throw_alert("nutrition", "/obj/screen/alert/hunger/[new_hunger]", icon_override = dna.species.hunger_icon)

/mob/living/carbon/human/handle_random_events()
	// Puke if toxloss is too high
	if(!stat)
		if(getToxLoss() >= 45 && nutrition > 20)
			lastpuke ++
			if(lastpuke >= 25) // about 25 second delay I guess
				vomit(20, 0, 1, 0, 1)
				adjustToxLoss(-3)
				lastpuke = 0

/mob/living/carbon/human/proc/handle_embedded_objects()
	for(var/X in bodyparts)
		var/obj/item/organ/external/BP = X
		for(var/obj/item/I in BP.embedded_objects)
			if(prob(I.embedded_pain_chance))
				BP.receive_damage(I.w_class*I.embedded_pain_multiplier)
				to_chat(src, "<span class='userdanger'>[I] embedded in your [BP.name] hurts!</span>")

			if(prob(I.embedded_fall_chance))
				BP.receive_damage(I.w_class*I.embedded_fall_pain_multiplier)
				BP.remove_embedded_object(I)
				I.forceMove(get_turf(src))
				visible_message("<span class='danger'>[I] falls out of [name]'s [BP.name]!</span>","<span class='userdanger'>[I] falls out of your [BP.name]!</span>")
				if(!has_embedded_objects())
					clear_alert("embeddedobject")

/mob/living/carbon/human/proc/handle_pulse(times_fired)
	if(times_fired % 5 == 1)
		return pulse	//update pulse every 5 life ticks (~1 tick/sec, depending on server load)

	if(NO_BLOOD in dna.species.species_traits)
		return PULSE_NONE //No blood, no pulse.

	if(stat == DEAD)
		return PULSE_NONE	//that's it, you're dead, nothing can influence your pulse

	if(undergoing_cardiac_arrest())
		return PULSE_NONE

	var/temp = PULSE_NORM

	if(blood_volume <= BLOOD_VOLUME_BAD)//how much blood do we have
		temp = PULSE_THREADY	//not enough :(     ) fuck you bracket colouriser

	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		temp = PULSE_NONE		//pretend that we're dead. unlike actual death, can be inflienced by meds

	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.heart_rate_decrease)
			if(temp <= PULSE_THREADY && temp >= PULSE_NORM)
				temp--
				break

	for(var/datum/reagent/R in reagents.reagent_list)//handles different chems' influence on pulse
		if(R.heart_rate_increase)
			if(temp <= PULSE_FAST && temp >= PULSE_NONE)
				temp++
				break

	for(var/datum/reagent/R in reagents.reagent_list) //To avoid using fakedeath
		if(R.heart_rate_stop)
			temp = PULSE_NONE
			break

	return temp

/mob/living/carbon/human/proc/handle_decay()
	var/decaytime = world.time - timeofdeath

	if(HAS_TRAIT(src, TRAIT_NODECAY))
		return

	if(reagents.has_reagent("formaldehyde")) //embalming fluid stops decay
		return

	if(decaytime <= 6000) //10 minutes for decaylevel1 -- stinky
		return

	if(decaytime > 6000 && decaytime <= 12000)//20 minutes for decaylevel2 -- bloated and very stinky
		decaylevel = 1

	if(decaytime > 12000 && decaytime <= 18000)//30 minutes for decaylevel3 -- rotting and gross
		decaylevel = 2

	if(decaytime > 18000 && decaytime <= 27000)//45 minutes for decaylevel4 -- skeleton
		decaylevel = 3

	if(decaytime > 27000)
		decaylevel = 4
		makeSkeleton()
		return //No puking over skeletons, they don't smell at all!

	if(!isturf(loc))
		return

	for(var/mob/living/carbon/human/H in range(decaylevel, src))
		if(prob(2))
			var/obj/item/clothing/mask/M = H.wear_mask
			if(M && (M.flags_cover & MASKCOVERSMOUTH))
				continue
			if(HAS_TRAIT(H, TRAIT_NOBREATH))
				continue //no puking if you can't smell!
			// Humans can lack a mind datum, y'know
			if(H.mind && (H.mind.assigned_role == "Detective" || H.mind.assigned_role == "Coroner"))
				continue //too cool for puke
			to_chat(H, "<span class='warning'>You smell something foul...</span>")
			H.fakevomit()

/mob/living/carbon/human/proc/handle_heartbeat()
	var/client/C = src.client
	if(C && C.prefs.sound & SOUND_HEARTBEAT) //disable heartbeat by pref
		var/obj/item/organ/internal/heart/H = get_int_organ(/obj/item/organ/internal/heart)

		if(!H) //H.status will runtime if there is no H (obviously)
			return

		if(H.is_robotic()) //Handle robotic hearts specially with a wuuuubb. This also applies to machine-people.
			if(isinspace())
				//PULSE_THREADY - maximum value for pulse, currently it 5.
				//High pulse value corresponds to a fast rate of heartbeat.
				//Divided by 2, otherwise it is too slow.
				var/rate = (PULSE_THREADY - 2)/2 //machine people (main target) have no pulse, manually subtract standard human pulse (2). Mechanic-heart humans probably have a pulse, but 'advanced neural systems' keep the heart rate steady, or something

				if(heartbeat >= rate)
					heartbeat = 0
					src << sound('sound/effects/electheart.ogg',0,0,CHANNEL_HEARTBEAT,30)//Credit to GhostHack (www.ghosthack.de) for sound.

				else
					heartbeat++
				return
			return

		if(pulse == PULSE_NONE)
			return

		if(pulse >= PULSE_2FAST || isinspace())
			//PULSE_THREADY - maximum value for pulse, currently it 5.
			//High pulse value corresponds to a fast rate of heartbeat.
			//Divided by 2, otherwise it is too slow.
			var/rate = (PULSE_THREADY - pulse)/2

			if(heartbeat >= rate)
				heartbeat = 0
				src << sound('sound/effects/singlebeat.ogg',0,0,CHANNEL_HEARTBEAT,50)
			else
				heartbeat++

/*
	Called by life(), instead of having the individual hud items update icons each tick and check for status changes
	we only set those statuses and icons upon changes.  Then those HUD items will simply add those pre-made images.
	This proc below is only called when those HUD elements need to change as determined by the mobs hud_updateflag.
*/

/mob/living/carbon/human/proc/can_heartattack()
	if((NO_BLOOD in dna.species.species_traits) && !dna.species.forced_heartattack)
		return FALSE
	if(NO_INTORGANS in dna.species.species_traits)
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/undergoing_cardiac_arrest()
	if(!can_heartattack())
		return FALSE

	var/obj/item/organ/internal/heart/heart = get_int_organ(/obj/item/organ/internal/heart)
	if(!istype(heart) || (heart.status & ORGAN_DEAD) || !heart.beating)
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/set_heartattack(status)
	if(!can_heartattack())
		return FALSE

	var/obj/item/organ/internal/heart/heart = get_int_organ(/obj/item/organ/internal/heart)
	if(!istype(heart))
		return FALSE

	heart.beating = !status

/mob/living/carbon/human/handle_heartattack()
	if(!can_heartattack() || !undergoing_cardiac_arrest() || reagents.has_reagent("corazone"))
		return
	if(getOxyLoss())
		adjustBrainLoss(3)
	else if(prob(10))
		adjustBrainLoss(1)
	Weaken(10 SECONDS)
	AdjustLoseBreath(40 SECONDS, bound_lower = 0, bound_upper = 50 SECONDS)
	adjustOxyLoss(20)



// Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
