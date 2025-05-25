/datum/station_trait/carp_infestation
	name = "Carp infestation"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Dangerous fauna is present in the area of this station."


/datum/station_trait/carp_infestation/on_round_start()
	. = ..()
	new /datum/event/carp_migration(new /datum/event_meta(EVENT_LEVEL_MAJOR))

/datum/station_trait/distant_supply_lines
	name = "Distant supply lines"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Due to the distance to our normal supply lines, cargo orders are more expensive."
	blacklist = list(/datum/station_trait/strong_supply_lines)

/datum/station_trait/distant_supply_lines/on_round_start()
	SSeconomy.pack_price_modifier *= 1.2

/datum/station_trait/empty_maint
	name = "Cleaned out maintenance"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Our workers cleaned out most of the junk in the maintenace areas."
	blacklist = list(/datum/station_trait/filled_maint)
	trait_to_give = STATION_TRAIT_EMPTY_MAINT

	// This station trait is checked when loot drops initialize, so it's too late
	can_revert = FALSE

/datum/station_trait/slow_shuttle
	name = "Slow Shuttle"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to distance to our supply station, the cargo shuttle will have a slower flight time to your cargo department."
	blacklist = list(/datum/station_trait/quick_shuttle)

/datum/station_trait/slow_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 1.5 // 3 minutes, for those wondering.

/datum/station_trait/messy_station
	name = "Messy Station"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "The previous crew has left the station completely trashed."
	trait_to_give = STATION_TRAIT_MESSY

// Abstract station trait used for traits that modify a random event in some way (their weight or max occurrences).
/datum/station_trait/random_event_weight_modifier
	name = "Random Event Modifier"
	report_message = "A random event has been modified this shift! Someone forgot to set this!"
	show_in_report = TRUE
	trait_flags = STATION_TRAIT_ABSTRACT
	weight = 0

	/// The names of the event we modify.
	var/list/event_names = list()
	/// The severity of the event we modify.
	var/datum/event_container/event_severity
	/// Multiplier applied to the weight of the event. may want to apply to scaling as well
	var/weight_multiplier = 1
	/// Do we want to turn off is one shot?
	var/disable_is_one_shot = FALSE

/datum/station_trait/random_event_weight_modifier/on_round_start()
	. = ..()
	for(var/datum/event_container/E in SSevents.event_containers)
		if(istype(E, event_severity))
			event_severity = E
	var/modified_event = FALSE
	for(var/datum/event_meta/E in event_severity.available_events)
		for(var/i in event_names)
			if(E.name == i)
				E.weight *= weight_multiplier
				for(var/role_weight in E.role_weights)
					E.role_weights[role_weight] *= weight_multiplier
				if(disable_is_one_shot)
					E.one_shot = FALSE
				modified_event = TRUE
	if(!modified_event)
		CRASH("[type] could not find a round event controller to modify on round start (likely has an invalid event_name or event_severity set, or an admin removed the event from the list)!")

/datum/station_trait/random_event_weight_modifier/ion_storms
	name = "Ionic Stormfront"
	report_message = "An ionic stormfront is passing over your station's system. Expect an increased likelihood of ion storms afflicting your station's silicon units."
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 3
	event_names = list("Ion Storm")
	event_severity = /datum/event_container/moderate
	blacklist = list(/datum/station_trait/unique_ai)
	weight_multiplier = 3

/datum/station_trait/random_event_weight_modifier/rad_storms
	name = "Radiation Stormfront"
	report_message = "A radioactive stormfront is passing through your station's system. Expect an increased likelihood of radiation storms passing over your station, as well the potential for multiple radiation storms to occur during your shift."
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 2
	event_names = list("Radiation Storm")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 3
	disable_is_one_shot = TRUE

/datum/station_trait/random_event_weight_modifier/meteor_showers
	name = "Meteor Swarm"
	report_message = "Meteors are passing through the stations space. Expect an increased likelyhood of meteor storms damaging the station hull."
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 2
	event_names = list("Meteor Shower")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 3

/datum/station_trait/random_event_weight_modifier/anomaly_storm
	name = "Anomaly Storm"
	report_message = "The station has moved into unstable space. Expect an increased likelihood of anomalies running rampant on the station."
	trait_type = STATION_TRAIT_NEGATIVE
	trait_flags = STATION_TRAIT_MAP_UNRESTRICTED
	weight = 2
	event_names = list("Pyro Anomaly", "Cryo Anomaly", "Vortex Anomaly", "Bluespace Anomaly", "Flux Anomaly", "Gravitational Anomaly", "Wormholes", "Dimensional Tear") //Added wormholes and dimensional tears to acoid this being too positive
	event_severity = /datum/event_container/moderate
	weight_multiplier = 2 //Only 2 as there are a *lot* of anomaly events.
