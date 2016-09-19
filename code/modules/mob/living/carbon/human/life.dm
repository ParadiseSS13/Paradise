//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

#define TINT_IMPAIR 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully

/mob/living/carbon/human

	var/pressure_alert = 0
	var/prev_gender = null // Debug for plural genders
	var/temperature_alert = 0
	var/in_stasis = 0
	var/exposedtimenow = 0
	var/firstexposed = 0
	var/heartbeat = 0
	var/tinttotal = 0				// Total level of visually impairing items

/mob/living/carbon/human/Life()
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.
	tinttotal = tintcheck() //here as both hud updates and status updates call it
	life_tick++

	in_stasis = 0
	if(istype(loc, /obj/structure/closet/body_bag/cryobag))
		var/obj/structure/closet/body_bag/cryobag/loc_as_cryobag = loc
		if(!loc_as_cryobag.opened)
			loc_as_cryobag.used++
			in_stasis = 1

	voice = GetVoice()

	if(..() && !in_stasis)

		if(check_mutations)
			domutcheck(src,null)
			update_mutations()
			check_mutations=0

		handle_shock()
		handle_pain()
		handle_heartbeat()
		handle_heartattack()
		handle_drunk()
		species.handle_life(src)

		if(!client)
			species.handle_npc(src)

	if(stat == DEAD)
		handle_decay()

	handle_stasis_bag()

	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000))	//We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
		return											//We go ahead and process them 5 times for HUD images and other stuff though.

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()
	pulse = handle_pulse()

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
		if(prob(1) && hallucination < 1)
			hallucination += 20

	if(disabilities & COUGHING)
		if((prob(5) && paralysis <= 1))
			drop_item()
			emote("cough")
	if(disabilities & TOURETTES)
		speech_problem_flag = 1
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
		speech_problem_flag = 1
		if(prob(10))
			stuttering = max(10, stuttering)

	if(getBrainLoss() >= 60 && stat != 2)
		speech_problem_flag = 1
		if(prob(3))
			var/list/s1 = list("IM A PONY NEEEEEEIIIIIIIIIGH",
							   "without oxigen blob don't evoluate?",
							   "CAPTAINS A COMDOM",
							   "[pick("", "that damn traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!",
							   "can u give me [pick("telikesis","halk","eppilapse")]?",
							   "THe saiyans screwed",
							   "Bi is THE BEST OF BOTH WORLDS>",
							   "I WANNA PET TEH monkeyS",
							   "stop grifing me!!!!",
							   "SOTP IT#")

			var/list/s2 = list("FUS RO DAH",
							   "fucking 4rries!",
							   "stat me",
							   ">my face",
							   "roll it easy!",
							   "waaaaaagh!!!",
							   "red wonz go fasta",
							   "FOR TEH EMPRAH",
							   "lol2cat",
							   "dem dwarfs man, dem dwarfs",
							   "SPESS MAHREENS",
							   "hwee did eet fhor khayosss",
							   "lifelike texture ;_;",
							   "luv can bloooom",
							   "PACKETS!!!")
			switch(pick(1,2,3))
				if(1)
					say(pick(s1))
				if(2)
					say(pick(s2))
				if(3)
					emote("drool")

	if(getBrainLoss() >= 100 && stat != 2) //you lapse into a coma and die without immediate aid; RIP. -Fox
		Weaken(20)
		losebreath += 10
		silent += 2

	if(getBrainLoss() >= 120 && stat != 2) //they died from stupidity--literally. -Fox
		visible_message("<span class='alert'><B>[src]</B> goes limp, their facial expression utterly blank.</span>")
		death()

/mob/living/carbon/human/proc/handle_stasis_bag()
	// Handle side effects from stasis bag
	if(in_stasis)
		// First off, there's no oxygen supply, so the mob will slowly take brain damage
		adjustBrainLoss(0.1)

		// Next, the method to induce stasis has some adverse side-effects, manifesting
		// as cloneloss
		adjustCloneLoss(0.1)

/mob/living/carbon/human/handle_mutations_and_radiation()
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			speech_problem_flag = 1
			gene.OnMobLife(src)
	if(gene_stability < GENETIC_DAMAGE_STAGE_1)
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

	if(!(species.flags & RADIMMUNE))
		if(radiation)

			if(get_int_organ(/obj/item/organ/internal/nucleation/resonant_crystal))
				var/rads = radiation/25
				radiation -= rads
				radiation -= 0.1
				reagents.add_reagent("radium", rads/10)
				if( prob(10) )
					to_chat(src, "<span class='notice'>You feel relaxed.</span>")
				return

			if(radiation > 100)
				radiation = 100
				Weaken(10)
				if(!lying)
					to_chat(src, "<span class='alert'>You feel weak.</span>")
					emote("collapse")

			if(radiation < 0)
				radiation = 0

			else
				var/damage = 0
				switch(radiation)
					if(0 to 49)
						radiation--
						if(prob(25))
							adjustToxLoss(1)
							damage = 1
							updatehealth()

					if(50 to 74)
						radiation -= 2
						damage = 1
						adjustToxLoss(1)
						if(prob(5))
							radiation -= 5
							Weaken(3)
							if(!lying)
								to_chat(src, "<span class='alert'>You feel weak.</span>")
								emote("collapse")
						updatehealth()

					if(75 to 100)
						radiation -= 3
						adjustToxLoss(3)
						damage = 3
						if(prob(1))
							to_chat(src, "<span class='alert'>You mutate!</span>")
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						updatehealth()

					else
						radiation -= 5
						adjustToxLoss(5)
						damage = 5
						if(prob(1))
							to_chat(src, "<span class='alert'>You mutate!</span>")
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						updatehealth()

				if(damage && organs.len)
					var/obj/item/organ/external/O = pick(organs)
					if(istype(O)) O.add_autopsy_data("Radiation Poisoning", damage)

/mob/living/carbon/human/breathe()

	if((NO_BREATH in mutations) || (species && (species.flags & NO_BREATHE)) || reagents.has_reagent("lexorin"))
		adjustOxyLoss(-5)
		oxygen_alert = 0
		toxins_alert = 0
		return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(health <= config.health_threshold_crit)
		losebreath++

	if(losebreath > 0)
		losebreath--
		if(prob(10))
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src, 0)
	else
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(!breath)
			if(isobj(loc)) //Breathe from loc as object
				var/obj/loc_as_obj = loc
				breath = loc_as_obj.handle_internal_lifeform(src, BREATH_MOLES)

			else if(isturf(loc)) //Breathe from loc as turf
				var/breath_moles = 0
				if(environment)
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)

				if(!is_lung_ruptured())																					// THIS FUCKING EXCERPT, THIS LITTLE FUCKING EXCERPT, SNOWFLAKED
					if(!breath || breath.total_moles() < BREATH_MOLES / 5 || breath.total_moles() > BREATH_MOLES * 5)	// RIGHT IN THE CENTER OF THE FUCKING BREATHE PROC
						if(prob(5))																						// IT IS THE ONLY FUCKING REASONS HUMAN OVERRIDE breathe()
							rupture_lung()																				// GOD FUCKING DAMNIT

		else //Breathe from loc as obj again
			if(istype(loc, /obj/))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	check_breath(breath)

	if(breath)
		loc.assume_air(breath)


// USED IN DEATHWHISPERS
/mob/living/carbon/human/proc/isInCrit()
	// Health is in deep shit and we're not already dead
	return health <= 0 && stat != 2


/mob/living/carbon/human/get_breath_from_internal(volume_needed) //making this call the parent would be far too complicated
	if(internal)
		var/null_internals = 0      //internals are invalid, therefore turn them off
		var/skip_contents_check = 0 //rigsuit snowflake, oxygen tanks aren't stored inside the mob, so the 'contents.Find' check has to be skipped.

		if(!(wear_mask && wear_mask.flags & AIRTIGHT)) //if NOT (wear_mask AND wear_mask.flags CONTAIN AIRTIGHT)
			if(!(head && head.flags & AIRTIGHT)) //if NOT (head AND head.flags CONTAIN AIRTIGHT)
				null_internals = 1 //not wearing a mask or suitable helmet

		if(istype(back, /obj/item/weapon/rig)) //wearing a rigsuit
			var/obj/item/weapon/rig/rig = back //needs to be typecasted because this doesn't use get_rig() for some reason
			if(rig.offline && (rig.air_supply && internal == rig.air_supply)) //if rig IS offline AND (rig HAS air_supply AND internal IS air_supply)
				null_internals = 1 //offline suits do not breath

			else if(rig.air_supply && internal == rig.air_supply) //if rig HAS air_supply AND internal IS rig air_supply
				skip_contents_check = 1 //skip contents.Find() check, the oxygen is valid even being outside of the mob

		if(!contents.Find(internal) && (!skip_contents_check)) //if internal NOT IN contents AND skip_contents_check IS false
			null_internals = 1 //not a rigsuit and your oxygen is gone

		if(null_internals) //something wants internals gone
			internal = null //so do it


	if(internal) //check for hud updates every time this is called
		update_internals_hud_icon(1)
		return internal.remove_air_volume(volume_needed) //returns the valid air
	else
		update_internals_hud_icon(0)

	return null

/mob/living/carbon/human/check_breath(var/datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return 0

	if(!breath || (breath.total_moles() == 0) || suiciding)
		var/oxyloss = 0
		if(suiciding)
			oxyloss = 2
			adjustOxyLoss(oxyloss)//If you are suiciding, you should die a little bit faster
			failed_last_breath = 1
			oxygen_alert = max(oxygen_alert, 1)
			return 0
		if(health > 0)
			oxyloss = HUMAN_MAX_OXYLOSS
			adjustOxyLoss(oxyloss)
			failed_last_breath = 1
		else
			oxyloss = HUMAN_CRIT_MAX_OXYLOSS
			adjustOxyLoss(oxyloss)
			failed_last_breath = 1

		var/obj/item/organ/external/affected = get_organ("chest")
		affected.add_autopsy_data("Suffocation", oxyloss)
		throw_alert("oxy", /obj/screen/alert/oxy)

		return 0

	return species.handle_breath(breath, src)

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
	if(bodytemperature > species.heat_level_1)
		//Body temperature is too hot.
		if(status_flags & GODMODE)	return 1	//godmode
		var/mult = species.hot_env_multiplier

		if(bodytemperature >= species.heat_level_1 && bodytemperature <= species.heat_level_2)
			throw_alert("temp", /obj/screen/alert/hot, 1)
			take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_1, used_weapon = "High Body Temperature")
		if(bodytemperature > species.heat_level_2 && bodytemperature <= species.heat_level_3)
			throw_alert("temp", /obj/screen/alert/hot, 2)
			take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_2, used_weapon = "High Body Temperature")
		if(bodytemperature > species.heat_level_3 && bodytemperature < INFINITY)
			throw_alert("temp", /obj/screen/alert/hot, 3)
			if(on_fire)
				take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_3, used_weapon = "Fire")
			else
				take_overall_damage(burn=mult*HEAT_DAMAGE_LEVEL_2, used_weapon = "High Body Temperature")

	else if(bodytemperature < species.cold_level_1)
		if(status_flags & GODMODE)
			return 1
		if(stat == DEAD)
			return 1

		if(!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/mult = species.cold_env_multiplier
			if(bodytemperature >= species.cold_level_2 && bodytemperature <= species.cold_level_1)
				throw_alert("temp", /obj/screen/alert/cold, 1)
				take_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_1, used_weapon = "Low Body Temperature")
			if(bodytemperature >= species.cold_level_3 && bodytemperature < species.cold_level_2)
				throw_alert("temp", /obj/screen/alert/cold, 2)
				take_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_2, used_weapon = "Low Body Temperature")
			if(bodytemperature > -INFINITY && bodytemperature < species.cold_level_3)
				throw_alert("temp", /obj/screen/alert/cold, 3)
				take_overall_damage(burn=mult*COLD_DAMAGE_LEVEL_3, used_weapon = "Low Body Temperature")
			else
				clear_alert("temp")
	else
		clear_alert("temp")

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	if(status_flags & GODMODE)	return 1	//godmode

	if(adjusted_pressure >= species.hazard_high_pressure)
		if(!(RESIST_HEAT in mutations))
			var/pressure_damage = min( ( (adjusted_pressure / species.hazard_high_pressure) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE)
			take_overall_damage(brute=pressure_damage, used_weapon = "High Pressure")
			throw_alert("pressure", /obj/screen/alert/highpressure, 2)
		else
			clear_alert("pressure")
	else if(adjusted_pressure >= species.warning_high_pressure)
		throw_alert("pressure", /obj/screen/alert/highpressure, 1)
	else if(adjusted_pressure >= species.warning_low_pressure)
		clear_alert("pressure")
	else if(adjusted_pressure >= species.hazard_low_pressure)
		throw_alert("pressure", /obj/screen/alert/lowpressure, 1)
	else
		if(RESIST_COLD in mutations)
			clear_alert("pressure")
		else
			take_overall_damage(brute=LOW_PRESSURE_DAMAGE, used_weapon = "Low Pressure")
			throw_alert("pressure", /obj/screen/alert/lowpressure, 2)


///FIRE CODE
/mob/living/carbon/human/handle_fire()
	if(..())
		return
	if(RESIST_HEAT in mutations)
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
	if(bodytemperature <= species.cold_level_1) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
		if(nutrition >= 2) //If we are very, very cold we'll use up quite a bit of nutriment to heat us up.
			nutrition -= 2
		var/body_temperature_difference = species.body_temperature - bodytemperature
		bodytemperature += max((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
	if(bodytemperature >= species.cold_level_1 && bodytemperature <= species.heat_level_1)
		var/body_temperature_difference = species.body_temperature - bodytemperature
		bodytemperature += body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR
	if(bodytemperature >= species.heat_level_1) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
		//We totally need a sweat system cause it totally makes sense...~
		var/body_temperature_difference = species.body_temperature - bodytemperature
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

	if(RESIST_HEAT in mutations)
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

	if(RESIST_COLD in mutations)
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
	if(species.flags & CAN_BE_FAT)
		if(FAT in mutations)
			if(overeatduration < 100)
				becomeSlim()
		else
			if(overeatduration > 500)
				becomeFat()

	// nutrition decrease
	if(nutrition > 0 && stat != 2)
		nutrition = max (0, nutrition - HUNGER_FACTOR)

	if(nutrition > 450)
		if(overeatduration < 800) //capped so people don't take forever to unfat
			overeatduration++

	else
		if(overeatduration > 1)
			if(OBESITY in mutations)
				overeatduration -= 1 // Those with obesity gene take twice as long to unfat
			else
				overeatduration -= 2

	if(drowsyness)
		drowsyness--
		eye_blurry = max(2, eye_blurry)
		if(prob(5))
			sleeping += 1
			Paralyse(5)

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 15)
		jitteriness = max(0, jitteriness - 15)
	else
		dizziness = max(0, dizziness - 3)
		jitteriness = max(0, jitteriness - 3)

	if(species && species.flags & NO_INTORGANS) return

	handle_trace_chems()

	updatehealth()

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
			if(!slurring) slurring = 1
			slurring = drunk
		if(alcohol_strength >= brawl_start) //the drunken martial art
			if(!istype(martial_art, /datum/martial_art/drunk_brawling))
				var/datum/martial_art/drunk_brawling/F = new
				F.teach(src,1)
		if(alcohol_strength < brawl_start) //removing the art
			if(istype(martial_art, /datum/martial_art/drunk_brawling))
				martial_art.remove(src)
		if(alcohol_strength >= confused_start && prob(33)) //confused walking
			if(!confused) confused = 1
			confused = max(confused+(3/sober_str),0)
		if(alcohol_strength >= blur_start) //blurry eyes
			eye_blurry = max(eye_blurry, 10/sober_str)
			drowsyness  = max(drowsyness, 0)
		if(!isSynthetic()) //stuff only for non-synthetics
			if(alcohol_strength >= vomit_start) //vomiting
				if(prob(8))
					fakevomit()
			if(alcohol_strength >= pass_out)
				Paralyse(5 / sober_str)
				drowsyness = max(drowsyness, 30/sober_str)
				if(L)
					L.take_damage(0.1, 1)
				adjustToxLoss(0.1)
		else //stuff only for synthetics
			if(alcohol_strength >= spark_start && prob(25))
				var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
			if(alcohol_strength >= collapse_start && prob(10))
				emote("collapse")
				var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
			if(alcohol_strength >= braindamage_start && prob(10))
				adjustBrainLoss(1)

	if(!has_booze())
		AdjustDrunk(-0.5)
	return

/mob/living/carbon/human/proc/has_booze() //checks if the human has ethanol or its subtypes inside
	for(var/A in reagents.reagent_list)
		var/datum/reagent/R = A
		if(istype(R, /datum/reagent/ethanol))
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
			blinded = 1
			stat = UNCONSCIOUS

		else if(sleeping)
			speech_problem_flag = 1

			blinded = 1
			stat = UNCONSCIOUS

			if(mind)
				if(mind.vampire)
					if(istype(loc, /obj/structure/closet/coffin))
						adjustBruteLoss(-1)
						adjustFireLoss(-1)
						adjustToxLoss(-1)

		else if(status_flags & FAKEDEATH)
			blinded = 1
			stat = UNCONSCIOUS

		if(embedded_flag && !(mob_master.current_cycle % 10))
			var/list/E
			E = get_visible_implants(0)
			if(!E.len)
				embedded_flag = 0


		//Vision //god knows why this is here
		var/obj/item/organ/vision
		if(species.vision_organ)
			vision = get_int_organ(species.vision_organ)

		if(!species.vision_organ) // Presumably if a species has no vision organs, they see via some other means.
			eye_blind =  0
			blinded =    0
			eye_blurry = 0

		else if(!vision || vision.is_broken())   // Vision organs cut out or broken? Permablind.
			eye_blind =  1
			blinded =    1
			eye_blurry = 1

		else
			//blindness
			if(disabilities & BLIND) // Disabled-blind, doesn't get better on its own
				blinded =    1

			else if(eye_blind)		       // Blindness, heals slowly over time
				eye_blind =  max(eye_blind-1,0)
				blinded =    1

			else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold))	//resting your eyes with a blindfold heals blurry eyes faster
				eye_blurry = max(eye_blurry-3, 0)
				blinded =    1

			//blurry sight
			if(vision.is_bruised())   // Vision organs impaired? Permablurry.
				eye_blurry = 1

			if(eye_blurry)	           // Blurry eyes heal slowly
				eye_blurry = max(eye_blurry-1, 0)


		//Ears
		if(disabilities & DEAF)	//disabled-deaf, doesn't get better on its own
			setEarDamage(-1, max(ear_deaf, 1))

		else if(ear_deaf)			//deafness, heals slowly over time
			adjustEarDamage(0,-1)

		else if(istype(l_ear, /obj/item/clothing/ears/earmuffs) || istype(r_ear, /obj/item/clothing/ears/earmuffs))	//resting your ears with earmuffs heals ear damage faster
			adjustEarDamage(-0.15,0)
			setEarDamage(-1, max(ear_deaf, 1))

		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			adjustEarDamage(-0.05,0)

		if(flying)
			animate(src, pixel_y = pixel_y + 5 , time = 10, loop = 1, easing = SINE_EASING)
			animate(pixel_y = pixel_y - 5, time = 10, loop = 1, easing = SINE_EASING)

		// If you're dirty, your gloves will become dirty, too.
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1

		if(!in_stasis)
			handle_organs()
			handle_blood()


	else //dead
		blinded = 1
		silent = 0


/mob/living/carbon/human/handle_vision()
	if(machine)
		if(!machine.check_eye(src))		reset_view(null)
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
			reset_view(null)

	species.handle_vision(src)

/mob/living/carbon/human/handle_hud_icons()
	species.handle_hud_icons(src)

/mob/living/carbon/human/handle_random_events()
	// Puke if toxloss is too high
	if(!stat)
		if(getToxLoss() >= 45 && nutrition > 20)
			lastpuke ++
			if(lastpuke >= 25) // about 25 second delay I guess
				Stun(5)

				visible_message("<span class='danger'>[src] throws up!</span>", \
						"<span class='userdanger'>[src] throws up!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

				var/turf/location = loc
				if(istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1)

				nutrition -= 20
				adjustToxLoss(-3)

				// make it so you can only puke so fast
				lastpuke = 0

	//0.1% chance of playing a scary sound to someone who's in complete darkness
	if(isturf(loc) && rand(1,1000) == 1)
		var/turf/currentTurf = loc
		var/atom/movable/lighting_overlay/L = locate(/atom/movable/lighting_overlay) in currentTurf
		if(L && L.lum_r + L.lum_g + L.lum_b == 0)
			playsound_local(src,pick(scarySounds),50, 1, -1)

/mob/living/carbon/human/handle_changeling()
	if(mind)
		if(mind.changeling)
			mind.changeling.regenerate()
			if(hud_used)
				hud_used.lingchemdisplay.invisibility = 0
				hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(mind.changeling.chem_charges)]</font></div>"
		else
			if(hud_used)
				hud_used.lingchemdisplay.invisibility = 101

/mob/living/carbon/human/handle_shock()
	..()
	if(status_flags & GODMODE)
		return 0	//godmode
	if(species && species.flags & NO_PAIN)
		return

	if(health <= config.health_threshold_softcrit)// health 0 makes you immediately collapse
		shock_stage = max(shock_stage, 61)

	if(traumatic_shock >= 100)
		shock_stage += 1
	else
		shock_stage = min(shock_stage, 160)
		shock_stage = max(shock_stage-1, 0)
		return

	if(shock_stage == 10)
		to_chat(src, "<font color='red'><b>"+pick("It hurts so much!", "You really need some painkillers..", "Dear god, the pain!"))

	if(shock_stage >= 30)
		if(shock_stage == 30) custom_emote(1,"is having trouble keeping their eyes open.")
		eye_blurry = max(2, eye_blurry)
		stuttering = max(stuttering, 5)

	if(shock_stage == 40)
		to_chat(src, "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!"))

	if(shock_stage >=60)
		if(shock_stage == 60) custom_emote(1,"falls limp.")
		if(prob(2))
			to_chat(src, "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!"))
			Weaken(20)

	if(shock_stage >= 80)
		if(prob(5))
			to_chat(src, "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!"))
			Weaken(20)

	if(shock_stage >= 120)
		if(prob(2))
			to_chat(src, "<font color='red'><b>"+pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness."))
			Paralyse(5)

	if(shock_stage == 150)
		custom_emote(1,"can no longer stand, collapsing!")
		Weaken(20)

	if(shock_stage >= 150)
		Weaken(20)


/mob/living/carbon/human/proc/handle_pulse()

	if(mob_master.current_cycle % 5)
		return pulse	//update pulse every 5 life ticks (~1 tick/sec, depending on server load)

	if(species && species.flags & NO_BLOOD)
		return PULSE_NONE //No blood, no pulse.

	if(stat == DEAD)
		return PULSE_NONE	//that's it, you're dead, nothing can influence your pulse

	if(heart_attack)
		return PULSE_NONE

	var/temp = PULSE_NORM

	var/blood_type = get_blood_name()
	if(round(vessel.get_reagent_amount(blood_type)) <= BLOOD_VOLUME_BAD)	//how much blood do we have
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


	for(var/mob/living/carbon/human/H in range(decaylevel, src))
		if(prob(2))
			if(istype(loc,/obj/item/bodybag))
				return
			var/obj/item/clothing/mask/M = H.wear_mask
			if(M && (M.flags & MASKCOVERSMOUTH))
				return
			if(H.species && H.species.flags & NO_BREATHE)
				return //no puking if you can't smell!
			// Humans can lack a mind datum, y'know
			if(H.mind && H.mind.assigned_role == "Detective")
				return //too cool for puke
			to_chat(H, "<spawn class='warning'>You smell something foul...")
			H.fakevomit()

/mob/living/carbon/human/proc/handle_heartbeat()
	var/client/C = src.client
	if(C && C.prefs.sound & SOUND_HEARTBEAT) //disable heartbeat by pref
		var/obj/item/organ/internal/heart/H = get_int_organ(/obj/item/organ/internal/heart)

		if(!H) //H.status will runtime if there is no H (obviously)
			return

		if(H.status & ORGAN_ROBOT) //Handle robotic hearts specially with a wuuuubb. This also applies to machine-people.
			if(shock_stage >= 10 || istype(get_turf(src), /turf/space))
				//PULSE_THREADY - maximum value for pulse, currently it 5.
				//High pulse value corresponds to a fast rate of heartbeat.
				//Divided by 2, otherwise it is too slow.
				var/rate = (PULSE_THREADY - 2)/2 //machine people (main target) have no pulse, manually subtract standard human pulse (2). Mechanic-heart humans probably have a pulse, but 'advanced neural systems' keep the heart rate steady, or something

				if(heartbeat >= rate)
					heartbeat = 0
					src << sound('sound/effects/electheart.ogg',0,0,0,30)//Credit to GhostHack (www.ghosthack.de) for sound.

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
				if(H.status & ORGAN_ASSISTED)
					src << sound('sound/effects/pacemakebeat.ogg',0,0,0,50)
				else
					src << sound('sound/effects/singlebeat.ogg',0,0,0,50)
			else
				heartbeat++

/*
	Called by life(), instead of having the individual hud items update icons each tick and check for status changes
	we only set those statuses and icons upon changes.  Then those HUD items will simply add those pre-made images.
	This proc below is only called when those HUD elements need to change as determined by the mobs hud_updateflag.
*/


/mob/living/carbon/human/handle_silent()
	if(..())
		speech_problem_flag = 1
	return silent

/mob/living/carbon/human/handle_slurring()
	if(..())
		speech_problem_flag = 1
	return slurring

/mob/living/carbon/human/handle_stunned()
	if(..())
		speech_problem_flag = 1
	return stunned

/mob/living/carbon/human/handle_stuttering()
	if(..())
		speech_problem_flag = 1
	return stuttering


/mob/living/carbon/human/proc/handle_heartattack()
	if(!heart_attack)
		return
	else
		if(losebreath < 3)
			losebreath += 2
		adjustOxyLoss(5)
		adjustBruteLoss(1)



// Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
