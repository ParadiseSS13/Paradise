// Process the predator's effects upon the contents of its belly (i.e digestion/transformation etc)
// Called from /mob/living/Life() proc.
/datum/belly/proc/process_Life()

/////////////////////////// Auto-Emotes ///////////////////////////
	if((digest_mode in emote_lists) && !emotePend)
		emotePend = 1

		spawn(emoteTime)
			var/list/EL = emote_lists[digest_mode]
			for(var/mob/living/M in internal_contents)
				to_chat(M, "<span class='notice'>[pick(EL)]</span>")
			src.emotePend = 0

//////////////////////// Absorbed Handling ////////////////////////
	for(var/mob/living/M in internal_contents)
		if(M.absorbed)
			M.Weaken(5)

///////////////////////////// DM_HOLD /////////////////////////////
	if(digest_mode == DM_HOLD)
		return //Pretty boring, huh

//////////////////////////// DM_DIGEST ////////////////////////////
	if(digest_mode == DM_DIGEST)

		if(prob(50)) //Was SO OFTEN. AAAA.
			var/churnsound = pick(digestion_sounds)
			for(var/mob/hearer in range(1,owner))
				hearer << sound(churnsound,volume=80)

		for (var/mob/living/M in internal_contents)
			//Pref protection!
			if (!M.digestable || M.absorbed)
				continue

			//Person just died in guts!
			if(M.stat == DEAD)
				var/digest_alert_owner = pick(digest_messages_owner)
				var/digest_alert_prey = pick(digest_messages_prey)

				//Replace placeholder vars
				digest_alert_owner = replacetext(digest_alert_owner,"%pred",owner)
				digest_alert_owner = replacetext(digest_alert_owner,"%prey",M)
				digest_alert_owner = replacetext(digest_alert_owner,"%belly",lowertext(name))

				digest_alert_prey = replacetext(digest_alert_prey,"%pred",owner)
				digest_alert_prey = replacetext(digest_alert_prey,"%prey",M)
				digest_alert_prey = replacetext(digest_alert_prey,"%belly",lowertext(name))

				//Send messages
				to_chat(owner, "<span class='notice'>" + digest_alert_owner + "</span>")
				to_chat(M, "<span class='notice'>" + digest_alert_prey + "</span>")

				owner.nutrition += 20 // so eating dead mobs gives you *something*.
				var/deathsound = pick(death_sounds)
				for(var/mob/hearer in range(1,owner))
					hearer << deathsound
				digestion_death(M)
				owner.update_icons()
				continue

			// Deal digestion damage (and feed the pred)
			if(!(M.status_flags & GODMODE))
				M.adjustBruteLoss(digest_brute)
				M.adjustFireLoss(digest_burn)

				var/offset = (1 + ((M.weight - 137) / 137)) // 130 pounds = .95 140 pounds = 1.02
				var/difference = 1 // owner.size_multiplier / M.size_multiplier
				if(offset) // If any different than default weight, multiply the % of offset.
					owner.nutrition += offset*(10/difference) // 9.5 nutrition per digestion tick if they're 130 pounds and it's same size. 10.2 per digestion tick if they're 140 and it's same size. Etc etc.
				else
					owner.nutrition += (10/difference)

		return

//////////////////////////// DM_ABSORB ////////////////////////////
	if(digest_mode == DM_ABSORB)

		for (var/mob/living/M in internal_contents)

			if(prob(10)) //Less often than gurgles. People might leave this on forever.
				var/absorbsound = pick(digestion_sounds)
				M << sound(absorbsound,volume=80)
				owner << sound(absorbsound,volume=80)

			if(M.absorbed)
				continue

			if(M.nutrition >= 100) //Drain them until there's no nutrients left. Slowly "absorb" them.
				var/oldnutrition = (M.nutrition * 0.05)
				M.nutrition = (M.nutrition * 0.95)
				owner.nutrition += oldnutrition
			else if(M.nutrition < 100) //When they're finally drained.
				absorb_living(M)

		return



//////////////////////////// DM_UNABSORB ////////////////////////////
	if(digest_mode == DM_UNABSORB)

		for (var/mob/living/M in internal_contents)
			if(M.absorbed && owner.nutrition >= 100)
				M.absorbed = 0
				to_chat(M, "<span class='notice'>You suddenly feel solid again </span>")
				to_chat(owner, "<span class='notice'>You feel like a part of you is missing.</span>")
				owner.nutrition -= 100
		return


//////////////////////////// DM_DRAIN ////////////////////////////
	if(digest_mode == DM_DRAIN)

		for (var/mob/living/M in internal_contents)

			if(prob(10)) //Less often than gurgles. People might leave this on forever.
				var/drainsound = pick(digestion_sounds)
				M << sound(drainsound,volume=80)
				owner << sound(drainsound,volume=80)

			if(M.nutrition >= 100) //Drain them until there's no nutrients left.
				var/oldnutrition = (M.nutrition * 0.05)
				M.nutrition = (M.nutrition * 0.95)
				owner.nutrition += oldnutrition
				return
		return

///////////////////////////// DM_HEAL /////////////////////////////
	if(digest_mode == DM_HEAL)
		if(prob(50)) //Wet heals!
			var/healsound = pick(digestion_sounds)
			for(var/mob/hearer in range(1,owner))
				hearer << sound(healsound,volume=80)

		for (var/mob/living/M in internal_contents)
			if(M.stat != DEAD)
				if(owner.nutrition > 90 && (M.health < M.maxHealth))
					M.adjustBruteLoss(-5)
					M.adjustFireLoss(-5)
					owner.nutrition -= 2
					if(M.nutrition <= 400)
						M.nutrition += 1
		return

///////////////////////////// DM_TRANSFORM_MALE /////////////////////////////
	if(digest_mode == DM_TRANSFORM_MALE && ishuman(owner))
		for (var/mob/living/carbon/human/P in internal_contents)
			if(P.stat)
				continue

			var/mob/living/carbon/human/O = owner

			var/TFchance = 1
			if(TFchance == 1)

				var/TFmodify = rand(1,3)
				if(TFmodify == 1)
					var/list/pred_eye_color = O.get_eye_color()
					var/list/prey_eye_color = P.get_eye_color()

					if(pred_eye_color[1] != prey_eye_color[1] || pred_eye_color[2] != prey_eye_color[2] || pred_eye_color[3] != prey_eye_color[3])
						P.change_eye_color(pred_eye_color[1], pred_eye_color[2], pred_eye_color[3])
						to_chat(P, "<span class='notice'>You feel lightheaded and drowsy...</span>")
						to_chat(owner, "<span class='notice'>You feel warm as you make subtle changes to your captive's body.</span>")
						P.update_eyes()

				if(TFmodify == 2)
					var/didchange = FALSE

					var/list/pred_hair_color = O.get_hair_color()
					var/list/prey_hair_color = P.get_hair_color()

					if(pred_hair_color[1] != prey_hair_color[1] || pred_hair_color[2] != prey_hair_color[2] || pred_hair_color[3] != prey_hair_color[3])
						P.change_hair_color(pred_hair_color[1], pred_hair_color[2], pred_hair_color[3])
						didchange = TRUE

					var/list/pred_facial_color = O.get_facial_hair_color()
					var/list/prey_facial_color = P.get_facial_hair_color()

					if(pred_facial_color[1] != prey_facial_color[1] || pred_facial_color[2] != prey_facial_color[2] || pred_facial_color[3] != prey_facial_color[3])
						P.change_facial_hair_color(pred_facial_color[1], pred_facial_color[2], pred_facial_color[3])
						didchange = TRUE

					if(O.s_tone != P.s_tone)
						P.change_skin_tone(O.s_tone)
						didchange = TRUE

					if(O.r_skin != P.r_skin || O.g_skin != P.g_skin || O.b_skin != P.b_skin)
						P.change_skin_color(O.r_skin, O.g_skin, O.b_skin)
						didchange = TRUE

					if(didchange)
						to_chat(P, "<span class='notice'>Your body tingles all over...</span>")
						to_chat(owner, "<span class='notice'>You tingle as you make noticeable changes to your captive's body.</span>")

				if(TFmodify == 3 && P.gender != MALE)
					P.gender = MALE
					to_chat(P, "<span class='notice'>Your body feels very strange...</span>")
					to_chat(owner, "<span class='notice'>You feel strange as you alter your captive's gender.</span>")
					P.update_body()

			if(O.nutrition > 0)
				O.nutrition -= 2
			if(P.nutrition < 400)
				P.nutrition += 1
		return


///////////////////////////// DM_TRANSFORM_FEMALE /////////////////////////////
	if(digest_mode == DM_TRANSFORM_FEMALE && ishuman(owner))
		for (var/mob/living/carbon/human/P in internal_contents)
			if(P.stat)
				continue

			var/mob/living/carbon/human/O = owner

			var/TFchance = 1
			if(TFchance == 1)
				var/TFmodify = rand(1,3)
				if(TFmodify == 1)
					var/list/pred_eye_color = O.get_eye_color()
					var/list/prey_eye_color = P.get_eye_color()

					if(pred_eye_color[1] != prey_eye_color[1] || pred_eye_color[2] != prey_eye_color[2] || pred_eye_color[3] != prey_eye_color[3])
						P.change_eye_color(pred_eye_color[1], pred_eye_color[2], pred_eye_color[3])
						to_chat(P, "<span class='notice'>You feel lightheaded and drowsy...</span>")
						to_chat(owner, "<span class='notice'>You feel warm as you make subtle changes to your captive's body.</span>")
						P.update_eyes()

				if(TFmodify == 2)
					var/didchange = FALSE

					var/list/pred_hair_color = O.get_hair_color()
					var/list/prey_hair_color = P.get_hair_color()

					if(pred_hair_color[1] != prey_hair_color[1] || pred_hair_color[2] != prey_hair_color[2] || pred_hair_color[3] != prey_hair_color[3])
						P.change_hair_color(pred_hair_color[1], pred_hair_color[2], pred_hair_color[3])
						didchange = TRUE

					var/list/pred_facial_color = O.get_facial_hair_color()
					var/list/prey_facial_color = P.get_facial_hair_color()

					if(pred_facial_color[1] != prey_facial_color[1] || pred_facial_color[2] != prey_facial_color[2] || pred_facial_color[3] != prey_facial_color[3])
						P.change_facial_hair_color(pred_facial_color[1], pred_facial_color[2], pred_facial_color[3])
						didchange = TRUE

					if(O.s_tone != P.s_tone)
						P.change_skin_tone(O.s_tone)
						didchange = TRUE

					if(O.r_skin != P.r_skin || O.g_skin != P.g_skin || O.b_skin != P.b_skin)
						P.change_skin_color(O.r_skin, O.g_skin, O.b_skin)
						didchange = TRUE

					if(didchange)
						to_chat(P, "<span class='notice'>Your body tingles all over...</span>")
						to_chat(owner, "<span class='notice'>You tingle as you make noticeable changes to your captive's body.</span>")

				if(TFmodify == 3 && P.gender != FEMALE)
					P.gender = FEMALE
					P.reset_facial_hair()
					to_chat(P, "<span class='notice'>Your body feels very strange...</span>")
					to_chat(owner, "<span class='notice'>You feel strange as you alter your captive's gender.</span>")
					P.update_body()

			if(O.nutrition > 0)
				O.nutrition -= 2
			if(P.nutrition < 400)
				P.nutrition += 1
		return

///////////////////////////// DM_TRANSFORM_KEEP_GENDER  /////////////////////////////
	if(digest_mode == DM_TRANSFORM_KEEP_GENDER && ishuman(owner))
		for (var/mob/living/carbon/human/P in internal_contents)
			if(P.stat)
				continue

			var/mob/living/carbon/human/O = owner

			var/TFchance = 1
			if(TFchance == 1)

				var/TFmodify = rand(1,2)
				if(TFmodify == 1)
					var/list/pred_eye_color = O.get_eye_color()
					var/list/prey_eye_color = P.get_eye_color()

					if(pred_eye_color[1] != prey_eye_color[1] || pred_eye_color[2] != prey_eye_color[2] || pred_eye_color[3] != prey_eye_color[3])
						P.change_eye_color(pred_eye_color[1], pred_eye_color[2], pred_eye_color[3])
						to_chat(P, "<span class='notice'>You feel lightheaded and drowsy...</span>")
						to_chat(owner, "<span class='notice'>You feel warm as you make subtle changes to your captive's body.</span>")
						P.update_eyes()

				if(TFmodify == 2)
					var/didchange = FALSE

					var/list/pred_hair_color = O.get_hair_color()
					var/list/prey_hair_color = P.get_hair_color()

					if(pred_hair_color[1] != prey_hair_color[1] || pred_hair_color[2] != prey_hair_color[2] || pred_hair_color[3] != prey_hair_color[3])
						P.change_hair_color(pred_hair_color[1], pred_hair_color[2], pred_hair_color[3])
						didchange = TRUE

					var/list/pred_facial_color = O.get_facial_hair_color()
					var/list/prey_facial_color = P.get_facial_hair_color()

					if(pred_facial_color[1] != prey_facial_color[1] || pred_facial_color[2] != prey_facial_color[2] || pred_facial_color[3] != prey_facial_color[3])
						P.change_facial_hair_color(pred_facial_color[1], pred_facial_color[2], pred_facial_color[3])
						didchange = TRUE

					if(O.s_tone != P.s_tone)
						P.change_skin_tone(O.s_tone)
						didchange = TRUE

					if(O.r_skin != P.r_skin || O.g_skin != P.g_skin || O.b_skin != P.b_skin)
						P.change_skin_color(O.r_skin, O.g_skin, O.b_skin)
						didchange = TRUE

					if(didchange)
						to_chat(P, "<span class='notice'>Your body tingles all over...</span>")
						to_chat(owner, "<span class='notice'>You tingle as you make noticeable changes to your captive's body.</span>")


			if(O.nutrition > 0)
				O.nutrition -= 2
			if(P.nutrition < 400)
				P.nutrition += 1
		return

///////////////////////////// DM_EGG /////////////////////////////
	if(digest_mode == DM_EGG && ishuman(owner))
		for (var/mob/living/carbon/human/P in internal_contents)
			if(P.stat)
				continue
			if(P.absorbed) //If they're absorbed, don't egg them
				return
			var/mob/living/carbon/human/O = owner

			to_chat(P, "<span class='notice'>You lose sensation of your body, feeling only the warmth around you as you're encased in an egg. </span>")
			to_chat(owner, "<span class='notice'>Your body shifts as you encase [P] in an egg.</span>")
			switch(O.egg_type_vr)
				if("Unathi")
					var/obj/structure/closet/secure_closet/egg/unathi/J = new /obj/structure/closet/secure_closet/egg/unathi(O.loc)
					P.forceMove(J)
					J.name = "Unathi egg"
					internal_contents -= P
				if("Tajaran")
					var/obj/structure/closet/secure_closet/egg/tajaran/J = new /obj/structure/closet/secure_closet/egg/tajaran(O.loc)
					P.forceMove(J)
					J.name = "Tajaran egg"
					internal_contents -= P
				if("Akula")
					var/obj/structure/closet/secure_closet/egg/shark/J = new /obj/structure/closet/secure_closet/egg/shark(O.loc)
					P.forceMove(J)
					J.name = "Akula egg"
					internal_contents -= P
				if("Skrell")
					var/obj/structure/closet/secure_closet/egg/skrell/J = new /obj/structure/closet/secure_closet/egg/skrell(O.loc)
					P.forceMove(J)
					J.name = "Skrell egg"
					internal_contents -= P
				if("Sergal")
					var/obj/structure/closet/secure_closet/egg/sergal/J = new /obj/structure/closet/secure_closet/egg/sergal(O.loc)
					P.forceMove(J)
					J.name = "Segal egg"
					internal_contents -= P
				if("Human")
					var/obj/structure/closet/secure_closet/egg/human/J = new /obj/structure/closet/secure_closet/egg/human(O.loc)
					P.forceMove(J)
					J.name = "Human egg"
					internal_contents -= P
				if("Slime")
					var/obj/structure/closet/secure_closet/egg/slime/J = new /obj/structure/closet/secure_closet/egg/slime(O.loc)
					P.forceMove(J)
					J.name = "Slime egg"
					internal_contents -= P
				if("Egg")
					var/obj/structure/closet/secure_closet/egg/J = new /obj/structure/closet/secure_closet/egg(O.loc)
					P.forceMove(J)
					J.name = "Egg"
					internal_contents -= P
				if("Xenochimera")
					var/obj/structure/closet/secure_closet/egg/scree/J = new /obj/structure/closet/secure_closet/egg/scree(O.loc)
					P.forceMove(J)
					J.name = "Xenochimera egg"
					internal_contents -= P
				if("Xenomorph")
					var/obj/structure/closet/secure_closet/egg/xenomorph/J = new /obj/structure/closet/secure_closet/egg/xenomorph(O.loc)
					P.forceMove(J)
					J.name = "Xenomorph egg"
					internal_contents -= P
				else
					var/obj/structure/closet/secure_closet/egg/J = new /obj/structure/closet/secure_closet/egg(O.loc)
					P.forceMove(J)
					J.name = "Odd egg" //Something went wrong. Since the default is "egg", they shouldn't see this.
					internal_contents -= P
