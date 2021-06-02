/datum/event/communications_blackout/announce()
	var/alert = pick(	"Обнаружены ионосферные аномалии. Неизбежен временный сбой связи. Пожалуйста, свяжитесь с вашим*%fj 00)`5 vc-БЗЗЗ", \
						"Обнаружены ионосферные аномалии. Неизбежен временный сбо*3mga;b4;'1v?-БЗЗЗЗ", \
						"Обнаружены ионосферные аномалии. Неизбежен време#MCi46:5.;@63-БЗЗЗЗЗ", \
						"Обнаружены ионосфе'fZ\\kg5_0-БЗЗЗЗЗ", \
						"Обнаруж:%? MCayj^j<.3-БЗЗЗЗЗ", \
						"#4nd%;f4y6,>?%-БЗЗЗЗЗЗЗ")

	for(var/mob/living/silicon/ai/A in GLOB.player_list)	//AIs are always aware of communication blackouts.
		to_chat(A, "<br>")
		to_chat(A, "<span class='ВНИМАНИЕ'><b>[alert]</b></span>")
		to_chat(A, "<br>")

	if(prob(30))	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.
		GLOB.event_announcement.Announce(alert)

/datum/event/communications_blackout/start()
	// This only affects the cores, relays should be unaffected imo
	for(var/obj/machinery/tcomms/core/T in GLOB.tcomms_machines)
		T.start_ion()
		// Bring it back sometime between 3-5 minutes. This uses deciseconds, so 1800 and 3000 respecticely.
		// The AI cannot disable this, it must be waited for
		addtimer(CALLBACK(T, /obj/machinery/tcomms.proc/end_ion), rand(1800, 3000))
