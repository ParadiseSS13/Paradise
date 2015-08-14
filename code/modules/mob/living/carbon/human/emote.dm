/mob/living/carbon/human/emote(var/act,var/m_type=1,var/message = null)
	var/param = null

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/muzzled = is_muzzled()
	if(sdisabilities & MUTE || silent)
		muzzled = 1
	//var/m_type = 1

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	if(src.stat == 2.0 && (act != "deathgasp"))
		return

	//Emote Cooldown System (it's so simple!)
	// proc/handle_emote_CD() located in [code\modules\mob\emote.dm]
	var/on_CD = 0
	switch(act)
		//Cooldown-inducing emotes
		if("ping","buzz","beep")
			if (species.name == "Machine")		//Only Machines can beep, ping, and buzz
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
			else								//Everyone else fails, skip the emote attempt
				return
		if("squish")
			if(species.name == "Slime People")	//Only Slime People can squish
				on_CD = handle_emote_CD()			//proc located in code\modules\mob\emote.dm
			else								//Everyone else fails, skip the emote attempt
				return
		if("scream", "fart", "flip", "snap")
			on_CD = handle_emote_CD()				//proc located in code\modules\mob\emote.dm
		//Everything else, including typos of the above emotes
		else
			on_CD = 0	//If it doesn't induce the cooldown, we won't check for the cooldown

	if(on_CD == 1)		// Check if we need to suppress the emote attempt.
		return			// Suppress emote, you're still cooling off.
	//--FalseIncarnate

	switch(act)
		if("ping")
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
			m_type = 1

		if("buzz")
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
			m_type = 1

		if("beep")
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
			m_type = 1

		if("squish")
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
			m_type = 1

		if("wag")
			if(species.bodyflags & TAIL_WAGGING)
				if(!wear_suit || !(wear_suit.flags_inv & HIDETAIL) && !istype(wear_suit, /obj/item/clothing/suit/space))
					message = "<B>[src]</B> starts wagging \his tail."
					src.start_tail_wagging(1)
				else
					return
			else
				return

		if("swag")
			if(species.bodyflags & TAIL_WAGGING)
				message = "<B>[src]</B> stops wagging \his tail."
				src.stop_tail_wagging(1)
			else
				return

		if ("airguitar")
			if (!src.restrained())
				message = "<B>[src]</B> is strumming the air and headbanging like a safari chimp."
				m_type = 1

		if ("blink")
			message = "<B>[src]</B> blinks."
			m_type = 1

		if ("blink_r")
			message = "<B>[src]</B> blinks rapidly."
			m_type = 1

		if ("bow")
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

		if ("custom")
			var/input = sanitize(copytext(input("Choose an emote to display.") as text|null,1,MAX_MESSAGE_LEN))
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = 1
			else if (input2 == "Hearable")
				if (src.miming)
					return
				m_type = 2
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			return custom_emote(m_type, message)

		if ("me")
			if(silent)
				return
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					src << "\red You cannot send IC messages (muted)."
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if ("salute")
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

		if ("choke")
			if(miming)
				message = "<B>[src]</B> clutches his throat desperately!"
				m_type = 1
			else
				if (!muzzled)
					message = "<B>[src]</B> chokes!"
					m_type = 2
				else
					message = "<B>[src]</B> makes a strong noise."
					m_type = 2

		if ("burp")
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
		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2
				if(miming)
					m_type = 1
		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = 2
				if(miming)
					m_type = 1

		if ("flip")
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

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
				m_type = 2
				if(miming)
					m_type = 1

		if ("drool")
			message = "<B>[src]</B> drools."
			m_type = 1

		if ("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = 1

		if ("chuckle")
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

		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = 1

		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = 1

		if ("faint")
			message = "<B>[src]</B> faints."
			if(src.sleeping)
				return //Can't faint while asleep
			src.sleeping += 10 //Short-short nap
			m_type = 1

		if ("cough")
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

		if ("frown")
			message = "<B>[src]</B> frowns."
			m_type = 1

		if ("nod")
			message = "<B>[src]</B> nods."
			m_type = 1

		if ("blush")
			message = "<B>[src]</B> blushes."
			m_type = 1

		if ("wave")
			message = "<B>[src]</B> waves."
			m_type = 1

		if ("quiver")
			message = "<B>[src]</B> quivers."
			m_type = 1

		if ("gasp")
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

		if ("deathgasp")
			message = "<B>[src]</B> seizes up and falls limp, \his eyes dead and lifeless..."
			m_type = 1

		if ("giggle")
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

		if ("glare")
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

		if ("stare")
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

		if ("look")
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

		if ("grin")
			message = "<B>[src]</B> grins."
			m_type = 1

		if ("cry")
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

		if ("sigh")
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

		if ("laugh")
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

		if ("mumble")
			message = "<B>[src]</B> mumbles!"
			m_type = 2
			if(miming)
				m_type = 1

		if ("grumble")
			if(miming)
				message = "<B>[src]</B> grumbles!"
				m_type = 1
			if (!muzzled)
				message = "<B>[src]</B> grumbles!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		if ("groan")
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

		if ("moan")
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
					message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows his name out in smoke."
					m_type = 2

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(null, null))
						if (param == A.name)
							M = A
							break

				if (!M)
					message = "<B>[src]</B> points."
				else
					M.point()

				if (M)
					message = "<B>[src]</B> points to [M]."
				else
			m_type = 1

		if ("raise")
			if (!src.restrained())
				message = "<B>[src]</B> raises a hand."
			m_type = 1

		if("shake")
			message = "<B>[src]</B> shakes \his head."
			m_type = 1

		if ("shrug")
			message = "<B>[src]</B> shrugs."
			m_type = 1

		if ("signal")
			if (!src.restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1))
					if (t1 <= 5 && (!src.r_hand || !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
					else if (t1 <= 10 && (!src.r_hand && !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
			m_type = 1

		if ("smile")
			message = "<B>[src]</B> smiles."
			m_type = 1

		if ("shiver")
			message = "<B>[src]</B> shivers."
			m_type = 2
			if(miming)
				m_type = 1

		if ("pale")
			message = "<B>[src]</B> goes pale for a second."
			m_type = 1

		if ("tremble")
			message = "<B>[src]</B> trembles in fear!"
			m_type = 1

		if ("sneeze")
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

		if ("sniff")
			message = "<B>[src]</B> sniffs."
			m_type = 2
			if(miming)
				m_type = 1

		if ("snore")
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

		if ("whimper")
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

		if ("wink")
			message = "<B>[src]</B> winks."
			m_type = 1

		if ("yawn")
			if (!muzzled)
				message = "<B>[src]</B> yawns."
				m_type = 2
				if(miming)
					m_type = 1

		if ("collapse")
			Paralyse(2)
			message = "<B>[src]</B> collapses!"
			m_type = 2
			if(miming)
				m_type = 1

		if("hug")
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

		if("dap")
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

		if("slap")
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

		if ("scream")
			if (miming)
				message = "<B>[src]</B> acts out a scream!"
				m_type = 1
			else
				if (!muzzled)
					if (!(species.name == "Vox" || species.name == "Vox Armalis"))
						message = "<B>[src]</B> screams!"
						m_type = 2
						if (prob(5))
							playsound(src.loc, 'sound/voice/WilhelmScream.ogg', 100, 1, 10)
						else
							playsound(src.loc, 'sound/voice/scream2.ogg', 100, 1, 10)
					else
						message = "<B>[src]</B> shrieks!"
						m_type = 2
						playsound(src.loc, 'sound/voice/shriek1.ogg', 100, 1, 10)

				else
					message = "<B>[src]</B> makes a very loud noise."
					m_type = 2


		if ("snap")
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
		if("fart")
			if(reagents.has_reagent("simethicone"))
				return
//			playsound(src.loc, 'sound/effects/fart.ogg', 50, 1, -3) //Admins still vote no to fun
			if(locate(/obj/item/weapon/storage/bible) in get_turf(src))
				viewers(src) << "<span class='warning'><b>[src] farts on the Bible!</b></span>"
				viewers(src) << "<span class='notice'><b>A mysterious force smites [src]!</b></span>"
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
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
			if(SUPER_FART in mutations)
				aoe_range+=3 //Was 5

			// Process toxic farts first.
			if(TOXIC_FARTS in mutations)
				for(var/mob/M in range(location,aoe_range))
					if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
						continue
					if(!airborne_can_reach(location,M,aoe_range))
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

			if(SUPER_FART in mutations)
				visible_message("\red <b>[name]</b> hunches down and grits their teeth!")
				if(do_after(usr,30))
					visible_message("\red <b>[name]</b> unleashes a [pick("tremendous","gigantic","colossal")] fart!","You hear a [pick("tremendous","gigantic","colossal")] fart.")
					//playsound(L.loc, 'superfart.ogg', 50, 0)
					for(var/mob/living/V in range(location,aoe_range))
						shake_camera(V,10,5)
						if (V == src)
							continue
						if(!airborne_can_reach(get_turf(src), get_turf(V)))
							continue
						V << "\red You are sent flying!"
						V.Weaken(5) // why the hell was this set to 12 christ
						step_away(V,location,15)
						step_away(V,location,15)
						step_away(V,location,15)
				else
					usr << "\red You were interrupted and couldn't fart! Rude!"


		if ("help")
			src << "blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough,\ncry, custom, deathgasp, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn"

		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."





	if (message)
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)


		if (m_type & 1)
			for (var/mob/O in get_mobs_in_view(world.view,src))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in (hearers(src.loc, null) | get_mobs_in_view(world.view,src)))
				O.show_message(message, m_type)


/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose = sanitize(copytext(input(usr, "This is [src]. \He is...", "Pose", null)  as text, 1, MAX_MESSAGE_LEN))

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text = TextPreview(input(usr, "Please enter your new flavour text.", "Flavour text", null) as text)
