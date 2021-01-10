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
			domutcheck(src,null)
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

	if(mind?.vampire)
		mind.vampire.handle_vampire()
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
	if(config.auto_cryo_ssd_mins && (player_logged >= (config.auto_cryo_ssd_mins * 30)) && player_logged % 30 == 0)
		var/turf/T = get_turf(src)
		if(!is_station_level(T.z))
			return
		var/area/A = get_area(src)
		cryo_ssd(src)
		if(A.fast_despawn)
			force_cryo_human(src)

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
		if(BLINDNESS in mutations) // Disabled-blind, doesn't get better on its own

		else if(eye_blind)		       // Blindness, heals slowly over time
			AdjustEyeBlind(-1)

		else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold) && eye_blurry)	//resting your eyes with a blindfold heals blurry eyes faster
			AdjustEyeBlurry(-3)

		//blurry sight
		if(vision.is_bruised())   // Vision organs impaired? Permablurry.
			EyeBlurry(2)

		if(eye_blurry)	           // Blurry eyes heal slowly
			AdjustEyeBlurry(-1)

	if(getBrainLoss() >= 60 && stat != DEAD)
		if(prob(3))
			var/list/s1 = list("SOY UN [pick("PONY","LAGARTIJA","taJaran","Gatitu","Vulpakin","drASK","ParJariTo","voxxie","auto de carreras","meCH de COMBATE","naVE EssssssPecial")] [pick("NEEEEEEIIIIIIIIIGH","sKREEEEEE","MEOW","NYA~","rawr","Barkbark","Hissssss","vROOOOOM","pewpew","choo Choo", "BWOINK")]!",
							   "sin oxigeno blob no evolacion?",
							   "CAPITAN CONDON",
							   "[pick("", "ese traidor")] [pick("joerge", "george", "gorge", "gdoruge", "paYaso")] [pick("mellenes", "melones", "mwerlones")] me grifea AYUD;A!!!",
							   "me dan [pick("telikesis","halk","eppilapsia")]?",
							   "THe saiyans screwed",
							   "Bi is LO MEJOR DE DOS MUNDOS",
							   "QUIERO ACARICIAr a los MOnos",
							   "deja de girfiarme!!!!",
							   "ALTO!",
							   "AYUDA SIGURIDAD MAINT",
							   "[src.name] llegar estaci�n",
							   "changling En maint!",
							   "EL chEf pusto [pick("PROTEINA", "agua del INDORO", "Semen", "Einzymas","ARA�AS","nuTrimentos","mUtaGeNO","TeSLium","sKrektonium", "amor")] en mi [pick("sopa","Bullito","ranburgeusa","sOilent GREEn","KoI Susish","yaya")]!",
							   "el mono tiene BRAZOS TASER!",
							   "qM uso MIS pUntos en [pick("escopetas","GuanTEs iNsULadoS","LOTS MASSHEEN!")]",
							   "EI'NATH!",
							   "COmuniDAd de RoL AlteRNATIva",
							   "baMOS a kedar un dia todos y entramos de [pick("FURries", "voxx", "tojARAN", "vuplKNIn")] y entramos a [pick("shittear", "chuPARNOS los PANES", "revolusion")]",
							   "fue [pick("ermano menor!!","PRomEtida","amiGO","orFANATO","interes rom�ntico","esposa","esposo","�i�os peque�os","gato","accidentalmente")]!",
							   "PAYSO ME GOLPPEEA MAINT")

			var/list/s2 = list("FUS RO DAH",
							   "malditas mandarinas!!!",
							   "curame",
							   ">mi cara",
							   "boop",
							   "waaaaaagh!!!",
							   "ke es eso",
							   "PRO EL EMPREADOR",
							   "TEN UN DIA SEGURO!!!!",
							   "los enanos",
							   "SPESS MAHREENS",
							   "kiiero comer krayones",
							   "texstura realista",
							   "el amor puedEEee florcer",
							   "PACKETS!!!",
							   "[pick("donde mi","io nesesite","dame mi","inyeccioneme un poco de.")] [pick("dermaline","alKkyZine","dylOvene","inAprovaline","biCaridine","Hyperzine","kELotane","lePorazine","bAcch Salts","tricord","clOnexazone","hydroChloric Acid","chlorine Hydrate","paRoxetine")]!",
							   "mALPRACTICEBAY",
							   "tengo UNNN doc to ra do en Ejecusion de reecursos y plnaneasion",
							   "a-a-a-ayu-da maint",
							   "ellos viene, ellos VIENEN, ELLOS VIENEN!!!",
							   "EL FINAL ESTA CERCA",
							   "luche i mori por mis [pick("derechos","LIBERTADES","salario","puntoz de kargo","nivel de tech","perros","sirpe de maPLEE","amigoz felpudoss","loot de gatewyyy")]",
							   "me mato [pick("shincurity","le payazoooo","un cluwne","mimo ASASAINO","bertender","kaopitan","changling","borrgk")]!")
			switch(pick(1,2,3))
				if(1)
					say(pick(s1))
				if(2)
					say(pick(s2))
				if(3)
					emote("drool")

/mob/living/carbon/human/handle_mutations_and_radiation()
	for(var/datum/dna/gene/gene in GLOB.dna_genes)
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
			radiation = clamp(radiation, 0, 200)

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
		if(health >= HEALTH_THRESHOLD_CRIT)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS + 1)
		else if(!(NOCRITDAMAGE in dna.species.species_traits))
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
	. = ..()
	if(!.)
		return
	if(HEATRES in mutations)
		return
	var/thermal_protection = get_thermal_protection()

	if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
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

	if(!(NO_HUNGER in dna.species.species_traits))
		if(FAT in mutations)
			if(overeatduration < 100)
				becomeSlim()
		else
			if(overeatduration > 500 && !(NO_OBESITY in dna.species.species_traits))
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
					Jitter(5)
				hunger_rate = 3 * hunger_drain
			adjust_nutrition(-hunger_rate)

		if(nutrition > NUTRITION_LEVEL_FULL)
			if(overeatduration < 600) //capped so people don't take forever to unfat
				overeatduration++

		else
			if(overeatduration > 1)
				if(OBESITY in mutations)
					overeatduration -= 1 // Those with obesity gene take twice as long to unfat
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

	if(drowsyness)
		AdjustDrowsy(-1)
		EyeBlurry(2)
		if(prob(5))
			AdjustSleeping(1)
			Paralyse(5)

	if(confused)
		AdjustConfused(-1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		if(dizziness)
			AdjustDizzy(-15)
		if(jitteriness)
			AdjustJitter(-15)
	else
		if(dizziness)
			AdjustDizzy(-3)
		if(jitteriness)
			AdjustJitter(-3)

	if(NO_INTORGANS in dna.species.species_traits)
		return

	handle_trace_chems()

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
	var/sober_str =! (SOBER in mutations) ? 1 : 2

	alcohol_strength /= sober_str

	var/obj/item/organ/internal/liver/L
	if(!ismachineperson(src))
		L = get_int_organ(/obj/item/organ/internal/liver)
		if(L)
			alcohol_strength *= L.alcohol_intensity
		else
			alcohol_strength *= 5

	if(alcohol_strength >= slur_start) //slurring
		Slur(drunk)
	if(mind)
		if(alcohol_strength >= brawl_start) //the drunken martial art
			if(!istype(mind.martial_art, /datum/martial_art/drunk_brawling))
				var/datum/martial_art/drunk_brawling/F = new
				F.teach(src, TRUE)
		else if(alcohol_strength < brawl_start) //removing the art
			if(istype(mind.martial_art, /datum/martial_art/drunk_brawling))
				mind.martial_art.remove(src)
	if(alcohol_strength >= confused_start && prob(33)) //confused walking
		if(!confused)
			Confused(1)
		AdjustConfused(3 / sober_str)
	if(alcohol_strength >= blur_start) //blurry eyes
		EyeBlurry(10 / sober_str)
	if(!ismachineperson(src)) //stuff only for non-synthetics
		if(alcohol_strength >= vomit_start) //vomiting
			if(prob(8))
				fakevomit()
		if(alcohol_strength >= pass_out)
			Paralyse(5 / sober_str)
			Drowsy(30 / sober_str)
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
		AdjustLoseBreath(10, bound_lower = 0, bound_upper = 25)
		Weaken(30)

	if(!check_death_method())
		if(health <= HEALTH_THRESHOLD_DEAD)
			var/deathchance = min(99, ((getBrainLoss() * -5) + (health + (getOxyLoss() / 2))) * -0.01)
			if(prob(deathchance))
				death()
				return

		if(health <= HEALTH_THRESHOLD_CRIT)
			if(prob(5))
				emote(pick("faint", "collapse", "cry", "moan", "gasp", "shudder", "shiver"))
			AdjustStuttering(5, bound_lower = 0, bound_upper = 5)
			EyeBlurry(5)
			if(prob(7))
				AdjustConfused(2)
			if(prob(5))
				Paralyse(2)
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
					Paralyse(5)
				if(-99 to -80)
					adjustOxyLoss(1)
					if(prob(4))
						to_chat(src, "<span class='userdanger'>Your chest hurts...</span>")
						Paralyse(2)
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
						Weaken(3)
					if(prob(3))
						Paralyse(2)
				if(-49 to 0)
					adjustOxyLoss(1)
					if(prob(3))
						var/datum/disease/D = new /datum/disease/critical/shock
						ForceContractDisease(D)
					if(prob(5))
						to_chat(src, "<span class='userdanger'>You feel [pick("terrible", "awful", "like shit", "sick", "numb", "cold", "sweaty", "tingly", "horrible")]!</span>")
						Weaken(3)

/mob/living/carbon/human/update_health_hud()
	if(!client)
		return
	if(dna.species.update_health_hud())
		return
	else
		if(healths)
			var/health_amount = get_perceived_trauma()
			if(..(health_amount)) //not dead
				switch(hal_screwyhud)
					if(SCREWYHUD_CRIT)
						healths.icon_state = "health6"
					if(SCREWYHUD_DEAD)
						healths.icon_state = "health7"
					if(SCREWYHUD_HEALTHY)
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
					var/damage = O.burn_dam + O.brute_dam
					var/comparison = (O.max_damage/5)
					var/icon_num = 0
					if(damage)
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

/mob/living/carbon/human/proc/handle_nutrition_alerts() //This is a terrible abuse of the alert system; something like this should be a HUD element
	if(NO_HUNGER in dna.species.species_traits)
		return
	if(mind?.vampire && (mind in SSticker.mode.vampires)) //Vampires
		switch(nutrition)
			if(NUTRITION_LEVEL_FULL to INFINITY)
				throw_alert("nutrition", /obj/screen/alert/fat/vampire)
			if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
				throw_alert("nutrition", /obj/screen/alert/full/vampire)
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
				throw_alert("nutrition", /obj/screen/alert/well_fed/vampire)
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				throw_alert("nutrition", /obj/screen/alert/fed/vampire)
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				throw_alert("nutrition", /obj/screen/alert/hungry/vampire)
			else
				throw_alert("nutrition", /obj/screen/alert/starving/vampire)

	else //Any other non-vampires
		switch(nutrition)
			if(NUTRITION_LEVEL_FULL to INFINITY)
				throw_alert("nutrition", /obj/screen/alert/fat)
			if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
				throw_alert("nutrition", /obj/screen/alert/full)
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
				throw_alert("nutrition", /obj/screen/alert/well_fed)
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				throw_alert("nutrition", /obj/screen/alert/fed)
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				throw_alert("nutrition", /obj/screen/alert/hungry)
			else
				throw_alert("nutrition", /obj/screen/alert/starving)

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

	if(NO_DECAY in dna.species.species_traits)
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
			if(NO_BREATHE in H.dna.species.species_traits)
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

/mob/living/carbon/human/handle_heartattack()
	if(!can_heartattack() || !undergoing_cardiac_arrest() || reagents.has_reagent("corazone"))
		return
	if(getOxyLoss())
		adjustBrainLoss(3)
	else if(prob(10))
		adjustBrainLoss(1)
	Weaken(5)
	AdjustLoseBreath(20, bound_lower = 0, bound_upper = 25)
	adjustOxyLoss(20)



// Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
