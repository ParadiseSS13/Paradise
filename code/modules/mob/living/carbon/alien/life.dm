/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return 0

	var/toxins_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	//Partial pressure of the toxins in our breath
	var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure

	if(Toxins_pp) // Detect toxins in air
		adjustPlasma(breath.toxins*250)
		toxins_alert = max(toxins_alert, 1)

		toxins_used = breath.toxins

	else
		toxins_alert = 0

	//Breathe in toxins and out oxygen
	breath.toxins -= toxins_used
	breath.oxygen += toxins_used

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	return 1

/mob/living/carbon/alien/handle_breath_temperature(datum/gas_mixture/breath)
	if(breath.temperature > (T0C + 66) && !(RESIST_COLD in mutations))
		if(prob(20))
			src << "<span class='danger'>You feel a searing heat in your lungs!</span>"
		fire_alert = max(fire_alert, 1)
	else
		fire_alert = 0