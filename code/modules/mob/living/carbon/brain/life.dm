/mob/living/carbon/brain/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE)
		return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(20.0*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(5.0*discomfort)

/mob/living/carbon/brain/Life()
	. = ..()
	if(.)
		if(!container && (world.time - timeofhostdeath) > GLOB.configuration.general.revival_brain_life)
			death()

/mob/living/carbon/brain/breathe()
	return
