/**
  * # Rep Purchase - Blackout
  */
/datum/rep_purchase/blackout
	name = "Blackout"
	description = "Overloads the station's power net, shorting random APCs."
	cost = 3
	// Settings
	/// How long a contractor must wait before calling another blackout, in deciseconds.
	var/static/cooldown = 15 MINUTES
	// Variables
	/// Static cooldown variable for blackouts.
	var/static/next_blackout = -1

/datum/rep_purchase/blackout/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	if(next_blackout > world.time)
		var/timeleft = (next_blackout - world.time) / 10
		to_chat(user, "<span class='warning'>Another blackout may not be requested for [seconds_to_clock(timeleft)].</span>")
		return FALSE
	return ..()

/datum/rep_purchase/blackout/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	..()
	next_blackout = world.time + cooldown
	power_failure()
