/**
  * # Rep Purchase - Blackout
  */
/datum/rep_purchase/blackout
	name = "Blackout"
	description = "Overloads the station's power net, shorting random APCs."
	cost = 3
	// Settings
	/// How long a contractor must wait before calling another blackout, in deciseconds.
	var/static/cooldown = 45 MINUTES
	// Variables
	/// Static cooldown variable for blackouts.
	var/static/next_blackout = 0

/datum/rep_purchase/blackout/buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	var/time_left = round(COOLDOWN_TIMELEFT(src, next_blackout) / 10)
	if(time_left)
		to_chat(user, "<span class='warning'>Another blackout may not be requested for [seconds_to_clock(time_left)].</span>")
		return FALSE
	return ..()

/datum/rep_purchase/blackout/on_buy(datum/contractor_hub/hub, mob/living/carbon/human/user)
	..()
	COOLDOWN_START(src, next_blackout, cooldown)
	power_failure()
