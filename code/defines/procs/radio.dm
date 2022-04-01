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
		if(SYND_TAIPAN_FREQ)
			freq_text = "#noid"
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

/proc/get_message_server()
	if(GLOB.message_servers)
		for(var/obj/machinery/message_server/MS in GLOB.message_servers)
			if(MS.active)
				return MS
	return null
