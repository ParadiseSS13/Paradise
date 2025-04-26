/datum/event/communications_blackout/announce(false_alarm)
	var/alert = pick(	"Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you*%fj00)`5vc-BZZT", \
						"Ionospheric anomalies detected. Temporary telecommunication failu*3mga;b4;'1v?-BZZZT", \
						"Ionospheric anomalies detected. Temporary telec#MCi46:5.;@63-BZZZZT", \
						"Ionospheric anomalies dete'fZ\\kg5_0-BZZZZZT", \
						"Ionospheri:%? MCayj^j<.3-BZZZZZZT", \
						"#4nd%;f4y6,>?%-BZZZZZZZT")

	for(var/mob/living/silicon/ai/A in GLOB.ai_list)	//AIs are always aware of communication blackouts.
		to_chat(A, "<br>")
		to_chat(A, "<span class='warning'><b>[alert]</b></span>")
		to_chat(A, "<br>")

	if(prob(30) || false_alarm)	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.
		GLOB.minor_announcement.Announce(alert)

/datum/event/communications_blackout/start()
	// This only affects the cores, relays should be unaffected imo
	for(var/obj/machinery/tcomms/core/T in GLOB.tcomms_machines)
		T.start_ion()
		// Bring it back sometime between 3-5 minutes. This uses deciseconds, so 1800 and 3000 respecticely.
		// The AI cannot disable this, it must be waited for
		addtimer(CALLBACK(T, TYPE_PROC_REF(/obj/machinery/tcomms, end_ion)), rand(1800, 3000))
