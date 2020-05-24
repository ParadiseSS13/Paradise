/mob/living/carbon/brain/handle_mutations_and_radiation()
	if(radiation)
		if(radiation > 100)
			if(!container)
				to_chat(src, "<span class='danger'>You feel weak.</span>")
			else
				to_chat(src, "<span class='danger'>STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED.</span>")

		switch(radiation)

			if(50 to 75)
				if(prob(5))
					if(!container)
						to_chat(src, "<span class='danger'>You feel weak.</span>")
					else
						to_chat(src, "<span class='danger'>STATUS: DANGEROUS AMOUNTS OF RADIATION DETECTED.</span>")
		..()

/mob/living/carbon/brain/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE)
		return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(20.0*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(5.0*discomfort)

/mob/living/carbon/brain/handle_regular_status_updates()
	. = ..()

	if(.)
		if(!container && (health < HEALTH_THRESHOLD_DEAD && check_death_method() || ((world.time - timeofhostdeath) > config.revival_brain_life)))
			death()
			return 0

/mob/living/carbon/brain/breathe()
	return
