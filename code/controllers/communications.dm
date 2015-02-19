/*
  HOW IT WORKS

  The radio_controller is a global object maintaining all radio transmissions, think about it as about "ether".
  Note that walkie-talkie, intercoms and headsets handle transmission using nonstandard way.
  procs:

    add_object(obj/device as obj, var/new_frequency as num, var/filter as text|null = null)
      Adds listening object.
      parameters:
        device - device receiving signals, must have proc receive_signal (see description below).
          one device may listen several frequencies, but not same frequency twice.
        new_frequency - see possibly frequencies below;
        filter - thing for optimization. Optional, but recommended.
                 All filters should be consolidated in this file, see defines later.
                 Device without listening filter will receive all signals (on specified frequency).
                 Device with filter will receive any signals sent without filter.
                 Device with filter will not receive any signals sent with different filter.
      returns:
       Reference to frequency object.

    remove_object (obj/device, old_frequency)
      Obliviously, after calling this proc, device will not receive any signals on old_frequency.
      Other frequencies will left unaffected.

   return_frequency(var/frequency as num)
      returns:
       Reference to frequency object. Use it if you need to send and do not need to listen.

  radio_frequency is a global object maintaining list of devices that listening specific frequency.
  procs:

    post_signal(obj/source as obj|null, datum/signal/signal, var/filter as text|null = null, var/range as num|null = null)
      Sends signal to all devices that wants such signal.
      parameters:
        source - object, emitted signal. Usually, devices will not receive their own signals.
        signal - see description below.
        filter - described above.
        range - radius of regular byond's square circle on that z-level. null means everywhere, on all z-levels.

  obj/proc/receive_signal(datum/signal/signal, var/receive_method as num, var/receive_param)
    Handler from received signals. By default does nothing. Define your own for your object.
    Avoid of sending signals directly from this proc, use spawn(-1). Do not use sleep() here please.
      parameters:
        signal - see description below. Extract all needed data from the signal before doing sleep(), spawn() or return!
        receive_method - may be TRANSMISSION_WIRE or TRANSMISSION_RADIO.
          TRANSMISSION_WIRE is currently unused.
        receive_param - for TRANSMISSION_RADIO here comes frequency.

  datum/signal
    vars:
    source
      an object that emitted signal. Used for debug and bearing.
    data
      list with transmitting data. Usual use pattern:
        data["msg"] = "hello world"
    encryption
      Some number symbolizing "encryption key".
      Note that game actually do not use any cryptography here.
      If receiving object don't know right key, it must ignore encrypted signal in its receive_signal.

*/

/*	the radio controller is a confusing piece of shit and didnt work
	so i made radios not use the radio controller.
*/
var/list/all_radios = list()

/proc/add_radio(var/obj/item/radio, freq)
	if(!freq || !radio)
		return
	if(!all_radios["[freq]"])
		all_radios["[freq]"] = list(radio)
		return freq

	all_radios["[freq]"] |= radio
	return freq

/proc/remove_radio(var/obj/item/radio, freq)
	if(!freq || !radio)
		return
	if(!all_radios["[freq]"])
		return

	all_radios["[freq]"] -= radio

/proc/remove_radio_all(var/obj/item/radio)
	for(var/freq in all_radios)
		all_radios["[freq]"] -= radio

/*
Frequency range: 1200 to 1600
Radiochat range: 1441 to 1489 (most devices refuse to be tune to other frequency, even during mapmaking)

Radio:
1459 - standard radio chat
1351 - Science
1353 - Command
1355 - Medical
1357 - Engineering
1359 - Security
1441 - death squad
1443 - Confession Intercom
1347 - Cargo techs
1349 - Service

Devices:
1451 - tracking implant
1457 - RSD default

On the map:
1311 for prison shuttle console (in fact, it is not used)
1435 for status displays
1437 for atmospherics/fire alerts
1439 for engine components
1439 for air pumps, air scrubbers, atmo control
1441 for atmospherics - supply tanks
1443 for atmospherics - distribution loop/mixed air tank
1445 for bot nav beacons
1447 for mulebot, secbot and ed209 control
1449 for airlock controls, electropack, magnets
1451 for toxin lab access
1453 for engineering access
1455 for AI access
*/

var/const/COMM_FREQ = 1353
var/const/SYND_FREQ = 1213
var/const/ERT_FREQ = 1345
var/const/DTH_FREQ = 1341
var/const/AI_FREQ = 1447

// department channels
var/const/PUB_FREQ = 1459
var/const/SEC_FREQ = 1359
var/const/ENG_FREQ = 1357
var/const/SCI_FREQ = 1351
var/const/MED_FREQ = 1355
var/const/SUP_FREQ = 1347
var/const/SRV_FREQ = 1349

var/list/radiochannels = list(
	"Common"		= PUB_FREQ,
	"Science"		= SCI_FREQ,
	"Command"		= COMM_FREQ,
	"Medical"		= MED_FREQ,
	"Engineering"	= ENG_FREQ,
	"Security" 		= SEC_FREQ,
	"Response Team" = ERT_FREQ,
	"Special Ops" 	= DTH_FREQ,
	"Syndicate" 	= SYND_FREQ,
	"Supply" 		= SUP_FREQ,
	"Service" 		= SRV_FREQ,
	"AI Private"	= AI_FREQ
)

// central command channels, i.e deathsquid & response teams
var/list/CENT_FREQS = list(ERT_FREQ, DTH_FREQ)

// Antag channels, i.e. Syndicate
var/list/ANTAG_FREQS = list(SYND_FREQ)

//depending helpers
var/list/DEPT_FREQS = list(SCI_FREQ, MED_FREQ, ENG_FREQ, SEC_FREQ, SUP_FREQ, SRV_FREQ, ERT_FREQ, SYND_FREQ, DTH_FREQ)

#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

/proc/frequency_span_class(var/frequency)
	// Antags!
	if (frequency in ANTAG_FREQS)
		return "syndradio"
	// centcomm channels (deathsquid and ert)
	else if(frequency in CENT_FREQS)
		return "centradio"
	// command channel
	else if(frequency == COMM_FREQ)
		return "comradio"
	// AI private channel
	else if(frequency == AI_FREQ)
		return "airadio"
	// department radio formatting (poorly optimized, ugh)
	else if(frequency == SEC_FREQ)
		return "secradio"
	else if (frequency == ENG_FREQ)
		return "engradio"
	else if(frequency == SCI_FREQ)
		return "sciradio"
	else if(frequency == MED_FREQ)
		return "medradio"
	else if(frequency == SUP_FREQ) // cargo
		return "supradio"
	else if(frequency == SRV_FREQ) // service
		return "srvradio"
	// If all else fails and it's a dept_freq, color me purple!
	else if(frequency in DEPT_FREQS)
		return "deptradio"

	return "radio"

/* filters */
var/const/RADIO_TO_AIRALARM = "1"
var/const/RADIO_FROM_AIRALARM = "2"
var/const/RADIO_CHAT = "3"
var/const/RADIO_ATMOSIA = "4"
var/const/RADIO_NAVBEACONS = "5"
var/const/RADIO_AIRLOCK = "6"
var/const/RADIO_SECBOT = "7"
var/const/RADIO_MULEBOT = "8"
var/const/RADIO_MAGNETS = "9"
var/const/RADIO_CLEANBOT = "10"
var/const/RADIO_FLOORBOT = "11"
var/const/RADIO_MEDBOT = "12"

var/global/datum/controller/radio/radio_controller

/hook/startup/proc/createRadioController()
	radio_controller = new /datum/controller/radio()
	return 1

datum/controller/radio
	var/list/datum/radio_frequency/frequencies = list()

	proc/add_object(obj/device as obj, var/new_frequency as num, var/filter = null as text|null)	
		var/f_text = num2text(new_frequency)
		var/datum/radio_frequency/frequency = frequencies[f_text]

		if(!frequency)
			frequency = new
			frequency.frequency = new_frequency
			frequencies[f_text] = frequency

		frequency.add_listener(device, filter)
		return frequency

	proc/remove_object(obj/device, old_frequency)
		var/f_text = num2text(old_frequency)
		var/datum/radio_frequency/frequency = frequencies[f_text]

		if(frequency)
			frequency.remove_listener(device)

			if(frequency.devices.len == 0)
				del(frequency)
				frequencies -= f_text

		return 1

	proc/return_frequency(var/new_frequency as num)
		var/f_text = num2text(new_frequency)
		var/datum/radio_frequency/frequency = frequencies[f_text]

		if(!frequency)
			frequency = new
			frequency.frequency = new_frequency
			frequencies[f_text] = frequency

		return frequency

datum/radio_frequency
	var/frequency as num
	var/list/list/obj/devices = list()

	proc
		post_signal(obj/source as obj|null, datum/signal/signal, var/filter = null as text|null, var/range = null as num|null)
			//log_admin("DEBUG \[[world.timeofday]\]: post_signal {source=\"[source]\", [signal.debug_print()], filter=[filter]}")
//			var/N_f=0
//			var/N_nf=0
//			var/Nt=0
			var/turf/start_point
			if(range)
				start_point = get_turf(source)
				if(!start_point)
					del(signal)
					return 0
			if (filter) //here goes some copypasta. It is for optimisation. -rastaf0
				for(var/obj/device in devices[filter])
					if(device == source)
						continue
					if(range)
						var/turf/end_point = get_turf(device)
						if(!end_point)
							continue
						//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
						if(start_point.z!=end_point.z || get_dist(start_point, end_point) > range)
							continue
					device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
				for(var/obj/device in devices["_default"])
					if(device == source)
						continue
					if(range)
						var/turf/end_point = get_turf(device)
						if(!end_point)
							continue
						//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
						if(start_point.z!=end_point.z || get_dist(start_point, end_point) > range)
							continue
					device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
//					N_f++
			else
				for (var/next_filter in devices)
//					var/list/obj/DDD = devices[next_filter]
//					Nt+=DDD.len
					for(var/obj/device in devices[next_filter])
						if(device == source)
							continue
						if(range)
							var/turf/end_point = get_turf(device)
							if(!end_point)
								continue
							//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
							if(start_point.z!=end_point.z || get_dist(start_point, end_point) > range)
								continue
						device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
//						N_nf++

//			log_admin("DEBUG: post_signal(source=[source] ([source.x], [source.y], [source.z]),filter=[filter]) frequency=[frequency], N_f=[N_f], N_nf=[N_nf]")


//			del(signal)

		add_listener(obj/device as obj, var/filter as text|null)
			if (!filter)
				filter = "_default"
			//log_admin("add_listener(device=[device],filter=[filter]) frequency=[frequency]")
			var/list/obj/devices_line = devices[filter]
			if (!devices_line)
				devices_line = new
				devices[filter] = devices_line
			devices_line+=device
//			var/list/obj/devices_line___ = devices[filter_str]
//			var/l = devices_line___.len
			//log_admin("DEBUG: devices_line.len=[devices_line.len]")
			//log_admin("DEBUG: devices(filter_str).len=[l]")

		remove_listener(obj/device)
			for (var/devices_filter in devices)
				var/list/devices_line = devices[devices_filter]
				devices_line-=device
				while (null in devices_line)
					devices_line -= null
				if (devices_line.len==0)
					devices -= devices_filter
					del(devices_line)


obj/proc
	receive_signal(datum/signal/signal, receive_method, receive_param)
		return null

datum/signal
	var/obj/source

	var/transmission_method = 0
	//0 = wire
	//1 = radio transmission
	//2 = subspace transmission

	var/data = list()
	var/encryption

	var/frequency = 0

	proc/copy_from(datum/signal/model)
		source = model.source
		transmission_method = model.transmission_method
		data = model.data
		encryption = model.encryption
		frequency = model.frequency

	proc/debug_print()
		if (source)
			. = "signal = {source = '[source]' ([source:x],[source:y],[source:z])\n"
		else
			. = "signal = {source = '[source]' ()\n"
		for (var/i in data)
			. += "data\[\"[i]\"\] = \"[data[i]]\"\n"
			if(islist(data[i]))
				var/list/L = data[i]
				for(var/t in L)
					. += "data\[\"[i]\"\] list has: [t]"
