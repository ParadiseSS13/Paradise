/mob/living/carbon/human/Life(seconds, times_fired)
	life_tick++

	voice = GetVoice()

	if(..())

		if(check_mutations)
			domutcheck(src,null)
			update_mutations()
			check_mutations=0

		handle_shock()
		handle_pain()
		handle_heartbeat()
		handle_heartattack()
		handle_drunk()
		dna.species.handle_life(src)

		if(!client)
			dna.species.handle_npc(src)

	if(stat != DEAD)
		//Stuff jammed in your limbs hurts
		handle_embedded_objects()

	if(stat == DEAD)
		handle_decay()

	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000))	//We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
		return											//We go ahead and process them 5 times for HUD images and other stuff though.

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()
	pulse = handle_pulse(times_fired)

	if(mind && mind.vampire)
		mind.vampire.handle_vampire()
		if(life_tick == 1)
			regenerate_icons() // Make sure the inventory updates

/mob/living/carbon/human/calculate_affecting_pressure(var/pressure)
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
	if(disabilities & EPILEPSY)
		if((prob(1) && paralysis < 1))
			visible_message("<span class='danger'>[src] starts having a seizure!</span>","<span class='alert'>You have a seizure!</span>")
			Paralyse(10)
			Jitter(1000)

	// If we have the gene for being crazy, have random events.
	if(dna.GetSEState(HALLUCINATIONBLOCK))
		if(prob(1))
			Hallucinate(20)

	if(disabilities & COUGHING)
		if((prob(5) && paralysis <= 1))
			drop_item()
			emote("cough")
	if(disabilities & TOURETTES)
		if((prob(10) && paralysis <= 1))
			Stun(10)
			switch(rand(1, 3))
				if(1)
					emote("twitch")
				if(2 to 3)
					var/tourettes = pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")
					say("[prob(50) ? ";" : ""][tourettes]")
			var/x_offset = pixel_x + rand(-2,2) //Should probably be moved into the twitch emote at some point.
			var/y_offset = pixel_y + rand(-1,1)
			animate(src, pixel_x = pixel_x + x_offset, pixel_y = pixel_y + y_offset, time = 1)
			animate(pixel_x = initial(pixel_x) , pixel_y = initial(pixel_y), time = 1)

	if(disabilities & NERVOUS)
		if(prob(10))
			Stuttering(10)

	if(getBrainLoss() >= 60 && stat != DEAD)
		if(prob(3))
			var/list/s1 = list("IM A [pick("PONY","LIZARD","taJaran","kitty","Vulpakin","drASK","BIRDIE","voxxie","race car","combat meCH","SPESSSHIP")] [pick("NEEEEEEIIIIIIIIIGH","sKREEEEEE","MEOW","NYA~","rawr","Barkbark","Hissssss","vROOOOOM","pewpew","choo Choo")]!",
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
							   "et wus my [pick("wittle brother!!","fiancee","friend staying over","entiRe orphanage","love interest","wife","husband","liTTle kids","sentient cAT","accidentally")]!")

			var/list/s2 = list("FUS RO DAH",
							   "fuckin tangerines!!!",
							   "stat me",
							   ">my face",
							   "roll it easy!",
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
							   "[pick("WHERE MY","aYE need","giv me my","bath me inn.")] [pick("dermaline","alKkyZine","dylOvene","inAprovaline","biCaridine","Hyperzine","kELotane","lePorazine","bAcch Salts","tricord","clOnexazone","hydroChloric Acid","chlorine Hydrate","paRoxetine")]!",
							   "mALPRACTICEBAY",
							   "I HavE A pe H dee iN ENTerpriSE resOUrCE pLaNNIN",
							   "h-h-HalP MaINT",
							   "dey come, dey COME! DEY COME!!!",
							   "THE END IS NIGH!",
							   "I FOT AND DIED FOR MUH [pick("RITES","FREEDOM","payCHECK","cARGO points","teCH Level","doG","mAPLe syrup","fluffy fWiends","gateway Loot")]",
							   "KILL DEM [pick("mainTnacE cHickinNS","kiRA CulwnNES","FLOOR CLUWNEs","MIME ASSASSIN","BOMBING TAJARAN","cC offiser","morPhlings","slinglings")]!")
			switch(pick(1,2,3))
				if(1)
					say(pick(s1))
				if(2)
					say(pick(s2))
				if(3)
					emote("drool")

	if(getBrainLoss() >= 100 && stat != DEAD) //you lapse into a coma and die without immediate aid; RIP. -Fox
		Weaken(20)
		AdjustLoseBreath(10)
		AdjustSilence(2)

	if(getBrainLoss() >= 120 && stat != DEAD) //they died from stupidity--literally. -Fox
		visible_message("<span class='alert'><B>[src]</B> goes limp, [p_their()] facial expression utterly blank.</span>")
		death()

/mob/living/carbon/human/handle_mutations_and_radiation()
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			gene.OnMobLife(src)
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

	if(!(RADIMMUNE in dna.species.species_traits))
		if(radiation)
			radiation = Clamp(radiation, 0, 200)

			var/autopsy_damage = 0
			switch(radiation)
				if(1 to 49)
					radiation = max(radiation-1, 0)
					if(prob(25))
						adjustToxLoss(1)
						adjustFireLoss(1)
						autopsy_damage = 2

				if(50 to 74)
					radiation = max(radiation-2, 0)
					adjustToxLoss(1)
					adjustFireLoss(1)
					autopsy_damage = 2
					if(prob(5))
						radiation = max(radiation-5, 0)
						Weaken(3)
						to_chat(src, "<span class='danger'>You feel weak.</span>")
						emote("collapse")

				if(75 to 100)
					radiation = max(radiation-2, 0)
					adjustToxLoss(2)
					adjustFireLoss(2)
					autopsy_damage = 4
					if(prob(2))
						to_chat(src, "<span class='danger'>You mutate!</span>")
						randmutb(src)
						domutcheck(src, null)

				if(101 to 150)
					radiation = max(radiation-3, 0)
					adjustToxLoss(2)
					adjustFireLoss(3)
					autopsy_damage = 5
					if(prob(4))
						to_chat(src, "<span class='danger'>You mutate!</span>")
						randmutb(src)
						domutcheck(src, null)

				if(151 to INFINITY)
					radiation = max(radiation-3, 0)
					adjustToxLoss(2)
					adjustFireLoss(3)
					autopsy_damage = 5
					if(prob(6))
						to_chat(src, "<span class='danger'>You mutate!</span>")
						randmutb(src)
						domutcheck(src, null)

			if(autopsy_damage)
				var/obj/item/organ/external/chest/chest = get_organ("chest")
				if(chest)
					chest.add_autopsy_data("Radiation Poisoning", autopsy_damage)

/mob/living/carbon/human/breathe()
	if(!dna.species.breathe(src))
		..()

/mob/living/carbon/human/check_breath(datum/gas_mixture/breath)

	var/obj/item/organ/internal/L = get_organ_slot("lungs")

	if(!L || L && (L.status & ORGAN_DEAD))
		if(health >= config.health_threshold_crit)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS + 1)
		else if(!(NOCRITDAMAGE in dna.species.species_traits))
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		failed_last_breath = TRUE

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
	return health <= 0 && stat != 2


/mob/living/carbon/human/get_breath_from_internal(volume_needed) //making this call the parent would be far too complicated
	if(internal)
		var/null_internals = 0      //internals are invalid, therefore turn them off
		var/skip_contents_check = 0 //rigsuit snowflake, oxygen tanks aren't stored inside the mob, so the 'contents.Find' check has to be skipped.

		if(!get_organ_slot("breathing_tube"))
			if(!(wear_mask && wear_mask.flags & AIRTIGHT)) //if NOT (wear_mask AND wear_mask.flags CONTAIN AIRTIGHT)
				if(!(head && head.flags & AIRTIGHT)) //if NOT (head AND head.flags CONTAIN AIRTIGHT)
					null_internals = 1 //not wearing a mask or suitable helmet

		if(istype(back, /obj/item/rig)) //wearing a rigsuit
			var/obj/item/rig/rig = back //needs to be typecasted because this doesn't use get_rig() for some reason
			if(rig.offline && (rig.air_supply && internal == rig.air_supply)) //if rig IS offline AND (rig HAS air_supply AND internal IS air_supply)
				null_internals = 1 //offline suits do not breath

			else if(rig.air_supply && internal == rig.air_supply) //if rig HAS air_supply AND internal IS rig air_supply
				skip_contents_check = 1 //skip contents.Find() check, the oxygen is valid even being outside of the mob

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
		var/mult = dna.species.heatmod

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
			return 1
		if(stat == DEAD)
			return 1

		if(!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/mult = dna.species.coldmod
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
		if(!(HEATRES in mutations))
			var/pressure_damage = min( ( (adjusted_pressure / dna.species.hazard_high_pressure) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE)
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
		if(COLDRES in mutations)
			clear_alert("pressure")
		else
			take_overall_damage(brute=LOW_PRESSURE_DAMAGE, updating_health = TRUE, used_weapon = "Low Pressure")
			throw_alert("pressure", /obj/screen/alert/lowpressure, 2)


///FIRE CODE
/mob/living/carbon/human/handle_fire()
	if(..())
		return
	if(HEATRES in mutations)
		return
	if(on_fire)
		var/thermal_protection = get_thermal_protection()

		if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
			return
		if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT)
			bodytemperature += 11
		else
			bodytemperature += (BODYTEMP_HEATING_MAX + (fire_stacks * 12))

/mob/living/carbon/human/proc/get_thermal_protection()
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

	if(HEATRES in mutations)
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

	if(COLDRES in mutations)
		return 1 //Fully protected from the cold.

	temperature = max(temperature, 2.7) //There is an occasional bug where the temperature is miscalculated in ares with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
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

	//The fucking FAT mutation is the greatest shit ever. It makes everyone so hot and bothered.
	if(CAN_BE_FAT in dna.species.species_traits)
		if(FAT in mutations)
			if(overeatduration < 100)
				becomeSlim()
		else
			if(overeatduration > 500)
				becomeFat()

	// nutrition decrease
	if(nutrition > 0 && stat != DEAD)
		// THEY HUNGER
		var/hunger_rate = hunger_drain
		if(satiety > 0)
			satiety--
		if(satiety < 0)
			satiety++
			if(prob(round(-satiety/40)))
				Jitter(5)
			hunger_rate = 3 * hunger_drain
		nutrition = max(0, nutrition - hunger_rate)

	if(nutrition > NUTRITION_LEVEL_FULL)
		if(overeatduration < 600) //capped so people don't take forever to unfat
			overeatduration++

	else
		if(overeatduration > 1)
			if(OBESITY in mutations)
				overeatduration -= 1 // Those with obesity gene take twice as long to unfat
			else
				overeatduration -= 2

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

	if(drowsyness)
		AdjustDrowsy(-1)
		EyeBlurry(2)
		if(prob(5))
			AdjustSleeping(1)
			Paralyse(5)

	AdjustConfused(-1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		AdjustDizzy(-15)
		AdjustJitter(-15)
	else
		AdjustDizzy(-3)
		AdjustJitter(-3)

	if(NO_INTORGANS in dna.species.species_traits)
		return

	handle_trace_chems()

	return //TODO: DEFERRED

/mob/living/carbon/human/handle_drunk()
	var/slur_start = 30 //12u ethanol, 30u whiskey FOR HUMANS
	var/confused_start = 40
	var/brawl_start = 30
	var/blur_start = 75
	var/vomit_start = 60
	var/pass_out = 90
	var/spark_start = 50 //40u synthanol
	var/collapse_start = 75
	var/braindamage_start = 120
	var/alcohol_strength = drunk
	var/sober_str=!(SOBER in mutations)?1:2

	if(drunk)
		alcohol_strength/=sober_str

		var/obj/item/organ/internal/liver/L
		if(!isSynthetic())
			L = get_int_organ(/obj/item/organ/internal/liver)
			if(L)
				alcohol_strength *= L.alcohol_intensity
			else
				alcohol_strength *= 5

		if(alcohol_strength >= slur_start) //slurring
			Slur(drunk)
		if(alcohol_strength >= brawl_start) //the drunken martial art
			if(!istype(martial_art, /datum/martial_art/drunk_brawling))
				var/datum/martial_art/drunk_brawling/F = new
				F.teach(src,1)
		if(alcohol_strength < brawl_start) //removing the art
			if(istype(martial_art, /datum/martial_art/drunk_brawling))
				martial_art.remove(src)
		if(alcohol_strength >= confused_start && prob(33)) //confused walking
			if(!confused) Confused(1)
			AdjustConfused(3/sober_str)
		if(alcohol_strength >= blur_start) //blurry eyes
			EyeBlurry(10/sober_str)
		if(!isSynthetic()) //stuff only for non-synthetics
			if(alcohol_strength >= vomit_start) //vomiting
				if(prob(8))
					fakevomit()
			if(alcohol_strength >= pass_out)
				Paralyse(5/sober_str)
				Drowsy(30/sober_str)
				if(L)
					L.receive_damage(0.1, 1)
				adjustToxLoss(0.1)
		else //stuff only for synthetics
			if(alcohol_strength >= spark_start && prob(25))
				do_sparks(3, 1, src)
			if(alcohol_strength >= collapse_start && prob(10))
				emote("collapse")
				do_sparks(3, 1, src)
			if(alcohol_strength >= braindamage_start && prob(10))
				adjustBrainLoss(1)

	if(!has_booze())
		AdjustDrunk(-0.5)
	return

/mob/living/carbon/human/proc/has_booze() //checks if the human has ethanol or its subtypes inside
	for(var/A in reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/consumable/ethanol))
			return 1
	return 0

/mob/living/carbon/human/handle_regular_status_updates()
	if(status_flags & GODMODE)
		return 0

	. = ..()

	if(.) //alive
		if(REGEN in mutations)
			heal_overall_damage(0.1, 0.1)

		if(paralysis)
			stat = UNCONSCIOUS

		else if(sleeping)

			stat = UNCONSCIOUS

			if(mind)
				if(mind.vampire)
					if(istype(loc, /obj/structure/closet/coffin))
						adjustBruteLoss(-1)
						adjustFireLoss(-1)
						adjustToxLoss(-1)

		else if(status_flags & FAKEDEATH)
			stat = UNCONSCIOUS

		//Vision //god knows why this is here
		var/obj/item/organ/vision
		if(dna.species.vision_organ)
			vision = get_int_organ(dna.species.vision_organ)

		if(!dna.species.vision_organ) // Presumably if a species has no vision organs, they see via some other means.
			SetEyeBlind(0)
			SetEyeBlurry(0)

		else if(!vision || vision.is_broken())   // Vision organs cut out or broken? Permablind.
			EyeBlind(2)
			EyeBlurry(2)

		else
			//blindness
			if(disabilities & BLIND) // Disabled-blind, doesn't get better on its own

			else if(eye_blind)		       // Blindness, heals slowly over time
				AdjustEyeBlind(-1)

			else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold))	//resting your eyes with a blindfold heals blurry eyes faster
				AdjustEyeBlurry(-3)

			//blurry sight
			if(vision.is_bruised())   // Vision organs impaired? Permablurry.
				EyeBlurry(2)

			if(eye_blurry)	           // Blurry eyes heal slowly
				AdjustEyeBlurry(-1)


		if(flying)
			animate(src, pixel_y = pixel_y + 5 , time = 10, loop = 1, easing = SINE_EASING)
			animate(pixel_y = pixel_y - 5, time = 10, loop = 1, easing = SINE_EASING)

		// If you're dirty, your gloves will become dirty, too.
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1

		handle_organs()


	else //dead
		SetSilence(0)


/mob/living/carbon/human/handle_vision()
	if(machine)
		if(!machine.check_eye(src))
			reset_perspective(null)
	else
		var/isRemoteObserve = 0
		if((REMOTE_VIEW in mutations) && remoteview_target)
			isRemoteObserve = 1

			if(remoteview_target.stat != CONSCIOUS)
				to_chat(src, "<span class='alert'>Your psy-connection grows too faint to maintain!</span>")
				isRemoteObserve = 0

			if(PSY_RESIST in remoteview_target.mutations)
				to_chat(src, "<span class='alert'>Your mind is shut out!</span>")
				isRemoteObserve = 0

			// Not on the station or mining?
			var/turf/temp_turf = get_turf(remoteview_target)
			if(!temp_turf in config.contact_levels)
				to_chat(src, "<span class='alert'>Your psy-connection grows too faint to maintain!</span>")
				isRemoteObserve = 0

		if(remote_view)
			isRemoteObserve = 1

		if(!isRemoteObserve && client && !client.adminobs)
			remoteview_target = null
			reset_perspective(null)

/mob/living/carbon/human/handle_hud_icons()
	dna.species.handle_hud_icons(src)

/mob/living/carbon/human/handle_hud_icons_health()
	dna.species.handle_hud_icons_health(src)
	handle_hud_icons_health_overlay()

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
				BP.embedded_objects -= I
				I.forceMove(get_turf(src))
				visible_message("<span class='danger'>[I] falls out of [name]'s [BP.name]!</span>","<span class='userdanger'>[I] falls out of your [BP.name]!</span>")
				if(!has_embedded_objects())
					clear_alert("embeddedobject")

/mob/living/carbon/human/handle_changeling()
	if(mind)
		if(mind.changeling)
			mind.changeling.regenerate(src)
			if(hud_used)
				hud_used.lingchemdisplay.invisibility = 0
				hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(mind.changeling.chem_charges)]</font></div>"
		else
			if(hud_used)
				hud_used.lingchemdisplay.invisibility = 101


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
		temp = PULSE_THREADY	//not enough :(

	if(status_flags & FAKEDEATH)
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

	if(isSynthetic())
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
				return
			if(NO_BREATHE in H.dna.species.species_traits)
				return //no puking if you can't smell!
			// Humans can lack a mind datum, y'know
			if(H.mind && (H.mind.assigned_role == "Detective" || H.mind.assigned_role == "Coroner"))
				return //too cool for puke
			to_chat(H, "<span class='warning'>You smell something foul...</span>")
			H.fakevomit()

/mob/living/carbon/human/proc/handle_heartbeat()
	var/client/C = src.client
	if(C && C.prefs.sound & SOUND_HEARTBEAT) //disable heartbeat by pref
		var/obj/item/organ/internal/heart/H = get_int_organ(/obj/item/organ/internal/heart)

		if(!H) //H.status will runtime if there is no H (obviously)
			return

		if(H.is_robotic()) //Handle robotic hearts specially with a wuuuubb. This also applies to machine-people.
			if(shock_stage >= 10 || istype(get_turf(src), /turf/space))
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

		if(pulse >= PULSE_2FAST || shock_stage >= 10 || istype(get_turf(src), /turf/space))
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
	if(NO_BLOOD in dna.species.species_traits)
		return FALSE
	if(NO_INTORGANS in dna.species.species_traits)
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/undergoing_cardiac_arrest()
	if(!can_heartattack())
		return FALSE
	var/obj/item/organ/internal/heart/heart = get_int_organ(/obj/item/organ/internal/heart)
	if(istype(heart))
		if(heart.status & ORGAN_DEAD)
			return TRUE
		if(heart.beating)
			return FALSE
	return TRUE

/mob/living/carbon/human/proc/set_heartattack(status)
	if(!can_heartattack())
		return FALSE

	var/obj/item/organ/internal/heart/heart = get_int_organ(/obj/item/organ/internal/heart)
	if(!istype(heart))
		return FALSE

	heart.beating = !status

/mob/living/carbon/human/proc/handle_heartattack()
	if(!can_heartattack() || !undergoing_cardiac_arrest() || reagents.has_reagent("corazone"))
		return
	AdjustLoseBreath(2, bound_lower = 0, bound_upper = 3)
	adjustOxyLoss(5)
	Paralyse(4)
	adjustBruteLoss(2)



// Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
