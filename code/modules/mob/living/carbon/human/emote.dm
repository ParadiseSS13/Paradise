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
		if("growl", "growls", "howl", "howls", "hiss", "hisses", "scream", "screams", "sneeze", "sneezes")
			if(getOxyLoss() > 35)		//no screaming if you don't have enough breath to scream
				on_CD = handle_emote_CD()
				emote("gasp")
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

		if("hiss", "hisses")
			if(isunathi(src)) //Only Unathi can hiss.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("quill", "quills")
			if(isvox(src)) //Only Vox can rustle their quills.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("warble", "warbles")
			if(isskrell(src)) //Only Skrell can warble.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("choke", "chokes","giggle", "giggles","cry", "cries","sigh", "sighs","laugh", "laughs","moan", "moans","snore", "snores","wink", "winks","whistle", "whistles", "yawn", "yawns")
			on_CD = handle_emote_CD(50) //longer cooldown
		if("scream", "screams")
			on_CD = handle_emote_CD(50) //longer cooldown
		if("fart", "farts", "flip", "flips", "snap", "snaps")
			on_CD = handle_emote_CD()				//proc located in code\modules\mob\emote.dm
		if("cough", "coughs", "slap", "slaps", "highfive")
			on_CD = handle_emote_CD()
		if("gasp", "gasps")
			on_CD = handle_emote_CD()
		if("deathgasp", "deathgasps")
			on_CD = handle_emote_CD(50)
		if("sneeze", "sneezes")
			on_CD = handle_emote_CD()
		if("clap", "claps")
			on_CD = handle_emote_CD()
		//Everything else, including typos of the above emotes
		else
			on_CD = FALSE	//If it doesn't induce the cooldown, we won't check for the cooldown

	if(!force && on_CD == 1)		// Check if we need to suppress the emote attempt.
		return			// Suppress emote, you're still cooling off.

	switch(act)		//This is for actually making the emotes happen
		if("me")									//OKAY SO RANT TIME, THIS FUCKING HAS TO BE HERE OR A SHITLOAD OF THINGS BREAK
			return custom_emote(m_type, message)	//DO YOU KNOW WHY SHIT BREAKS? BECAUSE SO MUCH OLDCODE CALLS mob.emote("me",1,"whatever_the_fuck_it_wants_to_emote")
													//WHO THE FUCK THOUGHT THAT WAS A GOOD FUCKING IDEA!?!?

		if("howl", "howls")
			var/M = handle_emote_param(param)
			if(miming)
				message = "делает вид что воет[M ? " на [M]" : ""]!"
				m_type = 1
			else
				if(!muzzled)
					message = "воет[M ? " на [M]" : ""]!"
					playsound(loc, 'sound/goonstation/voice/howl.ogg', 100, 1, 10, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает очень громкий шум[M ? " на [M]" : ""]."
					playsound(loc, 'sound/goonstation/voice/howl.ogg', 25, 1, 10, frequency = get_age_pitch())
					m_type = 2

		if("growl", "growls")
			var/M = handle_emote_param(param)
			message = "рычит[M ? " на [M]" : ""]."
			playsound(loc, "growls", !muzzled ? 80:25, 1, frequency = get_age_pitch())
			m_type = 2

		if("purr", "purrs")
			message = "мурчит."
			playsound(src, 'sound/voice/cat_purr.ogg', 80, 1, frequency = get_age_pitch())
			m_type = 2

		if("purrl")
			message = "мурчит."
			playsound(src, 'sound/voice/cat_purr_long.ogg', 80, 1, frequency = get_age_pitch())
			m_type = 2

		if("ping", "pings")
			var/M = handle_emote_param(param)

			message = "звенит[M ? " на [M]" : ""]."
			playsound(loc, 'sound/machines/ping.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("buzz2")
			var/M = handle_emote_param(param)

			message = "издает раздраженный жужжащий звук[M ? " на [M]" : ""]."
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("buzz", "buzzes")
			var/M = handle_emote_param(param)

			message = "жужжит[M ? " на [M]" : ""]."
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("beep", "beeps")
			var/M = handle_emote_param(param)

			message = "пищит[M ? " на [M]" : ""]."
			playsound(loc, 'sound/machines/twobeep.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("drone", "drones", "hum", "hums", "rumble", "rumbles")
			var/M = handle_emote_param(param)

			message = "[M ? "грохочет на [M]" : "грохочет"]."
			playsound(loc, 'sound/voice/drasktalk.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("squish", "squishes")
			var/M = handle_emote_param(param)

			message = "хлюпает[M ? " на [M]" : ""]."
			playsound(loc, 'sound/effects/slime_squish.ogg', 50, 1, frequency = get_age_pitch()) //Credit to DrMinky (freesound.org) for the sound.
			m_type = 2

		if("clack", "clacks")
			var/obj/item/organ/external/head = src.get_organ("head")
			var/M = handle_emote_param(param)
			mineral_scan_pulse(get_turf(src), range = world.view)
			m_type = 2
			if(head)
				message = "трещит своей нижней челюстью[M ? " на [M]" : ""]."
				playsound(loc, 'sound/effects/Kidanclack.ogg', 50, 1, frequency = get_age_pitch()) //Credit to DrMinky (freesound.org) for the sound.
			else
				message = "отчаянно дёргается."

		if("click", "clicks")
			var/obj/item/organ/external/head = src.get_organ("head")
			var/M = handle_emote_param(param)
			mineral_scan_pulse(get_turf(src), range = world.view)
			if(head)
				message = "щелкает своей нижней челюстью[M ? " на [M]" : ""]."
				playsound(loc, 'sound/effects/Kidanclack2.ogg', 50, 1, frequency = get_age_pitch()) //Credit to DrMinky (freesound.org) for the sound.
				m_type = 2
			else
				message = "отчаянно дёргается."
				m_type = 2

		if("creaks", "creak")
			var/M = handle_emote_param(param)

			message = "скрипит[M ? " на [M]" : ""]."
			playsound(loc, 'sound/voice/dionatalk1.ogg', 50, 1, frequency = get_age_pitch()) //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
			m_type = 2

		if("hiss", "hisses")
			var/M = handle_emote_param(param)

			if(!muzzled)
				message = "шипит[M ? " на [M]" : ""]."
				playsound(loc, 'sound/effects/unathihiss.ogg', 50, 1, frequency = get_age_pitch()) //Credit to Jamius (freesound.org) for the sound.
				m_type = 2
			else
				message = "тихо шипит."
				m_type = 2

		if("quill", "quills")
			var/M = handle_emote_param(param)

			message = "шуршит своими перьями[M ? " на [M]" : ""]."
			playsound(loc, 'sound/effects/voxrustle.ogg', 50, 1, frequency = get_age_pitch()) //Credit to sound-ideas (freesfx.co.uk) for the sound.
			m_type = 2

		if("warble", "warbles")
			var/M = handle_emote_param(param)

			message = "издает трель[M ? " на [M]" : ""]."
			playsound(loc, 'sound/effects/warble.ogg', 50, 1, frequency = get_age_pitch()) // Copyright CC BY 3.0 alienistcog (freesound.org) for the sound.
			m_type = 2

		if("yes")
			var/M = handle_emote_param(param)

			message = "испускает утвердительный сигнал[M ? " для [M]" : ""]."
			playsound(loc, 'sound/machines/synth_yes.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("no")
			var/M = handle_emote_param(param)

			message = "испускает отрицательный сигнал[M ? " для [M]" : ""]."
			playsound(loc, 'sound/machines/synth_no.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("wag", "wags")
			if(body_accessory)
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
			if(dna.species.bodyflags & TAIL_WAGGING || body_accessory)
				message = "прекращает махать хвостом."
				stop_tail_wagging()
			else
				return
			m_type = 1

		if("scratch")
			if(!restrained())
				message = "чешется."
				m_type = 1

		if("airguitar")
			if(!restrained())
				message = "делает невероятный запил на воображаемой гитаре!"
				m_type = 1

		if("dance")
			if(!restrained())
				message = "радостно танцует!"
				m_type = 1

		if("jump")
			if(!restrained())
				message = "прыгает!"
				m_type = 1

		if("blink", "blinks")
			message = "моргает."
			m_type = 1

		if("blink_r", "blinks_r")
			message = "быстро моргает."
			m_type = 1

		if("bow", "bows")
			if(!restrained())
				var/M = handle_emote_param(param)

				message = "делает поклон[M ? " [M]" : ""]."
			m_type = 1

		if("salute", "salutes")
			if(!restrained())
				var/M = handle_emote_param(param)

				message = "салютует[M ? " [M]" : ""]!"
				playsound(loc, 'sound/effects/salute.ogg', 50, 0)
			m_type = 1

		if("choke", "chokes")
			if(miming)
				message = "отчаяно хватается за свое горло!"
				m_type = 1
			else
				if(!muzzled)
					message = "подавился!"
					if(gender == FEMALE)
						playsound(src, pick('sound/voice/gasp_female1.ogg','sound/voice/gasp_female2.ogg','sound/voice/gasp_female3.ogg','sound/voice/gasp_female4.ogg','sound/voice/gasp_female5.ogg','sound/voice/gasp_female6.ogg','sound/voice/gasp_female7.ogg'), 50, 1, frequency = get_age_pitch())
					else
						playsound(src, pick('sound/voice/gasp_male1.ogg','sound/voice/gasp_male2.ogg','sound/voice/gasp_male3.ogg','sound/voice/gasp_male4.ogg','sound/voice/gasp_male5.ogg','sound/voice/gasp_male6.ogg','sound/voice/gasp_male7.ogg'), 50, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает сильный шум."
					m_type = 2

		if("burp", "burps")
			if(miming)
				message = "мерзко разевает рот."
				m_type = 1
			else
				if(!muzzled)
					message = "рыгает."
					m_type = 2
				else
					message = "издает своеобразный шум."
					m_type = 2
		if("clap", "claps")
			if(miming)
				message = "бесшумно хлопает."
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
					message = "хлопает."
					var/clap = pick('sound/misc/clap1.ogg', 'sound/misc/clap2.ogg', 'sound/misc/clap3.ogg', 'sound/misc/clap4.ogg')
					playsound(loc, clap, 50, 1, -1)

				else
					to_chat(usr, "Тебе нужно две рабочих руки чтобы хлопать.")

		if("flap", "flaps")
			if(!restrained())
				message = "машет крыльями."
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
						message = "упал на пол и кружится."
					else
						message = "кувыркается в направлении [M]."
						SpinAnimation(5,1)
				else
					if(lying || IsWeakened())
						message = "кружится лежа."
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
								message = "делает кувырок через [G.affecting]!"
						else

							if(iskidan(src) && !src.get_organ("head"))
								message = "пытается кувыркнуться и с грохотом падает на пол!"
								SpinAnimation(5,1)
								sleep(3)
								Weaken(2)
							else
								if(prob(5))
									message = "пытается кувыркнуться и с грохотом падает на пол!"
									SpinAnimation(5,1)
									sleep(3)
									Weaken(2)
								else
									message = "делает кувырок!"
									SpinAnimation(5,1)

		if("aflap", "aflaps")
			if(!restrained())
				message = "агрессивно машет крыльями!"
				m_type = 2
				if(miming)
					m_type = 1

		if("drool", "drools")
			message = "неразборчиво бурчит."
			m_type = 1

		if("eyebrow")
			message = "приподнимает бровь."
			m_type = 1

		if("chuckle", "chuckles")
			if(miming)
				message = "кажется усмехается."
				m_type = 1
			else
				if(!muzzled)
					message = "усмехается."
					m_type = 2
				else
					message = "издает шум."
					m_type = 2

		if("twitch", "twitches")
			message = "сильно дергается!"
			m_type = 1

		if("twitch_s", "twitches_s")
			message = "дергается."
			m_type = 1

		if("faint", "faints")
			message = "падает в обморок!"
			if(sleeping)
				return //Can't faint while asleep
			AdjustSleeping(2)
			m_type = 1

		if("cough", "coughs")
			if(miming)
				message = "кажется кашляет!"
				m_type = 1
			else
				if(!muzzled)
					message = "кашляет!"
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

			message = "хмурится[M ? " на [M]" : ""]."
			m_type = 1

		if("nod", "nods")
			var/M = handle_emote_param(param)

			message = "кивает[M ? " на [M]" : ""]."
			m_type = 1

		if("blush", "blushes")
			message = "краснеет..."
			m_type = 1

		if("wave", "waves")
			var/M = handle_emote_param(param)

			message = "машет[M ? " [M]" : ""]."
			m_type = 1

		if("quiver", "quivers")
			message = "трепещет."
			m_type = 1

		if("gasp", "gasps")
			if(miming)
				message = "кажется задыхается!"
				m_type = 1
			else
				if(!muzzled)
					message = "задыхается!"
					if(health <= 0)
						if(gender == FEMALE)
							playsound(loc, pick(dna.species.female_dying_gasp_sounds), 100, 1, frequency = get_age_pitch())
						else
							playsound(loc, pick(dna.species.male_dying_gasp_sounds), 100, 1, frequency = get_age_pitch())

					else
						playsound(loc, dna.species.gasp_sound, 50, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает слабый шум."
					m_type = 2

		if("deathgasp", "deathgasps")
			message = "[dna.species.death_message]"
			playsound(loc, pick(dna.species.death_sounds), 50, 1, frequency = get_age_pitch())
			m_type = 1

		if("giggle", "giggles")
			if(miming)
				message = "бесшумно хихикает!"
				m_type = 1
			else
				if(!muzzled)
					message = "хихикает."
					if(gender == FEMALE)
						playsound(src, pick('sound/voice/giggle_female_1.ogg','sound/voice/giggle_female_2.ogg','sound/voice/giggle_female_3.ogg'), 70, 1, frequency = get_age_pitch())
					else
						playsound(src, pick('sound/voice/giggle_male_1.ogg','sound/voice/giggle_male_2.ogg'), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает шум."
					m_type = 2

		if("glare", "glares")
			var/M = handle_emote_param(param)

			message = "недовольно смотрит[M ? " на [M]" : ""]."
			m_type = 1

		if("stare", "stares")
			var/M = handle_emote_param(param)

			message = "пялится[M ? " на [M]" : ""]."
			m_type = 1

		if("look", "looks")
			var/M = handle_emote_param(param)

			message = "смотрит[M ? " на [M]" : ""]."
			m_type = 1

		if("grin", "grins")
			var/M = handle_emote_param(param)

			message = "скалится в улыбке[M ? " на [M]" : ""]."
			m_type = 1

		if("cry", "cries")
			if(miming)
				message = "плачет."
				m_type = 1
			else
				if(!muzzled)
					message = "плачет."
					if(gender == FEMALE)
						playsound(src, pick('sound/voice/cry_female_1.ogg','sound/voice/cry_female_2.ogg','sound/voice/cry_female_3.ogg'), 70, 1, frequency = get_age_pitch())
					else
						playsound(src, pick('sound/voice/cry_male_1.ogg','sound/voice/cry_male_2.ogg'), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает слабый шум и хмурится."
					m_type = 2

		if("sigh", "sighs")
			if(miming)
				message = "вздыхает."
				m_type = 1
			else
				if(!muzzled)
					message = "вздыхает."
					if(gender == FEMALE)
						playsound(src, 'sound/voice/sigh_female.ogg', 70, 1, frequency = get_age_pitch())
					else
						playsound(src, 'sound/voice/sigh_male.ogg', 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает слабый шум."
					m_type = 2

		if("hsigh", "hsighs")
			if(!muzzled)
				message = "удовлетворенно вздыхает."
				m_type = 2
			else
				message = "издает [pick("спокойный", "расслабленный")] шум."
				m_type = 2

		if("laugh", "laughs")
			var/M = handle_emote_param(param)
			if(miming)
				message = "бесшумно смеется[M ? " над [M]" : ""]."
				m_type = 1
			else
				if(!muzzled)
					message = "смеется[M ? " над [M]" : ""]."
					if(gender == FEMALE)
						playsound(src, pick('sound/voice/laugh_female_1.ogg','sound/voice/laugh_female_2.ogg','sound/voice/laugh_female_3.ogg'), 70, 1, frequency = get_age_pitch())
					else
						playsound(src, pick('sound/voice/laugh_male_1.ogg','sound/voice/laugh_male_2.ogg','sound/voice/laugh_male_3.ogg'), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает шум."
					m_type = 2

		if("mumble", "mumbles")
			message = "бормочет!"
			m_type = 2
			if(miming)
				m_type = 1

		if("grumble", "grumbles")
			var/M = handle_emote_param(param)
			if(miming)
				message = "бесшумно ворчит[M ? " на [M]" : ""]!"
				m_type = 1
			if(!muzzled)
				message = "ворчит[M ? " на [M]" : ""]!"
				m_type = 2
			else
				message = "издает шум."
				m_type = 2

		if("groan", "groans")
			if(miming)
				message = "кажется болезненно вздыхает!"
				m_type = 1
			else
				if(!muzzled)
					message = "болезненно вздыхает!"
					m_type = 2
				else
					message = "издает громкий звук."
					m_type = 2

		if("moan", "moans")
			if(miming)
				message = "кажется стонет!"
				if(gender == FEMALE)
					playsound(src, pick('sound/voice/moan_female_1.ogg','sound/voice/moan_female_2.ogg','sound/voice/moan_female_3.ogg'), 70, 1, frequency = get_age_pitch())
				else
					playsound(src, pick('sound/voice/moan_male_1.ogg','sound/voice/moan_male_2.ogg','sound/voice/moan_male_3.ogg'), 70, 1, frequency = get_age_pitch())
				m_type = 1
			else
				message = "стонет!"
				m_type = 2

		if("johnny")
			var/M
			if(param)
				M = param
			if(!M)
				param = null
			else
				if(miming)
					message = "takes a drag from a cigarette and blows \"[M]\" out in smoke."
					m_type = 1
				else
					message = "says, \"[M], please. They had a family.\" [name] takes a drag from a cigarette and blows [p_their()] name out in smoke."
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
					message = "показывает пальцем."
				else
					pointed(M)
			m_type = 1

		if("raise", "raises")
			if(!restrained())
				message = "поднимает руку."
			m_type = 1

		if("shake", "shakes")
			var/M = handle_emote_param(param, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves.

			message = "трясет головой[M ? " на [M]" : ""]."
			m_type = 1

		if("shrug", "shrugs")
			message = "пожимает плечами."
			m_type = 1

		if("signal", "signals")
			if(!restrained())
				var/t1 = round(text2num(param))
				if(isnum(t1))
					if(t1 < 5 && t1 > 1 && (!r_hand || !l_hand))
						message = "показывает [t1] пальца."
					else if(t1 == 1 && (!r_hand || !l_hand))
						message = "показывает 1 палец."
					else if(t1 == 5 && (!r_hand || !l_hand))
						message = "показывает 5 пальцев."
					else if(t1 <= 10 && t1 >= 1 && (!r_hand && !l_hand))
						message = "показывает [t1] пальцев."
			m_type = 1

		if("smile", "smiles")
			var/M = handle_emote_param(param, 1)

			message = "улыбается[M ? " [M]" : ""]."
			m_type = 1

		if("shiver", "shivers")
			message = "дрожит."
			m_type = 2
			if(miming)
				m_type = 1

		if("pale", "pales")
			message = "на секунду бледнеет...."
			m_type = 1

		if("tremble", "trembles")
			message = "дрожит в ужасе!"
			m_type = 1

		if("shudder", "shudders")
			message = "содрогается."
			m_type = 1

		if("bshake", "bshakes")
			message = "трясется."
			m_type = 1

		if("sneeze", "sneezes")
			if(miming)
				message = "чихает."
				m_type = 1
			else
				if(!muzzled)
					message = "чихает."
					if(gender == FEMALE)
						playsound(src, dna.species.female_sneeze_sound, 70, 1, frequency = get_age_pitch())
					else
						playsound(src, dna.species.male_sneeze_sound, 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает странный шум."
					m_type = 2

		if("sniff", "sniffs")
			var/M = handle_emote_param(param, 1)

			message = "нюхает[M ? " [M]" : ""]."
			m_type = 2
			if(miming)
				m_type = 1

		if("snore", "snores")
			if(miming)
				message = "крепко спит."
				m_type = 1
			else
				if(!muzzled)
					message = "храпит."
					playsound(src, pick('sound/voice/snore_1.ogg', 'sound/voice/snore_2.ogg','sound/voice/snore_3.ogg', 'sound/voice/snore_4.ogg','sound/voice/snore_5.ogg', 'sound/voice/snore_6.ogg','sound/voice/snore_7.ogg'), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает шум."
					m_type = 2

		if("whimper", "whimpers")
			if(miming)
				message = "кажется ранен."
				m_type = 1
			else
				if(!muzzled)
					message = "хнычет."
					m_type = 2
				else
					message = "издает слабый шум."
					m_type = 2

		if("wink", "winks")
			var/M = handle_emote_param(param, 1)

			message = "подмигивает[M ? " [M]" : ""]."
			m_type = 1

		if("yawn", "yawns")
			if(miming)
				message = "делает вид что зевает."
			else
				if(!muzzled)
					message = "зевает."
					if(gender == FEMALE)
						playsound(src, pick('sound/voice/yawn_female_1.ogg', 'sound/voice/yawn_female_2.ogg','sound/voice/yawn_female_3.ogg'), 70, 1, frequency = get_age_pitch())
					else
						playsound(src, pick('sound/voice/yawn_male_1.ogg', 'sound/voice/yawn_male_2.ogg'), 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "издает шум."
					m_type = 2

		if("collapse", "collapses")
			Paralyse(2)
			message = "падает!"
			m_type = 2
			if(miming)
				m_type = 1

		if("hug", "hugs")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, 1, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves and only check mobs in our immediate vicinity (1 tile distance).

				if(M)
					message = "обнимает [M]."
				else
					message = "обнимает сам себя."

		if("handshake")
			m_type = 1
			if(!restrained() && !r_hand)
				var/mob/M = handle_emote_param(param, 1, 1, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves, only check mobs in our immediate vicinity (1 tile distance) and return the whole mob instead of just its name.

				if(M)
					if(M.canmove && !M.r_hand && !M.restrained())
						message = "пожимает руку [M]."
					else
						message = "протягивает руку [M]."

		if("dap", "daps")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, null, 1)

				if(M)
					message = "gives daps to [M]."
				else
					message = "sadly can't find anybody to give daps to, and daps [p_them()]self. Shameful."

		if("slap", "slaps")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, null, 1)

				if(M)
					for(var/mob/living/carbon/human/A in view(1, null))
						if(lowertext(M) == lowertext(A.name))
							message = "<span class='danger'>шлепает [M]. Оу!</span>"
							playsound(loc, 'sound/effects/snap.ogg', 50, 1)
							var/obj/item/organ/external/O = A.get_organ(src.zone_selected)
							if(O.brute_dam < 5)
								O.receive_damage(1)
				else
					message = "<span class='danger'>шлепает себя!</span>"
					playsound(loc, 'sound/effects/snap.ogg', 50, 1)
					var/obj/item/organ/external/O = src.get_organ(src.zone_selected)
					if(O.brute_dam < 5)
						O.receive_damage(1)

		if("scream", "screams")
			var/M = handle_emote_param(param)
			if(miming)
				message = "делает вид что кричит[M ? " на [M]" : ""]!"
				m_type = 1
			else
				if(!muzzled)
					message = "[dna.species.scream_verb][M ? " на [M]" : ""]!"
					m_type = 2
					if(gender == FEMALE)
						playsound(loc, dna.species.female_scream_sound, 80, 1, frequency = get_age_pitch())
					else
						playsound(loc, dna.species.male_scream_sound, 80, 1, frequency = get_age_pitch()) //default to male screams if no gender is present.

				else
					message = "издает очень громкий шум[M ? " в сторону [M]" : ""]."
					m_type = 2

		if("whistle", "whistles")
			if(miming)
				message = "бесшумно свистит."
				m_type = 1
			else
				if(!muzzled)
					message = "свистит."
					playsound(src, 'sound/voice/whistle.ogg', 70)
					m_type = 2
				else
					message = "издает шум."
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

				message = "щелкает пальцами[M ? " в сторону [M]" : ""]."
				playsound(loc, 'sound/effects/fingersnap.ogg', 50, 1, -3)
			else
				message = "<span class='danger'>ломает себе палец!</span>"
				playsound(loc, 'sound/effects/snap.ogg', 50, 1)

		if("fart", "farts")
			var/farted_on_thing = FALSE
			for(var/atom/A in get_turf(src))
				farted_on_thing += A.fart_act(src)
			if(!farted_on_thing)
				message = "[pick("пускает газы", "пердит")]."
			m_type = 2

		if("hem")
			message = "хмыкает."

		if("highfive")
			if(restrained())
				return
			if(has_status_effect(STATUS_EFFECT_HIGHFIVE))
				to_chat(src, "Вы убираете руку.")
				remove_status_effect(STATUS_EFFECT_HIGHFIVE)
				return
			visible_message("<b>[name]</b> просит пятюню.", "Вы просите пятюню.")
			apply_status_effect(STATUS_EFFECT_HIGHFIVE)
			for(var/mob/living/L in orange(1))
				if(L.has_status_effect(STATUS_EFFECT_HIGHFIVE))
					if((mind && mind.special_role == SPECIAL_ROLE_WIZARD) && (L.mind && L.mind.special_role == SPECIAL_ROLE_WIZARD))
						visible_message("<span class='danger'><b>[name]</b> и <b>[L.name]</b> дают ЭПИЧЕСКУЮ пятюню!</span>")
						status_flags |= GODMODE
						L.status_flags |= GODMODE
						explosion(loc,5,2,1,3)
						status_flags &= ~GODMODE
						L.status_flags &= ~GODMODE
						return
					visible_message("<b>[name]</b> и <b>[L.name]</b> дают пятюню!")
					playsound('sound/effects/snap.ogg', 50)
					remove_status_effect(STATUS_EFFECT_HIGHFIVE)
					L.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
					return

		if("help")
			var/emotelist = "aflap(s), airguitar, blink(s), blink(s)_r, blush(es), bow(s)-none/mob, burp(s), choke(s), chuckle(s), clap(s), collapse(s), cough(s), cry, cries, custom, dance, dap(s)-none/mob," \
			+ " deathgasp(s), drool(s), eyebrow, fart(s), faint(s), flap(s), flip(s), frown(s), gasp(s), giggle(s), glare(s)-none/mob, grin(s), groan(s), grumble(s), grin(s)," \
			+ " handshake-mob, hug(s)-none/mob, hem, highfive, johnny, jump, laugh(s), look(s)-none/mob, moan(s), mumble(s), nod(s), pale(s), point(s)-atom, quiver(s), raise(s), salute(s)-none/mob, scream(s), shake(s)," \
			+ " shiver(s), shrug(s), sigh(s), signal(s)-#1-10,slap(s)-none/mob, smile(s),snap(s), sneeze(s), sniff(s), snore(s), stare(s)-none/mob, tremble(s), twitch(es), twitch(es)_s," \
			+ " wave(s), whimper(s), wink(s), yawn(s)"

			switch(dna.species.name)
				if("Diona")
					emotelist += "\n<u>Специфические эмоуты рассы Diona</u> :- creak(s)"
				if("Drask")
					emotelist += "\n<u>Специфические эмоуты расы Drask</u> :- drone(s)-none/mob, hum(s)-none/mob, rumble(s)-none/mob"
				if("Kidan")
					emotelist += "\n<u>Специфические эмоуты расы Kidan</u> :- click(s), clack(s)"
				if("Skrell")
					emotelist += "\n<u>Специфические эмоуты расы Skrell</u> :- warble(s)"
				if("Tajaran")
					emotelist += "\n<u>Специфические эмоуты расы Tajaran</u> :- wag(s), swag(s)"
				if("Unathi")
					emotelist += "\n<u>Специфические эмоуты расы Unathi</u> :- wag(s), swag(s), hiss(es)"
				if("Vox")
					emotelist += "\n<u>Специфические эмоуты расы Vox</u> :- wag(s), swag(s), quill(s)"
				if("Vulpkanin")
					emotelist += "\n<u>Специфические эмоуты расы Vulpkanin</u> :- wag(s), swag(s), growl(s)-none/mob, howl(s)-none/mob"

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
