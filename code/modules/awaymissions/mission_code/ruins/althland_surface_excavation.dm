/obj/machinery/computer/loreconsole/althland_surface_excavation
	name = "\improper Ancient Communications Console"
	entries = list(
		new/datum/lore_console_entry(
			"ALERT LEVEL ELEVATED: OMEGA",
			{"!!OMEGA ALERT!!<br><br>\
			\
			SECURITY LEVEL OMEGA REACHED AT ALTHLAND STATION B3.<br><br>\
			\
			AUTHORIZING OFFICERS: QUARTERMASTER JOHNATHAN LEADBEATER, SENIOR MEDICAL OFFICER QOOXL VIAAOOOQLL.<br><br>\
			\
			REASON FOR EMERGENCY: \[ERROR: emergency_report_2483-14-11-20-04.txt IS UNABLE TO BE OPENED\].<br><br>\
			\
			EMERGENCY EVACUATION REQUESTED<br><br>\
			\
			AWAITING RESPONSE..."}
			),

		new/datum/lore_console_entry(
			"Strange Gas Samples",
			{"In one of the lower galleries, we've discovered substantial deposits of an unknown gas. None of our equipment can identify it.<br><br>\
			\
			Some basic tests show it has very unusual properties. While it initially appeared to be inert, \
			an accident involving a can of cola revealed that it violently burns carbon dioxide, releasing oxygen into the air. \
			This reaction was extremely exothermic, burning far hotter than typical plasma-oxygen mixes.<br><br>\
			\
			We may have just stumbled upon something big. A large quantity of the gas has been stored in the generator room, \
			please dispach a shuttle from the Farragus to collect it for further analysis ASAP."}
			)
		)

/area/ruin/unpowered/althland_excavation
	name = "Site B3"
	icon_state = "red"

/area/ruin/unpowered/althland_excavation/dorms
	name = "Site B3 Dorms"
	icon_state = "dorms"

/area/ruin/unpowered/althland_excavation/storage
	name = "Site B3 Equipment Storage"
	icon_state = "cargobay"

/area/ruin/unpowered/althland_excavation/mech_bay
	name = "Site B3 Equipment Storage"
	icon_state = "mechbay"

/area/ruin/unpowered/althland_excavation/electrical
	name = "Site B3 Generator Room"
	icon_state = "elect"

/area/ruin/unpowered/althland_excavation/atmos
	name = "Site B3 Life Support"
	icon_state = "atmos"
