/datum/station_trait/bananium_shipment
	name = "Bananium Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "An unidentified benefactor has dispatched a mysterious shipment to your station's clown. It was reported to smell faintly of bananas."
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/tranquilite_shipment
	name = "Tranquilite Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Shipping records show an unmarked crate being delivered to your station's mime."
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

/datum/station_trait/triple_ai
	name = "AI Triumvirate"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "As part of Operation Magi, your station has been equipped with three Nanotrasen Artificial Intelligence models. Please try not to break them."
	trait_to_give = STATION_TRAIT_TRIAI

/datum/station_trait/triple_ai/New()
	. = ..()
	SSticker.triai = TRUE

/datum/station_trait/triple_ai/revert()
	. = ..()
	SSticker.triai = FALSE

/datum/station_trait/rave
	name = "Rave"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "Our workers have installed new 'Motivational' lighting for you."

/datum/station_trait/rave/on_round_start()
	. = ..()
	for(var/obj/machinery/light/light in GLOB.machines)
		var/turf/our_turf = get_turf(light)
		if(!is_station_level(our_turf.z))
			continue
		var/list/rgb = hsl2rgb(rand(0, 255) / 255, rand((0.4 * 255), 255) / 255, rand((0.5 * 255), (0.8 * 255)) / 255)
		var/new_color = "#[num2hex(rgb[1], 2)][num2hex(rgb[2], 2)][num2hex(rgb[3], 2)]"
		light.color = new_color
		light.brightness_color = new_color
		light.update(FALSE, TRUE, FALSE)
