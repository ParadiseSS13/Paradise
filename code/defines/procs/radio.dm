#define TELECOMMS_RECEPTION_NONE 0
#define TELECOMMS_RECEPTION_SENDER 1
#define TELECOMMS_RECEPTION_RECEIVER 2
#define TELECOMMS_RECEPTION_BOTH 3

/proc/get_frequency_name(var/display_freq)
	var/freq_text

	// the name of the channel
	switch(display_freq)
		if(SYND_FREQ)
			freq_text = "#unkn"
		if(SYNDTEAM_FREQ)
			freq_text = "#unid"
		else
			for(var/channel in SSradio.radiochannels)
				if(SSradio.radiochannels[channel] == display_freq)
					freq_text = channel
					break

	// --- If the frequency has not been assigned a name, just use the frequency as the name ---
	if(!freq_text)
		freq_text = format_frequency(display_freq)

	return freq_text

/datum/reception
	var/obj/machinery/message_server/message_server = null
	var/telecomms_reception = TELECOMMS_RECEPTION_NONE
	var/message = ""

/datum/receptions
	var/obj/machinery/message_server/message_server = null
	var/sender_reception = TELECOMMS_RECEPTION_NONE
	var/list/receiver_reception = new

/proc/get_message_server()
	if(GLOB.message_servers)
		for(var/obj/machinery/message_server/MS in GLOB.message_servers)
			if(MS.active)
				return MS
	return null

/proc/check_signal(var/datum/signal/signal)
	return signal && signal.data["done"]

/proc/get_sender_reception(var/atom/sender, var/datum/signal/signal)
	return check_signal(signal) ? TELECOMMS_RECEPTION_SENDER : TELECOMMS_RECEPTION_NONE

/proc/get_receiver_reception(var/receiver, var/datum/signal/signal)
	if(receiver && check_signal(signal))
		var/turf/pos = get_turf(receiver)
		// Maybe should get tie-in to the space manager?
		if(pos && (pos.z in signal.data["level"]))
			return TELECOMMS_RECEPTION_RECEIVER
	return TELECOMMS_RECEPTION_NONE

/proc/get_reception(var/atom/sender, var/receiver, var/message = "", var/do_sleep = 1)
	var/datum/reception/reception = new

	// check if telecomms I/O route 1459 is stable
	reception.message_server = get_message_server()

	var/datum/signal/signal = sender.telecomms_process(do_sleep)	// Be aware that this proc calls sleep, to simulate transmition delays
	reception.telecomms_reception |= get_sender_reception(sender, signal)
	reception.telecomms_reception |= get_receiver_reception(receiver, signal)
	reception.message = signal && signal.data["compression"] > 0 ? Gibberish(message, signal.data["compression"] + 50) : message

	return reception

/proc/get_receptions(var/atom/sender, var/list/atom/receivers, var/do_sleep = 1)
	var/datum/receptions/receptions = new
	receptions.message_server = get_message_server()

	var/datum/signal/signal
	if(sender)
		signal = sender.telecomms_process(do_sleep)
		receptions.sender_reception = get_sender_reception(sender, signal)

	for(var/atom/receiver in receivers)
		if(!signal)
			signal = receiver.telecomms_process()
		receptions.receiver_reception[receiver] = get_receiver_reception(receiver, signal)

	return receptions
