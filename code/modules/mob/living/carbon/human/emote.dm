/mob/living/carbon/human/emote(act, m_type = 1, message = null, force)

	if((stat == DEAD) || (status_flags & FAKEDEATH))
		return // No screaming bodies

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
	switch(act)
		//Cooldown-inducing emotes
		if("ping", "pings", "buzz", "buzzes", "beep", "beeps", "yes", "no", "buzz2")
			var/found_machine_head = FALSE
			if(ismachine(src))		//Only Machines can beep, ping, and buzz, yes, no, and make a silly sad trombone noise.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
				found_machine_head = TRUE
			else
				var/obj/item/organ/external/head/H = get_organ("head") // If you have a robotic head, you can make beep-boop noises
				if(H && H.is_robotic())
					on_CD = handle_emote_CD()
					found_machine_head = TRUE

			if(!found_machine_head)								//Everyone else fails, skip the emote attempt
				return								//Everyone else fails, skip the emote attempt
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
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("click", "clicks")
			if(iskidan(src))	//Only Kidan can click and rightfully so.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
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

	switch(act)
		if("me")									//OKAY SO RANT TIME, THIS FUCKING HAS TO BE HERE OR A SHITLOAD OF THINGS BREAK
			return custom_emote(m_type, message)	//DO YOU KNOW WHY SHIT BREAKS? BECAUSE SO MUCH OLDCODE CALLS mob.emote("me",1,"whatever_the_fuck_it_wants_to_emote")
													//WHO THE FUCK THOUGHT THAT WAS A GOOD FUCKING IDEA!?!?

		if("howl", "howls")
			var/M = handle_emote_param(param) //Check to see if the param is valid (mob with the param name is in view).
			message = "<B>[src]</B> howls[M ? " at [M]" : ""]!"
			playsound(loc, 'sound/goonstation/voice/howl.ogg', 100, 1, 10, frequency = get_age_pitch())
			m_type = 2

		if("growl", "growls")
			var/M = handle_emote_param(param)
			message = "<B>[src]</B> growls[M ? " at [M]" : ""]."
			playsound(loc, "growls", 80, 1, frequency = get_age_pitch())
			m_type = 2

		if("ping", "pings")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> pings[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/ping.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("buzz2")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> emits an irritated buzzing sound[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("buzz", "buzzes")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> buzzes[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("beep", "beeps")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> beeps[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/twobeep.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("drone", "drones", "hum", "hums", "rumble", "rumbles")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> [M ? "drones at [M]" : "rumbles"]."
			playsound(loc, 'sound/voice/drasktalk.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("squish", "squishes")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> squishes[M ? " at [M]" : ""]."
			playsound(loc, 'sound/effects/slime_squish.ogg', 50, 1, frequency = get_age_pitch()) //Credit to DrMinky (freesound.org) for the sound.
			m_type = 2

		if("clack", "clacks")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> clacks [p_their()] mandibles[M ? " at [M]" : ""]."
			playsound(loc, 'sound/effects/Kidanclack.ogg', 50, 1, frequency = get_age_pitch()) //Credit to DrMinky (freesound.org) for the sound.
			m_type = 2

		if("click", "clicks")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> clicks [p_their()] mandibles[M ? " at [M]" : ""]."
			playsound(loc, 'sound/effects/Kidanclack2.ogg', 50, 1, frequency = get_age_pitch()) //Credit to DrMinky (freesound.org) for the sound.
			m_type = 2

		if("creaks", "creak")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> creaks[M ? " at [M]" : ""]."
			playsound(loc, 'sound/voice/dionatalk1.ogg', 50, 1, frequency = get_age_pitch()) //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
			m_type = 2

		if("hiss", "hisses")
			var/M = handle_emote_param(param)

			if(!muzzled)
				message = "<B>[src]</B> hisses[M ? " at [M]" : ""]."
				playsound(loc, 'sound/effects/unathihiss.ogg', 50, 1, frequency = get_age_pitch()) //Credit to Jamius (freesound.org) for the sound.
				m_type = 2
			else
				message = "<B>[src]</B> makes a weak hissing noise."
				m_type = 2

		if("quill", "quills")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> rustles [p_their()] quills[M ? " at [M]" : ""]."
			playsound(loc, 'sound/effects/voxrustle.ogg', 50, 1, frequency = get_age_pitch()) //Credit to sound-ideas (freesfx.co.uk) for the sound.
			m_type = 2

		if("warble", "warbles")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> warbles[M ? " at [M]" : ""]."
			playsound(loc, 'sound/effects/warble.ogg', 50, 1, frequency = get_age_pitch()) // Copyright CC BY 3.0 alienistcog (freesound.org) for the sound.
			m_type = 2

		if("yes")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> emits an affirmative blip[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/synth_yes.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("no")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> emits a negative blip[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/synth_no.ogg', 50, 1, frequency = get_age_pitch())
			m_type = 2

		if("wag", "wags")
			if(body_accessory)
				if(body_accessory.try_restrictions(src))
					message = "<B>[src]</B> starts wagging [p_their()] tail."
					start_tail_wagging(1)

			else if(dna.species.bodyflags & TAIL_WAGGING)
				if(!wear_suit || !(wear_suit.flags_inv & HIDETAIL))
					message = "<B>[src]</B> starts wagging [p_their()] tail."
					start_tail_wagging(1)
				else
					return
			else
				return
			m_type = 1

		if("swag", "swags")
			if(dna.species.bodyflags & TAIL_WAGGING || body_accessory)
				message = "<B>[src]</B> stops wagging [p_their()] tail."
				stop_tail_wagging(1)
			else
				return
			m_type = 1

		if("airguitar")
			if(!restrained())
				message = "<B>[src]</B> is strumming the air and headbanging like a safari chimp."
				m_type = 1

		if("dance")
			if(!restrained())
				message = "<B>[src]</B> dances around happily."
				m_type = 1

		if("jump")
			if(!restrained())
				message = "<B>[src]</B> jumps!"
				m_type = 1

		if("blink", "blinks")
			message = "<B>[src]</B> blinks."
			m_type = 1

		if("blink_r", "blinks_r")
			message = "<B>[src]</B> blinks rapidly."
			m_type = 1

		if("bow", "bows")
			if(!buckled)
				var/M = handle_emote_param(param)

				message = "<B>[src]</B> bows[M ? " to [M]" : ""]."
			m_type = 1

		if("salute", "salutes")
			if(!buckled)
				var/M = handle_emote_param(param)

				message = "<B>[src]</B> salutes[M ? " to [M]" : ""]."
			m_type = 1

		if("choke", "chokes")
			if(miming)
				message = "<B>[src]</B> clutches [p_their()] throat desperately!"
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> chokes!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a strong noise."
					m_type = 2

		if("burp", "burps")
			if(miming)
				message = "<B>[src]</B> opens [p_their()] mouth rather obnoxiously."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> burps."
					m_type = 2
				else
					message = "<B>[src]</B> makes a peculiar noise."
					m_type = 2
		if("clap", "claps")
			if(miming)
				message = "<B>[src]</B> claps silently."
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
					message = "<b>[src]</b> claps."
					var/clap = pick('sound/misc/clap1.ogg', 'sound/misc/clap2.ogg', 'sound/misc/clap3.ogg', 'sound/misc/clap4.ogg')
					playsound(loc, clap, 50, 1, -1)

				else
					to_chat(usr, "You need your hands working in order to clap.")

		if("flap", "flaps")
			if(!restrained())
				message = "<B>[src]</B> flaps [p_their()] wings."
				m_type = 2
				if(miming)
					m_type = 1

		if("flip", "flips")
			m_type = 1
			if(!restrained())
				var/M = null
				if(param)
					for(var/mob/A in view(1, null))
						if(param == A.name)
							M = A
							break
				if(M == src)
					M = null

				if(M)
					if(lying)
						message = "<B>[src]</B> flops and flails around on the floor."
					else
						message = "<B>[src]</B> flips in [M]'s general direction."
						SpinAnimation(5,1)
				else
					if(lying || IsWeakened())
						message = "<B>[src]</B> flops and flails around on the floor."
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
								forceMove(newloc)
								G.affecting.forceMove(oldloc)
								message = "<B>[src]</B> flips over [G.affecting]!"
						else
							if(prob(5))
								message = "<B>[src]</B> attempts a flip and crashes to the floor!"
								SpinAnimation(5,1)
								sleep(3)
								Weaken(2)
							else
								message = "<B>[src]</B> does a flip!"
								SpinAnimation(5,1)

		if("aflap", "aflaps")
			if(!restrained())
				message = "<B>[src]</B> flaps [p_their()] wings ANGRILY!"
				m_type = 2
				if(miming)
					m_type = 1

		if("drool", "drools")
			message = "<B>[src]</B> drools."
			m_type = 1

		if("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = 1

		if("chuckle", "chuckles")
			if(miming)
				message = "<B>[src]</B> appears to chuckle."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> chuckles."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if("twitch", "twitches")
			message = "<B>[src]</B> twitches violently."
			m_type = 1

		if("twitch_s", "twitches_s")
			message = "<B>[src]</B> twitches."
			m_type = 1

		if("faint", "faints")
			message = "<B>[src]</B> faints."
			if(sleeping)
				return //Can't faint while asleep
			AdjustSleeping(2)
			m_type = 1

		if("cough", "coughs")
			if(miming)
				message = "<B>[src]</B> appears to cough!"
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> coughs!"
					m_type = 2
					if(gender == FEMALE)
						if(dna.species.female_cough_sounds)
							playsound(src, pick(dna.species.female_cough_sounds), 120, 1, frequency = get_age_pitch())
					else
						if(dna.species.male_cough_sounds)
							playsound(src, pick(dna.species.male_cough_sounds), 120, 1, frequency = get_age_pitch())
				else
					message = "<B>[src]</B> makes a strong noise."
					m_type = 2

		if("frown", "frowns")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> frowns[M ? " at [M]" : ""]."
			m_type = 1

		if("nod", "nods")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> nods[M ? " at [M]" : ""]."
			m_type = 1

		if("blush", "blushes")
			message = "<B>[src]</B> blushes."
			m_type = 1

		if("wave", "waves")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> waves[M ? " at [M]" : ""]."
			m_type = 1

		if("quiver", "quivers")
			message = "<B>[src]</B> quivers."
			m_type = 1

		if("gasp", "gasps")
			if(miming)
				message = "<B>[src]</B> appears to be gasping!"
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> gasps!"
					if(health <= 0)
						if(gender == FEMALE)
							playsound(loc, pick(dna.species.female_dying_gasp_sounds), 100, 1, frequency = get_age_pitch())
						else
							playsound(loc, pick(dna.species.male_dying_gasp_sounds), 100, 1, frequency = get_age_pitch())

					else
						playsound(loc, dna.species.gasp_sound, 15, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = 2

		if("deathgasp", "deathgasps")
			message = "<B>[src]</B> [replacetext(dna.species.death_message, "their", p_their())]"
			playsound(loc, pick(dna.species.death_sounds), 40, 1, frequency = get_age_pitch())
			m_type = 1

		if("giggle", "giggles")
			if(miming)
				message = "<B>[src]</B> giggles silently!"
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> giggles."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if("glare", "glares")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> glares[M ? " at [M]" : ""]."
			m_type = 1

		if("stare", "stares")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> stares[M ? " at [M]" : ""]."
			m_type = 1

		if("look", "looks")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> looks[M ? " at [M]" : ""]."
			m_type = 1

		if("grin", "grins")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> grins[M ? " at [M]" : ""]."
			m_type = 1

		if("cry", "cries")
			if(miming)
				message = "<B>[src]</B> cries."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> cries."
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise. [p_they(TRUE)] frown[p_s()]."
					m_type = 2

		if("sigh", "sighs")
			var/M = handle_emote_param(param)
			if(miming)
				message = "<B>[src]</B> sighs[M ? " at [M]" : ""]."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> sighs[M ? " at [M]" : ""]."
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise"
					m_type = 2

		if("hsigh", "hsighs")
			if(!muzzled)
				message = "<B>[src]</B> sighs contentedly."
				m_type = 2
			else
				message = "<B>[src]</B> makes a [pick("chill", "relaxed")] noise"
				m_type = 2

		if("laugh", "laughs")
			var/M = handle_emote_param(param)
			if(miming)
				message = "<B>[src]</B> acts out a laugh[M ? " at [M]" : ""]."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> laughs[M ? " at [M]" : ""]."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if("mumble", "mumbles")
			message = "<B>[src]</B> mumbles!"
			m_type = 2
			if(miming)
				m_type = 1

		if("grumble", "grumbles")
			var/M = handle_emote_param(param)
			if(miming)
				message = "<B>[src]</B> grumbles[M ? " at [M]" : ""]!"
				m_type = 1
			if(!muzzled)
				message = "<B>[src]</B> grumbles[M ? " at [M]" : ""]!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if("groan", "groans")
			if(miming)
				message = "<B>[src]</B> appears to groan!"
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> groans!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a loud noise."
					m_type = 2

		if("moan", "moans")
			if(miming)
				message = "<B>[src]</B> appears to moan!"
				m_type = 1
			else
				message = "<B>[src]</B> moans!"
				m_type = 2

		if("johnny")
			var/M
			if(param)
				M = param
			if(!M)
				param = null
			else
				if(miming)
					message = "<B>[src]</B> takes a drag from a cigarette and blows \"[M]\" out in smoke."
					m_type = 1
				else
					message = "<B>[src]</B> says, \"[M], please. They had a family.\" [name] takes a drag from a cigarette and blows [p_their()] name out in smoke."
					m_type = 2

		if("point", "points")
			if(!restrained())
				var/atom/M = null
				if(param)
					for(var/atom/A as mob|obj|turf in view())
						if(param == A.name)
							M = A
							break

				if(!M)
					message = "<B>[src]</B> points."
				else
					pointed(M)
			m_type = 1

		if("raise", "raises")
			if(!restrained())
				message = "<B>[src]</B> raises a hand."
			m_type = 1

		if("shake", "shakes")
			var/M = handle_emote_param(param, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves.

			message = "<B>[src]</B> shakes [p_their()] head[M ? " at [M]" : ""]."
			m_type = 1

		if("shrug", "shrugs")
			message = "<B>[src]</B> shrugs."
			m_type = 1

		if("signal", "signals")
			if(!restrained())
				var/t1 = round(text2num(param))
				if(isnum(t1))
					if(t1 <= 5 && t1 >= 1 && (!r_hand || !l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
					else if(t1 <= 10 && t1 >= 1 && (!r_hand && !l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
			m_type = 1

		if("smile", "smiles")
			var/M = handle_emote_param(param, 1)

			message = "<B>[src]</B> smiles[M ? " at [M]" : ""]."
			m_type = 1

		if("shiver", "shivers")
			message = "<B>[src]</B> shivers."
			m_type = 2
			if(miming)
				m_type = 1

		if("pale", "pales")
			message = "<B>[src]</B> goes pale for a second."
			m_type = 1

		if("tremble", "trembles")
			message = "<B>[src]</B> trembles."
			m_type = 1

		if("shudder", "shudders")
			message = "<B>[src]</B> shudders."
			m_type = 1

		if("bshake", "bshakes")
			message = "<B>[src]</B> shakes."
			m_type = 1

		if("sneeze", "sneezes")
			if(miming)
				message = "<B>[src]</B> sneezes."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> sneezes."
					if(gender == FEMALE)
						playsound(src, dna.species.female_sneeze_sound, 70, 1, frequency = get_age_pitch())
					else
						playsound(src, dna.species.male_sneeze_sound, 70, 1, frequency = get_age_pitch())
					m_type = 2
				else
					message = "<B>[src]</B> makes a strange noise."
					m_type = 2

		if("sniff", "sniffs")
			message = "<B>[src]</B> sniffs."
			m_type = 2
			if(miming)
				m_type = 1

		if("snore", "snores")
			if(miming)
				message = "<B>[src]</B> sleeps soundly."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> snores."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if("whimper", "whimpers")
			if(miming)
				message = "<B>[src]</B> appears hurt."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> whimpers."
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = 2

		if("wink", "winks")
			var/M = handle_emote_param(param, 1)

			message = "<B>[src]</B> winks[M ? " at [M]" : ""]."
			m_type = 1

		if("yawn", "yawns")
			if(!muzzled)
				message = "<B>[src]</B> yawns."
				m_type = 2
				if(miming)
					m_type = 1

		if("collapse", "collapses")
			Paralyse(2)
			message = "<B>[src]</B> collapses!"
			m_type = 2
			if(miming)
				m_type = 1

		if("hug", "hugs")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, 1, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves and only check mobs in our immediate vicinity (1 tile distance).

				if(M)
					message = "<B>[src]</B> hugs [M]."
				else
					message = "<B>[src]</B> hugs [p_them()]self."

		if("handshake")
			m_type = 1
			if(!restrained() && !r_hand)
				var/mob/M = handle_emote_param(param, 1, 1, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves, only check mobs in our immediate vicinity (1 tile distance) and return the whole mob instead of just its name.

				if(M)
					if(M.canmove && !M.r_hand && !M.restrained())
						message = "<B>[src]</B> shakes hands with [M]."
					else
						message = "<B>[src]</B> holds out [p_their()] hand to [M]."

		if("dap", "daps")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, null, 1)

				if(M)
					message = "<B>[src]</B> gives daps to [M]."
				else
					message = "<B>[src]</B> sadly can't find anybody to give daps to, and daps [p_them()]self. Shameful."

		if("slap", "slaps")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, null, 1)

				if(M)
					message = "<span class='danger'>[src] slaps [M] across the face. Ouch!</span>"
				else
					message = "<span class='danger'>[src] slaps [p_them()]self!</span>"
					adjustFireLoss(4)
				playsound(loc, 'sound/effects/snap.ogg', 50, 1)

		if("scream", "screams")
			var/M = handle_emote_param(param)
			if(miming)
				message = "<B>[src]</B> acts out a scream[M ? " at [M]" : ""]!"
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> [dna.species.scream_verb][M ? " at [M]" : ""]!"
					m_type = 2
					if(gender == FEMALE)
						playsound(loc, dna.species.female_scream_sound, 80, 1, frequency = get_age_pitch())
					else
						playsound(loc, dna.species.male_scream_sound, 80, 1, frequency = get_age_pitch()) //default to male screams if no gender is present.

				else
					message = "<B>[src]</B> makes a very loud noise[M ? " at [M]" : ""]."
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
					to_chat(usr, "You need at least one hand in good working order to snap your fingers.")
					return

				var/M = handle_emote_param(param)

				message = "<b>[src]</b> snaps [p_their()] fingers[M ? " at [M]" : ""]."
				playsound(loc, 'sound/effects/fingersnap.ogg', 50, 1, -3)
			else
				message = "<span class='danger'><b>[src]</b> snaps [p_their()] fingers right off!</span>"
				playsound(loc, 'sound/effects/snap.ogg', 50, 1)

		if("fart", "farts")
			var/farted_on_thing = FALSE
			for(var/atom/A in get_turf(src))
				farted_on_thing += A.fart_act(src)
			if(!farted_on_thing)
				message = "<b>[src]</b> [pick("passes wind", "farts")]."
			m_type = 2

		if("hem")
			message = "<b>[src]</b> hems."

		if("highfive")
			if(restrained())
				return
			if(has_status_effect(STATUS_EFFECT_HIGHFIVE))
				to_chat(src, "You give up on the highfive.")
				remove_status_effect(STATUS_EFFECT_HIGHFIVE)
				return
			visible_message("<b>[name]</b> requests a highfive.", "You request a high five.")
			apply_status_effect(STATUS_EFFECT_HIGHFIVE)
			for(var/mob/living/L in orange(1))
				if(L.has_status_effect(STATUS_EFFECT_HIGHFIVE))
					if((mind && mind.special_role == SPECIAL_ROLE_WIZARD) && (L.mind && L.mind.special_role == SPECIAL_ROLE_WIZARD))
						visible_message("<span class='danger'><b>[name]</b> and <b>[L.name]</b> high-five EPICALLY!</span>")
						status_flags |= GODMODE
						L.status_flags |= GODMODE
						explosion(loc,5,2,1,3)
						status_flags &= ~GODMODE
						L.status_flags &= ~GODMODE
						return
					visible_message("<b>[name]</b> and <b>[L.name]</b> high-five!")
					playsound('sound/effects/snap.ogg', 50)
					remove_status_effect(STATUS_EFFECT_HIGHFIVE)
					L.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
					return

		if("help")
			var/emotelist = "aflap(s), airguitar, blink(s), blink(s)_r, blush(es), bow(s)-(none)/mob, burp(s), choke(s), chuckle(s), clap(s), collapse(s), cough(s),cry, cries, custom, dance, dap(s)(none)/mob," \
			+ " deathgasp(s), drool(s), eyebrow, fart(s), faint(s), flap(s), flip(s), frown(s), gasp(s), giggle(s), glare(s)-(none)/mob, grin(s), groan(s), grumble(s), grin(s)," \
			+ " handshake-mob, hug(s)-(none)/mob, hem, highfive, johnny, jump, laugh(s), look(s)-(none)/mob, moan(s), mumble(s), nod(s), pale(s), point(s)-atom, quiver(s), raise(s), salute(s)-(none)/mob, scream(s), shake(s)," \
			+ " shiver(s), shrug(s), sigh(s), signal(s)-#1-10,slap(s)-(none)/mob, smile(s),snap(s), sneeze(s), sniff(s), snore(s), stare(s)-(none)/mob, swag(s), tremble(s), twitch(es), twitch(es)_s," \
			+ " wag(s), wave(s),  whimper(s), wink(s), yawn(s), quill(s)"

			switch(dna.species.name)
				if("Drask")
					emotelist += "\nDrask specific emotes :- drone(s)-(none)/mob, hum(s)-(none)/mob, rumble(s)-(none)/mob"
				if("Kidan")
					emotelist += "\nKidan specific emotes :- click(s), clack(s)"
				if("Unathi")
					emotelist += "\nUnathi specific emotes :- hiss(es)"
				if("Vulpkanin")
					emotelist += "\nVulpkanin specific emotes :- growl(s)-none/mob, howl(s)-none/mob"
				if("Vox")
					emotelist += "\nVox specific emotes :- quill(s)"
				if("Diona")
					emotelist += "\nDiona specific emotes :- creak(s)"
				if("Skrell")
					emotelist += "\nSkrell specific emotes :- warble(s)"

			if(ismachine(src))
				emotelist += "\nMachine specific emotes :- beep(s)-(none)/mob, buzz(es)-none/mob, no-(none)/mob, ping(s)-(none)/mob, yes-(none)/mob, buzz2-(none)/mob"
			else
				var/obj/item/organ/external/head/H = get_organ("head") // If you have a robotic head, you can make beep-boop noises
				if(H && H.is_robotic())
					emotelist += "\nRobotic head specific emotes :- beep(s)-(none)/mob, buzz(es)-none/mob, no-(none)/mob, ping(s)-(none)/mob, yes-(none)/mob, buzz2-(none)/mob"

			if(isslimeperson(src))
				emotelist += "\nSlime people specific emotes :- squish(es)-(none)/mob"
			else
				for(var/obj/item/organ/external/L in bodyparts) // if your limbs are squishy you can squish too!
					if(istype(L.dna.species, /datum/species/slime))
						emotelist += "\nSlime people body part specific emotes :- squish(es)-(none)/mob"
						break

			to_chat(src, emotelist)
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

	if(message) //Humans are special fucking snowflakes and have 800 lines of emotes, they get to handle their own emotes, not call the parent.
		log_emote(message, src)

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in GLOB.dead_mob_list)
			if(!M.client)
				continue

			if(isnewplayer(M))
				continue

			if(isobserver(M) && M.get_preference(CHAT_GHOSTSIGHT) && !(M in viewers(src, null)) && client) // The client check makes sure people with ghost sight don't get spammed by simple mobs emoting.
				M.show_message(message)

		switch(m_type)
			if(1)
				visible_message(message)
			if(2)
				audible_message(message)

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose = sanitize(copytext(input(usr, "This is [src]. [p_they(TRUE)] [p_are()]...", "Pose", null)  as text, 1, MAX_MESSAGE_LEN))

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	update_flavor_text()
