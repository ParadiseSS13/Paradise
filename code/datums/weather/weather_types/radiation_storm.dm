/// Chance for mob to avoid being affected by rad storm
#define RAD_STORM_AVOID_CHANCE 40
/// Chance to additionally apply good or bad mutation
#define RAD_STORM_ADDITIONAL_MUT_CHANCE 50
/// Chance to apply bad mutation. When failed will apply good mutation instead
#define RAD_STORM_BAD_MUT_CHANCE 90
/// Amount of radiation mob receives when affected
#define RAD_STORM_RAD_AMOUNT 400

//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 400
	telegraph_message = "<span class='danger'>The air begins to grow warm.</span>"

	weather_message = "<span class='userdanger'><i>You feel waves of heat wash over you! Find shelter!</i></span>"
	weather_overlay = "ash_storm"
	weather_duration_lower = 600
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = "<span class='notice'>The air seems to be cooling off again.</span>"
	var/pre_maint_all_access
	area_types = list(/area)
	protected_areas = list(
		/area/station/maintenance,
		/area/station/turret_protected/ai_upload,
		/area/station/turret_protected/ai,
		/area/station/public/storage/emergency,
		/area/station/public/storage/emergency/port,
		/area/station/public/sleep,
		/area/station/security/brig,
		/area/shuttle,
		/area/survivalpod, //although survivalpods are off-station, creating one on station no longer protects pods on station from the rad storm
		/area/syndicate_depot/core, // exterior of depot still dangerous, gotta be inside
		/area/ruin, //Let us not completely kill space explorers.
		/area/station/command/server
	)
	target_trait = REACHABLE_SPACE_ONLY

	immunity_type = "rad"

/datum/weather/rad_storm/telegraph()
	..()
	status_alarm(TRUE)
	pre_maint_all_access = SSmapping.maint_all_access
	if(!SSmapping.maint_all_access)
		SSmapping.make_maint_all_access()

/datum/weather/rad_storm/weather_act(mob/living/carbon/human/human)
	if(!istype(human) || HAS_TRAIT(human, TRAIT_RADIMMUNE) || prob(RAD_STORM_AVOID_CHANCE))
		return

	var/resist = human.getarmor(armor_type = RAD)
	if(resist == INFINITY)
		return

	if(prob(max(0, 100 - ARMOUR_VALUE_TO_PERCENTAGE(resist))))
		human.base_rad_act(human, RAD_STORM_RAD_AMOUNT, BETA_RAD)
		if(HAS_TRAIT(human, TRAIT_GENELESS))
			return
		randmuti(human) // Applies appearance mutation
		if(prob(RAD_STORM_ADDITIONAL_MUT_CHANCE))
			if(prob(RAD_STORM_BAD_MUT_CHANCE))
				randmutb(human) // Applies bad mutation
			else
				randmutg(human) // Applies good mutation

		domutcheck(human, MUTCHK_FORCED)

/datum/weather/rad_storm/end()
	if(..())
		return

	status_alarm(FALSE)
	if(!pre_maint_all_access)
		GLOB.minor_announcement.Announce("The radiation threat has passed. Please return to your workplaces. Door access resetting momentarily.", "Anomaly Alert")
		addtimer(CALLBACK(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, revoke_maint_all_access)), 10 SECONDS) // Bit of time to get out / break into somewhere.
	else
		GLOB.minor_announcement.Announce("The radiation threat has passed. Please return to your workplaces.", "Anomaly Alert")

/datum/weather/rad_storm/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	if(active)
		post_status(STATUS_DISPLAY_ALERT, "radiation")
	else
		post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)

#undef RAD_STORM_AVOID_CHANCE
#undef RAD_STORM_ADDITIONAL_MUT_CHANCE
#undef RAD_STORM_BAD_MUT_CHANCE
#undef RAD_STORM_RAD_AMOUNT
