/datum/action/cooldown/flock/repair_burst
	name = "Concentrated Repair Burst"
	desc = "Transmit large amounts of energy into up to four drones in a small area, healing them up to half of their hitpoints. Does not work on dead drones."
	button_icon_state = "heal_drone"
	cooldown_time = 30 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/flock/repair_burst/Activate(atom/target)
	var/list/targets = list()
	for(var/mob/living/basic/flock/drone/bird in range(3, get_turf(target)))
		if(bird.stat == DEAD)
			continue

		targets += bird
		if(length(targets) >= 4)
			break

	if(!length(targets))
		to_chat(owner, SPAN_ALERT("No repairable drones in range."))
		return FALSE

	. = ..()

	to_chat(owner, SPAN_NOTICE("You transmit energy into your drones!"))
	playsound(owner, 'sound/goonstation/flockmind/flockmind_cast.ogg', 50)

	for(var/mob/living/basic/flock/drone/bird as anything in targets)
		playsound(bird, "sound/effects/radio_sweep[rand(1,5)].ogg", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		bird.adjustHealth(-50)
