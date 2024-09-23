/datum/wires/radio
	holder_type = /obj/item/radio
	wire_count = 3
	proper_name = "Radio"

/datum/wires/radio/New(atom/_holder)
	wires = list(WIRE_RADIO_SIGNAL, WIRE_RADIO_RECEIVER, WIRE_RADIO_TRANSMIT)
	return ..()

/datum/wires/radio/interactable(mob/user)
	var/obj/item/radio/R = holder
	if(R.b_stat)
		return TRUE
	return FALSE

/datum/wires/radio/on_pulse(wire)
	var/obj/item/radio/R = holder
	switch(wire)
		if(WIRE_RADIO_SIGNAL)
			R.listening = !R.listening && !is_cut(WIRE_RADIO_RECEIVER)
			R.broadcasting = R.listening && !is_cut(WIRE_RADIO_TRANSMIT)

		if(WIRE_RADIO_RECEIVER)
			R.listening = !R.listening && !is_cut(WIRE_RADIO_SIGNAL)

		if(WIRE_RADIO_TRANSMIT)
			R.broadcasting = !R.broadcasting && !is_cut(WIRE_RADIO_SIGNAL)
	..()

/datum/wires/radio/on_cut(wire, mend)
	var/obj/item/radio/R = holder
	switch(wire)
		if(WIRE_RADIO_SIGNAL)
			R.listening = mend && !is_cut(WIRE_RADIO_RECEIVER)
			R.broadcasting = mend && !is_cut(WIRE_RADIO_TRANSMIT)

		if(WIRE_RADIO_RECEIVER)
			R.listening = mend && !is_cut(WIRE_RADIO_SIGNAL)

		if(WIRE_RADIO_TRANSMIT)
			R.broadcasting = mend && !is_cut(WIRE_RADIO_SIGNAL)
	..()
