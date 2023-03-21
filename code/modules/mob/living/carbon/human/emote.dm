/mob/living/carbon/human/emote(act, m_type = 1, message = null, force)

	if((stat == DEAD) || (status_flags & FAKEDEATH))
		return // You can't just scream if you dead

	var/param = null
	if(findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = is_muzzled()
	if(muzzled)
		var/obj/item/clothing/mask/muzzle/M = wear_mask
		if(M.mute == MUZZLE_MUTE_NONE)
			muzzled = FALSE //Not all muzzles block sound
	if(!can_speak())
		muzzled = TRUE
	//var/m_type = 1

	for(var/obj/item/implant/I in src)
		if(I.implanted)
			I.trigger(act, src, force)

	var/miming = FALSE
	if(mind)
		miming = mind.miming

	//Emote Cooldown System (it's so simple!)
	//handle_emote_CD() located in [code\modules\mob\emote.dm]
	var/on_CD = FALSE
	act = lowertext(act)

	switch(act)		//This switch makes sure you have air in your lungs before you scream
		if("growl", "growls", "howl", "howls", "hiss", "hisses", "scream", "screams", "sneeze", "sneezes", "roar", "threat")
			if(getOxyLoss() > 35)		//no screaming if you don't have enough breath to scream
				on_CD = handle_emote_CD()
				emote("gasp")
				return
	switch(act)
		if("growl", "growls","purr", "purrs","purrl","drone", "drones", "hum", "hums",\
		"rumble", "rumbles","clack", "clacks","click", "clicks","warble", "warbles","salute",\
		"salutes","clap", "claps","deathgasp", "deathgasps","moan", "moans","slap", "slaps","snap", "snaps")	//If you are strangled you will not be able to gather your thoughts to make sounds or gestures,
			if(garroted_by.len)																						//not to mention saluting, spanking and finger-snapping
				on_CD = handle_emote_CD()
				emote("twitch")	//we pretend that the victim is trying to do something so that it doesn't look like hugs from the outside
				return

	switch(act)		//This switch adds cooldowns to some emotes
		if("ping", "pings", "buzz", "buzzes", "beep", "beeps", "yes", "no", "buzz2")
			var/found_machine_head = FALSE
			if(ismachineperson(src))		//Only Machines can beep, ping, and buzz, yes, no, and make a silly sad trombone noise.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
				found_machine_head = TRUE
			else
				var/obj/item/organ/external/head/H = get_organ("head") // If you have a robotic head, you can make beep-boop noises
				if(H && H.is_robotic())
					on_CD = handle_emote_CD()
					found_machine_head = TRUE

			if(!found_machine_head)								//Everyone else fails, skip the emote attempt
				return											//Everyone else fails, skip the emote attempt
		if("drone","drones","hum","hums","rumble","rumbles")
			if(isdrask(src))		//Only Drask can make whale noises
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
			else
				return
		if("howl", "howls")
			if(isvulpkanin(src))		//Only Vulpkanin can howl
				on_CD = handle_emote_CD(100)
			else
				return
		if("growl", "growls")
			if(isvulpkanin(src))		//Only Vulpkanin can growl
				on_CD = handle_emote_CD()
			else
				return
		if("purr", "purrl")
			if(istajaran(src))		//Only Tajaran can purr
				on_CD = handle_emote_CD(50)
			else
				return
		if("squish", "squishes")
			var/found_slime_bodypart = FALSE

			if(isslimeperson(src))	//Only Slime People can squish
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
				found_slime_bodypart = TRUE
			else
				for(var/obj/item/organ/external/L in bodyparts) // if your limbs are squishy you can squish too!
					if(istype(L.dna.species, /datum/species/slime))
						on_CD = handle_emote_CD()
						found_slime_bodypart = TRUE
						break

			if(!found_slime_bodypart)								//Everyone else fails, skip the emote attempt
				return

		if("clack", "clacks")
			if(iskidan(src))	//Only Kidan can clack and rightfully so.
				on_CD = handle_emote_CD(30)			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("click", "clicks")
			if(iskidan(src))	//Only Kidan can click and rightfully so.
				on_CD = handle_emote_CD(30)			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("creaks", "creak")
			if(isdiona(src)) //Only Dionas can Creaks.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("hiss")
			if(isunathi(src)) //Only Unathi can hiss.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'						//Everyone else fails, skip the emote attempt
			else								//Everyone else fails, skip the emote attempt
				return

		if("hisses")
			if(istajaran(src)) //tajaran hissing(sounds like cat hissing)
				on_CD = handle_emote_CD()
			else
				return

		if("roar")
			if(isunathi(src))
				on_CD = handle_emote_CD(50)
			else
				return

		if("threat")
			if(isunathi(src))
				on_CD = handle_emote_CD(50)
			else
				return

		if("whip")
			if(isunathi(src))
				on_CD = handle_emote_CD(20)
			else
				return

		if("whips")
			if(isunathi(src))
				on_CD = handle_emote_CD(40)
			else
				return

		if("quill", "quills")
			if(isvox(src)) //Only Vox can rustle their quills.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return
		if("flap", "flaps", "aflap", "aflaps","flutter", "flutters")
			if(ismoth(src))
				on_CD = handle_emote_CD()
			else								//Everyone else fails, skip the emote attempt
				return

		if("warble", "warbles")
			if(isskrell(src)) //Only Skrell can warble.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("choke", "chokes","giggle", "giggles","cry", "cries","sigh", "sighs","laugh", "laughs","moan", "moans","snore", "snores","wink", "winks","whistle", "whistles", "yawn", "yawns", "dance")
			on_CD = handle_emote_CD(50) //longer cooldown
		if("scream", "screams")
			on_CD = handle_emote_CD(50) //longer cooldown
		if("fart", "farts", "flip", "flips", "snap", "snaps")
			on_CD = handle_emote_CD()				//proc located in code\modules\mob\emote.dm
		if("cough", "coughs", "slap", "slaps", "highfive")
			on_CD = handle_emote_CD()
		if("gasp", "gasps")
			on_CD = handle_emote_CD()
		if("salute", "salutes")
			on_CD = handle_emote_CD()
		if("deathgasp", "deathgasps")
			on_CD = handle_emote_CD(50)
		if("sneeze", "sneezes")
			on_CD = handle_emote_CD()
		if("clap", "claps")
			on_CD = handle_emote_CD()
		//Everything else, including typos of the above emotes
		else
			if(last_emote == act)
				on_CD = handle_emote_CD(10)
			else
				on_CD = handle_emote_CD(5)		//no "snuffle" "sniff" spam

	if(!force && on_CD == 1)		// Check if we need to suppress the emote attempt.
		return			// Suppress emote, you're still cooling off.

	switch(act)		//This is for actually making the emotes happen
		if("me")									//OKAY SO RANT TIME, THIS FUCKING HAS TO BE HERE OR A SHITLOAD OF THINGS BREAK
			return custom_emote(m_type, message)	//DO YOU KNOW WHY SHIT BREAKS? BECAUSE SO MUCH OLDCODE CALLS mob.emote("me",1,"whatever_the_fuck_it_wants_to_emote")
													//WHO THE FUCK THOUGHT THAT WAS A GOOD FUCKING IDEA!?!?

		if("howl", "howls")
			var/M = handle_emote_param(param)
			if(miming)
				message = "делает вид, что воет[M ? " на [M]" : ""]!"
				m_type = 1
			else
				if(!muzzled)
					message = "воет[M ? " на [M]" : ""]!"
					playsound(loc, 'sound/goonstation/voice/howl.ogg', 100, 1, 10, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает очень громкий шум[M ? " на [M]" : ""]."
					m_type = 2

		if("growl", "growls")
			var/M = handle_emote_param(param)
			if(miming)
				message = "делает вид, что рычит[M ? " на [M]" : ""]."
				m_type = 1
			else
				message = "рычит[M ? " на [M]" : ""]."
				playsound(loc, "growls", !muzzled ? 80:25, 1, frequency = get_age_pitch())
				m_type = 2

		if("purr", "purrs")
			if(miming)
				message = "делает вид, что мурчит."
				m_type = 1
			else
				message = "мурчит."
				playsound(src, 'sound/voice/cat_purr.ogg', 80, 1, frequency = get_age_pitch())
				m_type = 2

		if("purrl")
			if(miming)
				message = "делает вид, что мурчит."
				m_type = 1
			else
				message = "мурчит."
				playsound(src, 'sound/voice/cat_purr_long.ogg', 80, 1, frequency = get_age_pitch())
				m_type = 2

		if("ping", "pings")
			if(!miming)
				var/M = handle_emote_param(param)

				message = "звенит[M ? " на [M]" : ""]."
				playsound(loc, 'sound/machines/ping.ogg', 50, 1, frequency = get_age_pitch())
				m_type = 2

		if("buzz2")
			if(!miming)
				var/M = handle_emote_param(param)

				message = "издает раздраженный жужжащий звук[M ? " на [M]" : ""]."
				playsound(loc, 'sound/machines/buzz-two.ogg', 50, 1, frequency = get_age_pitch())
				m_type = 2

		if("buzz", "buzzes")
			if(!miming)
				var/M = handle_emote_param(param)

				message = "жужжит[M ? " на [M]" : ""]."
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 1, frequency = get_age_pitch())
				m_type = 2

		if("beep", "beeps")
			if(!miming)
				var/M = handle_emote_param(param)

				message = "пищит[M ? " на [M]" : ""]."
				playsound(loc, 'sound/machines/twobeep.ogg', 50, 1, frequency = get_age_pitch())
				m_type = 2

		if("drone", "drones", "hum", "hums", "rumble", "rumbles")
			var/M = handle_emote_param(param)

			if(miming)
				message = "делает вид, что [M ? "грохочет на [M]" : "грохочет"]."
				m_type = 1
			else
				message = "[M ? "грохочет на [M]" : "грохочет"]."
				playsound(loc, 'sound/voice/drasktalk.ogg', 50, 1, frequency = get_age_pitch())
				m_type = 2

		if("squish", "squishes")
			var/M = handle_emote_param(param)

			if(miming)
				message = "делает вид, что хлюпает[M ? " на [M]" : ""]."
				m_type = 1
			else
				message = "хлюпает[M ? " на [M]" : ""]."
				playsound(loc, 'sound/effects/slime_squish.ogg', 50, 1, frequency = get_age_pitch()) //Credit to DrMinky (freesound.org) for the sound.
				m_type = 2

		if("clack", "clacks")
			var/M = handle_emote_param(param)

			var/obj/item/organ/external/head = src.get_organ("head")
			if(head)
				if(miming)
					message = "дёргает нижней челюстью[M ? " на [M]" : ""]."
					m_type = 1
				else
					mineral_scan_pulse(get_turf(src), range = world.view)
					message = "трещит своей нижней челюстью[M ? " на [M]" : ""]."
					m_type = 2
					playsound(loc, 'sound/effects/Kidanclack.ogg', 50, 1, frequency = get_age_pitch()) //Credit to DrMinky (freesound.org) for the sound.
			else
				message = "отчаянно дёргается."
				m_type = 1

		if("click", "clicks")
			var/M = handle_emote_param(param)

			var/obj/item/organ/external/head = src.get_organ("head")
			if(head)
				if(miming)
					message = "дёргает нижней челюстью[M ? " на [M]" : ""]."
					m_type = 1
				else
					mineral_scan_pulse(get_turf(src), range = world.view)
					message = "щелкает своей нижней челюстью[M ? " на [M]" : ""]."
					m_type = 2
					playsound(loc, 'sound/effects/Kidanclack2.ogg', 50, 1, frequency = get_age_pitch()) //Credit to DrMinky (freesound.org) for the sound.
			else
				message = "отчаянно дёргается."
				m_type = 1

		if("creaks", "creak")
			var/M = handle_emote_param(param)

			if(miming)
				message = "шевел[pluralize_ru(src.gender,"ит","ят")] ветками[M ? " на [M]" : ""]."
				m_type = 1
			else
				message = "скрип[pluralize_ru(src.gender,"ит","ят")][M ? " на [M]" : ""]."
				playsound(loc, 'sound/voice/dionatalk1.ogg', 50, 1, frequency = get_age_pitch()) //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
				m_type = 2

		if("hiss")
			var/M = handle_emote_param(param)

			if(miming)
				message = "делает вид, что шипит[M ? " на [M]" : ""]."
				m_type = 1
			else
				if(!muzzled)
					message = "шипит[M ? " на [M]" : ""]."
					playsound(loc, 'sound/effects/unathihiss.ogg', 50, 1, frequency = get_age_pitch()) //Credit to Jamius (freesound.org) for the sound.
					m_type = 2
				else
					message = "тихо шипит."
					m_type = 2

		if("roar")
			var/M = handle_emote_param(param)

			if(miming)
				message = "делает вид, что рычит[M ? " на [M]" : ""]."
				m_type = 1
			else
				if(!muzzled)
					message = "рычит[M ? " на [M]" : ""]."
					playsound(src, pick('sound/goonstation/voice/unathi/roar.ogg', 'sound/goonstation/voice/unathi/roar2.ogg', 'sound/goonstation/voice/unathi/roar3.ogg'), 50, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "тихо рычит."
					m_type = 2

		if("whip")
			var/obj/item/organ/external/tail = src.get_organ("tail")
			var/M = handle_emote_param(param)

			if(miming)
				message = "взмахивает хвостом и бесшумно опускает его на пол[M ? ", грозно смотря на [M]" : ""]."
				m_type = 1
			else
				if(tail)
					message = "ударяет хвостом[M ? ", грозно смотря на [M]" : ""]."
					m_type = 2
					playsound(loc, 'sound/goonstation/voice/unathi/whip_short.ogg', 100)
				else
					message = "пытается взмахнуть отсутствующим хвостом."
					m_type = 1

		if("whips")
			var/obj/item/organ/external/tail = src.get_organ("tail")
			var/M = handle_emote_param(param)

			if(miming)
				message = "взмахивает хвостом и бесшумно опускает его на пол[M ? ", грозно смотря на [M]" : ""]."
				m_type = 1
			else
				if(tail)
					message = "хлестает хвостом[M ? ", грозно смотря на [M]" : ""]."
					m_type = 2
					playsound(loc, 'sound/goonstation/voice/unathi/whip.ogg', 100)
				else
					message = "пытается взмахнуть отсутствующим хвостом."
					m_type = 1

		if("threat")
			var/M = handle_emote_param(param)

			if(miming)
				message = "угрожающе раскрывает пасть[M ? " на [M]" : ""]."
				m_type = 1
			else
				if(!muzzled)
					message = "угрожающе раскрывает пасть[M ? " на [M]" : ""]."
					playsound(src, pick('sound/goonstation/voice/unathi/threat.ogg', 'sound/goonstation/voice/unathi/threat2.ogg'), 50, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издаёт громкий шум."
					m_type = 2

		if("hisses")
			var/M = handle_emote_param(param)

			if(miming)
				message = "делает вид, что шипит[M ? " на [M]" : ""]."
				m_type = 1
			else
				if(!muzzled)
					message = "шипит[M ? " на [M]" : ""]."
					playsound(loc, 'sound/voice/tajarahiss.mp3', 100, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "тихо шипит."
					m_type = 2

		if("quill", "quills")
			if(!miming)
				var/M = handle_emote_param(param)

				message = "шуршит своими перьями[M ? " на [M]" : ""]."
				playsound(loc, 'sound/effects/voxrustle.ogg', 50, 1, frequency = get_age_pitch()) //Credit to sound-ideas (freesfx.co.uk) for the sound.
				m_type = 2

		if("warble", "warbles")
			if(!miming)
				var/M = handle_emote_param(param)

				message = "издает трель[M ? " на [M]" : ""]."
				playsound(loc, 'sound/effects/warble.ogg', 50, 1, frequency = get_age_pitch()) // Copyright CC BY 3.0 alienistcog (freesound.org) for the sound.
				m_type = 2

		if("yes")
			if(!miming)
				var/M = handle_emote_param(param)

				message = "испускает утвердительный сигнал[M ? " для [M]" : ""]."
				playsound(loc, 'sound/machines/synth_yes.ogg', 50, 1, frequency = get_age_pitch())
				m_type = 2

		if("no")
			if(!miming)
				var/M = handle_emote_param(param)

				message = "испускает отрицательный сигнал[M ? " для [M]" : ""]."
				playsound(loc, 'sound/machines/synth_no.ogg', 50, 1, frequency = get_age_pitch())
				m_type = 2

		if("wag", "wags")
			if(istype(body_accessory, /datum/body_accessory/tail))
				if(body_accessory.try_restrictions(src))
					message = "начинает махать хвостом."
					start_tail_wagging()

			else if(dna.species.bodyflags & TAIL_WAGGING)
				if(!wear_suit || !(wear_suit.flags_inv & HIDETAIL))
					message = "начинает махать хвостом."
					start_tail_wagging()
				else
					return
			else
				return
			m_type = 1

		if("swag", "swags")
			if((dna.species.bodyflags & TAIL_WAGGING) || istype(body_accessory, /datum/body_accessory/tail))
				message = "прекращает махать хвостом."
				stop_tail_wagging()
			else
				return
			m_type = 1

		if("scratch")
			if(!restrained())
				message = "чеш[pluralize_ru(src.gender,"е","у")]тся."
				m_type = 1

		if("airguitar")
			if(!restrained())
				message = "дела[pluralize_ru(src.gender,"ет","ют")] невероятный запил на воображаемой гитаре!"
				m_type = 1

		if("dance")
			if(!restrained())
				message = "радостно танцу[pluralize_ru(src.gender,"ет","ют")]!"
				m_type = 1
				var/dance_time = 3 SECONDS
				var/obj/structure/table/table = locate() in src.loc
				if(table)
					table.clumse_stuff(src)
				spin(dance_time, pick(0.1 SECONDS, 0.2 SECONDS))
				do_jitter_animation(rand(80, 160), dance_time / 4)

		if("jump")
			if(!restrained())
				message = "прыга[pluralize_ru(src.gender,"ет","ют")]!"
				m_type = 1

		if("blink", "blinks")
			message = "морга[pluralize_ru(src.gender,"ет","ют")]."
			m_type = 1

		if("blink_r", "blinks_r")
			message = "быстро морга[pluralize_ru(src.gender,"ет","ют")]."
			m_type = 1

		if("bow", "bows")
			if(!restrained())
				var/M = handle_emote_param(param)

				message = "дела[pluralize_ru(src.gender,"ет","ют")] поклон[M ? " [M]" : ""]."
			m_type = 1

		if("salute", "salutes")
			if(!restrained())
				var/M = handle_emote_param(param)

				message = "салюту[pluralize_ru(src.gender,"ет","ют")][M ? " [M]" : ""]!"
				playsound(loc, 'sound/effects/salute.ogg', 50, 0)
			m_type = 1

		if("choke", "chokes")
			if(miming)
				message = "отчаяно хвата[pluralize_ru(src.gender,"ет","ют")]ся за горло!"
				m_type = 1
			else
				if(!muzzled)
					message = "подавил[genderize_ru(src.gender,"ся","ась","ось","ись")]!"
					if(gender == FEMALE)
						playsound(src, pick('sound/voice/gasp_female1.ogg','sound/voice/gasp_female2.ogg','sound/voice/gasp_female3.ogg','sound/voice/gasp_female4.ogg','sound/voice/gasp_female5.ogg','sound/voice/gasp_female6.ogg','sound/voice/gasp_female7.ogg'), 50, 1, frequency = get_age_pitch())
					else
						playsound(src, pick('sound/voice/gasp_male1.ogg','sound/voice/gasp_male2.ogg','sound/voice/gasp_male3.ogg','sound/voice/gasp_male4.ogg','sound/voice/gasp_male5.ogg','sound/voice/gasp_male6.ogg','sound/voice/gasp_male7.ogg'), 50, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ёт","ют")] громкие звуки."
					m_type = 2

		if("burp", "burps")
			if(miming)
				message = "мерзко разева[pluralize_ru(src.gender,"ет","ют")] рот."
				m_type = 1
			else
				if(!muzzled)
					message = "рыга[pluralize_ru(src.gender,"ет","ют")]."
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ёт","ют")] своеобразные звуки."
					m_type = 2
		if("clap", "claps")
			if(miming)
				message = "бесшумно хлопа[pluralize_ru(src.gender,"ет","ют")]."
				m_type = 1
			else
				m_type = 2
				var/obj/item/organ/external/L = get_organ("l_hand")
				var/obj/item/organ/external/R = get_organ("r_hand")

				var/left_hand_good = FALSE
				var/right_hand_good = FALSE

				if(L && (!(L.status & ORGAN_SPLINTED)) && (!(L.status & ORGAN_BROKEN)))
					left_hand_good = TRUE
				if(R && (!(R.status & ORGAN_SPLINTED)) && (!(R.status & ORGAN_BROKEN)))
					right_hand_good = TRUE

				if(left_hand_good && right_hand_good)
					message = "хлопа[pluralize_ru(src.gender,"ет","ют")]."
					var/clap = pick('sound/misc/clap1.ogg', 'sound/misc/clap2.ogg', 'sound/misc/clap3.ogg', 'sound/misc/clap4.ogg')
					playsound(loc, clap, 50, 1, -1)

				else
					to_chat(usr, "Тебе нужно две рабочих руки чтобы хлопать.")

		if("flap", "flaps")
			if(istype(body_accessory, /datum/body_accessory/wing))
				if(body_accessory.try_restrictions(src))
					message = "маш[pluralize_ru(src.gender,"ет","ют")] крыльями."
					m_type = 2
					if(miming)
						m_type = 1

		if("flutter", "flutters")
			message = "маш[pluralize_ru(src.gender,"ет","ют")] крыльями."
			m_type = 2
			if(miming)
				m_type = 1

		if("flip", "flips")
			m_type = 1
			if(!restrained())
				var/M = null
				if(param)
					for(var/mob/A in view(1, null))
						if(lowertext(param) == lowertext(A.name))
							M = A
							break
				if(M == src)
					M = null

				if(M)
					if(lying)
						message = "упал[genderize_ru(src.gender,"","а","о","и")] на пол и круж[pluralize_ru(src.gender,"ит","ат")]ся."
					else
						message = "кувырка[pluralize_ru(src.gender,"ет","ют")]ся в направлении [M]."
						SpinAnimation(5,1)
				else
					if(lying || IsWeakened())
						message = "круж[pluralize_ru(src.gender,"ит","ат")]ся лежа."
					else
						var/obj/item/grab/G
						if(istype(get_active_hand(), /obj/item/grab))
							G = get_active_hand()
						if(G && G.affecting)
							if(buckled || G.affecting.buckled)
								return
							var/turf/oldloc = loc
							var/turf/newloc = G.affecting.loc
							if(isturf(oldloc) && isturf(newloc))
								SpinAnimation(5,1)
								glide_for(6) // This and the glide_for below are purely arbitrary. Pick something that looks aesthetically pleasing.
								forceMove(newloc)
								G.glide_for(6)
								G.affecting.forceMove(oldloc)
								message = "дела[pluralize_ru(src.gender,"ет","ют")] кувырок через [G.affecting]!"
						else

							if(iskidan(src) && !src.get_organ("head"))
								message = "пыта[pluralize_ru(src.gender,"ет","ют")]ся кувыркнуться и с грохотом пада[pluralize_ru(src.gender,"ет","ют")] на пол!"
								SpinAnimation(5,1)
								sleep(3)
								Weaken(2)
							else
								if(prob(5))
									message = "пыта[pluralize_ru(src.gender,"ет","ют")]ся кувыркнуться и с грохотом пада[pluralize_ru(src.gender,"ет","ют")] на пол!"
									SpinAnimation(5,1)
									sleep(3)
									Weaken(2)
								else
									message = "дела[pluralize_ru(src.gender,"ет","ют")] кувырок!"
									SpinAnimation(5,1)

		if("aflap", "aflaps")
			if(istype(body_accessory, /datum/body_accessory/tail))
				if(body_accessory.try_restrictions(src))
					message = "агрессивно маш[pluralize_ru(src.gender,"ет","ут")] крыльями!"
					m_type = 2
					if(miming)
						m_type = 1

		if("drool", "drools")
			message = "неразборчиво бурч[pluralize_ru(src.gender,"ит","ат")]."
			m_type = 1

		if("eyebrow")
			message = "приподнима[pluralize_ru(src.gender,"ет","ют")] бровь."
			m_type = 1

		if("chuckle", "chuckles")
			if(miming)
				message = "будто бы усмеха[pluralize_ru(src.gender,"ет","ют")]я."
				m_type = 1
			else
				if(!muzzled)
					message = "усмеха[pluralize_ru(src.gender,"ет","ют")]ся."
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ет","ют")] шум."
					m_type = 2

		if("twitch", "twitches")
			message = "сильно дерга[pluralize_ru(src.gender,"ет","ют")]ся!"
			m_type = 1

		if("twitch_s", "twitches_s")
			message = "дерга[pluralize_ru(src.gender,"ет","ют")]ся."
			m_type = 1

		if("faint", "faints")
			message = "пада[pluralize_ru(src.gender,"ет","ют")] в обморок!"
			if(sleeping)
				return //Can't faint while asleep
			AdjustSleeping(2)
			m_type = 1

		if("cough", "coughs")
			if(miming)
				message = "кажется кашля[pluralize_ru(src.gender,"ет","ют")]!"
				m_type = 1
			else
				if(!muzzled)
					message = "кашля[pluralize_ru(src.gender,"ет","ют")]!"
					m_type = 2
					if(gender == FEMALE)
						if(dna.species.female_cough_sounds)
							playsound(src, pick(dna.species.female_cough_sounds), 120, 1, frequency = get_age_pitch())
					else
						if(dna.species.male_cough_sounds)
							playsound(src, pick(dna.species.male_cough_sounds), 120, 1, frequency = get_age_pitch())
				else
					message = "издает сильный шум."
					m_type = 2

		if("frown", "frowns")
			var/M = handle_emote_param(param)

			message = "хмур[pluralize_ru(src.gender,"ит","ят")]ся[M ? " на [M]" : ""]."
			m_type = 1

		if("nod", "nods")
			var/M = handle_emote_param(param)

			message = "кива[pluralize_ru(src.gender,"ет","ют")][M ? " на [M]" : ""]."
			m_type = 1

		if("blush", "blushes")
			message = "красне[pluralize_ru(src.gender,"ет","ют")]…"
			m_type = 1

		if("wave", "waves")
			var/M = handle_emote_param(param)

			message = "маш[pluralize_ru(src.gender,"ет","ут")][M ? " [M]" : ""]."
			m_type = 1

		if("quiver", "quivers")
			message = "трепещ[pluralize_ru(src.gender,"ет","ут")]."
			m_type = 1

		if("gasp", "gasps")
			if(miming)
				message = "будто бы задыха[pluralize_ru(src.gender,"ет","ют")]ся!"
				m_type = 1
			else
				if(!muzzled)
					message = "задыха[pluralize_ru(src.gender,"ет","ют")]ся!"
					if(health <= 0)
						if(gender == FEMALE)
							playsound(loc, pick(dna.species.female_dying_gasp_sounds), 100, 1, frequency = get_age_pitch())
						else
							playsound(loc, pick(dna.species.male_dying_gasp_sounds), 100, 1, frequency = get_age_pitch())

					else
						playsound(loc, dna.species.gasp_sound, 50, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ёт","ют")] слабый шум."
					m_type = 2

		if("deathgasp", "deathgasps")
			message = "[dna.species.death_message]"
			playsound(loc, pick(dna.species.death_sounds), 50, 1, frequency = get_age_pitch())
			m_type = 1

		if("giggle", "giggles")
			if(miming)
				message = "бесшумно хихика[pluralize_ru(src.gender,"ет","ют")]!"
				m_type = 1
			else
				if(!muzzled)
					message = "хихика[pluralize_ru(src.gender,"ет","ют")]."
					if(gender == FEMALE)
						playsound(src, pick(dna.species.female_giggle_sound), 70, 1, frequency = get_age_pitch())
					else
						playsound(src, pick(dna.species.male_giggle_sound), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ет","ют")] шум."
					m_type = 2

		if("glare", "glares")
			var/M = handle_emote_param(param)

			message = "недовольно смотр[pluralize_ru(src.gender,"ит","ят")][M ? " на [M]" : ""]."
			m_type = 1

		if("stare", "stares")
			var/M = handle_emote_param(param)

			message = "пял[pluralize_ru(src.gender,"и","я")]тся[M ? " на [M]" : ""]."
			m_type = 1

		if("look", "looks")
			var/M = handle_emote_param(param)

			message = "смотр[pluralize_ru(src.gender,"ит","ят")][M ? " на [M]" : ""]."
			m_type = 1

		if("grin", "grins")
			var/M = handle_emote_param(param)

			message = "скал[pluralize_ru(src.gender,"ится","ятся")] в улыбке[M ? " на [M]" : ""]."
			m_type = 1

		if("cry", "cries")
			if(miming)
				message = "плач[pluralize_ru(src.gender,"ет","ут")]."
				m_type = 1
			else
				if(!muzzled)
					message = "плач[pluralize_ru(src.gender,"ет","ут")]."
					if(gender == FEMALE)
						playsound(src, pick('sound/voice/cry_female_1.ogg','sound/voice/cry_female_2.ogg','sound/voice/cry_female_3.ogg'), 70, 1, frequency = get_age_pitch())
					else
						playsound(src, pick('sound/voice/cry_male_1.ogg','sound/voice/cry_male_2.ogg'), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ёт","ют")] слабый шум и хмурится."
					m_type = 2

		if("sigh", "sighs")
			if(miming)
				message = "вздыха[pluralize_ru(src.gender,"ет","ют")]."
				m_type = 1
			else
				if(!muzzled)
					message = "вздыха[pluralize_ru(src.gender,"ет","ют")]."
					if(gender == FEMALE)
						playsound(src, 'sound/voice/sigh_female.ogg', 70, 1, frequency = get_age_pitch())
					else
						playsound(src, 'sound/voice/sigh_male.ogg', 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ет","ют")] слабый шум."
					m_type = 2

		if("hsigh", "hsighs")
			if(!muzzled)
				message = "удовлетворенно вздыха[pluralize_ru(src.gender,"ет","ют")]."
				m_type = 2
			else
				message = "изда[pluralize_ru(src.gender,"ет","ют")] [pick("спокойный", "расслабленный")] шум."
				m_type = 2

		if("laugh", "laughs")
			var/M = handle_emote_param(param)
			if(miming)
				message = "бесшумно сме[pluralize_ru(src.gender,"ет","ют")]ся[M ? " над [M]" : ""]."
				m_type = 1
			else
				if(!muzzled)
					message = "сме[pluralize_ru(src.gender,"ет","ют")]ся[M ? " над [M]" : ""]."
					if(gender == FEMALE)
						playsound(src, pick(dna.species.female_laugh_sound), 70, 1, frequency = get_age_pitch())
					else
						playsound(src, pick(dna.species.male_laugh_sound), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ет","ют")] шум."
					m_type = 2

		if("mumble", "mumbles")
			message = "бормоч[pluralize_ru(src.gender,"ет","ут")]!"
			m_type = 2
			if(miming)
				m_type = 1

		if("grumble", "grumbles")
			var/M = handle_emote_param(param)
			if(miming)
				message = "бесшумно ворч[pluralize_ru(src.gender,"ит","ят")][M ? " на [M]" : ""]!"
				m_type = 1
			if(!muzzled)
				message = "ворч[pluralize_ru(src.gender,"ит","ят")][M ? " на [M]" : ""]!"
				m_type = 2
			else
				message = "изда[pluralize_ru(src.gender,"ет","ют")] шум."
				m_type = 2

		if("groan", "groans")
			if(miming)
				message = "каж[pluralize_ru(src.gender,"ет","ут")]ся болезненно вздыхает!"
				m_type = 1
			else
				if(!muzzled)
					message = "болезненно вздыха[pluralize_ru(src.gender,"ет","ют")]!"
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ет","ют")] громкий звук."
					m_type = 2

		if("moan", "moans")
			if(miming)
				message = "каж[pluralize_ru(src.gender,"ет","ют")]ся стон[pluralize_ru(src.gender,"ет","ут")]!"
				m_type = 1
			else
				message = "стон[pluralize_ru(src.gender,"ет","ут")]!"
				if(gender == FEMALE)
					playsound(src, pick('sound/voice/moan_female_1.ogg','sound/voice/moan_female_2.ogg','sound/voice/moan_female_3.ogg'), 70, 1, frequency = get_age_pitch())
				else
					playsound(src, pick('sound/voice/moan_male_1.ogg','sound/voice/moan_male_2.ogg','sound/voice/moan_male_3.ogg'), 70, 1, frequency = get_age_pitch())
				m_type = 2

		if("johnny")
			var/M
			if(param)
				M = param
			if(!M)
				param = null
			else
				if(miming)
					message = "затягива[pluralize_ru(src.gender,"ет","ют")]ся сигаретой \"[M]\" и выдыха[pluralize_ru(src.gender,"ет","ют")] дым."
					m_type = 1
				else
					message = "говор[pluralize_ru(src.gender,"ит","ят")], \"[M], пожалуйста. У них была семья.\" [name] затягива[pluralize_ru(src.gender,"ет","ют")] сигаретой и выдыха[pluralize_ru(src.gender,"ет","ют")] свое имя в дыму."
					m_type = 2

		if("point", "points")
			if(!restrained())
				var/atom/M = null
				if(param)
					for(var/atom/A as mob|obj|turf in view())
						if(lowertext(param) == lowertext(A.name))
							M = A
							break

				if(!M)
					message = "показыва[pluralize_ru(src.gender,"ет","ют")] пальцем."
				else
					pointed(M)
			m_type = 1

		if("raise", "raises")
			if(!restrained())
				message = "поднима[pluralize_ru(src.gender,"ет","ют")] руку."
			m_type = 1

		if("shake", "shakes")
			var/M = handle_emote_param(param, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves.

			message = "тряс[pluralize_ru(src.gender,"ет","ут")] головой[M ? " на [M]" : ""]."
			m_type = 1

		if("shrug", "shrugs")
			message = "пожима[pluralize_ru(src.gender,"ет","ют")] плечами."
			m_type = 1

		if("signal", "signals")
			if(!restrained())
				var/t1 = round(text2num(param))
				if(isnum(t1))
					if(t1 < 5 && t1 > 1 && (!r_hand || !l_hand))
						message = "показыва[pluralize_ru(src.gender,"ет","ют")] [t1] пальца."
					else if(t1 == 1 && (!r_hand || !l_hand))
						message = "показыва[pluralize_ru(src.gender,"ет","ют")] 1 палец."
					else if(t1 == 5 && (!r_hand || !l_hand))
						message = "показыва[pluralize_ru(src.gender,"ет","ют")] 5 пальцев."
					else if(t1 <= 10 && t1 >= 1 && (!r_hand && !l_hand))
						message = "показыва[pluralize_ru(src.gender,"ет","ют")] [t1] пальцев."
			m_type = 1

		if("smile", "smiles")
			var/M = handle_emote_param(param, 1)

			message = "улыба[pluralize_ru(src.gender,"ет","ют")]ся[M ? " [M]" : ""]."
			m_type = 1

		if("shiver", "shivers")
			message = "дрож[pluralize_ru(src.gender,"ит","ат")]."
			m_type = 2
			if(miming)
				m_type = 1

		if("pale", "pales")
			message = "на секунду бледне[pluralize_ru(src.gender,"ет","ют")]...."
			m_type = 1

		if("tremble", "trembles")
			message = "дрож[pluralize_ru(src.gender,"ит","ат")] в ужасе!"
			m_type = 1

		if("shudder", "shudders")
			message = "содрога[pluralize_ru(src.gender,"ет","ют")]ся."
			m_type = 1

		if("bshake", "bshakes")
			message = "тряс[pluralize_ru(src.gender,"ет","ут")]ся."
			m_type = 1

		if("sneeze", "sneezes")
			if(miming)
				message = "чиха[pluralize_ru(src.gender,"ет","ют")]."
				m_type = 1
			else
				if(!muzzled)
					message = "чиха[pluralize_ru(src.gender,"ет","ют")]."
					if(gender == FEMALE)
						playsound(src, dna.species.female_sneeze_sound, 70, 1, frequency = get_age_pitch())
					else
						playsound(src, dna.species.male_sneeze_sound, 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ет","ют")] странный шум."
					m_type = 2

		if("sniff", "sniffs")
			var/M = handle_emote_param(param, 1)

			message = "нюха[pluralize_ru(src.gender,"ет","ют")][M ? " [M]" : ""]."
			m_type = 2
			if(miming)
				m_type = 1

		if("snuffle")
			message = "шмыга[pluralize_ru(gender,"ет","ют")] носом."
			m_type = 2
			if(miming)
				message = "беззвучно " + message
				m_type = 1

		if("snore", "snores")
			if(miming)
				message = "крепко сп[pluralize_ru(src.gender,"ит","ят")]."
				m_type = 1
			else
				if(!muzzled)
					message = "храп[pluralize_ru(src.gender,"ит","ят")]."
					playsound(src, pick('sound/voice/snore_1.ogg', 'sound/voice/snore_2.ogg','sound/voice/snore_3.ogg', 'sound/voice/snore_4.ogg','sound/voice/snore_5.ogg', 'sound/voice/snore_6.ogg','sound/voice/snore_7.ogg'), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ет","ют")] шум."
					m_type = 2

		if("whimper", "whimpers")
			if(miming)
				message = "каж[pluralize_ru(src.gender,"ет","ют")]ся ранен."
				m_type = 1
			else
				if(!muzzled)
					message = "хныч[pluralize_ru(src.gender,"ет","ют")]."
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ет","ют")] слабый шум."
					m_type = 2

		if("wink", "winks")
			var/M = handle_emote_param(param, 1)

			message = "подмигива[pluralize_ru(src.gender,"ет","ют")][M ? " [M]" : ""]."
			m_type = 1

		if("yawn", "yawns")
			if(miming)
				message = "дела[pluralize_ru(src.gender,"ет","ют")] вид что зева[pluralize_ru(src.gender,"ет","ют")]."
			else
				if(!muzzled)
					message = "зева[pluralize_ru(src.gender,"ет","ют")]."
					if(gender == FEMALE)
						playsound(src, pick('sound/voice/yawn_female_1.ogg', 'sound/voice/yawn_female_2.ogg','sound/voice/yawn_female_3.ogg'), 70, 1, frequency = get_age_pitch())
					else
						playsound(src, pick('sound/voice/yawn_male_1.ogg', 'sound/voice/yawn_male_2.ogg'), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ёт","ют")] шум."
					m_type = 2

		if("collapse", "collapses")
			Paralyse(2)
			message = "пада[pluralize_ru(src.gender,"ет","ют")]!"
			m_type = 2
			if(miming)
				m_type = 1

		if("hug", "hugs")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, 1, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves and only check mobs in our immediate vicinity (1 tile distance).

				if(M)
					message = "обнима[pluralize_ru(src.gender,"ет","ют")] [M]."
				else
					message = "обнима[pluralize_ru(src.gender,"ет","ют")] сам[genderize_ru(src.gender,"","а","о","и")] себя."

		if("handshake")
			m_type = 1
			if(!restrained() && !r_hand)
				var/mob/M = handle_emote_param(param, 1, 1, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves, only check mobs in our immediate vicinity (1 tile distance) and return the whole mob instead of just its name.

				if(M)
					if(M.canmove && !M.r_hand && !M.restrained())
						message = "пожима[pluralize_ru(src.gender,"ет","ют")] руку [M]."
					else
						message = "протягива[pluralize_ru(src.gender,"ет","ют")] руку [M]."

		if("dap", "daps")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, null, 1)

				if(M)
					message = "да[pluralize_ru(src.gender,"ёт","ют")] пять [M]."
				else
					message = "не смог[genderize_ru(src.gender,"","ла","ло","ли")] найти кому дать пять, и да[pluralize_ru(src.gender,"ёт","ют")] пять сам[genderize_ru(src.gender,"","а","о","и")] себе. Позорище."

		if("slap", "slaps")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, null, 1)

				if(M)
					for(var/mob/living/carbon/human/A in view(1, null))
						if(lowertext(M) == lowertext(A.name))
							message = "<span class='danger'>шлепа[pluralize_ru(src.gender,"ет","ют")] [M]. Оу!</span>"
							playsound(loc, 'sound/effects/snap.ogg', 50, 1)
							var/obj/item/organ/external/O = A.get_organ(src.zone_selected)
							if(O.brute_dam < 5)
								O.receive_damage(1)
				else
					message = "<span class='danger'>шлепа[pluralize_ru(src.gender,"ет","ют")] себя!</span>"
					playsound(loc, 'sound/effects/snap.ogg', 50, 1)
					var/obj/item/organ/external/O = src.get_organ(src.zone_selected)
					if(O.brute_dam < 5)
						O.receive_damage(1)

		if("scream", "screams")
			var/M = handle_emote_param(param)
			if(miming)
				message = "дела[pluralize_ru(src.gender,"ет","ют")] вид что крич[pluralize_ru(src.gender,"ит","ат")][M ? " на [M]" : ""]!"
				m_type = 1
			else
				if(!muzzled)
					message = "[pluralize_ru(src.gender,"[dna.species.scream_verb]","кричат")][M ? " на [M]" : ""]!"
					m_type = 2
					if(gender == FEMALE)
						playsound(loc, dna.species.female_scream_sound, 80, 1, frequency = get_age_pitch())
					else
						playsound(loc, dna.species.male_scream_sound, 80, 1, frequency = get_age_pitch()) //default to male screams if no gender is present.

				else
					message = "изда[pluralize_ru(src.gender,"ёт","ют")] очень громкий шум[M ? " в сторону [M]" : ""]."
					m_type = 2

		if("whistle", "whistles")
			if(miming)
				message = "бесшумно свист[pluralize_ru(src.gender,"ит","ят")]."
				m_type = 1
			else
				if(!muzzled)
					message = "свист[pluralize_ru(src.gender,"ит","ят")]."
					playsound(src, 'sound/voice/whistle.ogg', 70)
					m_type = 2
				else
					message = "изда[pluralize_ru(src.gender,"ёт","ют")] шум."
					m_type = 2

		if("snap", "snaps")
			if(prob(95))
				m_type = 2
				var/mob/living/carbon/human/H = src
				var/obj/item/organ/external/L = H.get_organ("l_hand")
				var/obj/item/organ/external/R = H.get_organ("r_hand")
				var/left_hand_good = 0
				var/right_hand_good = 0
				if(L && (!(L.status & ORGAN_SPLINTED)) && (!(L.status & ORGAN_BROKEN)))
					left_hand_good = 1
				if(R && (!(R.status & ORGAN_SPLINTED)) && (!(R.status & ORGAN_BROKEN)))
					right_hand_good = 1

				if(!left_hand_good && !right_hand_good)
					to_chat(usr, "Тебе нужна хотя бы одна рука в хорошем рабочем состоянии, чтобы щелкнуть пальцами.")
					return

				var/M = handle_emote_param(param)

				message = "щелка[pluralize_ru(src.gender,"ет","ют")] пальцами[M ? " в сторону [M]" : ""]."
				playsound(loc, 'sound/effects/fingersnap.ogg', 50, 1, -3)
			else
				message = "<span class='danger'>лома[pluralize_ru(src.gender,"ет","ют")] себе палец!</span>"
				playsound(loc, 'sound/effects/snap.ogg', 50, 1)

		if("fart", "farts")
			var/farted_on_thing = FALSE
			for(var/atom/A in get_turf(src))
				farted_on_thing += A.fart_act(src)
			if(!farted_on_thing)
				message = "[pick("пуска[pluralize_ru(src.gender,"ет","ют")] газы", "перд[pluralize_ru(src.gender,"ит","ят")]")]."
			m_type = 2

		if("hem")
			message = "хмыка[pluralize_ru(src.gender,"ет","ют")]."

		if("highfive")
			if(restrained())
				return
			if(has_status_effect(STATUS_EFFECT_HIGHFIVE))
				to_chat(src, "Вы убираете руку.")
				remove_status_effect(STATUS_EFFECT_HIGHFIVE)
				return
			visible_message("<b>[name]</b> прос[pluralize_ru(src.gender,"ит","ят")] пятюню.", "Вы просите пятюню.")
			apply_status_effect(STATUS_EFFECT_HIGHFIVE)
			for(var/mob/living/L in orange(1))
				if(L.has_status_effect(STATUS_EFFECT_HIGHFIVE))
					if((mind && mind.special_role == SPECIAL_ROLE_WIZARD) && (L.mind && L.mind.special_role == SPECIAL_ROLE_WIZARD))
						visible_message("<span class='danger'><b>[name]</b> и <b>[L.name]</b> дают ЛЕГЕНДАРНУЮ пятюню!</span>")
						status_flags |= GODMODE
						L.status_flags |= GODMODE
						explosion(loc,1,3,9,12, cause = "Wizard highfive")
						status_flags &= ~GODMODE
						L.status_flags &= ~GODMODE
						return
					else if((mind && (mind.special_role == SPECIAL_ROLE_WIZARD || mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)) && (L.mind && (L.mind.special_role == SPECIAL_ROLE_WIZARD ||  L.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)))
						visible_message("<span class='danger'><b>[name]</b> и <b>[L.name]</b> дают ЭПИЧЕСКУЮ пятюню!</span>")
						if (mind.special_role == SPECIAL_ROLE_WIZARD)
							status_flags |= GODMODE
						if (L.mind.special_role == SPECIAL_ROLE_WIZARD)
							L.status_flags |= GODMODE
						explosion(loc,0,0,3,9)
						if (mind.special_role == SPECIAL_ROLE_WIZARD)
							status_flags &= ~GODMODE
						if (L.mind.special_role == SPECIAL_ROLE_WIZARD)
							L.status_flags &= ~GODMODE
						return
					visible_message("<b>[name]</b> и <b>[L.name]</b> дают пятюню!")
					playsound('sound/effects/snap.ogg', 50)
					remove_status_effect(STATUS_EFFECT_HIGHFIVE)
					L.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
					return

		if("help")
			var/emotelist = "airguitar, blink(s), blink(s)_r, blush(es), bow(s)-none/mob, burp(s), choke(s), chuckle(s), clap(s), collapse(s), cough(s), cry, cries, custom, dance, dap(s)-none/mob," \
			+ " deathgasp(s), drool(s), eyebrow, fart(s), faint(s), flip(s), frown(s), gasp(s), giggle(s), glare(s)-none/mob, grin(s), groan(s), grumble(s), grin(s)," \
			+ " handshake-mob, hug(s)-none/mob, hem, highfive, johnny, jump, laugh(s), look(s)-none/mob, moan(s), mumble(s), nod(s), pale(s), point(s)-atom, quiver(s), raise(s), salute(s)-none/mob, scream(s), shake(s)," \
			+ " shiver(s), shrug(s), sigh(s), signal(s)-#1-10,slap(s)-none/mob, smile(s),snap(s), sneeze(s), sniff(s), snore(s), stare(s)-none/mob, tremble(s), twitch(es), twitch(es)_s," \
			+ " wave(s), whimper(s), wink(s), yawn(s)"

			switch(dna.species.name) //dear future coders, do not use strings like this
				if("Diona")
					emotelist += "\n<u>Специфические эмоуты рассы Diona</u> :- creak(s)"
				if("Drask")
					emotelist += "\n<u>Специфические эмоуты расы Drask</u> :- drone(s)-none/mob, hum(s)-none/mob, rumble(s)-none/mob"
				if("Kidan")
					emotelist += "\n<u>Специфические эмоуты расы Kidan</u> :- click(s), clack(s)"
				if("Skrell")
					emotelist += "\n<u>Специфические эмоуты расы Skrell</u> :- warble(s)"
				if("Tajaran")
					emotelist += "\n<u>Специфические эмоуты расы Tajaran</u> :- wag(s), swag(s), hisses"
				if("Unathi")
					emotelist += "\n<u>Специфические эмоуты расы Unathi</u> :- wag(s), swag(s), hiss, roar, threat, whip, whips"
				if("Vox")
					emotelist += "\n<u>Специфические эмоуты расы Vox</u> :- wag(s), swag(s), quill(s)"
				if("Vulpkanin")
					emotelist += "\n<u>Специфические эмоуты расы Vulpkanin</u> :- wag(s), swag(s), growl(s)-none/mob, howl(s)-none/mob"
				if("Nian")
					emotelist += "\n<u>Специфические эмоуты расы Nian</u> :- aflap(s), flap(s), flutter(s)"

			if(ismachineperson(src))
				emotelist += "\n<u>Специфические эмоуты машин</u> :- beep(s)-none/mob, buzz(es)-none/mob, no-none/mob, ping(s)-none/mob, yes-none/mob, buzz2-none/mob"
			else
				var/obj/item/organ/external/head/H = get_organ("head") // If you have a robotic head, you can make beep-boop noises
				if(H && H.is_robotic())
					emotelist += "\n<u>Специфические эмоуты электронной головы</u> :- beep(s)-none/mob, buzz(es)-none/mob, no-none/mob, ping(s)-none/mob, yes-none/mob, buzz2-none/mob"

			if(isslimeperson(src))
				emotelist += "\n<u>Специфические эмоуты расы Слаймов</u> :- squish(es)-none/mob"
			else
				for(var/obj/item/organ/external/L in bodyparts) // if your limbs are squishy you can squish too!
					if(istype(L.dna.species, /datum/species/slime))
						emotelist += "\n<u>Специфические эмоуты Cлаймовых конечностей</u> :- squish(es)-none/mob"
						break

			to_chat(src, emotelist)
		else
			to_chat(src, "<span class='notice'>Неизвестный эмоут '[act]'. Введи *help для отображения списка.</span>")

	last_emote = act

	..()

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Устанавливает короткое описание отображаемое при омотре вас."
	set category = "IC"

	pose = sanitize(copytext_char(input(usr, "Это [src]. [p_they(TRUE)] [p_are()]...", "Pose", null)  as text, 1, MAX_MESSAGE_LEN))

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Устанавливает подробное описание внешности вашего персонажа."
	set category = "IC"

	update_flavor_text()
