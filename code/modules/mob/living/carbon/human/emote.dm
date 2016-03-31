/mob/living/carbon/human/emote(var/act,var/m_type=1,var/message = null,var/force)

	if (stat == DEAD)
		return // No screaming bodies

	var/param = null
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = is_muzzled()
	if(sdisabilities & MUTE || silent)
		muzzled = 1
	//var/m_type = 1

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	var/miming = 0
	if(mind)
		miming = mind.miming

	//Emote Cooldown System (it's so simple!)
	// proc/handle_emote_CD() located in [code\modules\mob\emote.dm]
	var/on_CD = 0
	switch(act)
		//Cooldown-inducing emotes
		if("ping", "pings", "buzz", "buzzes", "beep", "beeps", "yes", "no")
			if (species.name == "Machine")		//Only Machines can beep, ping, and buzz
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
			else								//Everyone else fails, skip the emote attempt
				return
		if("squish", "squishes")
			var/found_slime_bodypart = 0

			if(species.name == "Slime People")	//Only Slime People can squish
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm'
				found_slime_bodypart = 1
			else
				for(var/obj/item/organ/external/L in organs) // if your limbs are squishy you can squish too!
					if(L.dna.species in list("Slime People"))
						on_CD = handle_emote_CD()
						found_slime_bodypart = 1
						break

			if(!found_slime_bodypart)								//Everyone else fails, skip the emote attempt
				return
		if("scream", "screams")
			on_CD = handle_emote_CD(50) //longer cooldown
		if("fart", "farts", "flip", "flips", "snap", "snaps")
			on_CD = handle_emote_CD()				//proc located in code\modules\mob\emote.dm
		//Everything else, including typos of the above emotes
		else
			on_CD = 0	//If it doesn't induce the cooldown, we won't check for the cooldown

	if(on_CD == 1)		// Check if we need to suppress the emote attempt.
		return			// Suppress emote, you're still cooling off.

	switch(act)
		if("me")									//OKAY SO RANT TIME, THIS FUCKING HAS TO BE HERE OR A SHITLOAD OF THINGS BREAK
			return custom_emote(m_type, message)	//DO YOU KNOW WHY SHIT BREAKS? BECAUSE SO MUCH OLDCODE CALLS mob.emote("me",1,"whatever_the_fuck_it_wants_to_emote")
													//WHO THE FUCK THOUGHT THAT WAS A GOOD FUCKING IDEA!?!?

		if("ping", "pings")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> pings at [param]."
			else
				message = "<B>[src]</B> pings."
			playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
			m_type = 2

		if("buzz", "buzzes")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> buzzes at [param]."
			else
				message = "<B>[src]</B> buzzes."
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			m_type = 2

		if("beep", "beeps")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> beeps at [param]."
			else
				message = "<B>[src]</B> beeps."
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
			m_type = 2

		if("squish", "squishes")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> squishes at [param]."
			else
				message = "<B>[src]</B> squishes."
			playsound(src.loc, 'sound/effects/slime_squish.ogg', 50, 0) //Credit to DrMinky (freesound.org) for the sound.
			m_type = 2

		if("yes")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> emits an affirmative blip at [param]."
			else
				message = "<B>[src]</B> emits an affirmative blip."
			playsound(src.loc, 'sound/machines/synth_yes.ogg', 50, 0)
			m_type = 2

		if("no")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> emits a negative blip at [param]."
			else
				message = "<B>[src]</B> emits a negative blip."
			playsound(src.loc, 'sound/machines/synth_no.ogg', 50, 0)
			m_type = 2

		if("wag", "wags")
			if(body_accessory)
				if(body_accessory.try_restrictions(src))
					message = "<B>[src]</B> starts wagging \his tail."
					start_tail_wagging(1)

			else if(species.bodyflags & TAIL_WAGGING)
				if(!wear_suit || !(wear_suit.flags_inv & HIDETAIL) && !istype(wear_suit, /obj/item/clothing/suit/space))
					message = "<B>[src]</B> starts wagging \his tail."
					src.start_tail_wagging(1)
				else
					return
			else
				return
			m_type = 1

		if("swag", "swags")
			if(species.bodyflags & TAIL_WAGGING || body_accessory)
				message = "<B>[src]</B> stops wagging \his tail."
				src.stop_tail_wagging(1)
			else
				return
			m_type = 1

		if ("airguitar")
			if (!src.restrained())
				message = "<B>[src]</B> is strumming the air and headbanging like a safari chimp."
				m_type = 1

		if ("blink", "blinks")
			message = "<B>[src]</B> blinks."
			m_type = 1

		if ("blink_r", "blinks_r")
			message = "<B>[src]</B> blinks rapidly."
			m_type = 1

		if ("bow", "bows")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> bows to [param]."
				else
					message = "<B>[src]</B> bows."
			m_type = 1

		if ("salute", "salutes")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> salutes to [param]."
				else
					message = "<B>[src]</b> salutes."
			m_type = 1

		if ("choke", "chokes")
			if(miming)
				message = "<B>[src]</B> clutches \his throat desperately!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> chokes!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a strong noise."
					m_type = 2

		if ("burp", "burps")
			if(miming)
				message = "<B>[src]</B> opens their mouth rather obnoxiously."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> burps."
					m_type = 2
				else
					message = "<B>[src]</B> makes a peculiar noise."
					m_type = 2
		if ("clap", "claps")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2
				if(miming)
					m_type = 1
		if ("flap", "flaps")
			if (!src.restrained())
				message = "<B>[src]</B> flaps \his wings."
				m_type = 2
				if(miming)
					m_type = 1

		if ("flip", "flips")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if(src.lying || src.weakened)
						message = "<B>[src]</B> flops and flails around on the floor."
					else
						message = "<B>[src]</B> flips in [M]'s general direction."
						src.SpinAnimation(5,1)
				else
					if(src.lying || src.weakened)
						message = "<B>[src]</B> flops and flails around on the floor."
					else
						message = "<B>[src]</B> does a flip!"
						src.SpinAnimation(5,1)

		if ("aflap", "aflaps")
			if (!src.restrained())
				message = "<B>[src]</B> flaps \his wings ANGRILY!"
				m_type = 2
				if(miming)
					m_type = 1

		if ("drool", "drools")
			message = "<B>[src]</B> drools."
			m_type = 1

		if ("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = 1

		if ("chuckle", "chuckles")
			if(miming)
				message = "<B>[src]</B> appears to chuckle."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> chuckles."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if ("twitch", "twitches")
			message = "<B>[src]</B> twitches violently."
			m_type = 1

		if ("twitch_s", "twitches_s")
			message = "<B>[src]</B> twitches."
			m_type = 1

		if ("faint", "faints")
			message = "<B>[src]</B> faints."
			if(src.sleeping)
				return //Can't faint while asleep
			src.sleeping += 10 //Short-short nap
			m_type = 1

		if ("cough", "coughs")
			if(miming)
				message = "<B>[src]</B> appears to cough!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> coughs!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a strong noise."
					m_type = 2

		if ("frown", "frowns")
			message = "<B>[src]</B> frowns."
			m_type = 1

		if ("nod", "nods")
			message = "<B>[src]</B> nods."
			m_type = 1

		if ("blush", "blushes")
			message = "<B>[src]</B> blushes."
			m_type = 1

		if ("wave", "waves")
			message = "<B>[src]</B> waves."
			m_type = 1

		if ("quiver", "quivers")
			message = "<B>[src]</B> quivers."
			m_type = 1

		if ("gasp", "gasps")
			if(miming)
				message = "<B>[src]</B> appears to be gasping!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> gasps!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = 2

		if ("deathgasp", "deathgasps")
			message = "<B>[src]</B> [species.death_message]"
			m_type = 1

		if ("giggle", "giggles")
			if(miming)
				message = "<B>[src]</B> giggles silently!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> giggles."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if ("glare", "glares")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."
			m_type = 1

		if ("stare", "stares")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."
			m_type = 1

		if ("look", "looks")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> looks at [param]."
			else
				message = "<B>[src]</B> looks."
			m_type = 1

		if ("grin", "grins")
			message = "<B>[src]</B> grins."
			m_type = 1

		if ("cry", "cries")
			if(miming)
				message = "<B>[src]</B> cries."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> cries."
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise. \He frowns."
					m_type = 2

		if ("sigh", "sighs")
			if(miming)
				message = "<B>[src]</B> sighs."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> sighs."
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = 2

		if ("laugh", "laughs")
			if(miming)
				message = "<B>[src]</B> acts out a laugh."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> laughs."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if ("mumble", "mumbles")
			message = "<B>[src]</B> mumbles!"
			m_type = 2
			if(miming)
				m_type = 1

		if ("grumble", "grumbles")
			if(miming)
				message = "<B>[src]</B> grumbles!"
				m_type = 1
			if (!muzzled)
				message = "<B>[src]</B> grumbles!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("groan", "groans")
			if(miming)
				message = "<B>[src]</B> appears to groan!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> groans!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a loud noise."
					m_type = 2

		if ("moan", "moans")
			if(miming)
				message = "<B>[src]</B> appears to moan!"
				m_type = 1
			else
				message = "<B>[src]</B> moans!"
				m_type = 2

		if ("johnny")
			var/M
			if (param)
				M = param
			if (!M)
				param = null
			else
				if(miming)
					message = "<B>[src]</B> takes a drag from a cigarette and blows \"[M]\" out in smoke."
					m_type = 1
				else
					message = "<B>[src]</B> says, \"[M], please. They had a family.\" [src.name] takes a drag from a cigarette and blows their name out in smoke."
					m_type = 2

		if ("point", "points")
			if (!src.restrained())
				var/atom/M = null
				if (param)
					for (var/atom/A as mob|obj|turf in view())
						if (param == A.name)
							M = A
							break

				if (!M)
					message = "<B>[src]</B> points."
				else
					pointed(M)
			m_type = 1

		if ("raise", "raises")
			if (!src.restrained())
				message = "<B>[src]</B> raises a hand."
			m_type = 1

		if("shake", "shakes")
			message = "<B>[src]</B> shakes \his head."
			m_type = 1

		if ("shrug", "shrugs")
			message = "<B>[src]</B> shrugs."
			m_type = 1

		if ("signal", "signals")
			if (!src.restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1))
					if (t1 <= 5 && (!src.r_hand || !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
					else if (t1 <= 10 && (!src.r_hand && !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
			m_type = 1

		if ("smile", "smiles")
			message = "<B>[src]</B> smiles."
			m_type = 1

		if ("shiver", "shivers")
			message = "<B>[src]</B> shivers."
			m_type = 2
			if(miming)
				m_type = 1

		if ("pale", "pales")
			message = "<B>[src]</B> goes pale for a second."
			m_type = 1

		if ("tremble", "trembles")
			message = "<B>[src]</B> trembles."
			m_type = 1

		if ("sneeze", "sneezes")
			if (miming)
				message = "<B>[src]</B> sneezes."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> sneezes."
					m_type = 2
				else
					message = "<B>[src]</B> makes a strange noise."
					m_type = 2

		if ("sniff", "sniffs")
			message = "<B>[src]</B> sniffs."
			m_type = 2
			if(miming)
				m_type = 1

		if ("snore", "snores")
			if (miming)
				message = "<B>[src]</B> sleeps soundly."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> snores."
					m_type = 2
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2

		if ("whimper", "whimpers")
			if (miming)
				message = "<B>[src]</B> appears hurt."
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> whimpers."
					m_type = 2
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = 2

		if ("wink", "winks")
			message = "<B>[src]</B> winks."
			m_type = 1

		if ("yawn", "yawns")
			if (!muzzled)
				message = "<B>[src]</B> yawns."
				m_type = 2
				if(miming)
					m_type = 1

		if ("collapse", "collapses")
			Paralyse(2)
			message = "<B>[src]</B> collapses!"
			m_type = 2
			if(miming)
				m_type = 1

		if("hug", "hugs")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					message = "<B>[src]</B> hugs [M]."
				else
					message = "<B>[src]</B> hugs \himself."

		if ("handshake")
			m_type = 1
			if (!src.restrained() && !src.r_hand)
				var/mob/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (M.canmove && !M.r_hand && !M.restrained())
						message = "<B>[src]</B> shakes hands with [M]."
					else
						message = "<B>[src]</B> holds out \his hand to [M]."

		if("dap", "daps")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M)
					message = "<B>[src]</B> gives daps to [M]."
				else
					message = "<B>[src]</B> sadly can't find anybody to give daps to, and daps \himself. Shameful."

		if("slap", "slaps")
			m_type = 1
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M)
					message = "\red <B>[src]</B> slaps [M] across the face. Ouch!"
					playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
				else
					message = "\red <B>[src]</B> slaps \himself!"
					playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
					src.adjustFireLoss(4)

		if ("scream", "screams")
			if (miming)
				message = "<B>[src]</B> acts out a scream!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> [species.scream_verb]!"
					m_type = 2
					if(gender == FEMALE)
						playsound(src.loc, "[species.female_scream_sound]", 80, 1, 0, pitch = get_age_pitch())
					else
						playsound(src.loc, "[species.male_scream_sound]", 80, 1, 0, pitch = get_age_pitch()) //default to male screams if no gender is present.

				else
					message = "<B>[src]</B> makes a very loud noise."
					m_type = 2


		if ("snap", "snaps")
			if(prob(95))
				m_type = 2
				var/mob/living/carbon/human/H = src
				var/obj/item/organ/external/L = H.get_organ("l_hand")
				var/obj/item/organ/external/R = H.get_organ("r_hand")
				var/left_hand_good = 0
				var/right_hand_good = 0
				if(L && (!(L.status & ORGAN_DESTROYED)) && (!(L.status & ORGAN_SPLINTED)) && (!(L.status & ORGAN_BROKEN)))
					left_hand_good = 1
				if(R && (!(R.status & ORGAN_DESTROYED)) && (!(R.status & ORGAN_SPLINTED)) && (!(R.status & ORGAN_BROKEN)))
					right_hand_good = 1

				if (!left_hand_good && !right_hand_good)
					usr << "You need at least one hand in good working order to snap your fingers."
					return

				message = "<b>[src]</b> snaps \his fingers."
				playsound(src.loc, 'sound/effects/fingersnap.ogg', 50, 1, -3)
			else
				message = "<span class='danger'><b>[src]</b> snaps \his fingers right off!</span>"
				playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)


		// Needed for M_TOXIC_FART
		if("fart", "farts")
			if(reagents.has_reagent("simethicone"))
				return
//			playsound(src.loc, 'sound/effects/fart.ogg', 50, 1, -3) //Admins still vote no to fun
			if(locate(/obj/item/weapon/storage/bible) in get_turf(src))
				viewers(src) << "<span class='warning'><b>[src] farts on the Bible!</b></span>"
				viewers(src) << "<span class='notice'><b>A mysterious force smites [src]!</b></span>"
				var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				src.gib()
			else if(TOXIC_FARTS in mutations)
				message = "<b>[src]</b> unleashes a [pick("horrible","terrible","foul","disgusting","awful")] fart."
			else
				message = "<b>[src]</b> [pick("passes wind","farts")]."
			m_type = 2

			var/turf/location = get_turf(src)
			var/aoe_range=2 // Default

			// Process toxic farts first.
			if(TOXIC_FARTS in mutations)
				for(var/mob/M in range(location,aoe_range))
					if (M.internal != null && M.wear_mask && (M.wear_mask.flags & AIRTIGHT))
						continue
					// Now, we don't have this:
					//new /obj/effects/fart_cloud(T,L)
					// But:
					// <[REDACTED]> so, what it does is...imagine a 3x3 grid with the person in the center. When someone uses the emote *fart (it's not a spell style ability and has no cooldown), then anyone in the 8 tiles AROUND the person who uses it
					// <[REDACTED]> gets between 1 and 10 units of jenkem added to them...we obviously don't have Jenkem, but Space Drugs do literally the same exact thing as Jenkem
					// <[REDACTED]> the user, of course, isn't impacted because it's not an actual smoke cloud
					// So, let's give 'em space drugs.
					if (M == src)
						continue
					M.reagents.add_reagent("space_drugs",rand(1,10))

		if ("help")
			var/emotelist = "aflap(s), airguitar, blink(s), blink(s)_r, blush(es), bow(s)-(none)/mob, burp(s), choke(s), chuckle(s), clap(s), collapse(s), cough(s),cry, cries, custom, dap(s)(none)/mob," \
			+ " deathgasp(s), drool(s), eyebrow,fart(s), faint(s), flap(s), flip(s), frown(s), gasp(s), giggle(s), glare(s)-(none)/mob, grin(s), groan(s), grumble(s), handshake-mob, hug(s)-(none)/mob," \
			+ " glare(s)-(none)/mob, grin(s), johnny, laugh(s), look(s)-(none)/mob, moan(s), mumble(s), nod(s), pale(s), point(s)-atom, quiver(s), raise(s), salute(s)-(none)/mob, scream(s), shake(s)," \
			+ " shiver(s), shrug(s), sigh(s), signal(s)-#1-10,slap(s)-(none)/mob, smile(s),snap(s), sneeze(s), sniff(s), snore(s), stare(s)-(none)/mob, swag(s), tremble(s), twitch(es), twitch(es)_s," \
			+ " wag(s), wave(s),  whimper(s), wink(s), yawn(s)"
			if(species.name == "Machine")
				emotelist += "\nMachine specific emotes :- beep(s)-(none)/mob, buzz(es)-none/mob, no-(none)/mob, ping(s)-(none)/mob, yes-(none)/mob"
			else if(species.name == "Slime People")
				emotelist += "\nSlime people specific emotes :- squish(es)-(none)/mob"
			src << emotelist

		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."





	if(message) //Humans are special fucking snowflakes and have 735 lines of emotes, they get to handle their own emotes, not call the parent
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
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
