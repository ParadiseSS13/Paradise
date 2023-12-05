/datum/station_trait/bananium_shipment
	name = "Bananium Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Rumor has it that the clown planet has been sending support packages to clowns in this system."
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/bananium_shipment
	name = "Tranquilite Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Rumor has it that the mime federation has been sending support packages to mimes in this system."
	trait_to_give = STATION_TRAIT_TRANQUILITE_SHIPMENTS

/datum/station_trait/unique_ai
	name = "Unique AI"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 15
	show_in_report = TRUE
	report_message = "For experimental purposes, this station AI might show divergence from default lawset. Do not meddle with this experiment, we've removed \
		access to your set of alternative upload modules because we know you're already thinking about meddling with this experiment."
	trait_to_give = STATION_TRAIT_UNIQUE_AI
	blacklist = list(/datum/station_trait/random_event_weight_modifier/ion_storms)

/datum/station_trait/glitched_pdas
	name = "PDA glitch"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 15
	show_in_report = TRUE
	report_message = "Something seems to be wrong with the PDAs issued to you all this shift. Nothing too bad though."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/late_arrivals
	name = "Late Arrivals"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "Sorry for that, we didn't expect to fly into that vomiting goose while bringing you to your new station."
	trait_to_give = STATION_TRAIT_LATE_ARRIVALS
	blacklist = list(/datum/station_trait/hangover)

/datum/station_trait/late_arrivals/New()
	. = ..()
	SSjobs.late_arrivals_spawning = TRUE

/datum/station_trait/late_arrivals/revert()
	. = ..()
	SSjobs.late_arrivals_spawning = FALSE


/datum/station_trait/hangover
	name = "Hangover"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "Ohh....Man....That mandatory office party from last shift...God that was awesome..I woke up in some random toilet 3 sectors away..."
	trait_to_give = STATION_TRAIT_HANGOVER
	blacklist = list(/datum/station_trait/late_arrivals)

/datum/station_trait/hangover/New()
	. = ..()
	SSjobs.drunken_spawning = TRUE

/datum/station_trait/hangover/revert()
	. = ..()
	SSjobs.drunken_spawning = FALSE
