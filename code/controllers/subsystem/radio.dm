SUBSYSTEM_DEF(radio)
	name = "Radio"
	flags = SS_NO_INIT | SS_NO_FIRE

	var/list/radiochannels = list(
	"Common"		= PUB_FREQ,
	"Science"		= SCI_FREQ,
	"Command"		= COMM_FREQ,
	"Procedure"		= PROC_FREQ,
	"Medical"		= MED_FREQ,
	"Engineering"	= ENG_FREQ,
	"Security" 		= SEC_FREQ,
	"Response Team" = ERT_FREQ,
	"Special Ops" 	= DTH_FREQ,
	"Syndicate" 	= SYND_FREQ,
	"SyndTaipan" 	= SYND_TAIPAN_FREQ,
	"SyndTeam" 		= SYNDTEAM_FREQ,
	"Supply" 		= SUP_FREQ,
	"Service" 		= SRV_FREQ,
	"AI Private"	= AI_FREQ,
	"Medical(I)"	= MED_I_FREQ,
	"Security(I)"	= SEC_I_FREQ
	)
	var/list/CENT_FREQS = list(ERT_FREQ, DTH_FREQ)
	var/list/ANTAG_FREQS = list(SYND_FREQ, SYNDTEAM_FREQ, SYND_TAIPAN_FREQ)
	var/list/DEPT_FREQS = list(AI_FREQ, COMM_FREQ, ENG_FREQ, MED_FREQ, SEC_FREQ, SCI_FREQ, SRV_FREQ, SUP_FREQ, PROC_FREQ)
	var/list/datum/radio_frequency/frequencies = list()

// This is fucking disgusting and needs to die
/datum/controller/subsystem/radio/proc/frequency_span_class(var/frequency)
	// Taipan!
	if(frequency == SYND_TAIPAN_FREQ)
		return "taipan"
	// Antags!
	if(frequency in ANTAG_FREQS)
		return "syndradio"
	// centcomm channels (deathsquid and ert)
	if(frequency in CENT_FREQS)
		return "centradio"
	// This switch used to be a shit tonne of if statements. I am gonna find who made this and give them a kind talking to
	switch(frequency)
		if(COMM_FREQ)
			return "comradio"
		if(AI_FREQ)
			return "airadio"
		if(SEC_FREQ)
			return "secradio"
		if(ENG_FREQ)
			return "engradio"
		if(SCI_FREQ)
			return "sciradio"
		if(MED_FREQ)
			return "medradio"
		if(SUP_FREQ)
			return "supradio"
		if(SRV_FREQ)
			return "srvradio"
		if(PROC_FREQ)
			return "proradio"

	// If the above switch somehow failed. And it needs the SSradio. part otherwise it fails to compile
	if(frequency in DEPT_FREQS)
		return "deptradio"

	// If its none of the others
	return "radio"


/datum/controller/subsystem/radio/proc/add_object(obj/device as obj, var/new_frequency as num, var/filter = null as text|null)
	var/f_text = num2text(new_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new
		frequency.frequency = new_frequency
		frequencies[f_text] = frequency

	frequency.add_listener(device, filter)
	return frequency

/datum/controller/subsystem/radio/proc/remove_object(obj/device, old_frequency)
	var/f_text = num2text(old_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]

	if(frequency)
		frequency.remove_listener(device)

		if(frequency.devices.len == 0)
			qdel(frequency)
			frequencies -= f_text

	return 1

/datum/controller/subsystem/radio/proc/return_frequency(var/new_frequency as num)
	var/f_text = num2text(new_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new
		frequency.frequency = new_frequency
		frequencies[f_text] = frequency

	return frequency


// ALL THE SHIT BELOW THIS LINE ISNT PART OF THE SUBSYSTEM AND REALLY NEEDS ITS OWN FILE
