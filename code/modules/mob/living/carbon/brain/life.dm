/mob/living/carbon/brain/handle_mutations_and_radiation()
	if(radiation)
		if(radiation > 100)
			radiation -= 3
			adjustToxLoss(3)
			updatehealth()
			if(!container)
				src << "<span class='danger'>You feel weak.</span>"
			else
				src << "<span class='danger'>STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED.</span>"

		switch(radiation)
			if(0 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)
					updatehealth()

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
					if(!container)
						src << "<span class='danger'>You feel weak.</span>"
					else
						src << "<span class='danger'>STATUS: DANGEROUS AMOUNTS OF RADIATION DETECTED.</span>"
				updatehealth()

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				updatehealth()

/mob/living/carbon/brain/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return
	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
		var/transfer_coefficient = 1

		handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

	if(stat == DEAD)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

/mob/living/carbon/brain/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE)
		return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		//adjustFireLoss(2.5*discomfort)
		//adjustFireLoss(5.0*discomfort)
		adjustFireLoss(20.0*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		//adjustFireLoss(2.5*discomfort)
		adjustFireLoss(5.0*discomfort)

/mob/living/carbon/brain/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)
		blinded = 1
		silent = 0
	else
		if(!container && (health < config.health_threshold_dead || ((world.time - timeofhostdeath) > config.revival_brain_life)))
			death()
			blinded =1
			silent = 0
			return 1

		. = 1

/mob/living/carbon/brain/handle_vision()
	..()

	if (stat == 2 || (XRAY in src.mutations))
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if (stat != 2)
		sight &= ~SEE_TURFS
		sight &= ~SEE_MOBS
		sight &= ~SEE_OBJS
		see_in_dark = 2
		see_invisible = SEE_INVISIBLE_LIVING
	handle_hud_icons_health()
