/datum/event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/event/falsealarm/announce()
	var/list/event
	var/list/minor_fake_events = list(
		list("A solar flare has been detected on collision course with the station. Do not conduct space walks or approach windows until the flare has passed!", "Incoming Solar Flare", 'sound/AI/flare.ogg'),
		list("Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you*%fj00`5vc-BZZT"),
		list("Overload detected in [station_name()]'s powernet. Engineering, please repair shorted APCs.", "Systems Power Failure", 'sound/AI/power_overload.ogg'),
		list("Localized hyper-energetic flux wave detected on long range scanners. Expected location of impact: Kitchen.", "Anomaly Alert", 'sound/AI/anomaly_flux.ogg'),
		list("Overload detected in [station_name()]'s powernet. Engineering, please check all underfloor APC terminals.", "Critical Power Failure", 'sound/AI/power_overload.ogg'),
		list("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.", "Network Alert", 'sound/AI/door_runtimes.ogg'),
		list("Rampant brand intelligence has been detected aboard [station_name()], please stand-by. The origin is believed to be a vendomat.", "Machine Learning Alert", 'sound/AI/brand_intelligence.ogg'),
		list("Massive migration of unknown biological entities has been detected near [station_name()], please stand-by.", "Lifesign Alert"),
		list("An electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert", 'sound/AI/elec_storm.ogg'),
		list("What the fuck was that?!", "General Alert"),
		list("Bioscans indicate that spiders have been breeding in the vault. Clear them out, before this starts to affect productivity.", "Lifesign Alert"),
		list("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", 'sound/AI/ions.ogg'),
		list("The [station_name()] is passing through a minor radiation field. Be advised that acute exposure to space radiation can induce hallucinogenic episodes."),
		list("Meteors have been detected on collision course with the station.", "Meteor Alert", 'sound/AI/meteors.ogg'),
		list("Malignant trojan detected in [station_name()] imprisonment subroutines. Secure any compromised areas immediately. Station AI involvement is recommended.", "Security Alert"),
		list("High levels of radiation detected near the station. Maintenance is best shielded from radiation.", "Anomaly Alert", 'sound/AI/radiation.ogg'),
		list("Contact has been lost with a combat drone wing operating out of the NSV Icarus. If any are sighted in the area, approach with caution.", "Rogue drone alert"),
		list("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/AI/aliens.ogg'),
		list("A Honknomoly has opened. Expected location: Clown's Office.", "Honknomoly Alert", 'sound/items/airhorn.ogg'),
		list("A tear in the fabric of space and time has opened. Expected location: Mime's Office.", "Anomaly Alert", 'sound/AI/anomaly.ogg'),
		list("A trading shuttle from Jupiter Station has been granted docking permission at [station_name()] arrivals port 4.", "Trader Shuttle Docking Request Accepted"),
		list("The scrubbers network is experiencing a backpressure surge.  Some ejection of contents may occur.", "Atmospherics alert", 'sound/AI/scrubbers.ogg'),
		list("Space-time anomalies detected on the station. There is no additional data.", "Anomaly Alert", 'sound/AI/spanomalies.ogg')
	)

	var/list/major_fake_events = list(
		list("Confirmed outbreak of level 3-X biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/AI/outbreak3.ogg'),
		list("Confirmed outbreak of level 3-S biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/AI/outbreak3.ogg'),
		list("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/AI/outbreak5.ogg')
	)

	if(prob(90))
		event = pick_n_take(minor_fake_events)
		GLOB.minor_announcement.Announce(event[1], listgetindex(event, 2), listgetindex(event, 3))
	else
		event = pick_n_take(major_fake_events)
		GLOB.major_announcement.Announce(event[1], listgetindex(event, 2), listgetindex(event, 3))

	message_admins("False Alarm: [event[1]]")
