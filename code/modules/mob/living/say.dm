var/list/department_radio_keys = list(
	  ":r" = "right ear",	"#r" = "right ear",		".r" = "right ear", "!r" = "fake right ear",
	  ":l" = "left ear",	"#l" = "left ear",		".l" = "left ear",  "!l" = "fake left ear",
	  ":i" = "intercom",	"#i" = "intercom",		".i" = "intercom",
	  ":h" = "department",	"#h" = "department",	".h" = "department",
	  ":c" = "Command",		"#c" = "Command",		".c" = "Command",
	  ":n" = "Science",		"#n" = "Science",		".n" = "Science",
	  ":m" = "Medical",		"#m" = "Medical",		".m" = "Medical",
	  ":e" = "Engineering", "#e" = "Engineering",	".e" = "Engineering",
	  ":s" = "Security",	"#s" = "Security",		".s" = "Security",
	  ":w" = "whisper",		"#w" = "whisper",		".w" = "whisper",
	  ":b" = "binary",		"#b" = "binary",		".b" = "binary",
	  ":d" = "drone",		"#d" = "drone",			".d" = "drone",
	  ":a" = "alientalk",	"#a" = "alientalk",		".a" = "alientalk",
	  ":t" = "Syndicate",	"#t" = "Syndicate",		".t" = "Syndicate",
	  ":u" = "Supply",		"#u" = "Supply",		".u" = "Supply",
	  ":z" = "Service",		"#z" = "Service",		".z" = "Service",
	  ":g" = "changeling",	"#g" = "changeling",	".g" = "changeling",


	  ":R" = "right ear",	"#R" = "right ear",		".R" = "right ear", "!R" = "fake right ear",
	  ":L" = "left ear",	"#L" = "left ear",		".L" = "left ear",  "!L" = "fake left ear",
	  ":I" = "intercom",	"#I" = "intercom",		".I" = "intercom",
	  ":H" = "department",	"#H" = "department",	".H" = "department",
	  ":C" = "Command",		"#C" = "Command",		".C" = "Command",
	  ":N" = "Science",		"#N" = "Science",		".N" = "Science",
	  ":M" = "Medical",		"#M" = "Medical",		".M" = "Medical",
	  ":E" = "Engineering",	"#E" = "Engineering",	".E" = "Engineering",
	  ":S" = "Security",	"#S" = "Security",		".S" = "Security",
	  ":W" = "whisper",		"#W" = "whisper",		".W" = "whisper",
	  ":D" = "drone",		"#D" = "drone",			".D" = "drone",
	  ":B" = "binary",		"#B" = "binary",		".B" = "binary",
	  ":A" = "alientalk",	"#A" = "alientalk",		".A" = "alientalk",
	  ":T" = "Syndicate",	"#T" = "Syndicate",		".T" = "Syndicate",
	  ":U" = "Supply",		"#U" = "Supply",		".U" = "Supply",
	  ":Z" = "Service",		"#Z" = "Service",		".Z" = "Service",
	  ":G" = "changeling",	"#G" = "changeling",	".G" = "changeling"

	/* //kinda localization -- rastaf0
	//same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
	  ":ê" = "right hand",	"#ê" = "right hand",    ".ê" = "right hand",
	  ":ä" = "left hand",   "#ä" = "left hand",     ".ä" = "left hand",
	  ":ø" = "intercom",    "#ø" = "intercom",      ".ø" = "intercom",
	  ":ð" = "department",  "#ð" = "department",    ".ð" = "department",
	  ":ñ" = "Command",     "#ñ" = "Command",       ".ñ" = "Command",
	  ":ò" = "Science",     "#ò" = "Science",       ".ò" = "Science",
	  ":ü" = "Medical",     "#ü" = "Medical",       ".ü" = "Medical",
	  ":ó" = "Engineering", "#ó" = "Engineering",   ".ó" = "Engineering",
	  ":û" = "Security",    "#û" = "Security",      ".û" = "Security",
	  ":ö" = "whisper",     "#ö" = "whisper",       ".ö" = "whisper",
	  ":è" = "binary",      "#è" = "binary",        ".è" = "binary",
	  ":ô" = "alientalk",   "#ô" = "alientalk",     ".ô" = "alientalk",
	  ":å" = "Syndicate",   "#å" = "Syndicate",     ".å" = "Syndicate",
	  ":é" = "Supply",      "#é" = "Supply",        ".é" = "Supply",
	  ":ï" = "changeling",  "#ï" = "changeling",    ".ï" = "changeling" */
)

/mob/living/proc/binarycheck()
	if (istype(src, /mob/living/silicon/pai))
		return
	if (issilicon(src))
		return 1
	if (!ishuman(src))
		return
	var/mob/living/carbon/human/H = src
	if (H.l_ear || H.r_ear)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.l_ear,/obj/item/device/radio/headset))
			dongle = H.l_ear
		else
			dongle = H.r_ear
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/proc/hivecheck()
	if (isalien(src)) return 1
	if (!ishuman(src)) return
	var/mob/living/carbon/human/H = src
	if (H.l_ear || H.r_ear)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.l_ear,/obj/item/device/radio/headset))
			dongle = H.l_ear
		else
			dongle = H.r_ear
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/say(var/message)

	/*
		Formatting and sanitizing.
	*/

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))


	/*
		Sanity checking and speech failure.
	*/

	if (!message)
		return

	if(silent)
		return

	if (stat == 2) // Dead.
		return say_dead(message)
	else if (stat) // Unconcious.
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return
	 // undo last word status.

	if(ishuman(src))
		var/mob/living/carbon/human/H=src
		if(H.said_last_words)
			H.said_last_words=0

	// Mute disability
	if (sdisabilities & MUTE)
		return

	// Muzzled.
	if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return

	// Emotes.
	if (copytext(message, 1, 2) == "*" && !stat)
		return emote(copytext(message, 2))

	/*
		Identity hiding.
	*/
	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && name != GetVoice())
		var/mob/living/carbon/human/H = src
		alt_name = " (as [H.get_id_name("Unknown")])"

	/*
		Now we get into the real meat of the say processing. Determining the message mode.
	*/

	var/italics = 0
	var/message_range = null
	var/message_mode = null

	var/datum/language/speaking = null //For use if a specific language is being spoken.

	var/braindam = getBrainLoss()
	if (braindam >= 60)
		if(prob(braindam/4))
			message = stutter(message)
		if(prob(braindam))
			message = uppertext(message)

	// General public key. Special message handling
	var/mmode
	var/cprefix = ""
	if(length(message) >= 2)
		cprefix = copytext(message, 1, 3)
		if(cprefix in department_radio_keys)
			mmode = department_radio_keys[cprefix]
	if (copytext(message, 1, 2) == ";" || (prob(braindam/2) && !mmode))
		message_mode = "headset"
		message = copytext(message, 2)
	// Begin checking for either a message mode or a language to speak.
	else if (length(message) >= 2)
		var/channel_prefix = copytext(message, 1, 3)

		//Check if the person is speaking a language that they know.
		if(languages.len)
			for(var/datum/language/L in languages)
				if(lowertext(channel_prefix) == ":[L.key]")
					speaking = L
					break
		message_mode = department_radio_keys[channel_prefix]
		if (message_mode || speaking || copytext(message,1,2) == ":")
			message = trim(copytext(message, 3))
			if (!(istype(src,/mob/living/carbon/human) && !isAI(src) && !isrobot(src) || istype(src,/mob/living/carbon/monkey) || istype(src, /mob/living/simple_animal/parrot) || isrobot(src) && (message_mode=="department") || isAI(src) && (message_mode=="department") || (message_mode in radiochannels)))
				message_mode = null //only humans can use headsets

	if(traumatic_shock > 61 && prob(50))
		if(message_mode)
			src << "<span class='warning'>You try to use your radio, but you are in too much pain.</span>"
		message_mode = null //people in shock will have a high chance of not being able to speak on radio; needed since people don't instantly pass out at 100 damage.

	message = capitalize(message)

	if (!message)
		return

	if (stuttering)
		message = stutter(message)

	///////////////////////////////////////////////////////////
	// VIDEO KILLED THE RADIO STAR V2.0
	//
	// EXPERIMENTAL CODE BY YOUR PALS AT /vg/
	///////////////////////////////////////////////////////////

	var/list/obj/item/used_radios = new

	// Actually speaking on the radio?
	var/is_speaking_radio = 0

	// Devices selected
	var/list/devices=list()

	// Select all always_talk devices
	//  Carbon lifeforms
	//if(istype(src, /mob/living/carbon))
	for(var/obj/item/device/radio/R in contents)
		if(R.always_talk)
			devices += R

	//src << "Speaking on [message_mode]: [message]"
	if(message_mode)
		switch (message_mode)
			if ("right ear")
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:r_ear) devices += C:r_ear
				message_mode="headset"
				message_range = 1
				italics = 1

			if ("left ear")
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:l_ear) devices += C:l_ear
				message_mode="headset"
				message_range = 1
				italics = 1

			// Select a headset and speak into it without actually sending a message
			if ("fake")
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:l_ear) used_radios += C:l_ear
					if(C:r_ear) used_radios += C:r_ear
				if(issilicon(src))
					var/mob/living/silicon/Ro=src
					if(Ro:radio) devices += Ro:radio
				message_range = 1
				italics = 1
			if ("fake left ear")
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:l_ear) used_radios += C:l_ear
				message_range = 1
				italics = 1
			if ("fake right ear")
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:r_ear) used_radios += C:r_ear
				message_range = 1
				italics = 1

			if ("intercom")
				for (var/obj/item/device/radio/intercom/I in view(1, null))
					devices += I
				message_mode=null
				message_range = 1
				italics = 1

			//I see no reason to restrict such way of whispering
			if ("whisper")
				whisper(message)
				return

			if ("binary")
				if(robot_talk_understand || binarycheck())
				//message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)) //seems redundant
					robot_talk(message)
				return

			if ("alientalk")
				if(alien_talk_understand || hivecheck())
				//message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)) //seems redundant
					alien_talk(message)
				return

			if ("pAI")
				message_range = 1
				italics = 1

			if("changeling")
				if(mind && mind.changeling)
					log_say("[key_name(src)] ([mind.changeling.changelingID]): [message]")
					for(var/mob/Changeling in mob_list)
						if(istype(Changeling, /mob/living/silicon)) continue //WHY IS THIS NEEDED?
						if((Changeling.mind && Changeling.mind.changeling) || istype(Changeling, /mob/dead/observer))
							Changeling << "<i><font color=#800080><b>[mind.changeling.changelingID]:</b> [message]</font></i>"
						else if(istype(Changeling,/mob/dead/observer)  && (Changeling.client && Changeling.client.prefs.toggles & CHAT_GHOSTEARS))
							Changeling << "<i><font color=#800080><b>[mind.changeling.changelingID] (:</b> <a href='byond://?src=\ref[Changeling];follow2=\ref[Changeling];follow=\ref[src]'>(Follow)</a> [message]</font></i>"
					return
			else // headset, department channels.
				if(iscarbon(src))
					var/mob/living/carbon/C=src
					if(C:l_ear) devices += C:l_ear
					if(C:r_ear) devices += C:r_ear
				if(issilicon(src))
					if(isAI(src))//for the AI's radio.  This can't be with the borg thing above due to typecasting.
						var/mob/living/silicon/ai/A = src
						if(A.aiRadio)
							A.aiRadio.talk_into(src, message, message_mode)
							used_radios += A.aiRadio
					else
						var/mob/living/silicon/Ro=src
						if(!isAI(Ro))
							if(Ro:radio)
								devices += Ro:radio
						else
							warning("[src] has no radio!")
				message_range = 1
				italics = 1
	if(devices.len>0)
		for(var/obj/item/device/radio/R in devices)
			if(istype(R))
				R.talk_into(src, message, message_mode)
				used_radios += R
				is_speaking_radio = 1

	/////////////////////////////////////////////////////////////////
	// </NEW RADIO CODE>
	/////////////////////////////////////////////////////////////////

	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		var/pressure = environment.return_pressure()
		if(pressure < SOUND_MINIMUM_PRESSURE)
			italics = 1
			message_range = 1

	var/list/listening

	listening = get_mobs_in_view(message_range, src)
	var/list/onscreen = viewers()
	for(var/mob/M in player_list)
		if (!M.client)
			continue //skip monkeys and leavers
		if (istype(M, /mob/new_player))
			continue
		if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTEARS) && src.client) // src.client is so that ghosts don't have to listen to mice
			listening|=M

	var/turf/T = get_turf(src)
	var/list/W = hear(message_range, T)

	for (var/obj/O in ((W | contents)-used_radios))
		W |= O

	for (var/mob/M in W)
		W |= M.contents

	for (var/atom/A in W)
		if(istype(A, /mob/living/simple_animal/parrot)) //Parrot speech mimickry
			if(A == src)
				continue //Dont imitate ourselves

			var/mob/living/simple_animal/parrot/P = A
			if(P.speech_buffer.len >= 10)
				P.speech_buffer.Remove(pick(P.speech_buffer))
			P.speech_buffer.Add(message)

		if (isslime(A))
			var/mob/living/carbon/slime/S = A
			if (src in S.Friends)
				S.speech_buffer = list()
				S.speech_buffer.Add(src)
				S.speech_buffer.Add(lowertext(html_decode(message)))

		if(istype(A, /obj/)) //radio in pocket could work, radio in backpack wouldn't --rastaf0
			var/obj/O = A
			spawn (0)
				if(O && !istype(O.loc, /obj/item/weapon/storage))
					O.hear_talk(src, message)


	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/M in listening)
		if(hascall(M,"say_understands"))
			if (M:say_understands(src,speaking))
				heard_a += M
			else
				heard_b += M
		else
			heard_a += M

	var/speech_bubble_test = say_test(message)
	var/image/speech_bubble = image('icons/mob/talk.dmi',src,"h[speech_bubble_test]")
	spawn(30) del(speech_bubble)

	for(var/mob/M in hearers(5, src))
		if(M != src && is_speaking_radio)
			M:show_message("<span class='notice'>[src] talks into [used_radios.len ? used_radios[1] : "radio"]</span>")

/*	if(message_mode == null)
		var/accent = "en-us"
		var/voice = "m7"
		var/speed = 175
		var/pitch = 0
		var/echo = 10
		if(istype(src, /mob/living/silicon/ai))
			echo = 90
		if(istype(src, /mob/living/silicon/robot))
			echo = 60
		if(src.client && src.client.prefs)
			accent = src.client.prefs.accent
			voice = src.client.prefs.voice
			speed = src.client.prefs.talkspeed
			pitch = src.client.prefs.pitch
			src:texttospeech(message, speed, pitch, accent, "+[voice]", echo)*/

	var/rendered = null

	if (length(heard_a))
		var/message_a = say_quote(message,speaking)

		if (italics)
			message_a = "<i>[message_a]</i>"

		var/message_ghost = "<b>[message_a]</b>" // bold so ghosts know the person is in view.
		rendered = "<span class='game say'><span class='name'>[GetVoice()]</span>[alt_name] <span class='message'>[message_a]</span></span>"
		var/rendered2 = null

		for (var/mob/M in heard_a)
		//BEGIN TELEPORT CHANGES
/*			if(message_mode == null && fexists("sound/playervoices/[src.ckey].ogg"))
				if(M.client)
					if(M.client.prefs)
						if(M.client.prefs.sound & SOUND_VOICES)
							M.playsound_local(get_turf(src), "sound/playervoices/[src.ckey].ogg", 70, 0, 5, 1)*/
			if(!istype(M, /mob/new_player))
				if(M && M.stat == DEAD)
					if (M.client && M.client.prefs && (M.client.prefs.toggles & CHAT_GHOSTEARS) &&  M in onscreen)
						rendered2 = "<span class='game say'><span class='name'>[GetVoice()]</span></span> [alt_name] <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_ghost]</span></span>"
					else
						rendered2 = "<span class='game say'><span class='name'>[GetVoice()]</span></span> [alt_name] <a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span>"
					M:show_message(rendered2, 2)
					continue
	//END CHANGES

			if(hascall(M,"show_message"))
				var/deaf_message = ""
				var/deaf_type = 1
				if(M != src)
					deaf_message = "<span class='name'>[name]</span>[alt_name] talks but you cannot hear them."
				else
					deaf_message = "<span class='notice'>You cannot hear yourself!</span>"
					deaf_type = 2 // Since you should be able to hear yourself without looking
				M:show_message(rendered, 2, deaf_message, deaf_type)
				M << speech_bubble

	if (length(heard_b))

		var/message_b
		message_b = stars(message)
		message_b = say_quote(message_b,speaking)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[name]</span>[alt_name] <span class='message'>[message_b]</span></span>" //Voice_name isn't too useful. You'd be able to tell who was talking presumably.
		var/rendered2 = null

		for (var/M in heard_b)
			var/mob/MM
			if(istype(M, /mob))
				MM = M
			if(!istype(MM, /mob/new_player) && MM)
				if(MM && MM.stat == DEAD)
					rendered2 = "<span class='game say'><span class='name'>[voice_name]</span></span> <a href='byond://?src=\ref[MM];follow2=\ref[MM];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_b]</span></span>"
					MM:show_message(rendered2, 2)
					continue
			if(hascall(M,"show_message"))
				M:show_message(rendered, 2)
				M << speech_bubble

			/*
			if(M.client)

				if(!M.client.bubbles || M == src)
					var/image/I = image('icons/effects/speechbubble.dmi', B, "override")
					I.override = 1
					M << I
			*/ /*

		flick("[presay]say", B)

		if(istype(loc, /turf))
			B.loc = loc
		else
			B.loc = loc.loc

		spawn()
			sleep(11)
			del(B)
		*/

	log_say("[name]/[key] : [message]")

/obj/effect/speech_bubble
	var/mob/parent

/mob/living/proc/GetVoice()
	return name


