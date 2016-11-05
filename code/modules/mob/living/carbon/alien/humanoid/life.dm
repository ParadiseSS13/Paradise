//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/alien/humanoid
	oxygen_alert = 0
	toxins_alert = 0
	fire_alert = 0
	pass_flags = PASSTABLE
	var/temperature_alert = 0



/mob/living/carbon/alien/humanoid/handle_disabilities()
	if(disabilities & EPILEPSY)
		if((prob(1) && paralysis < 10))
			to_chat(src, "<span class='danger'>You have a seizure!</span>")
			Paralyse(10)
	if(disabilities & COUGHING)
		if((prob(5) && paralysis <= 1))
			drop_item()
			spawn( 0 )
				emote("cough")
				return
	if(disabilities & TOURETTES)
		if((prob(10) && paralysis <= 1))
			Stun(10)
			spawn( 0 )
				emote("twitch")
				return
	if(disabilities & NERVOUS)
		if(prob(10))
			Stuttering(10)

/mob/living/carbon/alien/humanoid/proc/adjust_body_temperature(current, loc_temp, boost)
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
