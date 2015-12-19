/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

/mob/living/captive_brain/say(var/message)

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if(istype(src.loc,/mob/living/simple_animal/borer))
		message = trim(sanitize(copytext(message, 1, MAX_MESSAGE_LEN)))
		if (!message)
			return
		log_say("[key_name(src)] : [message]")
		if (stat == 2)
			return say_dead(message)
		var/mob/living/simple_animal/borer/B = src.loc
		src << "You whisper silently, \"[message]\""
		B.host << "The captive mind of [src] whispers, \"[message]\""

		for(var/mob/M in mob_list)
			if(M.mind && (istype(M, /mob/dead/observer)))
				M << "<i>Thought-speech, <b>[src]</b> -> <b>[B.truename]:</b> [message]</i>"

/mob/living/captive_brain/emote(var/message)
	return

/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, quivering sluglike creature."
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes"
	response_disarm = "prods the"
	response_harm   = "stomps on the"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = I_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = 0
	small = 1
	density = 0
	pass_flags = PASSTABLE
	ventcrawler = 2

	var/used_dominate
	var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/docile = 0                          // Sugar can stop borers from acting.

/mob/living/simple_animal/borer/Life()

	..()

	if(host)

		if(!stat && host.stat != DEAD)

			if(host.reagents.has_reagent("sugar"))
				if(!docile)
					if(controlling)
						host << "\blue You feel the soporific flow of sugar in your host's blood, lulling you into docility."
					else
						src << "\blue You feel the soporific flow of sugar in your host's blood, lulling you into docility."
					docile = 1
			else
				if(docile)
					if(controlling)
						host << "\blue You shake off your lethargy as the sugar leaves your host's blood."
					else
						src << "\blue You shake off your lethargy as the sugar leaves your host's blood."
					docile = 0

			if(chemicals < 250)
				chemicals++
			if(controlling)

				if(docile)
					host << "\blue You are feeling far too docile to continue controlling your host..."
					host.release_control()
					return

				if(prob(5))
					host.adjustBrainLoss(rand(1,2))

				if(prob(host.getBrainLoss()/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")

/mob/living/simple_animal/borer/New(var/by_gamemode=0)
	..()
	add_language("Cortical Link")
	truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"

	if(!by_gamemode)
		request_player()

/mob/living/simple_animal/borer/Stat()
	..()
	statpanel("Status")

	if(shuttle_master.emergency.mode >= SHUTTLE_RECALL)
		var/timeleft = shuttle_master.emergency.timeLeft()
		if(timeleft > 0)
			stat(null, "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]")

	if (client.statpanel == "Status")
		stat("Chemicals", chemicals)

// VERBS!

/mob/living/simple_animal/borer/proc/borer_speak(var/message)
	if(!message)
		return

	for(var/mob/M in mob_list)
		if(M.mind && (istype(M, /mob/living/simple_animal/borer) || istype(M, /mob/dead/observer)))
			M << "<i>Cortical link, <b>[truename]:</b> [copytext(message, 2)]</i>"

/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Alien"
	set name = "Dominate Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 300)
		src << "You cannot use that ability again so soon."
		return

	if(host)
		src << "You cannot do that from within a host body."
		return

	if(src.stat)
		src << "You cannot do that in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(3,src))
		if(C.stat != DEAD)
			choices += C

	if(world.time - used_dominate < 300)
		src << "You cannot use that ability again so soon."
		return

	var/mob/living/carbon/M = input(src,"Who do you wish to dominate?") in null|choices

	if(!M || !src) return

	if(M.has_brain_worms())
		src << "You cannot infest someone who is already infested!"
		return

	src << "\red You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread."
	M << "\red You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing."
	M.Weaken(3)

	used_dominate = world.time

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Alien"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!host)
		src << "You are not inside a host body."
		return

	if(src.stat)
		src << "You cannot do that in your current state."
		return

	if(docile)
		src << "\blue You are feeling far too docile to do that."
		return

	src << "You begin delicately adjusting your connection to the host brain..."

	spawn(300+(host.getBrainLoss()*5))

		if(!host || !src || controlling)
			return
		else
			src << "\red <B>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</B>"
			host << "\red <B>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</B>"
			var/borer_key = src.key
			host.attack_log += text("\[[time_stamp()]\] <font color='blue'>[key_name(src)] has assumed control of [key_name(host)]</font>")
			msg_admin_attack("[key_name_admin(src)] has assumed control of [key_name_admin(host)]")
			// host -> brain
			var/h2b_id = host.computer_id
			var/h2b_ip= host.lastKnownIP
			host.computer_id = null
			host.lastKnownIP = null

			qdel(host_brain)
			host_brain = new(src)

			host_brain.ckey = host.ckey

			host_brain.name = host.name

			if(!host_brain.computer_id)
				host_brain.computer_id = h2b_id

			if(!host_brain.lastKnownIP)
				host_brain.lastKnownIP = h2b_ip

			// self -> host
			var/s2h_id = src.computer_id
			var/s2h_ip= src.lastKnownIP
			src.computer_id = null
			src.lastKnownIP = null

			host.ckey = src.ckey

			if(!host.computer_id)
				host.computer_id = s2h_id

			if(!host.lastKnownIP)
				host.lastKnownIP = s2h_ip

			controlling = 1

			host.verbs += /mob/living/carbon/proc/release_control
			host.verbs += /mob/living/carbon/proc/punish_host
			host.verbs += /mob/living/carbon/proc/spawn_larvae

			if(src && !src.key)
				src.key = "@[borer_key]"
			return

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals (30)"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		src << "You are not inside a host body."
		return

	if(stat)
		src << "You cannot secrete chemicals in your current state."

	if(docile)
		src << "\blue You are feeling far too docile to do that."
		return

	if(chemicals < 30)
		src << "You don't have enough chemicals!"

	var/chem = input("Select a chemical to secrete.", "Chemicals") as null|anything in list("mannitol","styptic_powder","methamphetamine","sal_acid")

	if(!chem || chemicals < 30 || !host || controlling || !src || stat) //Sanity check.
		return

	src << "\red <B>You squirt a measure of [chem] from your reservoirs into [host]'s bloodstream.</B>"
	host.reagents.add_reagent(chem, 9)
	chemicals -= 30

/mob/living/simple_animal/borer/verb/release_host()
	set category = "Alien"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!host)
		src << "You are not inside a host body."
		return

	if(stat)
		src << "You cannot leave your host in your current state."

	if(docile)
		src << "\blue You are feeling far too docile to do that."
		return

	if(!host || !src) return

	src << "You begin disconnecting from [host]'s synapses and prodding at their internal ear canal."

	spawn(200)

		if(!host || !src) return

		if(src.stat)
			src << "You cannot release a target in your current state."
			return

		src << "You wiggle out of [host]'s ear and plop to the ground."

		detatch()
		leave_host()

mob/living/simple_animal/borer/proc/detatch()

	if(!host) return

	if(istype(host,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/head = H.get_organ("head")
		head.implants -= src

	controlling = 0

	reset_view(null)
	machine = null

	host.verbs -= /mob/living/carbon/proc/release_control
	host.verbs -= /mob/living/carbon/proc/punish_host
	host.verbs -= /mob/living/carbon/proc/spawn_larvae


	if(host_brain)
		host.attack_log += text("\[[time_stamp()]\] <font color='blue'>[host_brain.name] ([host_brain.ckey]) has taken control back from [src.name] ([host.ckey])</font>")
		msg_admin_attack("[host_brain.name] ([host_brain.ckey]) has taken control back from [src.name] ([host.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[host.x];Y=[host.y];Z=[host.z]'>JMP</a>)")
		// host -> self
		var/h2s_id = host.computer_id
		var/h2s_ip= host.lastKnownIP
		host.computer_id = null
		host.lastKnownIP = null

		src.ckey = host.ckey

		if(!src.computer_id)
			src.computer_id = h2s_id

		if(!host_brain.lastKnownIP)
			src.lastKnownIP = h2s_ip

		// brain -> host
		var/b2h_id = host_brain.computer_id
		var/b2h_ip= host_brain.lastKnownIP
		host_brain.computer_id = null
		host_brain.lastKnownIP = null

		host.ckey = host_brain.ckey

		if(!host.computer_id)
			host.computer_id = b2h_id

		if(!host.lastKnownIP)
			host.lastKnownIP = b2h_ip

	qdel(host_brain)

	return

/mob/living/simple_animal/borer/proc/leave_host()

	if(!host)	return

	src.forceMove(get_turf(host))

	reset_view(null)
	machine = null

	host.reset_view(null)
	host.machine = null

	var/mob/living/H = host
	H.status_flags &= ~PASSEMOTES
	host = null
	return

/mob/living/simple_animal/borer/verb/infest()
	set category = "Alien"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		src << "You are already within a host."
		return

	if(stat)
		src << "You cannot infest a target in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(1,src))
		var/obj/item/organ/external/head/head = H.get_organ("head")
		if(head.status & ORGAN_ROBOT)
			continue
		if(H.stat != DEAD && src.Adjacent(H) && !H.has_brain_worms())
			choices += H

	var/mob/living/carbon/human/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src) return

	if(!(src.Adjacent(M))) return

	if(M.has_brain_worms())
		src << "You cannot infest someone who is already infested!"
		return

	src << "You slither up [M] and begin probing at their ear canal..."

	if(!do_after(src,50, target = M))
		src << "As [M] moves away, you are dislodged and fall to the ground."
		return

	if(!M || !src) return

	if(src.stat)
		src << "You cannot infest a target in your current state."
		return

	if(M.stat == 2)
		src << "That is not an appropriate target."
		return

	if(M in view(1, src))
		src << "You wiggle into [M]'s ear."
		if(!M.stat)
			M << "Something disgusting and slimy wiggles into your ear!"

		src.host = M
		src.forceMove(M)

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/head = H.get_organ("head")
			head.implants += src

		host.status_flags |= PASSEMOTES

		return
	else
		src << "They are no longer in range!"
		return

/mob/living/simple_animal/borer/proc/perform_infestation(var/mob/living/carbon/M)
	src.host = M
	src.forceMove(M)

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head = H.get_organ("head")
		head.implants += src

	host_brain.name = M.name
	host_brain.real_name = M.real_name
	host.status_flags |= PASSEMOTES

/mob/living/simple_animal/borer/can_use_vents()
	return

//Procs for grabbing players.
mob/living/simple_animal/borer/proc/request_player()
	for(var/mob/O in respawnable_list)
		if(jobban_isbanned(O, "Syndicate"))
			continue
		if(O.client)
			if(O.client.prefs.be_special & BE_ALIEN && !jobban_isbanned(O, "alien"))
				question(O.client)

mob/living/simple_animal/borer/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		var/response = alert(C, "A cortical borer needs a player. Are you interested?", "Cortical borer request", "Yes", "No", "Never for this round")
		if(!C || ckey)
			return
		if(response == "Yes")
			transfer_personality(C)
		else if (response == "Never for this round")
			C.prefs.be_special ^= BE_ALIEN

mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)

	if(!candidate)
		return

	src.mind = candidate.mob.mind
	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.assigned_role = "Cortical Borer"

/mob/living/simple_animal/borer/verb/borerhide()
	set category = "Alien"
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."

	if(stat != CONSCIOUS)
		return

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\green You are now hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("<B>[] scurries to the ground!</B>", src)
	else
		layer = MOB_LAYER
		src << text("\green You have stopped hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("[] slowly peaks up from the ground...", src)
