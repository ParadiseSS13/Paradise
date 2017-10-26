/mob/living/carbon/human/emote(var/act,var/m_type=1,var/message = null,var/force)

	if((stat == DEAD) || (status_flags & FAKEDEATH))
		return // No screaming bodies

	var/param = null
	if(findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = is_muzzled()
	if(!can_speak())
		muzzled = 1
	//var/m_type = 1

	for(var/obj/item/weapon/implant/I in src)
		if(I.implanted)
			I.trigger(act, src)

	var/miming = 0
	if(mind)
		miming = mind.miming

	//Emote Cooldown System (it's so simple!)
	// proc/handle_emote_CD() located in [code\modules\mob\emote.dm]
	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		//Cooldown-inducing emotes
		if("ping", "pings", "buzz", "buzzes", "beep", "beeps", "yes", "no", "buzz2")
			if(species.name == "Machine")		//Only Machines can beep, ping, and buzz, yes, no, and make a silly sad trombone noise.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
			else								//Everyone else fails, skip the emote attempt
				return
		if("drone","drones","hum","hums","rumble","rumbles")
			if(species.name == "Drask")		//Only Drask can make whale noises
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
			else
				return
		if("howl", "howls")
			if (species.name == "Vulpkanin")		//Only Vulpkanin can howl
				on_CD = handle_emote_CD(100)
			else
				return
		if("growl", "growls")
			if (species.name == "Vulpkanin")		//Only Vulpkanin can growl
				on_CD = handle_emote_CD()
			else
				return
		if("squish", "squishes")
			var/found_slime_bodypart = 0

			if(species.name == "Slime People")	//Only Slime People can squish
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
				found_slime_bodypart = 1
			else
				for(var/obj/item/organ/external/L in bodyparts) // if your limbs are squishy you can squish too!
					if(L.dna.species in list("Slime People"))
						on_CD = handle_emote_CD()
						found_slime_bodypart = 1
						break

			if(!found_slime_bodypart)								//Everyone else fails, skip the emote attempt
				return

		if("clack", "clacks")
			if(species.name == "Kidan")	//Only Kidan can clack and rightfully so.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("click", "clicks")
			if(species.name == "Kidan")	//Only Kidan can click and rightfully so.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("creaks", "creak")
			if(species.name == "Diona") //Only Dionas can Creaks.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("hiss", "hisses")
			if(species.name == "Unathi") //Only Unathi can hiss.
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
			else								//Everyone else fails, skip the emote attempt
				return

		if("scream", "screams")
			on_CD = handle_emote_CD(50) //longer cooldown
		if("fart", "farts", "flip", "flips", "snap", "snaps")
			on_CD = handle_emote_CD()				//proc located in code\modules\mob\emote.dm
		if("cough", "coughs", "slap", "slaps", "highfive")
			on_CD = handle_emote_CD()
		if("sneeze", "sneezes")
			on_CD = handle_emote_CD()
		//Everything else, including typos of the above emotes
		else
			on_CD = 0	//If it doesn't induce the cooldown, we won't check for the cooldown

	if(on_CD == 1)		// Check if we need to suppress the emote attempt.
		return			// Suppress emote, you're still cooling off.

	switch(act)
		if("me")									//OKAY SO RANT TIME, THIS FUCKING HAS TO BE HERE OR A SHITLOAD OF THINGS BREAK
			return custom_emote(m_type, message)	//DO YOU KNOW WHY SHIT BREAKS? BECAUSE SO MUCH OLDCODE CALLS mob.emote("me",1,"whatever_the_fuck_it_wants_to_emote")
													//WHO THE FUCK THOUGHT THAT WAS A GOOD FUCKING IDEA!?!?

		if("howl", "howls")
			var/M = handle_emote_param(param) //Check to see if the param is valid (mob with the param name is in view).
			message = "<B>[src]</B> howls[M ? " at [M]" : ""]!"
			playsound(loc, 'sound/goonstation/voice/howl.ogg', 100, 0, 10)
			m_type = 2

		if("growl", "growls")
			var/M = handle_emote_param(param)
			message = "<B>[src]</B> growls[M ? " at [M]" : ""]."
			playsound(loc, "growls", 80, 0)
			m_type = 2

		if("ping", "pings")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> pings[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/ping.ogg', 50, 0)
			m_type = 2

		if("buzz2")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> emits an irritated buzzing sound[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
			m_type = 2

		if("buzz", "buzzes")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> buzzes[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = 2

		if("beep", "beeps")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> beeps[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/twobeep.ogg', 50, 0)
			m_type = 2

		if("drone", "drones", "hum", "hums", "rumble", "rumbles")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> [M ? "drones at [M]" : "rumbles"]."
			playsound(loc, 'sound/voice/DraskTalk.ogg', 50, 0)
			m_type = 2

		if("squish", "squishes")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> squishes[M ? " at [M]" : ""]."
			playsound(loc, 'sound/effects/slime_squish.ogg', 50, 0) //Credit to DrMinky (freesound.org) for the sound.
			m_type = 2

		if("clack", "clacks")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> clacks their mandibles[M ? " at [M]" : ""]."
			playsound(loc, 'sound/effects/Kidanclack.ogg', 50, 0) //Credit to DrMinky (freesound.org) for the sound.
			m_type = 2

		if("click", "clicks")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> clicks their mandibles[M ? " at [M]" : ""]."
			playsound(loc, 'sound/effects/Kidanclack2.ogg', 50, 0) //Credit to DrMinky (freesound.org) for the sound.
			m_type = 2

		if("creaks", "creak")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> creaks[M ? " at [M]" : ""]."
			playsound(loc, 'sound/voice/dionatalk1.ogg', 50, 0) //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
			m_type = 2

		if("hiss", "hisses")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> hisses[M ? " at [M]" : ""]."
			playsound(loc, 'sound/effects/unathihiss.ogg', 50, 0) //Credit to Jamius (freesound.org) for the sound.
			m_type = 2

		if("yes")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> emits an affirmative blip[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/synth_yes.ogg', 50, 0)
			m_type = 2

		if("no")
			var/M = handle_emote_param(param)

			message = "<B>[src]</B> emits a negative blip[M ? " at [M]" : ""]."
			playsound(loc, 'sound/machines/synth_no.ogg', 50, 0)
			m_type = 2

		if("wag", "wags")
			if(body_accessory)
				if(body_accessory.try_restrictions(src))
					message = "<B>[src]</B> starts wagging \his tail."
					start_tail_wagging(1)

			else if(species.bodyflags & TAIL_WAGGING)
				if(!wear_suit || !(wear_suit.flags_inv & HIDETAIL) && !istype(wear_suit, /obj/item/clothing/suit/space))
					message = "<B>[src]</B> starts wagging \his tail."
					start_tail_wagging(1)
				else
					return
			else
				return
			m_type = 1

		if("swag", "swags")
			if(species.bodyflags & TAIL_WAGGING || body_accessory)
				message = "<B>[src]</B> stops wagging \his tail."
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
				message = "<B>[src]</B> clutches \his throat desperately!"
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
				message = "<B>[src]</B> opens their mouth rather obnoxiously."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> burps."
					m_type = 2
				else
					message = "<B>[src]</B> makes a peculiar noise."
					m_type = 2
		if("clap", "claps")
			if(!restrained())
				message = "<B>[src]</B> claps."
				m_type = 2
				if(miming)
					m_type = 1
		if("flap", "flaps")
			if(!restrained())
				message = "<B>[src]</B> flaps \his wings."
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
					if(lying || weakened)
						message = "<B>[src]</B> flops and flails around on the floor."
					else
						var/obj/item/weapon/grab/G
						if(istype(get_active_hand(), /obj/item/weapon/grab))
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
				message = "<B>[src]</B> flaps \his wings ANGRILY!"
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
						if(species.female_cough_sounds)
							playsound(src, pick(species.female_cough_sounds), 120)
					else
						if(species.male_cough_sounds)
							playsound(src, pick(species.male_cough_sounds), 120)
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
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = 2

		if("deathgasp", "deathgasps")
			message = "<B>[src]</B> [species.death_message]"
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
					message = "<B>[src]</B> makes a weak noise. \He frowns."
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
					message = "<B>[src]</B> says, \"[M], please. They had a family.\" [name] takes a drag from a cigarette and blows their name out in smoke."
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

			message = "<B>[src]</B> shakes \his head[M ? " at [M]" : ""]."
			m_type = 1

		if("shrug", "shrugs")
			message = "<B>[src]</B> shrugs."
			m_type = 1

		if("signal", "signals")
			if(!restrained())
				var/t1 = round(text2num(param))
				if(isnum(t1))
					if(t1 <= 5 && (!r_hand || !l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
					else if(t1 <= 10 && (!r_hand && !l_hand))
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

		if("sneeze", "sneezes")
			if(miming)
				message = "<B>[src]</B> sneezes."
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> sneezes."
					if(gender == FEMALE)
						playsound(src, species.female_sneeze_sound, 70)
					else
						playsound(src, species.male_sneeze_sound, 70)
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
					message = "<B>[src]</B> hugs \himself."

		if("handshake")
			m_type = 1
			if(!restrained() && !r_hand)
				var/mob/M = handle_emote_param(param, 1, 1, 1) //Check to see if the param is valid (mob with the param name is in view) but exclude ourselves, only check mobs in our immediate vicinity (1 tile distance) and return the whole mob instead of just its name.

				if(M)
					if(M.canmove && !M.r_hand && !M.restrained())
						message = "<B>[src]</B> shakes hands with [M]."
					else
						message = "<B>[src]</B> holds out \his hand to [M]."

		if("dap", "daps")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, null, 1)

				if(M)
					message = "<B>[src]</B> gives daps to [M]."
				else
					message = "<B>[src]</B> sadly can't find anybody to give daps to, and daps \himself. Shameful."

		if("slap", "slaps")
			m_type = 1
			if(!restrained())
				var/M = handle_emote_param(param, null, 1)

				if(M)
					message = "<span class='danger'>[src] slaps [M] across the face. Ouch!</span>"
				else
					message = "<span class='danger'>[src] slaps \himself!</span>"
					adjustFireLoss(4)
				playsound(loc, 'sound/effects/snap.ogg', 50, 1)

		if("scream", "screams")
			var/M = handle_emote_param(param)
			if(miming)
				message = "<B>[src]</B> acts out a scream[M ? " at [M]" : ""]!"
				m_type = 1
			else
				if(!muzzled)
					message = "<B>[src]</B> [species.scream_verb][M ? " at [M]" : ""]!"
					m_type = 2
					if(gender == FEMALE)
						playsound(loc, "[species.female_scream_sound]", 80, 1, frequency = get_age_pitch())
					else
						playsound(loc, "[species.male_scream_sound]", 80, 1, frequency = get_age_pitch()) //default to male screams if no gender is present.

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

				message = "<b>[src]</b> snaps \his fingers[M ? " at [M]" : ""]."
				playsound(loc, 'sound/effects/fingersnap.ogg', 50, 1, -3)
			else
				message = "<span class='danger'><b>[src]</b> snaps \his fingers right off!</span>"
				playsound(loc, 'sound/effects/snap.ogg', 50, 1)

		// Needed for M_TOXIC_FART
		if("fart", "farts")
			if(reagents.has_reagent("simethicone"))
				return
//			playsound(loc, 'sound/effects/fart.ogg', 50, 1, -3) //Admins still vote no to fun
			if(locate(/obj/item/weapon/storage/bible) in get_turf(src))
				to_chat(viewers(src), "<span class='warning'><b>[src] farts on the Bible!</b></span>")
				var/image/cross = image('icons/obj/storage.dmi',"bible")
				var/adminbfmessage = "\blue [bicon(cross)] <b><font color=red>Bible Fart: </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=[UID()]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) ([admin_jump_link(src)]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;Smite=[UID()]'>SMITE</A>):</b>"
				for(var/client/X in admins)
					if(check_rights(R_EVENT,0,X.mob))
						to_chat(X, adminbfmessage)
			else if(TOXIC_FARTS in mutations)
				message = "<b>[src]</b> unleashes a [pick("horrible","terrible","foul","disgusting","awful")] fart."
			else if(SUPER_FART in mutations)
				message = "<b>[src]</b> unleashes a [pick("loud","deafening")] fart."
				newtonian_move(dir)
			else
				message = "<b>[src]</b> [pick("passes wind","farts")]."
			m_type = 2

			var/turf/location = get_turf(src)
			var/aoe_range=2 // Default

			// Process toxic farts first.
			if(TOXIC_FARTS in mutations)
				for(var/mob/M in range(location,aoe_range))
					if(M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
						continue
					// Now, we don't have this:
					//new /obj/effects/fart_cloud(T,L)
					if(M == src)
						continue
					M.reagents.add_reagent("jenkem", 1)

		if("hem")
			message = "<b>[src]</b> hems."

		if("highfive")
			if(restrained())
				return
			if(EFFECT_HIGHFIVE in active_effect)
				to_chat(src, "You give up on the high-five.")
				active_effect -= EFFECT_HIGHFIVE
				return
			active_effect |= EFFECT_HIGHFIVE
			for(var/mob/living/carbon/C in orange(1))
				if(EFFECT_HIGHFIVE in C.active_effect)
					if((C.mind.special_role == SPECIAL_ROLE_WIZARD) && (mind.special_role == SPECIAL_ROLE_WIZARD))
						visible_message("<span class='danger'><b>[name]</b> and <b>[C.name]</b> high-five EPICALLY!</span>")
						status_flags |= GODMODE
						C.status_flags |= GODMODE
						explosion(loc,5,2,1,3)
						status_flags &= ~GODMODE
						C.status_flags &= ~GODMODE
						break
				visible_message("<b>[name]</b> and <b>[C.name]</b> high-five!")
				C.active_effect -= EFFECT_HIGHFIVE
				active_effect -= EFFECT_HIGHFIVE
				playsound('sound/effects/snap.ogg', 50)
				break
			if(EFFECT_HIGHFIVE in active_effect)
				visible_message("<b>[name]</b> requests a highfive.", "You request a highfive.")
				if(do_after(src, 25, target = src))
					visible_message("[name] was left hanging. Embarrassing.", "You are left hanging. How embarrassing!")
					active_effect -= EFFECT_HIGHFIVE

		if("help")
			var/emotelist = "aflap(s), airguitar, blink(s), blink(s)_r, blush(es), bow(s)-(none)/mob, burp(s), choke(s), chuckle(s), clap(s), collapse(s), cough(s),cry, cries, custom, dance, dap(s)(none)/mob," \
			+ " deathgasp(s), drool(s), eyebrow, fart(s), faint(s), flap(s), flip(s), frown(s), gasp(s), giggle(s), glare(s)-(none)/mob, grin(s), groan(s), grumble(s), grin(s)," \
			+ " handshake-mob, hug(s)-(none)/mob, hem, highfive, johnny, jump, laugh(s), look(s)-(none)/mob, moan(s), mumble(s), nod(s), pale(s), point(s)-atom, quiver(s), raise(s), salute(s)-(none)/mob, scream(s), shake(s)," \
			+ " shiver(s), shrug(s), sigh(s), signal(s)-#1-10,slap(s)-(none)/mob, smile(s),snap(s), sneeze(s), sniff(s), snore(s), stare(s)-(none)/mob, swag(s), tremble(s), twitch(es), twitch(es)_s," \
			+ " wag(s), wave(s),  whimper(s), wink(s), yawn(s)"

			switch(species.name)
				if("Machine")
					emotelist += "\nMachine specific emotes :- beep(s)-(none)/mob, buzz(es)-none/mob, no-(none)/mob, ping(s)-(none)/mob, yes-(none)/mob, buzz2-(none)/mob"
				if("Drask")
					emotelist += "\nDrask specific emotes :- drone(s)-(none)/mob, hum(s)-(none)/mob, rumble(s)-(none)/mob"
				if("Kidan")
					emotelist += "\nKidan specific emotes :- click(s), clack(s)"
				if("Unathi")
					emotelist += "\nUnathi specific emotes :- hiss(es)"
				if("Vulpkanin")
					emotelist += "\nVulpkanin specific emotes :- growl(s)-none/mob, howl(s)-none/mob"
				if("Diona")
					emotelist += "\nDiona specific emotes :- creak(s)"

			if (species.name == "Slime People")
				emotelist += "\nSlime people specific emotes :- squish(es)-(none)/mob"
			else
				for(var/obj/item/organ/external/L in bodyparts) // if your limbs are squishy you can squish too!
					if(L.dna.species in list("Slime People"))
						emotelist += "\nSlime people body part specific emotes :- squish(es)-(none)/mob"
						break

			to_chat(src, emotelist)
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

	if(message) //Humans are special fucking snowflakes and have 800 lines of emotes, they get to handle their own emotes, not call the parent.
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && M.get_preference(CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
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

	pose = sanitize(copytext(input(usr, "This is [src]. \He is...", "Pose", null)  as text, 1, MAX_MESSAGE_LEN))

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	update_flavor_text()
