/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

/mob/living/captive_brain/say(message)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return

	if(istype(loc,/mob/living/simple_animal/borer))
		message = trim(sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN)))
		if(!message)
			return
		log_say(message, src)
		if(stat == DEAD)
			return say_dead(message)
		var/mob/living/simple_animal/borer/B = loc
		to_chat(src, "You whisper silently, \"[message]\"")
		to_chat(B.host, "<i><span class='alien'>The captive mind of [src] whispers, \"[message]\"</span></i>")

		for(var/mob/M in GLOB.mob_list)
			if(M.mind && isobserver(M))
				to_chat(M, "<i>Thought-speech, <b>[src]</b> -> <b>[B.truename]:</b> [message]</i>")

/mob/living/captive_brain/say_understands(var/mob/other, var/datum/language/speaking = null)
	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		log_runtime(EXCEPTION("Trapped mind found without a borer!"), src)
		return FALSE
	return B.host.say_understands(other, speaking)

/mob/living/captive_brain/emote(act, m_type = 1, message = null, force)
	return

/mob/living/captive_brain/resist()
	var/mob/living/simple_animal/borer/B = loc

	to_chat(src, "<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</span>")
	to_chat(B.host, "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>")

	var/delay = (rand(350,450) + B.host.getBrainLoss())
	addtimer(CALLBACK(src, .proc/return_control, B), delay)


/mob/living/captive_brain/proc/return_control(mob/living/simple_animal/borer/B)
	if(!B || !B.controlling)
		return

	B.host.adjustBrainLoss(rand(5,10))
	to_chat(src, "<span class='danger'>With an immense exertion of will, you regain control of your body!</span>")
	to_chat(B.host, "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>")

	B.detach()

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
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = 0
	mob_size = MOB_SIZE_TINY
	density = 0
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	faction = list("creature")
	ventcrawler = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	var/generation = 1
	var/static/list/borer_names = list(
			"Primary", "Secondary", "Tertiary", "Quaternary", "Quinary", "Senary",
			"Septenary", "Octonary", "Novenary", "Decenary", "Undenary", "Duodenary",
			)
	var/talk_inside_host = FALSE			// So that borers don't accidentally give themselves away on a botched message
	var/used_dominate
	var/attempting_to_dominate = FALSE		// To prevent people from spam opening the Dominate Victim input
	var/chemicals = 10						// Chemicals used for reproduction and chemical injection.
	var/max_chems = 250
	var/mob/living/carbon/human/host		// Human host for the brain worm.
	var/truename							// Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain	// Used for swapping control of the body back and forth.
	var/controlling							// Used in human death check.
	var/docile = FALSE						// Sugar can stop borers from acting.
	var/bonding = FALSE
	var/leaving = FALSE
	var/hiding = FALSE
	var/datum/action/innate/borer/talk_to_host/talk_to_host_action = new
	var/datum/action/innate/borer/infest_host/infest_host_action = new
	var/datum/action/innate/borer/toggle_hide/toggle_hide_action = new
	var/datum/action/innate/borer/talk_to_borer/talk_to_borer_action = new
	var/datum/action/innate/borer/talk_to_brain/talk_to_brain_action = new
	var/datum/action/innate/borer/take_control/take_control_action = new
	var/datum/action/innate/borer/give_back_control/give_back_control_action = new
	var/datum/action/innate/borer/leave_body/leave_body_action = new
	var/datum/action/innate/borer/make_chems/make_chems_action = new
	var/datum/action/innate/borer/make_larvae/make_larvae_action = new
	var/datum/action/innate/borer/freeze_victim/freeze_victim_action = new
	var/datum/action/innate/borer/torment/torment_action = new

/mob/living/simple_animal/borer/New(atom/newloc, var/gen=1)
	..(newloc)
	remove_from_all_data_huds()
	generation = gen
	add_language("Cortical Link")
	notify_ghosts("A cortical borer has been created in [get_area(src)]!", enter_link = "<a href=?src=[UID()];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)
	real_name = "Cortical Borer [rand(1000,9999)]"
	truename = "[borer_names[min(generation, borer_names.len)]] [rand(1000,9999)]"
	GrantBorerActions()

/mob/living/simple_animal/borer/attack_ghost(mob/user)
	if(cannotPossess(user))
		to_chat(user, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(jobban_isbanned(user, "Syndicate"))
		to_chat(user, "<span class='warning'>You are banned from antagonists!</span>")
		return
	if(key)
		return
	if(stat != CONSCIOUS)
		return
	var/be_borer = alert("Become a cortical borer? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_borer == "No" || !src || QDELETED(src))
		return
	if(key)
		return
	transfer_personality(user.client)

/mob/living/simple_animal/borer/Stat()
	..()
	statpanel("Status")

	show_stat_emergency_shuttle_eta()

	if(client.statpanel == "Status")
		stat("Chemicals", chemicals)

/mob/living/simple_animal/borer/say(var/message)
	var/list/message_pieces = parse_languages(message)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		if(!istype(S.speaking, /datum/language/corticalborer) && loc == host && !talk_inside_host)
			to_chat(src, "<span class='warning'>You've disabled audible speech while inside a host! Re-enable it under the borer tab, or stick to borer communications.</span>")
			return

	. = ..()

/mob/living/simple_animal/borer/verb/Communicate()
	set category = "Borer"
	set name = "Converse with Host"
	set desc = "Send a silent message to your host."

	if(!host)
		to_chat(src, "You do not have a host to communicate with!")
		return

	if(stat)
		to_chat(src, "You cannot do that in your current state.")
		return

	var/input = stripped_input(src, "Please enter a message to tell your host.", "Borer", "")
	if(!input)
		return

	if(src && !QDELETED(src) && !QDELETED(host))
		var/say_string = (docile) ? "slurs" :"states"
		if(host)
			to_chat(host, "<span class='changeling'><i>[truename] [say_string]:</i> [input]</span>")
			log_say("(BORER to [key_name(host)]) [input]", src)
			for(var/M in GLOB.dead_mob_list)
				if(isobserver(M))
					to_chat(M, "<span class='changeling'><i>Borer Communication from <b>[truename]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
		to_chat(src, "<span class='changeling'><i>[truename] [say_string]:</i> [input]</span>")
		host.verbs += /mob/living/proc/borer_comm
		talk_to_borer_action.Grant(host)

/mob/living/simple_animal/borer/verb/toggle_silence_inside_host()
	set name = "Toggle speech inside Host"
	set category = "Borer"
	set desc = "Toggle whether you will be able to say audible messages while inside your host."

	if(talk_inside_host)
		talk_inside_host = FALSE
		to_chat(src, "<span class='notice'>You will no longer talk audibly while inside a host.</span>")
	else
		talk_inside_host = TRUE
		to_chat(src, "<span class='notice'>You will now be able to audibly speak from inside of a host.</span>")

/mob/living/proc/borer_comm()
	set name = "Converse with Borer"
	set category = "Borer"
	set desc = "Communicate mentally with your borer."


	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B)
		return

	var/input = stripped_input(src, "Please enter a message to tell the borer.", "Message", "")
	if(!input)
		return

	to_chat(B, "<span class='changeling'><i>[src] says:</i> [input]</span>")
	log_say("(BORER to [key_name(B)]) [input]", src)

	for(var/M in GLOB.dead_mob_list)
		if(isobserver(M))
			to_chat(M, "<span class='changeling'><i>Borer Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[src] says:</i> [input]</span>")

/mob/living/proc/trapped_mind_comm()
	set name = "Converse with Trapped Mind"
	set category = "Borer"
	set desc = "Communicate mentally with the trapped mind of your host."


	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B || !B.host_brain)
		return
	var/mob/living/captive_brain/CB = B.host_brain
	var/input = stripped_input(src, "Please enter a message to tell the trapped mind.", "Message", "")
	if(!input)
		return

	to_chat(CB, "<span class='changeling'><i>[B.truename] says:</i> [input]</span>")
	log_say("(BORER to [key_name(CB)]) [input]", B)

	for(var/M in GLOB.dead_mob_list)
		if(isobserver(M))
			to_chat(M, "<span class='changeling'><i>Borer Communication from <b>[B]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[B.truename] says:</i> [input]</span>")

/mob/living/simple_animal/borer/Life(seconds, times_fired)

	..()

	if(host)

		if(!stat && host.stat != DEAD)

			if(host.reagents.has_reagent("sugar"))
				if(!docile)
					if(controlling)
						to_chat(host, "<span class='notice'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>")
					else
						to_chat(src, "<span class='notice'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>")
					docile = TRUE
			else
				if(docile)
					if(controlling)
						to_chat(host, "<span class='notice'>You shake off your lethargy as the sugar leaves your host's blood.</span>")
					else
						to_chat(src, "<span class='notice'>You shake off your lethargy as the sugar leaves your host's blood.</span>")
					docile = FALSE

			if(chemicals < max_chems)
				chemicals++
			if(controlling)

				if(docile)
					to_chat(host, "<span class='notice'>You are feeling far too docile to continue controlling your host...</span>")
					host.release_control()
					return

				if(prob(5))
					host.adjustBrainLoss(rand(1,2))

				if(prob(host.getBrainLoss()/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")

/mob/living/simple_animal/borer/handle_environment()
	if(host)
		return // Snuggled up, nice and warm, in someone's head
	else
		return ..()

/mob/living/simple_animal/borer/UnarmedAttack(mob/living/M)
	chemscan(usr, M)
	return

/mob/living/simple_animal/borer/verb/infest()
	set category = "Borer"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		to_chat(src, "You are already within a host.")
		return

	if(stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(1,src))
		var/obj/item/organ/external/head/head = H.get_organ("head")
		if(head.is_robotic())
			continue
		if(H.stat != DEAD && Adjacent(H) && !H.has_brain_worms())
			choices += H

	var/mob/living/carbon/human/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src)
		return

	if(!Adjacent(M))
		return

	if(M.has_brain_worms())
		to_chat(src, "You cannot infest someone who is already infested!")
		return

	if(incapacitated())
		return

	to_chat(src, "You slither up [M] and begin probing at [M.p_their()] ear canal...")

	if(!do_after(src, 50, target = M))
		to_chat(src, "As [M] moves away, you are dislodged and fall to the ground.")
		return

	if(!M || !src)
		return

	if(stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	if(M.stat == DEAD)
		to_chat(src, "That is not an appropriate target.")
		return

	if(M in view(1, src))
		to_chat(src, "You wiggle into [M]'s ear.")
		/*
		if(!M.stat)
			to_chat(M, "Something disgusting and slimy wiggles into your ear!")
		*/ // Let's see how stealthborers work out

		perform_infestation(M)

		return
	else
		to_chat(src, "They are no longer in range!")
		return

/mob/living/simple_animal/borer/proc/perform_infestation(mob/living/carbon/M)
	if(!M)
		return

	if(M.has_brain_worms())
		to_chat(src, "<span class='warning'>[M] is already infested!</span>")
		return

	host = M
	add_attack_logs(src, host, "Infested as borer")
	M.borer = src
	forceMove(M)

	host.status_flags |= PASSEMOTES

	RemoveBorerActions()
	GrantInfestActions()

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(stat)
		to_chat(src, "You cannot secrete chemicals in your current state.")

	if(docile)
		to_chat(src, "<font color='blue'> You are feeling far too docile to do that.</font>")
		return

	var/content = ""

	content += "<table>"

	for(var/datum in typesof(/datum/borer_chem))
		var/datum/borer_chem/C = datum
		var/cname = initial(C.chemname)
		var/datum/reagent/R = GLOB.chemical_reagents_list[cname]
		if(cname)
			content += "<tr><td><a class='chem-select' href='?_src_=[UID()];src=[UID()];borer_use_chem=[cname]'>[R.name] ([initial(C.chemuse)])</a><p>[initial(C.chemdesc)]</p></td></tr>"

	content += "</table>"

	var/html = get_html_template(content)

	usr << browse(null, "window=ViewBorer[UID()]Chems;size=585x400")
	usr << browse(html, "window=ViewBorer[UID()]Chems;size=585x400")

	return

/mob/living/simple_animal/borer/Topic(href, href_list, hsrc)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)
	if(href_list["borer_use_chem"])
		locate(href_list["src"])
		if(!istype(src, /mob/living/simple_animal/borer))
			return

		var/topic_chem = href_list["borer_use_chem"]
		var/datum/borer_chem/C = null

		for(var/datum in typesof(/datum/borer_chem))
			var/datum/borer_chem/test = datum
			if(initial(test.chemname) == topic_chem)
				C = new test()
				break

		if(!C || !host || controlling || !src || stat)
			return
		var/datum/reagent/R = GLOB.chemical_reagents_list[C.chemname]
		if(chemicals < C.chemuse)
			to_chat(src, "<span class='boldnotice'>You need [C.chemuse] chemicals stored to secrete [R.name]!</span>")
			return

		to_chat(src, "<span class='userdanger'>You squirt a measure of [R.name] from your reservoirs into [host]'s bloodstream.</span>")
		host.reagents.add_reagent(C.chemname, C.quantity)
		chemicals -= C.chemuse
		log_game("[key_name(src)] has injected [R.name] into their host [host]/([host.ckey])")

		// This is used because we use a static set of datums to determine what chems are available,
		// instead of a table or something. Thus, when we instance it, we can safely delete it
		qdel(C)
	..()

/mob/living/simple_animal/borer/verb/hide_borer()
	set category = "Borer"
	set name = "Hide"
	set desc = "Become invisible to the common eye."

	if(host)
		to_chat(usr, "<span class='warning'>You cannot do this while you're inside a host.</span>")
		return

	if(stat != CONSCIOUS)
		return

	if(!hiding)
		layer = TURF_LAYER+0.2
		to_chat(src, "<span class=notice'>You are now hiding.</span>")
		hiding = TRUE
	else
		layer = MOB_LAYER
		to_chat(src, "<span class=notice'>You stop hiding.</span>")
		hiding = FALSE

/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
	set name = "Dominate Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 150)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	if(host)
		to_chat(src, "You cannot do that from within a host body.")
		return

	if(stat)
		to_chat(src, "You cannot do that in your current state.")
		return

	if(attempting_to_dominate)
		to_chat(src, "You're already targeting someone!")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(3,src))
		if(C.stat != DEAD)
			choices += C

	if(world.time - used_dominate < 300)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	attempting_to_dominate = TRUE

	var/mob/living/carbon/M = input(src,"Who do you wish to dominate?") in null|choices

	if(!M)
		attempting_to_dominate = FALSE
		return

	if(!src) //different statement to avoid a runtime since if the source is deleted then attempting_to_dominate would also be deleted
		return

	if(M.has_brain_worms())
		to_chat(src, "You cannot dominate someone who is already infested!")
		attempting_to_dominate = FALSE
		return

	if(incapacitated())
		attempting_to_dominate = FALSE
		return

	if(get_dist(src, M) > 7) //to avoid people remotely doing from across the map etc, 7 is the default view range
		to_chat(src, "<span class='warning'>You're too far away!</span>")
		attempting_to_dominate = FALSE
		return

	to_chat(src, "<span class='warning'>You focus your psychic lance on [M] and freeze [M.p_their()] limbs with a wave of terrible dread.</span>")
	to_chat(M, "<span class='warning'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>")
	M.Weaken(3)

	used_dominate = world.time
	attempting_to_dominate = FALSE

/mob/living/simple_animal/borer/verb/release_host()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(stat)
		to_chat(src, "You cannot leave your host in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	if(!host || !src)
		return

	if(leaving)
		leaving = FALSE
		to_chat(src, "<span class='userdanger'>You decide against leaving your host.</span>")
		return

	to_chat(src, "You begin disconnecting from [host]'s synapses and prodding at [host.p_their()] internal ear canal.")

	leaving = TRUE

	addtimer(CALLBACK(src, .proc/let_go), 200)

/mob/living/simple_animal/borer/proc/let_go()

	if(!host || !src || QDELETED(host) || QDELETED(src))
		return
	if(!leaving)
		return
	if(controlling)
		return
	if(stat)
		to_chat(src, "You cannot release a target in your current state.")
		return

	to_chat(src, "You wiggle out of [host]'s ear and plop to the ground.")

	leaving = FALSE
	leave_host()

/mob/living/simple_animal/borer/proc/leave_host()

	if(!host)
		return
	if(controlling)
		detach()
	GrantBorerActions()
	RemoveInfestActions()
	forceMove(get_turf(host))
	machine = null

	host.reset_perspective(null)
	host.machine = null

	var/mob/living/carbon/H = host
	H.borer = null
	H.verbs -= /mob/living/proc/borer_comm
	talk_to_borer_action.Remove(host)
	H.status_flags &= ~PASSEMOTES
	host = null
	return

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(host.stat == DEAD)
		to_chat(src, "This host is in no condition to be controlled.")
		return

	if(stat)
		to_chat(src, "You cannot do that in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	if(bonding)
		bonding = FALSE
		to_chat(src, "<span class='userdanger'>You stop attempting to take control of your host.</span>")
		return

	to_chat(src, "You begin delicately adjusting your connection to the host brain...")

	if(QDELETED(src) || QDELETED(host))
		return

	bonding = TRUE

	var/delay = 300+(host.getBrainLoss()*5)
	addtimer(CALLBACK(src, .proc/assume_control), delay)

/mob/living/simple_animal/borer/proc/assume_control()
	if(!host || !src || controlling)
		return
	if(!bonding)
		return
	if(docile)
		to_chat(src,"<span class='warning'>You are feeling far too docile to do that.</span>")
		return
	else
		to_chat(src, "<span class='danger'>You plunge your probosci deep into the cortex of the host brain, interfacing directly with [host.p_their()] nervous system.</span>")
		to_chat(host, "<span class='danger'>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</span>")
		var/borer_key = src.key
		add_attack_logs(src, host, "Assumed control of (borer)")
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

		bonding = FALSE
		controlling = TRUE

		host.verbs += /mob/living/carbon/proc/release_control
		host.verbs += /mob/living/carbon/proc/punish_host
		host.verbs += /mob/living/carbon/proc/spawn_larvae
		host.verbs -= /mob/living/proc/borer_comm
		host.verbs += /mob/living/proc/trapped_mind_comm

		GrantControlActions()
		talk_to_borer_action.Remove(host)
		host.med_hud_set_status()

		if(src && !src.key)
			src.key = "@[borer_key]"
		return

/mob/living/carbon/proc/punish_host()
	set category = "Borer"
	set name = "Torment Host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain)
		to_chat(src, "<span class='danger'>You send a punishing spike of psychic agony lancing into your host's brain.</span>")
		to_chat(B.host_brain, "<span class='danger'><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></span>")

//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Borer"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(B && B.host_brain)
		to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain]</span>")

		B.detach()

	else
		log_runtime(EXCEPTION("Missing borer or missing host brain upon borer release."), src)

//Check for brain worms in head.
/mob/proc/has_brain_worms()
	return FALSE

/mob/living/carbon/has_brain_worms()

	if(borer)
		return borer

	return FALSE

/mob/living/carbon/proc/spawn_larvae()
	set category = "Borer"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.chemicals >= 100)
		to_chat(src, "<span class='danger'>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</span>")
		visible_message("<span class='danger'>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</span>")
		B.chemicals -= 100
		var/turf/T = get_turf(src)
		T.add_vomit_floor()
		new /mob/living/simple_animal/borer(T, B.generation + 1)

	else
		to_chat(src, "You need 100 chemicals to reproduce!")
		return

/mob/living/simple_animal/borer/proc/detach()

	if(!host || !controlling)
		return

	controlling = FALSE

	reset_perspective(null)
	machine = null

	host.verbs -= /mob/living/carbon/proc/release_control
	host.verbs -= /mob/living/carbon/proc/punish_host
	host.verbs -= /mob/living/carbon/proc/spawn_larvae
	host.verbs += /mob/living/proc/borer_comm
	host.verbs -= /mob/living/proc/trapped_mind_comm

	RemoveControlActions()
	talk_to_borer_action.Grant(host)
	host.med_hud_set_status()

	if(host_brain)
		add_attack_logs(host, src, "Took control back (borer)")
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

/mob/living/simple_animal/borer/can_use_vents()
	return

/mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)

	if(!candidate || !candidate.mob)
		return

	if(!QDELETED(candidate) || !QDELETED(candidate.mob))
		var/datum/mind/M = create_borer_mind(candidate.ckey)
		M.transfer_to(src)
		candidate.mob = src
		ckey = candidate.ckey
		to_chat(src, "<span class='notice'>You are a cortical borer!</span>")
		to_chat(src, "You are a brain slug that worms its way into the head of its victim. Use stealth, persuasion and your powers of mind control to keep you, your host and your eventual spawn safe and warm.")
		to_chat(src, "Sugar nullifies your abilities, avoid it at all costs!")
		to_chat(src, "You can speak to your fellow borers by prefixing your messages with ':bo'. Check out your Borer tab to see your abilities.")

/proc/create_borer_mind(key)
	var/datum/mind/M = new /datum/mind(key)
	M.assigned_role = "Cortical Borer"
	M.special_role = "Cortical Borer"
	return M

/mob/living/simple_animal/borer/proc/GrantBorerActions()
	infest_host_action.Grant(src)
	toggle_hide_action.Grant(src)
	freeze_victim_action.Grant(src)

/mob/living/simple_animal/borer/proc/RemoveBorerActions()
	infest_host_action.Remove(src)
	toggle_hide_action.Remove(src)
	freeze_victim_action.Remove(src)

/mob/living/simple_animal/borer/proc/GrantInfestActions()
	talk_to_host_action.Grant(src)
	leave_body_action.Grant(src)
	take_control_action.Grant(src)
	make_chems_action.Grant(src)

/mob/living/simple_animal/borer/proc/RemoveInfestActions()
	talk_to_host_action.Remove(src)
	take_control_action.Remove(src)
	leave_body_action.Remove(src)
	make_chems_action.Remove(src)

/mob/living/simple_animal/borer/proc/GrantControlActions()
	talk_to_brain_action.Grant(host)
	give_back_control_action.Grant(host)
	make_larvae_action.Grant(host)
	torment_action.Grant(host)

/mob/living/simple_animal/borer/proc/RemoveControlActions()
	talk_to_brain_action.Remove(host)
	make_larvae_action.Remove(host)
	give_back_control_action.Remove(host)
	torment_action.Remove(host)

/datum/action/innate/borer
	background_icon_state = "bg_alien"

/datum/action/innate/borer/talk_to_host
	name = "Converse with Host"
	desc = "Send a silent message to your host."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_host/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.Communicate()

/datum/action/innate/borer/infest_host
	name = "Infest"
	desc = "Infest a suitable humanoid host."
	button_icon_state = "infest"

/datum/action/innate/borer/infest_host/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.infest()

/datum/action/innate/borer/toggle_hide
	name = "Toggle Hide"
	desc = "Become invisible to the common eye. Toggled on or off."
	button_icon_state = "borer_hiding_false"

/datum/action/innate/borer/toggle_hide/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.hide_borer()
	button_icon_state = "borer_hiding_[B.hiding ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/borer/talk_to_borer
	name = "Converse with Borer"
	desc = "Communicate mentally with your borer."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_borer/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.borer_comm()

/datum/action/innate/borer/talk_to_brain
	name = "Converse with Trapped Mind"
	desc = "Communicate mentally with the trapped mind of your host."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_brain/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.trapped_mind_comm()

/datum/action/innate/borer/take_control
	name = "Assume Control"
	desc = "Fully connect to the brain of your host."
	button_icon_state = "borer_brain"

/datum/action/innate/borer/take_control/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.bond_brain()

/datum/action/innate/borer/give_back_control
	name = "Release Control"
	desc = "Release control of your host's body."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/give_back_control/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.release_control()

/datum/action/innate/borer/leave_body
	name = "Release Host"
	desc = "Slither out of your host."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/leave_body/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.release_host()

/datum/action/innate/borer/make_chems
	name = "Secrete Chemicals"
	desc = "Push some chemicals into your host's bloodstream."
	icon_icon = 'icons/obj/chemical.dmi'
	button_icon_state = "minidispenser"

/datum/action/innate/borer/make_chems/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.secrete_chemicals()

/datum/action/innate/borer/make_larvae
	name = "Reproduce"
	desc = "Spawn several young."
	button_icon_state = "borer_reproduce"

/datum/action/innate/borer/make_larvae/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.spawn_larvae()

/datum/action/innate/borer/freeze_victim
	name = "Dominate Victim"
	desc = "Freeze the limbs of a potential host with supernatural fear."
	button_icon_state = "genetic_cryo"

/datum/action/innate/borer/freeze_victim/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.dominate_victim()

/datum/action/innate/borer/torment
	name = "Torment Host"
	desc = "Punish your host with agony."
	button_icon_state = "blind"

/datum/action/innate/borer/torment/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.punish_host()
