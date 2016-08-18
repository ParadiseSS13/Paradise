/datum/language/binary
	name = "Robot Talk"
	desc = "Most human stations support free-use communications protocols and routing hubs for synthetic use."
	colour = "say_quote"
	speech_verb = "states"
	ask_verb = "queries"
	exclaim_verb = "declares"
	key = "b"
	flags = RESTRICTED | HIVEMIND
	follow = 1
	var/drone_only

/datum/language/binary/broadcast(var/mob/living/speaker, var/message, var/speaker_mask)
	if(!speaker.binarycheck())
		return

	if(!message)
		return

	var/message_start = "<i><span class='game say'>[name], <span class='name'>[speaker.name]</span>"
	var/message_body = "<span class='message'>[speaker.say_quote(message)], \"[message]\"</span></span></i>"

	for(var/mob/M in dead_mob_list)
		if(!isnewplayer(M) && !isbrain(M))
			M.show_message("[message_start] ([ghost_follow_link(speaker, ghost=M)]) [message_body]", 2)

	for(var/mob/living/S in living_mob_list)
		if(drone_only && !isdrone(S))
			continue
		else if(istype(S , /mob/living/silicon/ai))
			message_start = "<i><span class='game say'>[name], <a href='byond://?src=\ref[S];track=\ref[speaker]'><span class='name'>[speaker.name]</span></a>"
		else if(!S.binarycheck())
			continue

		S.show_message("[message_start] [message_body]", 2)

	var/list/listening = hearers(1, src)
	listening -= src

	for(var/mob/living/M in listening)
		if(issilicon(M) || M.binarycheck())
			continue
		M.show_message("<i><span class='game say'><span class='name'>synthesised voice</span> <span class='message'>beeps, \"beep beep beep\"</span></span></i>",2)

/datum/language/binary/drone
	name = "Drone Talk"
	desc = "A heavily encoded damage control coordination stream."
	speech_verb = "transmits"
	ask_verb = "transmits"
	exclaim_verb = "transmits"
	colour = "say_quote"
	key = "d"
	flags = RESTRICTED | HIVEMIND
	drone_only = 1
	follow = 1