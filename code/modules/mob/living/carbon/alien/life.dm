/mob/living/carbon/alien/check_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles() == 0))
		//Aliens breathe in vaccuum
		return FALSE

	var/toxins_used = 0
	var/tox_detect_threshold = 0.02
	var/breath_pressure = (breath.total_moles() * R_IDEAL_GAS_EQUATION * breath.temperature) / BREATH_VOLUME

	//Partial pressure of the toxins in our breath
	var/Toxins_pp = (breath.toxins / breath.total_moles()) * breath_pressure

	if(Toxins_pp > tox_detect_threshold) // Detect toxins in air
		adjustPlasma(breath.toxins*250)
		throw_alert("alien_tox", /obj/screen/alert/alien_tox)

		toxins_used = breath.toxins

	else
		clear_alert("alien_tox")

	//Breathe in toxins and out oxygen
	breath.toxins -= toxins_used
	breath.oxygen += toxins_used

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

/mob/living/carbon/alien/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		grant_death_vision()
		return

	sight = SEE_MOBS
	if(nightvision)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else
		see_in_dark = 4
		see_invisible = SEE_INVISIBLE_LEVEL_TWO

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	for(var/obj/item/organ/internal/cyberimp/eyes/E in internal_organs)
		sight |= E.vision_flags
		if(E.dark_view)
			see_in_dark = max(see_in_dark, E.dark_view)
		if(E.see_invisible)
			see_invisible = min(see_invisible, E.see_invisible)

	if(see_override)
		see_invisible = see_override
