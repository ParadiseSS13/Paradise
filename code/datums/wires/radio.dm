/datum/wires/radio
	holder_type = /obj/item/radio
	wire_count = 3

#define RADIO_WIRE_SIGNAL 1
#define RADIO_WIRE_RECEIVE 2
#define RADIO_WIRE_TRANSMIT 4

/datum/wires/radio/GetWireName(index)
	switch(index)
		if(RADIO_WIRE_SIGNAL)
			return "Signal"
		
		if(RADIO_WIRE_RECEIVE)
			return "Receiver"
		
		if(RADIO_WIRE_TRANSMIT)
			return "Transmitter"

/datum/wires/radio/CanUse(mob/living/L)
	var/obj/item/radio/R = holder
	if(R.b_stat)
		return 1
	return 0

/datum/wires/radio/UpdatePulsed(index)
	var/obj/item/radio/R = holder
	switch(index)
		if(RADIO_WIRE_SIGNAL)
			R.listening = !R.listening && !IsIndexCut(RADIO_WIRE_RECEIVE)
			R.broadcasting = R.listening && !IsIndexCut(RADIO_WIRE_TRANSMIT)

		if(RADIO_WIRE_RECEIVE)
			R.listening = !R.listening && !IsIndexCut(RADIO_WIRE_SIGNAL)

		if(RADIO_WIRE_TRANSMIT)
			R.broadcasting = !R.broadcasting && !IsIndexCut(RADIO_WIRE_SIGNAL)
	..()

/datum/wires/radio/UpdateCut(index, mended)
	var/obj/item/radio/R = holder
	switch(index)
		if(RADIO_WIRE_SIGNAL)
			R.listening = mended && !IsIndexCut(RADIO_WIRE_RECEIVE)
			R.broadcasting = mended && !IsIndexCut(RADIO_WIRE_TRANSMIT)

		if(RADIO_WIRE_RECEIVE)
			R.listening = mended && !IsIndexCut(RADIO_WIRE_SIGNAL)

		if(RADIO_WIRE_TRANSMIT)
			R.broadcasting = mended && !IsIndexCut(RADIO_WIRE_SIGNAL)
	..()
