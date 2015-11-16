//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32


var/global/list/unconscious_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage6"),\
	"7" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage7"),\
	"8" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage8"),\
	"9" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage9"),\
	"10" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage10"))
var/global/list/oxyloss_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay6"),\
	"7" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay7"))
var/global/list/brutefireloss_overlays = list("1" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay1"),\
	"2" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay2"),\
	"3" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay3"),\
	"4" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay4"),\
	"5" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay5"),\
	"6" = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay6"))

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

	if(mob_master.current_cycle % 30 == 15)
		hud_updateflag = 1022

	voice = GetVoice()

	if(..() && !in_stasis)

		if(check_mutations)
			domutcheck(src,null)
			update_mutations()
			check_mutations=0

		handle_virus_updates()

		handle_shock()
		handle_pain()
		handle_heartbeat()
		handle_heartattack()

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
		handle_vampire()
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
	if (disabilities & EPILEPSY)
		if ((prob(1) && paralysis < 1))
			visible_message("<span class='danger'>[src] starts having a seizure!</span>","<span class='alert'>You have a seizure!</span>")
			Paralyse(10)
			Jitter(1000)

	// If we have the gene for being crazy, have random events.
	if(dna.GetSEState(HALLUCINATIONBLOCK))
		if(prob(1) && hallucination < 1)
			hallucination += 20

	if (disabilities & COUGHING)
		if ((prob(5) && paralysis <= 1))
			drop_item()
			emote("cough")
	if (disabilities & TOURETTES)
		speech_problem_flag = 1
		if ((prob(10) && paralysis <= 1))
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
	if (disabilities & NERVOUS)
		speech_problem_flag = 1
		if (prob(10))
			stuttering = max(10, stuttering)

	if (getBrainLoss() >= 60 && stat != 2)
		speech_problem_flag = 1
		if (prob(3))
			switch(pick(1,2,3))
				if(1)
					say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", "without oxigen blob don't evoluate?", "CAPTAINS A COMDOM", "[pick("", "that damn traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", "can u give me [pick("telikesis","halk","eppilapse")]?", "THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", "I WANNA PET TEH monkeyS", "stop grifing me!!!!", "SOTP IT#"))
				if(2)
					say(pick("FUS RO DAH","fucking 4rries!", "stat me", ">my face", "roll it easy!", "waaaaaagh!!!", "red wonz go fasta", "FOR TEH EMPRAH", "lol2cat", "dem dwarfs man, dem dwarfs", "SPESS MAHREENS", "hwee did eet fhor khayosss", "lifelike texture ;_;", "luv can bloooom", "PACKETS!!!"))
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
	if(getFireLoss())
		if((RESIST_HEAT in mutations) || (prob(1)))
			heal_organ_damage(0,1)


	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
		/*	if (prob(10) && prob(gene.instability))
				adjustCloneLoss(1) */
			speech_problem_flag = 1
			gene.OnMobLife(src)

	if (radiation)

		if((locate(src.internal_organs_by_name["resonant crystal"]) in src.internal_organs))
			var/rads = radiation/25
			radiation -= rads
			radiation -= 0.1
			reagents.add_reagent("radium", rads/10)
			if( prob(10) )
				src << "<span class='notice'>You feel relaxed.</span>"
			return

		if (radiation > 100)
			radiation = 100
			if(!(species.flags & RAD_ABSORB))
				Weaken(10)
				if(!lying)
					src << "<span class='alert'>You feel weak.</span>"
					emote("collapse")

		if (radiation < 0)
			radiation = 0

		else
			if(species.flags & RAD_ABSORB)
				var/rads = radiation/25
				radiation -= rads
				nutrition += rads
				adjustBruteLoss(-(rads))
				adjustOxyLoss(-(rads))
				adjustToxLoss(-(rads))
				updatehealth()
				return

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
							src << "<span class='alert'>You feel weak.</span>"
							emote("collapse")
					updatehealth()

				if(75 to 100)
					radiation -= 3
					adjustToxLoss(3)
					damage = 3
					if(prob(1))
						src << "<span class='alert'>You mutate!</span>"
						randmutb(src)
						domutcheck(src,null)
						emote("gasp")
					updatehealth()

				else
					radiation -= 5
					adjustToxLoss(5)
					damage = 5
					if(prob(1))
						src << "<span class='alert'>You mutate!</span>"
						randmutb(src)
						domutcheck(src,null)
						emote("gasp")
					updatehealth()

			if(damage && organs.len)
				var/obj/item/organ/external/O = pick(organs)
				if(istype(O)) O.add_autopsy_data("Radiation Poisoning", damage)

/mob/living/carbon/human/breathe()
	if(reagents.has_reagent("lexorin"))
		return
	if(NO_BREATH in mutations)
		return // No breath mutation means no breathing. //DID YOU REALLY NEED TO FUCKING STATE THIS?
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return
	if(species && (species.flags & NO_BREATHE))
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
		//spread virus2
		if(virus2.len > 0)
			if(prob(10) && get_infection_chance(src))
				for(var/mob/living/carbon/M in view(1,src))
					src.spread_disease_to(M)



// USED IN DEATHWHISPERS
/mob/living/carbon/human/proc/isInCrit()
	// Health is in deep shit and we're not already dead
	return health <= 0 && stat != 2


/mob/living/carbon/human/get_breath_from_internal(volume_needed) //making this call the parent would be far too complicated
	var/null_internals = 0
	if(internal)
		if(istype(back, /obj/item/weapon/rig))
			var/obj/item/weapon/rig/rig = back
			if(rig.offline && (rig.air_supply && internal == rig.air_supply))
				null_internals = 1

		if(!(wear_mask && (wear_mask.flags & AIRTIGHT))) //not wearing mask
			if(!(head && (head.flags & AIRTIGHT))) //not wearing helmet
				null_internals = 1

		if(null_internals)
			internal = null

		if(internal)
			if(internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if(internals)
				internals.icon_state = "internal0"

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

		oxygen_alert = max(oxygen_alert, 1)

		return 0

	return species.handle_breath(breath, src)

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/loc_temp = get_temperature(environment)
	//world << "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Thermal protection: [get_thermal_protection()] - Fire protection: [thermal_protection + add_fire_protection(loc_temp)] - Heat capacity: [environment_heat_capacity] - Location: [loc] - src: [src]"

	//Body temperature is adjusted in two steps. Firstly your body tries to stabilize itself a bit.
	if(stat != 2)
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
		fire_alert = max(fire_alert, 1)
		if(status_flags & GODMODE)	return 1	//godmode

		if(bodytemperature >= species.heat_level_1 && bodytemperature <= species.heat_level_2)
			take_overall_damage(burn=HEAT_DAMAGE_LEVEL_1, used_weapon = "High Body Temperature")
			fire_alert = max(fire_alert, 2)
		if(bodytemperature > species.heat_level_2 && bodytemperature <= species.heat_level_3)
			take_overall_damage(burn=HEAT_DAMAGE_LEVEL_2, used_weapon = "High Body Temperature")
			fire_alert = max(fire_alert, 2)
		if(bodytemperature > species.heat_level_3 && bodytemperature < INFINITY)
			if(on_fire)
				take_overall_damage(burn=HEAT_DAMAGE_LEVEL_3, used_weapon = "Fire")
				fire_alert = max(fire_alert, 2)
			else
				take_overall_damage(burn=HEAT_DAMAGE_LEVEL_2, used_weapon = "High Body Temperature")
				fire_alert = max(fire_alert, 2)

	else if(bodytemperature < species.cold_level_1)
		fire_alert = max(fire_alert, 1)
		if(status_flags & GODMODE)	return 1	//godmode

		if(stat == DEAD) return 1 //ZomgPonies -- No need for cold burn damage if dead

		if(!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			if(bodytemperature >= species.cold_level_2 && bodytemperature <= species.cold_level_1)
				take_overall_damage(burn=COLD_DAMAGE_LEVEL_1, used_weapon = "Low Body Temperature")
				fire_alert = max(fire_alert, 1)
			if(bodytemperature >= species.cold_level_3 && bodytemperature < species.cold_level_2)
				take_overall_damage(burn=COLD_DAMAGE_LEVEL_2, used_weapon = "Low Body Temperature")
				fire_alert = max(fire_alert, 1)
			if(bodytemperature > -INFINITY && bodytemperature < species.cold_level_3)
				take_overall_damage(burn=COLD_DAMAGE_LEVEL_3, used_weapon = "Low Body Temperature")
				fire_alert = max(fire_alert, 1)

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	if(status_flags & GODMODE)	return 1	//godmode

	if(adjusted_pressure >= species.hazard_high_pressure)
		var/pressure_damage = min( ( (adjusted_pressure / species.hazard_high_pressure) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE)
		take_overall_damage(brute=pressure_damage, used_weapon = "High Pressure")
		pressure_alert = 2
	else if(adjusted_pressure >= species.warning_high_pressure)
		pressure_alert = 1
	else if(adjusted_pressure >= species.warning_low_pressure)
		pressure_alert = 0
	else if(adjusted_pressure >= species.hazard_low_pressure)
		pressure_alert = -1
	else
		if(RESIST_COLD in mutations)
			pressure_alert = -1
		else
			take_overall_damage(brute=LOW_PRESSURE_DAMAGE, used_weapon = "Low Pressure")
			pressure_alert = -2

	return

///FIRE CODE
/mob/living/carbon/human/handle_fire()
	if(..())
		return
	var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			thermal_protection += (wear_suit.max_heat_protection_temperature*0.7)
	if(head)
		if(head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT)
			thermal_protection += (head.max_heat_protection_temperature*THERMAL_PROTECTION_HEAD)
	thermal_protection = round(thermal_protection)
	if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
		return
	if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT)
		bodytemperature += 11
		return
	else
		bodytemperature += BODYTEMP_HEATING_MAX
	return
//END FIRE CODE

	/*
/mob/living/carbon/human/proc/adjust_body_temperature(current, loc_temp, boost)
	var/temperature = current
	var/difference = abs(current-loc_temp)	//get difference
	var/increments// = difference/10			//find how many increments apart they are
	if(difference > 50)
		increments = difference/5
	else
		increments = difference/10
	var/change = increments*boost	// Get the amount to change by (x per increment)
	var/temp_change
	if(current < loc_temp)
		temperature = min(loc_temp, temperature+change)
	else if(current > loc_temp)
		temperature = max(loc_temp, temperature-change)
	temp_change = (temperature - current)
	return temp_change
	*/

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
	var/thermal_protection_flags = get_heat_protection_flags(temperature)

	var/thermal_protection = 0.0
	if(RESIST_HEAT in mutations)
		return 1
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

	if(species.flags & REQUIRE_LIGHT)
		var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
		if(isturf(loc)) //else, there's considered to be no light
			var/turf/T = loc
			light_amount = min(T.get_lumcount()*10, 5)  //hardcapped so it's not abused by having a ton of flashlights
		nutrition += light_amount
		traumatic_shock -= light_amount

		if(species.flags & IS_PLANT)
			if(nutrition > 450)
				nutrition = 450
			if((light_amount >= 5) && !suiciding) //if there's enough light, heal
				adjustBruteLoss(-(light_amount/2))
				adjustFireLoss(-(light_amount/4))
				//adjustToxLoss(-(light_amount))
				adjustOxyLoss(-(light_amount))
				//TODO: heal wounds, heal broken limbs.

	if(species.light_dam)
		var/light_amount = 0
		if(isturf(loc))
			var/turf/T = loc
			light_amount = T.get_lumcount()*10
		if(light_amount > species.light_dam && !incorporeal_move) //if there's enough light, start dying
			if(species.light_effect_amp)
				adjustFireLoss(4.7) //This gets multiplied by 1.5 due to Shadowling's innate fire weakness, so it ends up being about 7.
			else
				adjustFireLoss(1)
				adjustBruteLoss(1)
			src << "<span class='userdanger'>The light burns you!</span>"
			src << 'sound/weapons/sear.ogg'
		else //heal in the dark
			if(species.light_effect_amp)
				adjustFireLoss(-5)
				adjustBruteLoss(-5)
				adjustBrainLoss(-25) //gibbering shadowlings are hilarious but also bad to have
				adjustCloneLoss(-1)
				SetWeakened(0)
				SetStunned(0)
			else
				adjustFireLoss(-1)
				adjustBruteLoss(-1)


	//The fucking FAT mutation is the greatest shit ever. It makes everyone so hot and bothered.
	if(species.flags & CAN_BE_FAT)
		if(FAT in mutations)
			if(overeatduration < 100)
				src << "<span class='notice'>You feel fit again!</span>"
				mutations.Remove(FAT)
				update_mutantrace(0)
				update_mutations(0)
				update_inv_w_uniform(0)
				update_inv_wear_suit()
		else
			if(overeatduration > 500)
				src << "<span class='alert'>You suddenly feel blubbery!</span>"
				mutations.Add(FAT)
				update_mutantrace(0)
				update_mutations(0)
				update_inv_w_uniform(0)
				update_inv_wear_suit()

	// nutrition decrease
	if (nutrition > 0 && stat != 2)
		nutrition = max (0, nutrition - HUNGER_FACTOR)

	if (nutrition > 450)
		if(overeatduration < 800) //capped so people don't take forever to unfat
			overeatduration++

	else
		if(overeatduration > 1)
			if(OBESITY in mutations)
				overeatduration -= 1 // Those with obesity gene take twice as long to unfat
			else
				overeatduration -= 2

	if(species.flags & REQUIRE_LIGHT)
		if(nutrition < 200)
			take_overall_damage(10,0)
			traumatic_shock++

	if (drowsyness)
		drowsyness--
		eye_blurry = max(2, eye_blurry)
		if (prob(5))
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

/mob/living/carbon/human/handle_regular_status_updates()

	if(status_flags & GODMODE)
		return 0

	//SSD check, if a logged player is awake put them back to sleep!
	if(player_logged && sleeping < 2)
		sleeping = 2

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON

		if(REGEN in mutations)
			if(nutrition)
				if(prob(10))
					var/randumb = rand(1,5)
					nutrition -= randumb
					heal_overall_damage(randumb,randumb)
				if(nutrition < 0)
					nutrition = 0

		// Sobering multiplier.
		// Sober block grants quadruple the alcohol metabolism.
//			var/sober_str=!(SOBER in mutations)?1:4

		updatehealth()	//TODO
		if(!in_stasis)
			handle_organs()	//Optimized.
			handle_blood()

		if(health <= config.health_threshold_dead || brain_op_stage == 4.0)
			death()
			blinded = 1
			silent = 0
			return 1

		// the analgesic effect wears off slowly
		analgesic = max(0, analgesic - 1)

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 50) || (config.health_threshold_crit >= health) )
			Paralyse(3)

			/* Done by handle_breath()
			if( health <= 20 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_reagent("epinephrine"))
				adjustOxyLoss(1)*/

		if(hallucination && !(species.flags & NO_DNA_RAD))
			spawn handle_hallucinations()

			if(hallucination<=2)
				hallucination = 0
				halloss = 0
			else
				hallucination -= 2


		if(halloss > 100)
			src << "<span class='notice'>You're in too much pain to keep going...</span>"
			for(var/mob/O in oviewers(src, null))
				O.show_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.", 1)
			Paralyse(10)
			setHalLoss(99)

		if(paralysis)
			blinded = 1
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(sleeping)
			speech_problem_flag = 1
			handle_dreams()
			adjustStaminaLoss(-10)
			adjustHalLoss(-3)
			if (mind)
				//Are they SSD? If so we'll keep them asleep but work off some of that sleep var in case of ether or similar.
				if(player_logged)
					sleeping = max(sleeping-1, 2)
				else
					sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if( prob(2) && health && !hal_crit )
				spawn(0)
					emote("snore")
			if(mind)
				if(mind.vampire)
					if(istype(loc, /obj/structure/closet/coffin))
						adjustBruteLoss(-1)
						adjustFireLoss(-1)
						adjustToxLoss(-1)
		else if(status_flags & FAKEDEATH)
			blinded = 1
			stat = UNCONSCIOUS
		else if(resting)
			if(halloss > 0)
				adjustHalLoss(-3)
		//CONSCIOUS
		else
			stat = CONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-1)

		if(embedded_flag && !(mob_master.current_cycle % 10))
			var/list/E
			E = get_visible_implants(0)
			if(!E.len)
				embedded_flag = 0

		//Vision
		var/obj/item/organ/vision
		if(species.vision_organ)
			vision = internal_organs_by_name[species.vision_organ]

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
			if(sdisabilities & BLIND) // Disabled-blind, doesn't get better on its own
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
		if(sdisabilities & DEAF)	//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf-1, 0)
		else if(istype(l_ear, /obj/item/clothing/ears/earmuffs) || istype(r_ear, /obj/item/clothing/ears/earmuffs))	//resting your ears with earmuffs heals ear damage faster
			ear_damage = max(ear_damage-0.15, 0)
			ear_deaf = max(ear_deaf, 1)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage-0.05, 0)

		//Dizziness
		if(dizziness)
			var/client/C = client
			var/pixel_x_diff = 0
			var/pixel_y_diff = 0
			var/temp
			var/saved_dizz = dizziness
			dizziness = max(dizziness-1, 0)
			if(C)
				var/oldsrc = src
				var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70 // This shit is annoying at high strength
				src = null
				spawn(0)
					if(C)
						temp = amplitude * sin(0.008 * saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp
						temp = amplitude * cos(0.008 * saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp
						sleep(3)
						if(C)
							temp = amplitude * sin(0.008 * saved_dizz * world.time)
							pixel_x_diff += temp
							C.pixel_x += temp
							temp = amplitude * cos(0.008 * saved_dizz * world.time)
							pixel_y_diff += temp
							C.pixel_y += temp
						sleep(3)
						if(C)
							C.pixel_x -= pixel_x_diff
							C.pixel_y -= pixel_y_diff
				src = oldsrc

		//Jitteryness
		if(jitteriness)
			do_jitter_animation(jitteriness)

		//Flying
		if(flying)
			spawn()
				animate(src, pixel_y = pixel_y + 5 , time = 10, loop = 1, easing = SINE_EASING)
			spawn(10)
				if(flying)
					animate(src, pixel_y = pixel_y - 5, time = 10, loop = 1, easing = SINE_EASING)

		// If you're dirty, your gloves will become dirty, too.
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1

		CheckStamina()

	return 1

/mob/living/carbon/human/handle_vision()
	client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask)
	if(machine)
		if(!machine.check_eye(src))		reset_view(null)
	else
		var/isRemoteObserve = 0
		if((REMOTE_VIEW in mutations) && remoteview_target)
			isRemoteObserve = 1

			if(remoteview_target.stat != CONSCIOUS)
				src << "<span class='alert'>Your psy-connection grows too faint to maintain!</span>"
				isRemoteObserve = 0

			if(PSY_RESIST in remoteview_target.mutations)
				src << "<span class='alert'>Your mind is shut out!</span>"
				isRemoteObserve = 0

			// Not on the station or mining?
			var/turf/temp_turf = get_turf(remoteview_target)
			if(!temp_turf in config.contact_levels)
				src << "<span class='alert'>Your psy-connection grows too faint to maintain!</span>"
				isRemoteObserve = 0

		if(!isRemoteObserve && client && !client.adminobs)
			remoteview_target = null
			reset_view(null)

	species.handle_vision(src)

/mob/living/carbon/human/handle_hud_icons()
	species.handle_hud_icons(src)

/mob/living/carbon/human/handle_regular_hud_updates()
	if(hud_updateflag)
		handle_hud_list()

	if(..())
		if(hud_updateflag)
			handle_hud_list()

	if(ticker && ticker.mode.name == "nations")
		process_nations()



/mob/living/carbon/human/handle_random_events()
	// Puke if toxloss is too high
	if(!stat)
		if (getToxLoss() >= 45 && nutrition > 20)
			vomit()

	//0.1% chance of playing a scary sound to someone who's in complete darkness
	if(isturf(loc) && rand(1,1000) == 1)
		var/turf/currentTurf = loc
		var/atom/movable/lighting_overlay/L = locate(/atom/movable/lighting_overlay) in currentTurf
		if(L && L.lum_r + L.lum_g + L.lum_b == 0)
			playsound_local(src,pick(scarySounds),50, 1, -1)

	// Separate proc so we can jump out of it when we've succeeded in spreading disease.
/mob/living/carbon/human/proc/findAirborneVirii()
	for(var/obj/effect/decal/cleanable/blood/B in get_turf(src))
		if(B.virus2.len)
			for (var/ID in B.virus2)
				var/datum/disease2/disease/V = B.virus2[ID]
				if (infect_virus2(src,V))
					return 1

	for(var/obj/effect/decal/cleanable/mucus/M in get_turf(src))
		if(M.virus2.len)
			for (var/ID in M.virus2)
				var/datum/disease2/disease/V = M.virus2[ID]
				if (infect_virus2(src,V))
					return 1

	for(var/obj/effect/decal/cleanable/poop/P in get_turf(src))
		if(P.virus2.len)
			for (var/ID in P.virus2)
				var/datum/disease2/disease/V = P.virus2[ID]
				if (infect_virus2(src,V))
					return 1


	return 0

/mob/living/carbon/human/proc/handle_virus_updates()
	if(status_flags & GODMODE)	return 0	//godmode
	if(bodytemperature > 406)
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			V.cure(src)
	if(mob_master.current_cycle % 3) //don't spam checks over all objects in view every tick.
		for(var/obj/effect/decal/cleanable/O in view(1,src))
			if(istype(O,/obj/effect/decal/cleanable/blood))
				var/obj/effect/decal/cleanable/blood/B = O
				if(B.virus2.len)
					for (var/ID in B.virus2)
						var/datum/disease2/disease/V = B.virus2[ID]
						infect_virus2(src,V.getcopy())

			else if(istype(O,/obj/effect/decal/cleanable/mucus))
				var/obj/effect/decal/cleanable/mucus/M = O
				if(M.virus2.len)
					for (var/ID in M.virus2)
						var/datum/disease2/disease/V = M.virus2[ID]
						infect_virus2(src,V.getcopy())


	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		if(isnull(V)) // Trying to figure out a runtime error that keeps repeating
			CRASH("virus2 nulled before calling activate()")
		else
			V.activate(src)
		// activate may have deleted the virus
		if(!V) continue

		// check if we're immune
		if(V.antigen & src.antibodies)
			V.dead = 1
	return

/mob/living/carbon/human/handle_changeling()
	if(mind && mind.changeling)
		mind.changeling.regenerate()

/mob/living/carbon/human/handle_shock()
	..()
	if(status_flags & GODMODE)	return 0	//godmode
	if(analgesic || (species && species.flags & NO_PAIN)) return // analgesic avoids all traumatic shock temporarily

	if(health <= config.health_threshold_softcrit)// health 0 makes you immediately collapse
		shock_stage = max(shock_stage, 61)

	if(traumatic_shock >= 100)
		shock_stage += 1
	else
		shock_stage = min(shock_stage, 160)
		shock_stage = max(shock_stage-1, 0)
		return

	if(shock_stage == 10)
		src << "<font color='red'><b>"+pick("It hurts so much!", "You really need some painkillers..", "Dear god, the pain!")

	if(shock_stage >= 30)
		if(shock_stage == 30) custom_emote(1,"is having trouble keeping their eyes open.")
		eye_blurry = max(2, eye_blurry)
		stuttering = max(stuttering, 5)

	if(shock_stage == 40)
		src << "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")

	if(shock_stage >=60)
		if(shock_stage == 60) custom_emote(1,"falls limp.")
		if (prob(2))
			src << "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")
			Weaken(20)

	if(shock_stage >= 80)
		if (prob(5))
			src << "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")
			Weaken(20)

	if(shock_stage >= 120)
		if (prob(2))
			src << "<font color='red'><b>"+pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness.")
			Paralyse(5)

	if(shock_stage == 150)
		custom_emote(1,"can no longer stand, collapsing!")
		Weaken(20)

	if(shock_stage >= 150)
		Weaken(20)


/mob/living/carbon/human/proc/handle_pulse()

	if(mob_master.current_cycle % 5) return pulse	//update pulse every 5 life ticks (~1 tick/sec, depending on server load)

	if(species && species.flags & NO_BLOOD) return PULSE_NONE //No blood, no pulse.

	if(stat == DEAD)
		return PULSE_NONE	//that's it, you're dead, nothing can influence your pulse

	if(heart_attack)
		return PULSE_NONE

	var/temp = PULSE_NORM

	if(round(vessel.get_reagent_amount("blood")) <= BLOOD_VOLUME_BAD)	//how much blood do we have
		temp = PULSE_THREADY	//not enough :(

	if(status_flags & FAKEDEATH)
		temp = PULSE_NONE		//pretend that we're dead. unlike actual death, can be inflienced by meds

	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.id in bradycardics)
			if(temp <= PULSE_THREADY && temp >= PULSE_NORM)
				temp--
				break		//one reagent is enough
							//comment out the breaks to make med effects stack
	for(var/datum/reagent/R in reagents.reagent_list)				//handles different chems' influence on pulse
		if(R.id in tachycardics)
			if(temp <= PULSE_FAST && temp >= PULSE_NONE)
				temp++
				break
	for(var/datum/reagent/R in reagents.reagent_list) //To avoid using fakedeath
		if(R.id in heartstopper)
			temp = PULSE_NONE
			break
	for(var/datum/reagent/R in reagents.reagent_list) //Conditional heart-stoppage
		if(R.id in cheartstopper)
			if(R.volume >= R.overdose_threshold)
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
		if(prob(5))
			if(airborne_can_reach(get_turf(src), get_turf(H)))
				if(istype(loc,/obj/item/bodybag))
					return
				var/obj/item/clothing/mask/M = H.wear_mask
				if(M && (M.flags & MASKCOVERSMOUTH))
					return
				if(H.species && H.species.flags & NO_BREATHE)
					return //no puking if you can't smell!
				H << "<spawn class='warning'>You smell something foul..."
				H.fakevomit()

/mob/living/carbon/human/proc/handle_heartbeat()
	var/client/C = src.client
	if(C && C.prefs.sound & SOUND_HEARTBEAT) //disable heartbeat by pref
		var/obj/item/organ/heart/H = internal_organs_by_name["heart"]

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
					src << sound('sound/effects/electheart.ogg',0,0,0,30) //Credit to GhostHack (www.ghosthack.de) for sound.
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


/mob/living/carbon/human/proc/handle_hud_list()

	if(hud_updateflag & 1 << HEALTH_HUD)
		var/image/holder = hud_list[HEALTH_HUD]
		if(stat == 2)
			holder.icon_state = "hudhealth-100" 	// X_X
		else
			holder.icon_state = "hud[RoundHealth(health)]"

		hud_list[HEALTH_HUD] = holder


	if(hud_updateflag & 1 << STATUS_HUD)
		var/foundVirus = 0
		for (var/ID in virus2)
			if (ID in virusDB)
				foundVirus = 1
				break

		var/image/holder = hud_list[STATUS_HUD]
		var/image/holder2 = hud_list[STATUS_HUD_OOC]
		if(stat == 2)
			holder.icon_state = "huddead"
			holder2.icon_state = "huddead"
		else if(status_flags & XENO_HOST)
			holder.icon_state = "hudxeno"
			holder2.icon_state = "hudxeno"
		else if(foundVirus)
			holder.icon_state = "hudill"
		else if(has_brain_worms())
			var/mob/living/simple_animal/borer/B = has_brain_worms()
			if(B.controlling)
				holder.icon_state = "hudbrainworm"
			else
				holder.icon_state = "hudhealthy"
			holder2.icon_state = "hudbrainworm"
		else
			holder.icon_state = "hudhealthy"
			if(virus2.len)
				holder2.icon_state = "hudill"
			else
				holder2.icon_state = "hudhealthy"

		hud_list[STATUS_HUD] = holder
		hud_list[STATUS_HUD_OOC] = holder2


	if(hud_updateflag & 1 << ID_HUD)
		var/image/holder = hud_list[ID_HUD]
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				holder.icon_state = "hud[ckey(I.GetJobName())]"
			else
				holder.icon_state = "hudunknown"
		else
			holder.icon_state = "hudunknown"


		hud_list[ID_HUD] = holder


	if(hud_updateflag & 1 << WANTED_HUD)
		var/image/holder = hud_list[WANTED_HUD]
		holder.icon_state = "hudblank"
		var/perpname = name
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				perpname = I.registered_name
		for(var/datum/data/record/E in data_core.general)
			if(E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						holder.icon_state = "hudwanted"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
						holder.icon_state = "hudprisoner"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Parolled"))
						holder.icon_state = "hudparolled"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
						holder.icon_state = "hudreleased"
						break
		hud_list[WANTED_HUD] = holder


	if(hud_updateflag & 1 << IMPLOYAL_HUD || hud_updateflag & 1 << IMPCHEM_HUD || hud_updateflag & 1 << IMPTRACK_HUD)
		var/image/holder1 = hud_list[IMPTRACK_HUD]
		var/image/holder2 = hud_list[IMPLOYAL_HUD]
		var/image/holder3 = hud_list[IMPCHEM_HUD]

		holder1.icon_state = "hudblank"
		holder2.icon_state = "hudblank"
		holder3.icon_state = "hudblank"

		for(var/obj/item/weapon/implant/I in src)
			if(I.implanted)
				if(istype(I,/obj/item/weapon/implant/tracking))
					holder1.icon_state = "hud_imp_tracking"
				if(istype(I,/obj/item/weapon/implant/loyalty))
					holder2.icon_state = "hud_imp_loyal"
				if(istype(I,/obj/item/weapon/implant/chem))
					holder3.icon_state = "hud_imp_chem"

		hud_list[IMPTRACK_HUD] = holder1
		hud_list[IMPLOYAL_HUD] = holder2
		hud_list[IMPCHEM_HUD] = holder3

	if(hud_updateflag & 1 << SPECIALROLE_HUD)
		var/image/holder = hud_list[SPECIALROLE_HUD]
		holder.icon_state = "hudblank"

		if(mind)

			switch(mind.special_role)
				if("traitor","Syndicate")
					holder.icon_state = "hudsyndicate"
				if("Revolutionary")
					holder.icon_state = "hudrevolutionary"
				if("Head Revolutionary")
					holder.icon_state = "hudheadrevolutionary"
				if("Cultist")
					holder.icon_state = "hudcultist"
				if("Changeling")
					holder.icon_state = "hudchangeling"
				if("Wizard","Fake Wizard")
					holder.icon_state = "hudwizard"
				if("Death Commando")
					holder.icon_state = "huddeathsquad"
				if("Ninja")
					holder.icon_state = "hudninja"
				if("Vampire") // TODO: Check this
					holder.icon_state = "hudvampire"
				if("VampThrall")
					holder.icon_state = "hudvampthrall"
				if("head_loyalist")
					holder.icon_state = "loyalist"
				if("loyalist")
					holder.icon_state = "loyalist"
				if("head_mutineer")
					holder.icon_state = "mutineer"
				if("mutineer")
					holder.icon_state = "mutineer"
				if("Shadowling")
					holder.icon_state = "hudshadowling"
				if("shadowling thrall")
					holder.icon_state = "hudshadowlingthrall"

			hud_list[SPECIALROLE_HUD] = holder

	if(hud_updateflag & 1 << NATIONS_HUD)
		var/image/holder = hud_list[NATIONS_HUD]
		holder.icon_state = "hudblank"

		if(mind && mind.nation)
			switch(mind.nation.name)
				if("Atmosia")
					holder.icon_state = "hudatmosia"
				if("Brigston")
					holder.icon_state = "hudbrigston"
				if("Cargonia")
					holder.icon_state = "hudcargonia"
				if("People's Republic of Commandzakstan")
					holder.icon_state = "hudcommand"
				if("Medistan")
					holder.icon_state = "hudmedistan"
				if("Scientopia")
					holder.icon_state = "hudscientopia"

			hud_list[NATIONS_HUD] = holder

	hud_updateflag = 0

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
		losebreath += 5
		adjustOxyLoss(10)
		adjustBrainLoss(rand(4,10))
		Paralyse(2)
	return


/mob/living/carbon/human/proc/process_nations()
	var/client/C = client
	for(var/mob/living/carbon/human/H in view(world.view, src))
		C.images += H.hud_list[NATIONS_HUD]

// Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
