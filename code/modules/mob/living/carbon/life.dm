/mob/living/carbon/Life(seconds, times_fired)
	set invisibility = 0

	if(notransform)
		return

	if(damageoverlaytemp)
		damageoverlaytemp = 0
		update_damage_hud()

	if(stat != DEAD)
		handle_organs()

	//stuff in the stomach
	if(LAZYLEN(stomach_contents))
		handle_stomach(times_fired)

	. = ..()

	if(QDELETED(src))
		return

	if(.) //not dead
		handle_blood()

	if(LAZYLEN(processing_patches))
		handle_patches()
	if(mind)
		handle_changeling()
	handle_wetness(times_fired)

	// Increase germ_level regularly
	handle_germs()

	if(stat != DEAD)
		return TRUE


///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing(times_fired)
	if(times_fired % 2 == 1)
		breathe() //Breathe every other tick, unless suffocating
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

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(health <= HEALTH_THRESHOLD_CRIT && check_death_method())
		AdjustLoseBreath(1)

	//Suffocate
	if(losebreath > 0)
		AdjustLoseBreath(-1)
		if(prob(75))
			emote("gasp")
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
		return FALSE

	var/lungs = get_organ_slot("lungs")
	if(!lungs)
		adjustOxyLoss(2)

	//CRIT
	if(!breath || (breath.total_moles() == 0) || !lungs)
		adjustOxyLoss(1)
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		return FALSE

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
	var/SA_partialpressure = (breath.sleeping_agent/breath.total_moles())*breath_pressure

	//OXYGEN
	if(O2_partialpressure < safe_oxy_min) //Not enough oxygen
		if(prob(20))
			emote("gasp")
		if(O2_partialpressure > 0)
			var/ratio = 1 - O2_partialpressure/safe_oxy_min
			adjustOxyLoss(min(5*ratio, 3))
			oxygen_used = breath.oxygen*ratio
		else
			adjustOxyLoss(3)
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)

	else //Enough oxygen
		adjustOxyLoss(-5)
		oxygen_used = breath.oxygen
		clear_alert("not_enough_oxy")

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
			emote("cough")

	else
		co2overloadtime = 0

	//TOXINS/PLASMA
	if(Toxins_partialpressure > safe_tox_max)
		var/ratio = (breath.toxins/safe_tox_max) * 10
		adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
	else
		clear_alert("too_much_tox")

	//TRACE GASES
	if(breath.sleeping_agent)
		if(SA_partialpressure > SA_para_min)
			Paralyse(3)
			if(SA_partialpressure > SA_sleep_min)
				AdjustSleeping(2, bound_lower = 0, bound_upper = 10)
		else if(SA_partialpressure > 0.01)
			if(prob(20))
				emote(pick("giggle","laugh"))

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	return TRUE

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	return

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if(internal.loc != src)
			internal = null
		if(!get_organ_slot("breathing_tube"))
			if(!wear_mask || !(wear_mask.flags & AIRTIGHT)) //not wearing mask or non-breath mask
				if(!head || !(head.flags & AIRTIGHT)) //not wearing helmet or non-breath helmet
					internal = null //turn off internals

		if(internal)
			return internal.remove_air_volume(volume_needed)
		else
			update_action_buttons_icon()

/mob/living/carbon/proc/handle_organs()
	for(var/thing in internal_organs)
		var/obj/item/organ/internal/O = thing
		O.on_life()

/mob/living/carbon/handle_diseases()
	for(var/thing in viruses)
		var/datum/disease/D = thing
		if(prob(D.infectivity))
			D.spread()

		if(stat != DEAD)
			D.stage_act()

//remember to remove the "proc" of the child procs of these.
/mob/living/carbon/proc/handle_blood()
	return

/mob/living/carbon/proc/handle_changeling()
	return

/mob/living/carbon/handle_mutations_and_radiation()
	if(radiation)

		switch(radiation)
			if(0 to 50)
				radiation--
				if(prob(25))
					adjustToxLoss(1)
					updatehealth("handle mutations and radiation(0-50)")

			if(50 to 75)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
				updatehealth("handle mutations and radiation(50-75)")

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				updatehealth("handle mutations and radiation(75-100)")

		radiation = clamp(radiation, 0, 100)


/mob/living/carbon/handle_chemicals_in_body()
	reagents.metabolize(src)


/mob/living/carbon/proc/handle_wetness(times_fired)
	if(times_fired % 20==2) //dry off a bit once every 20 ticks or so
		wetlevel = max(wetlevel - 1,0)

/mob/living/carbon/proc/handle_stomach(times_fired)
	for(var/thing in stomach_contents)
		var/mob/living/M = thing
		if(M.loc != src)
			LAZYREMOVE(stomach_contents, M)
			continue
		if(stat != DEAD)
			if(M.stat == DEAD)
				LAZYREMOVE(stomach_contents, M)
				qdel(M)
				continue
			if(times_fired % 3 == 1)
				M.adjustBruteLoss(5)
				adjust_nutrition(10)

//this updates all special effects: stunned, sleeping, weakened, druggy, stuttering, etc..
/mob/living/carbon/handle_status_effects()
	..()
	if(stam_regen_start_time <= world.time)
		if(stam_paralyzed)
			update_stamina()
		if(staminaloss)
			setStaminaLoss(0, FALSE)
			update_health_hud()

	var/restingpwr = 1 + 4 * resting

	//Dizziness
	if(dizziness)
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
		AdjustDizzy(-restingpwr)

	if(drowsyness)
		AdjustDrowsy(-restingpwr)
		EyeBlurry(2)
		if(prob(5))
			AdjustSleeping(1)
			Paralyse(5)

	if(confused)
		AdjustConfused(-1)

	//Jitteryness
	if(jitteriness)
		do_jitter_animation(jitteriness)
		AdjustJitter(-restingpwr)

	if(hallucination)
		spawn handle_hallucinations()

		AdjustHallucinate(-2)

	// Keep SSD people asleep
	if(player_logged)
		Sleeping(2)

/mob/living/carbon/handle_sleeping()
	if(..())
		if(mind?.vampire)
			if(istype(loc, /obj/structure/closet/coffin))
				adjustBruteLoss(-1, FALSE)
				adjustFireLoss(-1, FALSE)
				adjustToxLoss(-1)
		handle_dreams()
		adjustStaminaLoss(-10)
		var/comfort = 1
		if(istype(buckled, /obj/structure/bed))
			var/obj/structure/bed/bed = buckled
			comfort+= bed.comfort
		for(var/obj/item/bedsheet/bedsheet in range(loc,0))
			if(bedsheet.loc != loc) //bedsheets in your backpack/neck don't give you comfort
				continue
			comfort+= bedsheet.comfort
			break //Only count the first bedsheet
		if(drunk)
			comfort += 1 //Aren't naps SO much better when drunk?
			AdjustDrunk(-0.2*comfort) //reduce drunkenness while sleeping.
		if(comfort > 1 && prob(3))//You don't heal if you're just sleeping on the floor without a blanket.
			adjustBruteLoss(-1 * comfort, FALSE)
			adjustFireLoss(-1 * comfort)
		if(prob(10) && health && hal_screwyhud != SCREWYHUD_CRIT)
			emote("snore")

	return sleeping

/mob/living/carbon/update_health_hud(shown_health_amount)
	if(!client)
		return

	if(healths)
		if(stat != DEAD)
			. = TRUE
			if(shown_health_amount == null)
				shown_health_amount = health
			if(shown_health_amount >= maxHealth)
				healths.icon_state = "health0"
			else if(shown_health_amount > maxHealth * 0.8)
				healths.icon_state = "health1"
			else if(shown_health_amount > maxHealth * 0.6)
				healths.icon_state = "health2"
			else if(shown_health_amount > maxHealth * 0.4)
				healths.icon_state = "health3"
			else if(shown_health_amount > maxHealth * 0.2)
				healths.icon_state = "health4"
			else if(shown_health_amount > 0)
				healths.icon_state = "health5"
			else
				healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

/mob/living/carbon/update_damage_hud()
	if(!client)
		return
	if(stat == UNCONSCIOUS && health <= HEALTH_THRESHOLD_CRIT)
		if(check_death_method())
			var/severity = 0
			switch(health)
				if(-20 to -10)
					severity = 1
				if(-30 to -20)
					severity = 2
				if(-40 to -30)
					severity = 3
				if(-50 to -40)
					severity = 4
				if(-60 to -50)
					severity = 5
				if(-70 to -60)
					severity = 6
				if(-80 to -70)
					severity = 7
				if(-90 to -80)
					severity = 8
				if(-95 to -90)
					severity = 9
				if(-INFINITY to -95)
					severity = 10
			overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
	else if(stat == CONSCIOUS)
		if(check_death_method())
			clear_fullscreen("crit")
			if(getOxyLoss())
				var/severity = 0
				switch(getOxyLoss())
					if(10 to 20)
						severity = 1
					if(20 to 25)
						severity = 2
					if(25 to 30)
						severity = 3
					if(30 to 35)
						severity = 4
					if(35 to 40)
						severity = 5
					if(40 to 45)
						severity = 6
					if(45 to INFINITY)
						severity = 7
				overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
			else
				clear_fullscreen("oxy")

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			var/severity = 0
			switch(hurtdamage)
				if(5 to 15) severity = 1
				if(15 to 30) severity = 2
				if(30 to 45) severity = 3
				if(45 to 70) severity = 4
				if(70 to 85) severity = 5
				if(85 to INFINITY) severity = 6
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

/mob/living/carbon/proc/handle_patches()
	var/multiple_patch_multiplier = processing_patches.len > 1 ? (processing_patches.len * 1.5) : 1
	var/applied_amount = 0.35 * multiple_patch_multiplier

	for(var/patch in processing_patches)
		var/obj/item/reagent_containers/food/pill/patch/P = patch

		if(P.reagents && P.reagents.total_volume)
			var/fractional_applied_amount = applied_amount  / P.reagents.total_volume
			P.reagents.reaction(src, REAGENT_TOUCH, fractional_applied_amount, P.needs_to_apply_reagents)
			P.needs_to_apply_reagents = FALSE
			P.reagents.trans_to(src, applied_amount * 0.5)
			P.reagents.remove_any(applied_amount * 0.5)
		else
			if(!P.reagents || P.reagents.total_volume <= 0)
				LAZYREMOVE(processing_patches, P)
				qdel(P)

/mob/living/carbon/proc/handle_germs()
	if(germ_level < GERM_LEVEL_AMBIENT && prob(30))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
		germ_level++
