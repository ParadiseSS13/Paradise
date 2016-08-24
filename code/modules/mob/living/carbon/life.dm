/mob/living/carbon/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if(notransform)
		return
	if(!loc)
		return

	if(..())
		. = 1
		for(var/obj/item/organ/internal/O in internal_organs)
			O.on_life()
		handle_changeling()

	handle_wetness()

	// Increase germ_level regularly
	if(germ_level < GERM_LEVEL_AMBIENT && prob(30))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
		germ_level++


///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing()
	if(mob_master.current_cycle%4==2 || failed_last_breath)
		breathe() //Breathe per 4 ticks, unless suffocating
	else
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe()
	if(reagents.has_reagent("lexorin"))
		return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return
	if(NO_BREATH in mutations)
		return // No breath mutation means no breathing.

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(health <= config.health_threshold_crit)
		AdjustLoseBreath(1)

	if(losebreath > 0)
		AdjustLoseBreath(-1)
		if(prob(10))
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src, 0)
	else
		//Breathe from internal
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

		else //Breathe from loc as obj again
			if(istype(loc, /obj/))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	check_breath(breath)

	if(breath)
		loc.assume_air(breath)
		air_update_turf()

//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return 0

	//CRIT
	if(!breath || (breath.total_moles() == 0))
		adjustOxyLoss(1)
		failed_last_breath = 1
		throw_alert("oxy", /obj/screen/alert/oxy)
		return 0

	var/safe_oxy_min = 16
	var/safe_co2_max = 10
	var/safe_tox_max = 0.05
	var/SA_para_min = 1
	var/SA_sleep_min = 1
	var/oxygen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	var/O2_partialpressure = (breath.oxygen/breath.total_moles())*breath_pressure
	var/Toxins_partialpressure = (breath.toxins/breath.total_moles())*breath_pressure
	var/CO2_partialpressure = (breath.carbon_dioxide/breath.total_moles())*breath_pressure


	//OXYGEN
	if(O2_partialpressure < safe_oxy_min) //Not enough oxygen
		if(prob(20))
			spawn(0)
				emote("gasp")
		if(O2_partialpressure > 0)
			var/ratio = safe_oxy_min/O2_partialpressure
			adjustOxyLoss(min(5*ratio, 3))
			failed_last_breath = 1
			oxygen_used = breath.oxygen*ratio/6
		else
			adjustOxyLoss(3)
			failed_last_breath = 1
		throw_alert("oxy", /obj/screen/alert/oxy)

	else //Enough oxygen
		failed_last_breath = 0
		adjustOxyLoss(-5)
		oxygen_used = breath.oxygen/6
		clear_alert("oxy")

	breath.oxygen -= oxygen_used
	breath.carbon_dioxide += oxygen_used

	//CARBON DIOXIDE
	if(CO2_partialpressure > safe_co2_max)
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Paralyse(3)
			adjustOxyLoss(3)
			if(world.time - co2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			spawn(0) emote("cough")
	else
		co2overloadtime = 0

	//TOXINS/PLASMA
	if(Toxins_partialpressure > safe_tox_max)
		var/ratio = (breath.toxins/safe_tox_max) * 10
		if(reagents)
			reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		throw_alert("tox_in_air", /obj/screen/alert/tox_in_air)
	else
		clear_alert("tox_in_air")

	//TRACE GASES
	if(breath.trace_gases.len)
		for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
			var/SA_partialpressure = (SA.moles/breath.total_moles())*breath_pressure
			if(SA_partialpressure > SA_para_min)
				Paralyse(3)
				if(SA_partialpressure > SA_sleep_min)
					AdjustSleeping(2, bound_lower = 0, bound_upper = 10)
			else if(SA_partialpressure > 0.01)
				if(prob(20))
					spawn(0) emote(pick("giggle","laugh"))

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	return 1

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	return

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if(internal.loc != src)
			internal = null
		if(!wear_mask || !(wear_mask.flags & AIRTIGHT)) //not wearing mask or non-breath mask
			if(!head || !(head.flags & AIRTIGHT)) //not wearing helmet or non-breath helmet
				internal = null //turn off internals

		if(internal)
			update_internals_hud_icon(1)
			return internal.remove_air_volume(volume_needed)
		else
			update_internals_hud_icon(0)

	return

//remember to remove the "proc" of the child procs of these.

/mob/living/carbon/proc/handle_changeling()
	return

/mob/living/carbon/handle_radiation()
	if(radiation)

		switch(radiation)
			if(0 to 50)
				radiation--
				if(prob(25))
					adjustToxLoss(1)
					updatehealth()

			if(50 to 75)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
				updatehealth()

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				updatehealth()

		radiation = Clamp(radiation, 0, 100)


/mob/living/carbon/handle_chemicals_in_body()
	if(reagents)
		reagents.metabolize(src)


/mob/living/carbon/proc/handle_wetness()
	if(mob_master.current_cycle%20==2) //dry off a bit once every 20 ticks or so
		wetlevel = max(wetlevel - 1,0)

/mob/living/carbon/handle_stomach()
	spawn(0)
		for(var/mob/living/M in stomach_contents)
			if(M.loc != src)
				stomach_contents.Remove(M)
				continue
			if(istype(M, /mob/living) && stat != 2)
				if(M.stat == 2)
					M.death(1)
					stomach_contents.Remove(M)
					qdel(M)
					continue
				if(mob_master.current_cycle%3==1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10

//this updates all special effects: stunned, sleeping, weakened, druggy, stuttering, etc..
/mob/living/carbon/handle_status_effects()
	..()
	adjustStaminaLoss(-3)

	// Dizziness, drowsiness, and jitteriness all recover 5x faster when resting
	var/restingpwr = 1 + 4 * resting

	//Dizziness
	if(dizziness)
		dizzy_animation()
		AdjustDizzy(-restingpwr)

	if(drowsy)
		AdjustDrowsy(-restingpwr)
		EyeBlurry(2)
		if(prob(5))
			AdjustSleeping(1)
			Paralyse(5)
	//Jitteryness
	if(jitteriness)
		do_jitter_animation(jitteriness)
		AdjustJitter(-restingpwr)

	if(confused)
		AdjustConfused(-1)

	if(hallucination)
		spawn handle_hallucinations()
		// This was formerly clocked at -2 per tick, not sure why
		AdjustHallucinate(-1)

/mob/living/carbon/handle_sleeping()
	if(..())
		handle_dreams()
		adjustStaminaLoss(-10)
		if(prob(10) && health && !hal_crit)
			spawn(0)
				emote("snore")
	// Keep SSD people asleep
	if(player_logged)
		Sleeping(2)
	return sleeping

/mob/living/carbon/proc/dizzy_animation()
	var/client/C = client
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/temp
	var/saved_dizz = dizziness
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

/mob/living/carbon/update_sight()
	if(stat == DEAD)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		if(XRAY in mutations)
			sight |= SEE_TURFS
			sight |= SEE_MOBS
			sight |= SEE_OBJS
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_LEVEL_TWO

		else
			see_in_dark = 2
			see_invisible = SEE_INVISIBLE_LIVING

		if(see_override)
			see_invisible = see_override

/mob/living/carbon/handle_eyes_update()
	//Eyes
	if(!(disabilities & BLIND))	//disabled-blind, doesn't get better on its own
		if(eye_blind)
			AdjustEyeBlind(-1)
		else
			AdjustEyeBlurry(-1)

/mob/living/carbon/handle_ears_update()
	//Ears
	if(!(disabilities & DEAF))	//disabled-deaf, doesn't get better on its own
		if(ear_deaf)			//deafness, heals slowly over time
			AdjustEarDeaf(-1)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold.
			AdjustEarDamage(-0.05)
