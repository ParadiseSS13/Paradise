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
/mob/living/carbon/human
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/co2_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/prev_gender = null // Debug for plural genders
	var/temperature_alert = 0
	var/in_stasis = 0
	var/exposedtimenow = 0
	var/firstexposed = 0

/mob/living/carbon/human/Life()
	set invisibility = 0
	//set background = 1

	if (monkeyizing)	return
	if(!loc)			return	// Fixing a null error that occurs when the mob isn't found in the world -- TLE

	..()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//TODO: seperate this out
	// update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++
	var/datum/gas_mixture/environment = loc.return_air()

	in_stasis = istype(loc, /obj/structure/closet/body_bag/cryobag) && loc:opened == 0
	if(in_stasis) loc:used++

	if(life_tick%30==15)
		hud_updateflag = 1022

	voice = GetVoice()

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD && !in_stasis)
		if(air_master.current_cycle%4==2 || failed_last_breath) 	//First, resolve location and get a breath
			breathe() 				//Only try to take a breath every 4 ticks, unless suffocating

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		if(check_mutations)
//			testing("Updating [src.real_name]'s mutations: "+english_list(mutations))
			domutcheck(src,null)
			update_mutations()
			check_mutations=0

		//Updates the number of stored chemicals for powers
		handle_changeling()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

		//Random events (vomiting etc)
		handle_random_events()

		handle_virus_updates()

		//Check if we're on fire
		handle_fire()

		//stuff in the stomach
		handle_stomach()

		handle_shock()

		handle_pain()

		handle_medical_side_effects()

	if(stat == DEAD)
		handle_decay()

	handle_stasis_bag()

	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000))	//We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
		return											//We go ahead and process them 5 times for HUD images and other stuff though.


	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)		//Optimized a good bit.

	//Status updates, death etc.
	handle_regular_status_updates()		//Optimized a bit
	update_canmove()

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	handle_regular_hud_updates()

	pulse = handle_pulse()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	if(mind && mind.vampire)
		handle_vampire()


//Much like get_heat_protection(), this returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
/mob/living/carbon/human/proc/get_pressure_protection()
	var/pressure_adjustment_coefficient = 1	//Determins how much the clothing you are wearing protects you in percent.

	if(head && (head.flags & STOPSPRESSUREDMAGE))
		pressure_adjustment_coefficient -= PRESSURE_HEAD_REDUCTION_COEFFICIENT

	if(wear_suit && (wear_suit.flags & STOPSPRESSUREDMAGE))
		pressure_adjustment_coefficient -= PRESSURE_SUIT_REDUCTION_COEFFICIENT

		//Handles breaches in your space suit. 10 suit damage equals a 100% loss of pressure reduction.
		if(istype(wear_suit,/obj/item/clothing/suit/space))
			var/obj/item/clothing/suit/space/S = wear_suit
			if(S.can_breach && S.damage)
				var/pressure_loss = S.damage * 0.1
				pressure_adjustment_coefficient += pressure_loss

	pressure_adjustment_coefficient = min(1,max(pressure_adjustment_coefficient,0)) //So it isn't less than 0 or larger than 1.

	return 1 - pressure_adjustment_coefficient	//want 0 to be bad protection, 1 to be good protection

// Calculate how vulnerable the human is to under- and overpressure.
// Returns 0 (equals 0 %) if sealed in an undamaged suit, 1 if unprotected (equals 100%).
// Suitdamage can modifiy this in 10% steps.
/mob/living/carbon/human/proc/get_pressure_weakness()

	var/pressure_adjustment_coefficient = 1 // Assume no protection at first.

	if(wear_suit && (wear_suit.flags & STOPSPRESSUREDMAGE) && head && (head.flags & STOPSPRESSUREDMAGE)) // Complete set of pressure-proof suit worn, assume fully sealed.
		pressure_adjustment_coefficient = 0

		// Handles breaches in your space suit. 10 suit damage equals a 100% loss of pressure protection.
		if(istype(wear_suit,/obj/item/clothing/suit/space))
			var/obj/item/clothing/suit/space/S = wear_suit
			if(S.can_breach && S.damage)
				pressure_adjustment_coefficient += S.damage * 0.1

	pressure_adjustment_coefficient = min(1,max(pressure_adjustment_coefficient,0)) // So it isn't less than 0 or larger than 1.

	return pressure_adjustment_coefficient

/mob/living/carbon/human/calculate_affecting_pressure(var/pressure)
	var/pressure_difference

	// First get the absolute pressure difference.
	if(pressure < ONE_ATMOSPHERE) // We are in an underpressure.
		pressure_difference = ONE_ATMOSPHERE - pressure

	else //We are in an overpressure or standard atmosphere.
		pressure_difference = pressure - ONE_ATMOSPHERE

	if(pressure_difference < 5) // If the difference is small, don't bother calculating the fraction.
		pressure_difference = 0

	else
		// Otherwise calculate how much of that absolute pressure difference affects us, can be 0 to 1 (equals 0% to 100%).
		// This is our relative difference.
		pressure_difference *= get_pressure_weakness()

	// The difference is always positive to avoid extra calculations.
	// Apply the relative difference on a standard atmosphere to get the final result.
	// The return value will be the adjusted_pressure of the human that is the basis of pressure warnings and damage.
	if(pressure < ONE_ATMOSPHERE)
		return ONE_ATMOSPHERE - pressure_difference
	else
		return ONE_ATMOSPHERE + pressure_difference


/mob/living/carbon/human

	proc/handle_disabilities()
		if (disabilities & EPILEPSY)
			if ((prob(1) && paralysis < 1))
				src << "\red You have a seizure!"
				for(var/mob/O in viewers(src, null))
					if(O == src)
						continue
					O.show_message(text("\red <B>[src] starts having a seizure!"), 1)
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

        /*
		if(species.name == "Tajaran")
			if(prob(1))
				if(prob(1))
					vomit(1) // Hairball

        */

		if(stat != 2)
			var/rn = rand(0, 200)
			if(getBrainLoss() >= 5)
				if(0 <= rn && rn <= 3)
					custom_pain("Your head feels numb and painful.")
			if(getBrainLoss() >= 15)
				if(4 <= rn && rn <= 6) if(eye_blurry <= 0)
					src << "\red It becomes hard to see for some reason."
					eye_blurry = 10
			if(getBrainLoss() >= 35)
				if(7 <= rn && rn <= 9) if(hand && equipped())
					src << "\red Your hand won't respond properly, you drop what you're holding."
					drop_item()
			if(getBrainLoss() >= 50)
				if(10 <= rn && rn <= 12) if(!lying)
					src << "\red Your legs won't respond properly, you fall down."
					resting = 1

	proc/handle_stasis_bag()
		// Handle side effects from stasis bag
		if(in_stasis)
			// First off, there's no oxygen supply, so the mob will slowly take brain damage
			adjustBrainLoss(0.1)

			// Next, the method to induce stasis has some adverse side-effects, manifesting
			// as cloneloss
			adjustCloneLoss(0.1)

	proc/handle_mutations_and_radiation()

		if(species.flags & IS_SYNTHETIC) //Robots don't suffer from mutations or radloss.
			return

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
			if (radiation > 100)
				radiation = 100
				if(!(species.flags & RAD_ABSORB))
					Weaken(10)
					if(!lying)
						src << "\red You feel weak."
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
								src << "\red You feel weak."
								emote("collapse")
						updatehealth()

					if(75 to 100)
						radiation -= 3
						adjustToxLoss(3)
						damage = 3
						if(prob(1))
							src << "\red You mutate!"
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						updatehealth()

					else
						radiation -= 5
						adjustToxLoss(5)
						damage = 5
						if(prob(1))
							src << "\red You mutate!"
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						updatehealth()

				if(damage && organs.len)
					var/datum/organ/external/O = pick(organs)
					if(istype(O)) O.add_autopsy_data("Radiation Poisoning", damage)

	proc/breathe()
		if(reagents.has_reagent("lexorin")) return
		if(NO_BREATH in mutations) return // No breath mutation means no breathing.
		if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return
		if(species && (species.flags & NO_BREATHE)) return

		var/datum/gas_mixture/environment = loc.return_air()
		var/datum/gas_mixture/breath

		// HACK NEED CHANGING LATER
		if(health <= config.health_threshold_crit)
			losebreath++

		if(losebreath>0) //Suffocating so do not take a breath
			losebreath--
			if (prob(10)) //Gasp per 10 ticks? Sounds about right.
				spawn emote("gasp")
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

		else
			//First, check for air from internal atmosphere (using an air tank and mask generally)
			breath = get_breath_from_internal(BREATH_VOLUME) // Super hacky -- TLE
			//breath = get_breath_from_internal(0.5) // Manually setting to old BREATH_VOLUME amount -- TLE

			//No breath from internal atmosphere so get breath from location
			if(!breath)
				if(isobj(loc))
					var/obj/location_as_object = loc
					breath = location_as_object.handle_internal_lifeform(src, BREATH_MOLES)
				else if(isturf(loc))
					var/breath_moles = 0
					/*if(environment.return_pressure() > ONE_ATMOSPHERE)
						// Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
						breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
					else*/
						// Not enough air around, take a percentage of what's there to model this properly
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

					breath = loc.remove_air(breath_moles)

					if(!is_lung_ruptured())
						if(!breath || breath.total_moles < BREATH_MOLES / 5 || breath.total_moles > BREATH_MOLES * 5)
							if(prob(5))
								rupture_lung()

					// Handle chem smoke effect  -- Doohl
					var/block = 0
					if(wear_mask)
						if(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
							block = 1
					if(glasses)
						if(glasses.flags & BLOCK_GAS_SMOKE_EFFECT)
							block = 1
					if(head)
						if(head.flags & BLOCK_GAS_SMOKE_EFFECT)
							block = 1

					if(!block)

						for(var/obj/effect/effect/chem_smoke/smoke in view(1, src))
							if(smoke.reagents.total_volume)
								smoke.reagents.reaction(src, INGEST)
								spawn(5)
									if(smoke)
										smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
								break // If they breathe in the nasty stuff once, no need to continue checking

			else //Still give containing object the chance to interact
				if(istype(loc, /obj/))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src, 0)

		handle_breath(breath)

		if(species.name=="Plasmaman")

			// Check if we're wearing our biosuit and mask.
			if (!istype(wear_suit,/obj/item/clothing/suit/space/eva/plasmaman) || !istype(head,/obj/item/clothing/head/helmet/space/eva/plasmaman))
				//testing("Plasmaman [src] leakin'.  coverflags=[cover_flags]")
				// OH FUCK HE LEAKIN'.
				// This was OP.
				//environment.adjust(tx = environment.total_moles()*BREATH_PERCENTAGE) // About one breath's worth. (I know we aren't breathing it out, but this should be about the right amount)
				src << "<span class='warning'>Your body reacts with the atmosphere and bursts into flame!</span>"
				adjust_fire_stacks(0.5)
				IgniteMob()

		if(breath)
			loc.assume_air(breath)

			//spread some viruses while we are at it
			if (virus2.len > 0)
				if (prob(10) && get_infection_chance(src))
//					log_debug("[src] : Exhaling some viruses")
					for(var/mob/living/carbon/M in view(1,src))
						src.spread_disease_to(M)

// USED IN DEATHWHISPERS
	proc/isInCrit()
		// Health is in deep shit and we're not already dead
		return health <= 0 && stat != 2

	proc/handle_breath(var/datum/gas_mixture/breath)
		if(status_flags & GODMODE)
			return 0

		if(!breath || (breath.total_moles() == 0) || suiciding)
			var/oxyloss = 0
			if(reagents.has_reagent("inaprovaline"))
				return
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

			var/datum/organ/external/affected = get_organ("chest")
			affected.add_autopsy_data("Suffocation", oxyloss)

			oxygen_alert = max(oxygen_alert, 1)

			return 0

		return species.handle_breath(breath, src)

	proc/handle_environment(datum/gas_mixture/environment)
		if(!environment)
			return

		//Moved pressure calculations here for use in skip-processing check.
		var/pressure = environment.return_pressure()
		var/adjusted_pressure = calculate_affecting_pressure(pressure)

		if(!istype(get_turf(src), /turf/space)) //space is not meant to change your body temperature.
			var/loc_temp = T0C
			if(istype(loc, /obj/mecha))
				var/obj/mecha/M = loc
				loc_temp =  M.return_temperature()

			if(istype(loc, /obj/spacepod))
				var/obj/spacepod/S = loc
				loc_temp = S.return_temperature()
			//else if(istype(get_turf(src), /turf/space))

			else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
				loc_temp = loc:air_contents.temperature
			else
				loc_temp = environment.temperature

			if(adjusted_pressure < species.warning_high_pressure && adjusted_pressure > species.warning_low_pressure && abs(loc_temp - bodytemperature) < 20 && bodytemperature < species.heat_level_1 && bodytemperature > species.cold_level_1 && environment.toxins < MOLES_PLASMA_VISIBLE)
				pressure_alert = 0
				return // Temperatures are within normal ranges, fuck all this processing. ~Ccomp

			if(!on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
				//Body temperature adjusts depending on surrounding atmosphere based on your thermal protection
				var/temp_adj = 0
				if(loc_temp < bodytemperature)			//Place is colder than we are
					var/thermal_protection = get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
					if(thermal_protection < 1)
						temp_adj = (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR)	//this will be negative
				else if (loc_temp > bodytemperature)			//Place is hotter than we are
					var/thermal_protection = get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
					if(thermal_protection < 1)
						temp_adj = (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)

				//Use heat transfer as proportional to the gas density. However, we only care about the relative density vs standard 101 kPa/20 C air. Therefore we can use mole ratios
				var/relative_density = environment.total_moles() / MOLES_CELLSTANDARD
				temp_adj *= relative_density

				if (temp_adj > BODYTEMP_HEATING_MAX) temp_adj = BODYTEMP_HEATING_MAX
				if (temp_adj < BODYTEMP_COOLING_MAX) temp_adj = BODYTEMP_COOLING_MAX
				//world << "Environment: [loc_temp], [src]: [bodytemperature], Adjusting: [temp_adj]"
				bodytemperature += temp_adj

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
			if( !(RESIST_COLD in mutations))
				take_overall_damage(brute=LOW_PRESSURE_DAMAGE, used_weapon = "Low Pressure")
				pressure_alert = -2
			else
				pressure_alert = -1

		if(environment.toxins > MOLES_PLASMA_VISIBLE)
			pl_effects()
		return

	///FIRE CODE
	handle_fire()
		if(..())
			return
		var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
		if(wear_suit)
			if(wear_suit.max_heat_protection_temperature >= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE)
				thermal_protection += (wear_suit.max_heat_protection_temperature*0.7)
		if(head)
			if(head.max_heat_protection_temperature >= FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE)
				thermal_protection += (head.max_heat_protection_temperature*THERMAL_PROTECTION_HEAD)
		thermal_protection = round(thermal_protection)
		if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
			return
		if(thermal_protection >= FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE)
			bodytemperature += 11
			return
		else
			bodytemperature += BODYTEMP_HEATING_MAX
		return
	//END FIRE CODE

	/*
	proc/adjust_body_temperature(current, loc_temp, boost)
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

	proc/stabilize_body_temperature()
		//TODO find a better place to put this
		if (s_store && istype(s_store, /obj/item/device/suit_cooling_unit))
			var/obj/item/device/suit_cooling_unit/CU = s_store
			CU.cool_mob(src)

//		if (species.flags & IS_SYNTHETIC)
//			bodytemperature += species.synth_temp_gain		//that CPU/posibrain just keeps putting out heat.		// commented out as making synthetics unplayable until cooling system sorted out
//			return

		var/body_temperature_difference = species.body_temperature - bodytemperature

		if (abs(body_temperature_difference) < 0.5)
			return //fuck this precision

		if(bodytemperature < species.cold_level_1) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
			if(nutrition >= 2) //If we are very, very cold we'll use up quite a bit of nutriment to heat us up.
				nutrition -= 2
			var/recovery_amt = max((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
			//world << "Cold. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Cold. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
			bodytemperature += recovery_amt
		else if(species.cold_level_1 <= bodytemperature && bodytemperature <= species.heat_level_1)
			var/recovery_amt = body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR
			//world << "Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
			bodytemperature += recovery_amt
		else if(bodytemperature > species.heat_level_1) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
			//We totally need a sweat system cause it totally makes sense...~
			var/recovery_amt = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers
			//world << "Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
			bodytemperature += recovery_amt

	//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, UPPER_TORSO, LOWER_TORSO, etc. See setup.dm for the full list)
	proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
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

	proc/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.
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
	proc/get_cold_protection_flags(temperature)
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

	proc/get_cold_protection(temperature)

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

	/*
	proc/add_fire_protection(var/temp)
		var/fire_prot = 0
		if(head)
			if(head.protective_temperature > temp)
				fire_prot += (head.protective_temperature/10)
		if(wear_mask)
			if(wear_mask.protective_temperature > temp)
				fire_prot += (wear_mask.protective_temperature/10)
		if(glasses)
			if(glasses.protective_temperature > temp)
				fire_prot += (glasses.protective_temperature/10)
		if(ears)
			if(ears.protective_temperature > temp)
				fire_prot += (ears.protective_temperature/10)
		if(wear_suit)
			if(wear_suit.protective_temperature > temp)
				fire_prot += (wear_suit.protective_temperature/10)
		if(w_uniform)
			if(w_uniform.protective_temperature > temp)
				fire_prot += (w_uniform.protective_temperature/10)
		if(gloves)
			if(gloves.protective_temperature > temp)
				fire_prot += (gloves.protective_temperature/10)
		if(shoes)
			if(shoes.protective_temperature > temp)
				fire_prot += (shoes.protective_temperature/10)

		return fire_prot

	proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
		if(nodamage)
			return
		//world <<"body_part = [body_part], exposed_temperature = [exposed_temperature], exposed_intensity = [exposed_intensity]"
		var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)

		if(exposed_temperature > bodytemperature)
			discomfort *= 4

		if(mutantrace == "plant")
			discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT * 2 //I don't like magic numbers. I'll make mutantraces a datum with vars sometime later. -- Urist
		else
			discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT //Dangercon 2011 - now with less magic numbers!
		//world <<"[discomfort]"

		switch(body_part)
			if(HEAD)
				apply_damage(2.5*discomfort, BURN, "head")
			if(UPPER_TORSO)
				apply_damage(2.5*discomfort, BURN, "chest")
			if(LEGS)
				apply_damage(0.6*discomfort, BURN, "l_leg")
				apply_damage(0.6*discomfort, BURN, "r_leg")
			if(ARMS)
				apply_damage(0.4*discomfort, BURN, "l_arm")
				apply_damage(0.4*discomfort, BURN, "r_arm")
	*/

	proc/get_covered_bodyparts()
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

	proc/handle_chemicals_in_body()

		if(reagents && !(species.flags & IS_SYNTHETIC)) //Synths don't process reagents.
			var/alien = 0
			if(species && species.reagent_tag)
				alien = species.reagent_tag
			reagents.metabolize(src,alien)

			var/total_plasmaloss = 0
			for(var/obj/item/I in src)
				if(I.contaminated)
					total_plasmaloss += vsc.plc.CONTAMINATION_LOSS
			if(!(status_flags & GODMODE)) adjustToxLoss(total_plasmaloss)

		if(status_flags & GODMODE)	return 0	//godmode

		if(species.flags & REQUIRE_LIGHT)
			var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
			if(isturf(loc)) //else, there's considered to be no light
				var/turf/T = loc
				var/area/A = T.loc
				if(A)
					if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5 //hardcapped so it's not abused by having a ton of flashlights
					else						light_amount =  5
			nutrition += light_amount
			traumatic_shock -= light_amount

			if(species.flags & IS_PLANT)
				if(nutrition > 450)
					nutrition = 450
				if(light_amount >= 5) //if there's enough light, heal
					adjustBruteLoss(-(light_amount/2))
					adjustFireLoss(-(light_amount/4))
					//adjustToxLoss(-(light_amount))
					adjustOxyLoss(-(light_amount))
					//TODO: heal wounds, heal broken limbs.

		if(dna && dna.mutantrace == "shadow")
			var/light_amount = 0
			if(isturf(loc))
				var/turf/T = loc
				var/area/A = T.loc
				if(A)
					if(A.lighting_use_dynamic)	light_amount = T.lighting_lumcount
					else						light_amount =  10
			if(light_amount > 2) //if there's enough light, start dying
				take_overall_damage(1,1)
			else if (light_amount < 2) //heal in the dark
				heal_overall_damage(1,1)

		//The fucking FAT mutation is the greatest shit ever. It makes everyone so hot and bothered.
		if(species.flags & CAN_BE_FAT)
			if(FAT in mutations)
				if(overeatduration < 100)
					src << "\blue You feel fit again!"
					mutations.Remove(FAT)
					update_mutantrace(0)
					update_mutations(0)
					update_inv_w_uniform(0)
					update_inv_wear_suit()
			else
				if(overeatduration > 500)
					src << "\red You suddenly feel blubbery!"
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

		if(!(species.flags & IS_SYNTHETIC)) handle_trace_chems()

		updatehealth()

		return //TODO: DEFERRED

	proc/handle_regular_status_updates()

		if(status_flags & GODMODE)	return 0

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
				stabilize_body_temperature()	//Body temperature adjusts itself
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
				if(!reagents.has_reagent("inaprovaline"))
					adjustOxyLoss(1)*/

			if(hallucination && !(species.flags & IS_SYNTHETIC))
				spawn handle_hallucinations()

				if(hallucination<=2)
					hallucination = 0
					halloss = 0
				else
					hallucination -= 2

			else
				for(var/atom/a in hallucinations)
					del a

				if(halloss > 100)
					src << "<span class='notice'>You're in too much pain to keep going...</span>"
					for(var/mob/O in oviewers(src, null))
						O.show_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.", 1)
					Paralyse(10)
					setHalLoss(99)

			if(paralysis)
				AdjustParalysis(-1)
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
					if((mind.active && client != null) || immune_to_ssd) //This also checks whether a client is connected, if not, sleep is not reduced.
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
			else if(resting)
				if(halloss > 0)
					adjustHalLoss(-3)
			//CONSCIOUS
			else
				stat = CONSCIOUS
				if(halloss > 0)
					adjustHalLoss(-1)

			if(embedded_flag && !(life_tick % 10))
				var/list/E
				E = get_visible_implants(0)
				if(!E.len)
					embedded_flag = 0


			//Eyes
			if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
				blinded = 1
			else if(eye_blind)			//blindness, heals slowly over time
				eye_blind = max(eye_blind-1,0)
				blinded = 1
			else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold))	//resting your eyes with a blindfold heals blurry eyes faster
				eye_blurry = max(eye_blurry-3, 0)
				blinded = 1
			else if(eye_blurry)	//blurry eyes heal slowly
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

			//Other
			handle_statuses()

			// If you're dirty, your gloves will become dirty, too.
			if(gloves && germ_level > gloves.germ_level && prob(10))
				gloves.germ_level += 1

			CheckStamina()

		return 1

	proc/handle_regular_hud_updates()
		if(hud_updateflag)
			handle_hud_list()


		if(!client)	return 0

		if(hud_updateflag)
			handle_hud_list()

		for(var/image/hud in client.images)
			if(copytext(hud.icon_state,1,4) == "hud") //ugly, but icon comparison is worse, I believe
				client.images.Remove(hud)

		client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask,/* global_hud.nvg*/)

		update_action_buttons()

		if(damageoverlay.overlays)
			damageoverlay.overlays = list()

		if(stat == UNCONSCIOUS)
			//Critical damage passage overlay
			if(health <= 0)
				//var/image/I
				switch(health)
					if(-20 to -10)
						damageoverlay.overlays += unconscious_overlays["1"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage1")
					if(-30 to -20)
						damageoverlay.overlays +=  unconscious_overlays["2"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage2")
					if(-40 to -30)
						damageoverlay.overlays +=  unconscious_overlays["3"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage3")
					if(-50 to -40)
						damageoverlay.overlays +=  unconscious_overlays["4"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage4")
					if(-60 to -50)
						damageoverlay.overlays +=  unconscious_overlays["5"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage5")
					if(-70 to -60)
						damageoverlay.overlays +=  unconscious_overlays["6"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage6")
					if(-80 to -70)
						damageoverlay.overlays +=  unconscious_overlays["7"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage7")
					if(-90 to -80)
						damageoverlay.overlays +=  unconscious_overlays["8"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage8")
					if(-95 to -90)
						damageoverlay.overlays +=  unconscious_overlays["9"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage9")
					if(-INFINITY to -95)
						damageoverlay.overlays +=  unconscious_overlays["10"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage10")
				//damageoverlay.overlays += I
		else
			//Oxygen damage overlay
			if(oxyloss)
				//var/image/I
				switch(oxyloss)
					if(10 to 20)
						damageoverlay.overlays += oxyloss_overlays["1"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay1")
					if(20 to 25)
						damageoverlay.overlays += oxyloss_overlays["2"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay2")
					if(25 to 30)
						damageoverlay.overlays += oxyloss_overlays["3"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay3")
					if(30 to 35)
						damageoverlay.overlays += oxyloss_overlays["4"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay4")
					if(35 to 40)
						damageoverlay.overlays += oxyloss_overlays["5"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay5")
					if(40 to 45)
						damageoverlay.overlays += oxyloss_overlays["6"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay6")
					if(45 to INFINITY)
						damageoverlay.overlays += oxyloss_overlays["7"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay7")
				//damageoverlay.overlays += I

			//Fire and Brute damage overlay (BSSR)
			var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp
			damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
			if(hurtdamage)
				//var/image/I
				switch(hurtdamage)
					if(10 to 25)
						damageoverlay.overlays += brutefireloss_overlays["1"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay1")
					if(25 to 40)
						damageoverlay.overlays += brutefireloss_overlays["2"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay2")
					if(40 to 55)
						damageoverlay.overlays += brutefireloss_overlays["3"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay3")
					if(55 to 70)
						damageoverlay.overlays += brutefireloss_overlays["4"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay4")
					if(70 to 85)
						damageoverlay.overlays += brutefireloss_overlays["5"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay5")
					if(85 to INFINITY)
						damageoverlay.overlays += brutefireloss_overlays["6"]//image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay6")
				//damageoverlay.overlays += I
		if( stat == DEAD )
			sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
			see_in_dark = 8
			if(!druggy)		see_invisible = SEE_INVISIBLE_LEVEL_TWO
			if(healths)		healths.icon_state = "health7"	//DEAD healthmeter
		else
			sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)
			if(dna)
				switch(dna.mutantrace)
					if("slime")
						see_in_dark = 3
						see_invisible = SEE_INVISIBLE_LEVEL_ONE
					if("shadow")
						see_in_dark = 8
						see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

			if(mind && mind.vampire)
				if((VAMP_VISION in mind.vampire.powers) && !(VAMP_FULL in mind.vampire.powers))
					sight |= SEE_MOBS
				if((VAMP_FULL in mind.vampire.powers))
					sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
					see_in_dark = 8
					if(!druggy)		see_invisible = SEE_INVISIBLE_LEVEL_TWO
			if(XRAY in mutations)
				sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
				see_in_dark = 8
				if(!druggy)		see_invisible = SEE_INVISIBLE_LEVEL_TWO

			if(seer==1)
				var/obj/effect/rune/R = locate() in loc
				if(R && R.word1 == cultwords["see"] && R.word2 == cultwords["hell"] && R.word3 == cultwords["join"])
					see_invisible = SEE_INVISIBLE_OBSERVER
				else
					see_invisible = SEE_INVISIBLE_LIVING
					seer = 0

			if(glasses)
				var/obj/item/clothing/glasses/G = glasses
				if(istype(G))
					see_in_dark += G.darkness_view
					if(G.vision_flags)		// MESONS
						sight |= G.vision_flags
						if(!druggy)
							see_invisible = SEE_INVISIBLE_MINIMUM
					if(istype(G,/obj/item/clothing/glasses/night))
						see_invisible = SEE_INVISIBLE_MINIMUM
	/* HUD shit goes here, as long as it doesn't modify sight flags */
	// The purpose of this is to stop xray and w/e from preventing you from using huds -- Love, Doohl

				if(istype(glasses, /obj/item/clothing/glasses/sunglasses))
					see_in_dark = 1
					if(istype(glasses, /obj/item/clothing/glasses/sunglasses/sechud))
						var/obj/item/clothing/glasses/sunglasses/sechud/O = glasses
						if(O.hud)		O.hud.process_hud(src)
						if(!druggy)		see_invisible = SEE_INVISIBLE_LIVING

				if(istype(glasses, /obj/item/clothing/glasses/hud))
					var/obj/item/clothing/glasses/hud/O = glasses
					O.process_hud(src)
					if(!druggy)
						see_invisible = SEE_INVISIBLE_LIVING
					if(istype(O,/obj/item/clothing/glasses/hud/security/night) || istype(O,/obj/item/clothing/glasses/hud/health/night))
						see_invisible = SEE_INVISIBLE_MINIMUM
			else if(!seer)
				see_in_dark = species.darksight
				see_invisible = SEE_INVISIBLE_LIVING

			if(ticker && ticker.mode.name == "nations")
				process_nations()

			if(healths)
				if (analgesic)
					healths.icon_state = "health_health_numb"
				else
					switch(hal_screwyhud)
						if(1)	healths.icon_state = "health6"
						if(2)	healths.icon_state = "health7"
						else
							//switch(health - halloss)
							switch(100 - ((species && species.flags & NO_PAIN) ? 0 : traumatic_shock) - staminaloss)
								if(100 to INFINITY)		healths.icon_state = "health0"
								if(80 to 100)			healths.icon_state = "health1"
								if(60 to 80)			healths.icon_state = "health2"
								if(40 to 60)			healths.icon_state = "health3"
								if(20 to 40)			healths.icon_state = "health4"
								if(0 to 20)				healths.icon_state = "health5"
								else					healths.icon_state = "health6"

			if(healthdoll)
				healthdoll.overlays.Cut()
				if(stat == DEAD)
					healthdoll.icon_state = "healthdoll_DEAD"
				else
					healthdoll.icon_state = "healthdoll_OVERLAY"
					for(var/datum/organ/external/O in organs)
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
						if(icon_num)
							healthdoll.overlays += image('icons/mob/screen_gen.dmi',"[O.name][icon_num]")

			if(nutrition_icon)
				switch(nutrition)
					if(450 to INFINITY)				nutrition_icon.icon_state = "nutrition0"
					if(350 to 450)					nutrition_icon.icon_state = "nutrition1"
					if(250 to 350)					nutrition_icon.icon_state = "nutrition2"
					if(150 to 250)					nutrition_icon.icon_state = "nutrition3"
					else							nutrition_icon.icon_state = "nutrition4"

			if(pressure)
				pressure.icon_state = "pressure[pressure_alert]"

			if(pullin)
				if(pulling)								pullin.icon_state = "pull1"
				else									pullin.icon_state = "pull0"
//			if(rest)	//Not used with new UI
//				if(resting || lying || sleeping)		rest.icon_state = "rest1"
//				else									rest.icon_state = "rest0"
			if(toxin)
				if(hal_screwyhud == 4 || toxins_alert)	toxin.icon_state = "tox1"
				else									toxin.icon_state = "tox0"
			if(oxygen)
				if(hal_screwyhud == 3 || oxygen_alert)	oxygen.icon_state = "oxy1"
				else									oxygen.icon_state = "oxy0"
			if(fire)
				if(fire_alert)							fire.icon_state = "fire[fire_alert]" //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
				else									fire.icon_state = "fire0"

			if(bodytemp)
				if (!species)
					switch(bodytemperature) //310.055 optimal body temp
						if(370 to INFINITY)		bodytemp.icon_state = "temp4"
						if(350 to 370)			bodytemp.icon_state = "temp3"
						if(335 to 350)			bodytemp.icon_state = "temp2"
						if(320 to 335)			bodytemp.icon_state = "temp1"
						if(300 to 320)			bodytemp.icon_state = "temp0"
						if(295 to 300)			bodytemp.icon_state = "temp-1"
						if(280 to 295)			bodytemp.icon_state = "temp-2"
						if(260 to 280)			bodytemp.icon_state = "temp-3"
						else					bodytemp.icon_state = "temp-4"
				else
					var/temp_step
					if (bodytemperature >= species.body_temperature)
						temp_step = (species.heat_level_1 - species.body_temperature)/4

						if (bodytemperature >= species.heat_level_1)
							bodytemp.icon_state = "temp4"
						else if (bodytemperature >= species.body_temperature + temp_step*3)
							bodytemp.icon_state = "temp3"
						else if (bodytemperature >= species.body_temperature + temp_step*2)
							bodytemp.icon_state = "temp2"
						else if (bodytemperature >= species.body_temperature + temp_step*1)
							bodytemp.icon_state = "temp1"
						else
							bodytemp.icon_state = "temp0"

					else if (bodytemperature < species.body_temperature)
						temp_step = (species.body_temperature - species.cold_level_1)/4

						if (bodytemperature <= species.cold_level_1)
							bodytemp.icon_state = "temp-4"
						else if (bodytemperature <= species.body_temperature - temp_step*3)
							bodytemp.icon_state = "temp-3"
						else if (bodytemperature <= species.body_temperature - temp_step*2)
							bodytemp.icon_state = "temp-2"
						else if (bodytemperature <= species.body_temperature - temp_step*1)
							bodytemp.icon_state = "temp-1"
						else
							bodytemp.icon_state = "temp0"
			if(blind)
				if(blinded)		blind.layer = 18
				else			blind.layer = 0

			if(disabilities & NEARSIGHTED)	//this looks meh but saves a lot of memory by not requiring to add var/prescription
				if(glasses)					//to every /obj/item
					var/obj/item/clothing/glasses/G = glasses
					if(!G.prescription)
						client.screen += global_hud.vimpaired
				else
					client.screen += global_hud.vimpaired

			if(eye_blurry)			client.screen += global_hud.blurry
			if(druggy)				client.screen += global_hud.druggy

			var/masked = 0

			if( istype(head, /obj/item/clothing/head/welding) || istype(head, /obj/item/clothing/head/helmet/space/unathi))
				var/obj/item/clothing/head/welding/O = head
				if(!O.up && tinted_weldhelh)
					client.screen += global_hud.darkMask
					masked = 1

			if(!masked && istype(glasses, /obj/item/clothing/glasses/welding) )
				var/obj/item/clothing/glasses/welding/O = glasses
				if(!O.up && tinted_weldhelh)
					client.screen += global_hud.darkMask

			if(machine)
				if(!machine.check_eye(src))		reset_view(null)
			else
				var/isRemoteObserve = 0
				if((REMOTE_VIEW in mutations) && remoteview_target)
					isRemoteObserve = 1
					// Is he unconscious or dead?
					if(remoteview_target.stat!=CONSCIOUS)
						src << "\red Your psy-connection grows too faint to maintain!"
						isRemoteObserve = 0

					// Does he have psy resist?
					if(PSY_RESIST in remoteview_target.mutations)
						src << "\red Your mind is shut out!"
						isRemoteObserve = 0

					// Not on the station or mining?
					var/turf/temp_turf = get_turf(remoteview_target)
					if((!(temp_turf.z in config.contact_levels)) || remoteview_target.stat!=CONSCIOUS)
						src << "\red Your psy-connection grows too faint to maintain!"
						isRemoteObserve = 0
				if(!isRemoteObserve && client && !client.adminobs)
					remoteview_target = null
					reset_view(null)
		return 1

	proc/handle_random_events()
		// Puke if toxloss is too high
		if(!stat)
			if (getToxLoss() >= 45 && nutrition > 20)
				vomit()

		//0.1% chance of playing a scary sound to someone who's in complete darkness
		if(isturf(loc) && rand(1,1000) == 1)
			var/turf/currentTurf = loc
			if(!currentTurf.lighting_lumcount)
				playsound_local(src,pick(scarySounds),50, 1, -1)

	// Separate proc so we can jump out of it when we've succeeded in spreading disease.
	proc/findAirborneVirii()
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

	proc/handle_virus_updates()
		if(status_flags & GODMODE)	return 0	//godmode
		if(bodytemperature > 406)
			for (var/ID in virus2)
				var/datum/disease2/disease/V = virus2[ID]
				V.cure(src)
		if(life_tick % 3) //don't spam checks over all objects in view every tick.
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

	proc/handle_stomach()
		spawn(0)
			for(var/mob/living/M in stomach_contents)
				if(M.loc != src)
					stomach_contents.Remove(M)
					continue
				if(isliving(M) && stat != 2)
					if(M.stat == 2)
						M.death(1)
						stomach_contents.Remove(M)
						del(M)
						continue
					if(air_master.current_cycle%3==1)
						if(!(M.status_flags & GODMODE))
							M.adjustBruteLoss(5)
						nutrition += 10

	proc/handle_changeling()
		if(mind && mind.changeling)
			mind.changeling.regenerate()

	handle_shock()
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
			if(shock_stage == 30) emote("me",1,"is having trouble keeping their eyes open.")
			eye_blurry = max(2, eye_blurry)
			stuttering = max(stuttering, 5)

		if(shock_stage == 40)
			src << "<font color='red'><b>"+pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")

		if(shock_stage >=60)
			if(shock_stage == 60) emote("me",1,"'s body becomes limp.")
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
			emote("me",1,"can no longer stand, collapsing!")
			Weaken(20)

		if(shock_stage >= 150)
			Weaken(20)


	proc/handle_pulse()

		if(life_tick % 5) return pulse	//update pulse every 5 life ticks (~1 tick/sec, depending on server load)

		if(species && species.flags & NO_BLOOD) return PULSE_NONE //No blood, no pulse.

		if(stat == DEAD)
			return PULSE_NONE	//that's it, you're dead, nothing can influence your pulse

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
				if(R.volume >= R.overdose)
					temp = PULSE_NONE
					break

		return temp

	proc/handle_decay()
		var/decaytime = world.time - timeofdeath

		if(species.flags & IS_SYNTHETIC)
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
					H << "<spawn class='warning'>You smell something foul..."
					H.vomit()

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
	update_power_buttons()
	hud_updateflag = 0

/mob/living/carbon/human/proc/process_nations()
	var/client/C = client
	for(var/mob/living/carbon/human/H in view(src, 14))
		C.images += H.hud_list[NATIONS_HUD]

/mob/living/carbon/human/handle_silent()
	if(..())
		speech_problem_flag = 1
	return silent

/mob/living/carbon/human/handle_slurring()
	if(..())
		speech_problem_flag = 1
	return slurring

/mob/living/carbon/human/handle_stunned()
	if(species.flags & NO_PAIN)
		stunned = 0
		return 0
	if(..())
		speech_problem_flag = 1
	return stunned

/mob/living/carbon/human/handle_stuttering()
	if(..())
		speech_problem_flag = 1
	return stuttering

// Need this in species.
//#undef HUMAN_MAX_OXYLOSS
//#undef HUMAN_CRIT_MAX_OXYLOSS
