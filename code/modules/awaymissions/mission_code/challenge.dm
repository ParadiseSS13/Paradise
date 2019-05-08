//Challenge Areas

/area/awaymission/challenge
	name = "Challenge"
	icon_state = "away"
	report_alerts = FALSE

/area/awaymission/challenge/start
	name = "Where Am I?"
	icon_state = "away"

/area/awaymission/challenge/main
	name = "\improper Danger Room"
	icon_state = "away1"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/awaymission/challenge/end
	name = "Administration"
	icon_state = "away2"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED


/obj/machinery/power/emitter/energycannon
	name = "Energy Cannon"
	desc = "A heavy duty industrial laser"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 1
	density = 1

	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

	active = 1
	locked = 1
	state = 2
