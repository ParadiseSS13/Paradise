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
		if (stat == DEAD)
			return say_dead(message)
		var/mob/living/simple_animal/borer/B = src.loc
		src << "You whisper silently, \"[message]\""
		B.host << "The captive mind of [src] whispers, \"[message]\""

		for(var/mob/M in mob_list)
			if(M.mind && (istype(M, /mob/dead/observer)))
				M << "<i>Thought-speech, <b>[src]</b> -> <b>[B.truename]:</b> [message]</i>"

/mob/living/captive_brain/say_understands(var/mob/other, var/datum/language/speaking = null)
	var/mob/living/simple_animal/borer/B = src.loc
	if(!istype(B))
		log_to_dd("Trapped mind found without a borer!")
		return 0
	return B.host.say_understands(other, speaking)

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

	var/talk_inside_host = 0 				// So that borers don't accidentally give themselves away on a botched message
	var/used_dominate
	var/chemicals = 10                      // Chemicals used for reproduction and chemical injection.
	var/max_chems = 250						// How many chemicals that can be stored in total
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/docile = 0                          // Sugar can stop borers from acting.
	var/list/borer_injection_chems = list("mannitol","salglu_solution","methamphetamine", "hydrocodone", "spaceacillin", "mitocholide", "charcoal", "salbutamol", "capulettium_plus")

	var/injection_amount = 9
	var/chem_cost = 30
	var/static/obj/item/device/healthanalyzer/healthchecker = null

/mob/living/simple_animal/borer/proc/Communicate()
	set category = "Borer"
	set name = "Converse with Host"
	set desc = "Send a silent message to your host."
	if(!host)
		src << "You do not have a host to communicate with!"
		return

	var/input = stripped_input(src, "Please enter a message to tell your host.", "Borer", "")
	if(!input) return


	var/say_string = (docile) ? "slurs" :"states"
	if(host)
		host << "<span class='changeling'><i>[src.truename] [say_string]:</i> [input]</span>"
		log_say("Borer Communication: [key_name(src)] -> [key_name(host)] : [input]")
		for(var/M in dead_mob_list)
			if(istype(M, /mob/dead/observer))
				M << "<span class='changeling'><i>Borer Communication from <b>[src.truename]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>"
	src << "<span class='changeling'><i>[src.truename] [say_string]:</i> [input]</span>"
	host.verbs += /mob/living/proc/borer_comm

/*
/mob/living/simple_animal/borer/verb/toggle_silence_inside_host()
	set category = "Borer"
	set name = "Toggle speech inside Host"
	set desc = "Toggle whether you will be able to say audible messages while inside your host."

	if(talk_inside_host)
		talk_inside_host = 0
		src << "<span class='notice'>You will no longer talk audibly while inside a host.</span>"
	else
		talk_inside_host = 1
		src << "<span class='notice'>You will now be able to audibly speak from inside of a host.</span>"
*/
/mob/living/proc/borer_comm()
	set name = "Converse with Borer"
	set category = "Borer"
	set desc = "Communicate mentally with your borer."


	var/mob/living/simple_animal/borer/B = src.has_brain_worms()
	if(!B)
		return

	var/input = stripped_input(src, "Please enter a message to tell the borer.", "Message", "")
	if(!input) return

	B << "<span class='changeling'><i>[src] says:</i> [input]</span>"
	log_say("Borer Communication: [key_name(src)] -> [key_name(B)] : [input]")

	for(var/M in dead_mob_list)
		if(istype(M, /mob/dead/observer))
			M << "<span class='changeling'><i>Borer Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>"
	src << "<span class='changeling'><i>[src] says:</i> [input]</span>"

/mob/living/proc/trapped_mind_comm()
	set name = "Converse with Trapped Mind"
	set category = "Borer"
	set desc = "Communicate mentally with the trapped mind of your host."


	var/mob/living/simple_animal/borer/B = src.has_brain_worms()
	if(!B || !B.host_brain)
		return
	var/mob/living/captive_brain/CB = B.host_brain
	var/input = stripped_input(src, "Please enter a message to tell the trapped mind.", "Message", "")
	if(!input) return

	CB << "<span class='changeling'><i>[B.truename] says:</i> [input]</span>"
	log_say("Borer Communication: [key_name(B)] -> [key_name(CB)] : [input]")

	for(var/M in dead_mob_list)
		if(istype(M, /mob/dead/observer))
			M << "<span class='changeling'><i>Borer Communication from <b>[B]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>"
	src << "<span class='changeling'><i>[B.truename] says:</i> [input]</span>"

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

			if(chemicals < max_chems)
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
	if(!healthchecker)
		healthchecker = new /obj/item/device/healthanalyzer(null)
		healthchecker.upgraded = 1
	add_language("Cortical Link")
	updatename()

	if(!by_gamemode)
		request_player()

/mob/living/simple_animal/borer/proc/updatename()
	var/index_num = rand(1000,9999)
	real_name = "Cortical Borer ([index_num])"
	truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [index_num]"

/mob/living/simple_animal/borer/Stat()
	..()
	statpanel("Status")

	show_stat_emergency_shuttle_eta()

	if (client.statpanel == "Status")
		stat("Chemicals", chemicals)
		if(host)
			stat(null, "Host's Health: [host.health]")

// BORER VERBS! (Or verb-like procs!)
/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
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

/mob/living/simple_animal/borer/proc/bond_brain()
	set category = "Borer"
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
		assume_direct_control()

/mob/living/simple_animal/borer/proc/secrete_chemicals()
	set category = "Borer"
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

	if(chemicals < chem_cost)
		src << "You don't have enough chemicals!"
		return

	var/list/nice_name_chem_list = list()
	for(var/rgnt in borer_injection_chems)
		var/datum/reagent/R2 = chemical_reagents_list[rgnt]
		nice_name_chem_list[R2.name] = rgnt
	var/chem_name = input("Select a chemical to secrete.", "Chemicals") as null|anything in nice_name_chem_list
	var/chem = nice_name_chem_list[chem_name]
	inject_chem(chem)


/mob/living/simple_animal/borer/proc/release_host()
	set category = "Borer"
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


/mob/living/simple_animal/borer/verb/infest()
	set category = "Borer"
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

	if(M.stat == DEAD)
		src << "That is not an appropriate target."
		return

	if(M in view(1, src))
		src << "You wiggle into [M]'s ear."
		/*
		if(!M.stat)
			M << "Something disgusting and slimy wiggles into your ear!"
		*/ // Let's see how stealthborers work out

		perform_infestation(M)

		return
	else
		src << "They are no longer in range!"
		return

/mob/living/simple_animal/borer/proc/check_host_health()
	set category = "Borer"
	set name = "Analyze Host Health (5)"
	set desc = "Display a detailed health report of your host's body"

	scan_host()

// HUMANOID VERBS!

/mob/living/carbon/proc/spawn_larvae()
	set category = "Borer"
	set name = "Reproduce (100)"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.chemicals >= 100)
		src << "\red <B>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</B>"
		visible_message("\red <B>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</B>")
		B.chemicals -= 100

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		new /mob/living/simple_animal/borer(get_turf(src))

	else
		src << "You do not have enough chemicals stored to reproduce."
		return


//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Borer"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		src << "\red <B>You send a punishing spike of psychic agony lancing into your host's brain.</B>"
		B.host_brain << "\red <B><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></B>"


//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Borer"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(B && B.host_brain)
		src << "\red <B>You withdraw your probosci, releasing control of [B.host_brain]</B>"

		B.detatch()

	else
		src << "\red <B>ERROR NO BORER OR BRAINMOB DETECTED IN THIS MOB, THIS IS A BUG !</B>"

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			return I

	return 0


// PROCS!

/mob/living/simple_animal/borer/proc/scan_host()
	if(!host)
		return
	healthchecker.attack(host, src)

/mob/living/simple_animal/borer/proc/inject_chem(var/chem)


	var/chem_amount = host.reagents.get_reagent_amount(chem)
	if(!chem || chemicals < chem_cost || !host || controlling || !src || stat == DEAD) //Sanity check.
		return
	var/datum/reagent/R = chemical_reagents_list[chem]
	if(R.overdose_threshold && chem_amount + injection_amount > R.overdose_threshold)
		src << "<span class='warning'>Doing so would cause grievous harm to your host, reducing ability to reproduce. Aborting.</span>"
		return

	src << "<span class='notice'>You squirt a measure of [R.name] from your reservoirs into [host]'s bloodstream.</span>"
	host.reagents.add_reagent(chem, injection_amount)
	chemicals -= chem_cost

/mob/living/simple_animal/borer/proc/borer_speak(var/message)
	if(!message)
		return

	for(var/mob/M in mob_list)
		if(M.mind && (istype(M, /mob/living/simple_animal/borer) || istype(M, /mob/dead/observer)))
			M << "<i>Cortical link, <b>[truename]:</b> [copytext(message, 2)]</i>"

/mob/living/simple_animal/borer/proc/assume_direct_control()

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
		host.verbs -= /mob/living/proc/borer_comm
		host.verbs += /mob/living/proc/trapped_mind_comm

		if(src && !src.key)
			src.key = "@[borer_key]"
		return

/mob/living/simple_animal/borer/proc/detatch()

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
	host.verbs += /mob/living/proc/borer_comm
	host.verbs -= /mob/living/proc/trapped_mind_comm


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

	verbs -= /mob/living/simple_animal/borer/proc/release_host
	verbs -= /mob/living/simple_animal/borer/proc/Communicate
	verbs -= /mob/living/simple_animal/borer/proc/secrete_chemicals
	verbs -= /mob/living/simple_animal/borer/proc/check_host_health
	verbs -= /mob/living/simple_animal/borer/proc/bond_brain

	verbs += /mob/living/simple_animal/borer/verb/dominate_victim
	verbs += /mob/living/simple_animal/borer/verb/infest

	var/mob/living/H = host
	H.verbs -= /mob/living/proc/borer_comm
	H.status_flags &= ~PASSEMOTES
	host = null
	return


/mob/living/simple_animal/borer/proc/perform_infestation(var/mob/living/carbon/M)
	src.host = M
	src.forceMove(M)

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head = H.get_organ("head")
		head.implants += src

	world << "Swapping around verbs!"
	verbs -= /mob/living/simple_animal/borer/verb/dominate_victim
	verbs -= /mob/living/simple_animal/borer/verb/infest

	verbs += /mob/living/simple_animal/borer/proc/release_host
	verbs += /mob/living/simple_animal/borer/proc/Communicate
	verbs += /mob/living/simple_animal/borer/proc/secrete_chemicals
	verbs += /mob/living/simple_animal/borer/proc/check_host_health
	verbs += /mob/living/simple_animal/borer/proc/bond_brain

	host.status_flags |= PASSEMOTES

/mob/living/simple_animal/borer/can_use_vents()
	return

//Procs for grabbing players.
/mob/living/simple_animal/borer/proc/request_player()
	notify_ghosts("A mindless borer has been created in [get_area(src)]! <a href=?src=\ref[src];ghostjoin=1>(Click to enter)</a>")

/mob/living/simple_animal/borer/attack_ghost(mob/user as mob)
	if(key || stat == DEAD)
		return
	var/be_borer = alert("Become a borer? (This will sever all ties with your old body)", , "Yes", "No")
	if(be_borer == "No")
		return
	if(key)
		user << "The borer already has someone in control of it."
		return
	transfer_personality(user.client)

/mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)

	if(!candidate || key)
		return

	src.key = candidate.key
	if(src.mind)
		src.mind.assigned_role = "Cortical Borer"

/mob/living/simple_animal/borer/Topic(href, href_list)
	world << "Borer's topic was called"
	if(..())
		world << "Some other topic was chosen"
		return 1
	if(href_list["ghostjoin"])
		world << "Ghost join reached"
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/mob/living/simple_animal/borer/verb/borerhide()
	set category = "Borer"
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."

	if(stat != CONSCIOUS)
		return

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << "\green You are now hiding."
	else
		layer = MOB_LAYER
		src << "\green You have stopped hiding."

/mob/living/simple_animal/borer/say(var/message)
	var/datum/language/dialect = parse_language(message)
	if(!dialect)
		dialect = get_default_language()
	if(!istype(dialect, /datum/language/corticalborer) && loc == host && !talk_inside_host)
		src << "<span class='warning'>You've disabled audible speech while inside a host! Re-enable it under the borer tab, or stick to borer communications.</span>"
		return
	..()
