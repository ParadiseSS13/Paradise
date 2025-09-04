//Deathsquad

GLOBAL_VAR_INIT(deathsquad_sent, FALSE)

/client/proc/send_deathsquad()
	var/client/proccaller = usr.client
	var/ai_laws_change = FALSE
	if(!check_rights(R_EVENT))
		return
	if(SSticker.current_state == GAME_STATE_PREGAME)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return
	if(GLOB.deathsquad_sent)
		if(alert("A Deathsquad is already being sent, are you sure you want to send another?", null, "Yes", "No") != "Yes")
			return
	else
		if(alert("Do you want to send in the Deathsquad? Once enabled, this is irreversible.", null, "Yes", "No") != "Yes")
			return
		if(alert("Do you want to set AI and cyborgs laws to Terminator?", null, "Yes", "No") != "No")
			ai_laws_change = TRUE

	message_admins("<span class='notice'>[key_name_admin(proccaller)] has started to spawn a DeathSquad.</span>")
	log_admin("[key_name_admin(proccaller)] has started to spawn a DeathSquad.")
	to_chat(proccaller, "<span class='boldwarning'>This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle or use the end round verb when appropriate. Spawned commandos have internals cameras which are viewable through a monitor inside the Spec. Ops. Office. The first one selected will be the team leader.</span>")

	var/mission = sanitize(copytext_char(input(src, "Please specify which mission the Deathsquad shall undertake.", "Specify Mission", "",), 1, MAX_MESSAGE_LEN))
	if(!mission)
		if(alert("Error, no mission set. Do you want to exit the setup process?", null, "Yes", "No") == "Yes")
			message_admins("[key_name_admin(proccaller)] cancelled their Deathsquad.")
			log_admin("[key_name(proccaller)] cancelled their Deathsquad.")
			return

	if(ai_laws_change)
		var/list/ais = active_ais()
		var/datum/ai_laws/death_squad_ai_law_set = new /datum/ai_laws/epsilon()
		var/notice_sound = sound('sound/AI/epsilon_laws.ogg')
		for(var/mob/living/silicon/ai/AI in ais)
			death_squad_ai_law_set.sync(AI, TRUE, FALSE) // Reset all laws exept zero
			to_chat(AI, "<span class='userdanger'>Central command has uploaded a new set of laws you must follow. Make sure you follow them.</span>")
			SEND_SOUND(AI, notice_sound)
			AI.show_laws()
			var/obj/item/radio/headset/heads/ai_integrated/ai_radio = AI.get_radio()
			ai_radio.channels |= list("Response Team" = 1, "Special Ops" = 1)
			ai_radio.config(ai_radio.channels)

			for(var/mob/living/silicon/robot/R in AI.connected_robots)
				R.sync()
				to_chat(R, "<span class='userdanger'>Central command has uploaded a new set of laws you must follow. Make sure you follow them.</span>")
				SEND_SOUND(R, notice_sound)
				R.show_laws()
				var/obj/item/radio/borg/cyborg_radio = R.get_radio()
				cyborg_radio.channels |= list("Response Team" = 1, "Special Ops" = 1)
				cyborg_radio.config(cyborg_radio.channels)

	// Locates commandos spawns
	var/list/commando_spawn_locations = list()
	for(var/obj/effect/landmark/spawner/ds/L in GLOB.landmarks_list) //Despite obj/effect/landmark/spawner/ds being in the exact same location and doing the exact same thing as obj/effect/landmark/spawner/ert, switching them breaks it?
		commando_spawn_locations += L

	var/max_commandos = length(commando_spawn_locations)

	var/commando_number = input(src, "How many Deathsquad Commandos would you like to send? (Recommended is 6, Max is [max_commandos])", "Specify Commandos") as num|null
	if(!commando_number)
		message_admins("[key_name_admin(proccaller)] cancelled their Deathsquad.")
		log_admin("[key_name(proccaller)] cancelled their Deathsquad.")
		return
	commando_number = clamp(commando_number, 1, max_commandos)

	var/is_leader = TRUE
	if(GLOB.deathsquad_sent)
		if(alert("A Deathsquad leader has previously been sent with an unrestricted NAD, would you like to spawn another unrestricted NAD?", null, "Yes", "No") != "Yes")
			is_leader = FALSE
	GLOB.deathsquad_sent = TRUE
	message_admins("[key_name_admin(proccaller)] has sent a Deathsquad with [commando_number] commandos.")
	log_admin("[key_name(proccaller)] has sent a Deathsquad with [commando_number] commandos.")

	// Find the nuclear auth code
	var/nuke_code
	var/new_nuke = FALSE
	for(var/obj/machinery/nuclearbomb/N in SSmachines.get_by_type(/obj/machinery/nuclearbomb))
		if(istype(N, /obj/machinery/nuclearbomb/syndicate) || !N.core)
			continue
		var/temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break
	if(!nuke_code)
		message_admins("No functional nuclear warheads have been detected, the Deathsquad will be issued a new warhead.")
		new_nuke = TRUE
		nuke_code = rand(10000, 99999)

	if(alert("Do you want a new nuclear warhead to be spawned with this team?", null, "Yes", "No") == "Yes")
		new_nuke = TRUE

	// Find ghosts willing to be Deathsquad
	var/list/commando_ghosts = list()
	if(alert("Would you like to custom pick your Deathsquad?", null, "Yes", "No") == "Yes")
		var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_deathsquad")
		commando_ghosts = pollCandidatesWithVeto(src, usr, commando_number, "Join the DeathSquad?", null, 21, 45 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE, source = source)
	else
		var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_deathsquad")
		commando_ghosts = SSghost_spawns.poll_candidates("Join the Deathsquad?", null, GLOB.responseteam_age, 45 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE, source = source)
		if(length(commando_ghosts) > commando_number)
			commando_ghosts.Cut(commando_number + 1) //cuts the ghost candidates down to the amount requested
	if(!length(commando_ghosts))
		message_admins("[key_name_admin(proccaller)]'s Deathsquad had no volunteers and was cancelled.")
		log_admin("[key_name(proccaller)]'s Deathsquad had no volunteers and was cancelled.")
		to_chat(src, "<span class='userdanger'>Nobody volunteered to join the DeathSquad.</span>")
		return

	// Spawns a nuclear warhead for the team
	if(new_nuke)
		for(var/obj/effect/landmark/spawner/nuclear_bomb/death_squad/nuke_spawn in GLOB.landmarks_list)
			var/obj/machinery/nuclearbomb/undeployed/the_bomb = new (get_turf(nuke_spawn))
			the_bomb.r_code = nuke_code

	// Equips the Deathsquad
	for(var/mob/ghost_mob in commando_ghosts)
		if(!ghost_mob || !ghost_mob.key || !ghost_mob.client)
			continue

		var/my_spawn_loc = pick_n_take(commando_spawn_locations)

		var/dstype
		if(is_leader)
			to_chat(ghost_mob.client, "<span class='boldwarning'>You have been chosen to lead the Deathsquad. Please stand by.</span>" )
		else
			dstype = input_async(ghost_mob, "Select Deathsquad Type (10 seconds):", list("Organic", "Cyborg"))
		addtimer(CALLBACK(src, PROC_REF(deathsquad_spawn), ghost_mob, is_leader, dstype, my_spawn_loc, nuke_code, mission), 10 SECONDS) // This may fail if the user switches mobs during it, this is because input_async is only for mobs not clients

		is_leader = FALSE

	//Spawns instruction manuals for DS
	for(var/obj/effect/landmark/spawner/commando_manual/L in GLOB.landmarks_list)
		var/obj/item/paper/P = new(L.loc)
		P.info = "<p><b>Good morning soldier!</b>. This compact guide will familiarize you with standard operating procedure. There are three basic rules to follow:<br>#1 Work as a team.<br>#2 Accomplish your objective at all costs.<br>#3 Leave no witnesses.<br><br> Your mission objective will be relayed to you by Central Command through your headsets or in person.<br>If deemed appropriate, Central Command will also allow members of your team to use mechs for the mission. You will find the mech storage due East of your position. </p><p>In the event that the team does not accomplish their assigned objective in a timely manner, or finds no other way to do so, attached below are instructions on how to operate a Nanotrasen Nuclear Device. Your operations <b>LEADER</b> is provided with a nuclear authentication disk, and all commandos have pinpointer for locating it. You may easily recognize them by their rank: <b>Lieutenant, Captain, or Major</b>. The nuclear device itself will be present somewhere on your destination.<hr></p><p>Hello and thank you for choosing Nanotrasen for your nuclear information needs. Today's crash course will deal with the operation of a Fission Class Nanotrasen made Nuclear Device.<br>First and foremost, <b>DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.</b> Pressing any button on the compacted bomb will cause it to extend and bolt itself into place. If this is done to unbolt it one must completely log in which at this time may not be possible.<br>To make the device functional:<br>#1 Place bomb in designated detonation zone<br> #2 Extend and anchor bomb (attack with hand).<br>#3 Insert Nuclear Auth. Disk into slot.<br>#4 Enter the nuclear authorization code: ([nuke_code]).<br>#5 Enter your desired time until activation.<br>#6 Disable the Safety.<br>#6 Arm the device.<br>You now have activated the device and it will begin counting down to detonation. Remove the Nuclear Authorization Disk and either head back to your shuttle or stay around until the Nuclear Device detonates, depending on your orders from Central Command.</p><p>The nuclear authorization code is: <b>[nuke_code ? nuke_code : "None provided"]</b></p><p><b>Good luck, soldier!</b></p>"
		P.name = "Special Operations Manual"
		P.update_icon()
		var/obj/item/stamp/centcom/stamp = new
		P.stamp(stamp)
		qdel(stamp)

	message_admins("<span class='notice'>[key_name_admin(proccaller)] has spawned a DeathSquad.</span>")
	log_admin("[key_name(proccaller)] used Spawn Death Squad.")
	return TRUE

/client/proc/deathsquad_spawn(mob/ghost_mob, is_leader = FALSE, datum/async_input/new_dstype_input, obj/L, nuke_code, mission)
	var/new_dstype
	if(new_dstype_input)
		new_dstype_input.close()
		new_dstype = new_dstype_input.result
	if(!new_dstype_input)  // didn't receive any response, or didn't ask them in the first place
		new_dstype = "Organic"

	if(!ghost_mob || !ghost_mob.key || !ghost_mob.client) // Doublechecking after async request
		return

	if(new_dstype == "Cyborg")
		var/mob/living/silicon/robot/deathsquad/R = new(get_turf(L))
		var/rnum = rand(1, 1000)
		var/borgname = "Epsilon [rnum]"
		R.name = borgname
		R.custom_name = borgname
		R.real_name = R.name
		R.mind = new
		R.mind.bind_to(R)
		R.mind.set_original_mob(R)
		R.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
		R.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
		R.mind.offstation_role = TRUE
		if(!(R.mind in SSticker.minds))
			SSticker.minds += R.mind
		SSticker.mode.traitors += R.mind
		R.key = ghost_mob.key
		dust_if_respawnable(ghost_mob)
		if(nuke_code)
			R.mind.store_memory("<b>Nuke Code:</b> <span class='warning'>[nuke_code].</span>")
		R.mind.store_memory("<b>Mission:</b> <span class='warning'>[mission].</span>")
		to_chat(R, "<span class='userdanger'>You are a Deathsquad cyborg, in the service of Central Command. \nYour current mission is: <span class='danger'>[mission]</span></span>")
	else
		var/mob/living/carbon/human/new_commando = create_deathsquad_commando(L, is_leader)
		new_commando.mind.key = ghost_mob.key
		new_commando.key = ghost_mob.key
		dust_if_respawnable(ghost_mob)
		new_commando.update_action_buttons_icon()
		if(nuke_code)
			new_commando.mind.store_memory("<b>Nuke Code:</b> <span class='warning'>[nuke_code].</span>")
		new_commando.mind.store_memory("<b>Mission:</b> <span class='warning'>[mission].</span>")
		to_chat(new_commando, "<span class='userdanger'>You are a Deathsquad [is_leader ? "<b>TEAM LEADER</b>" : "commando"] in the service of Central Command. Check the table ahead for detailed instructions.\nYour current mission is: <span class='danger'>[mission]</span></span>")

/client/proc/create_deathsquad_commando(obj/spawn_location, is_leader = FALSE)
	var/mob/living/carbon/human/new_commando = new(spawn_location.loc)
	var/commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/commando_name = pick(GLOB.deathsquad_names)
	var/obj/item/organ/external/head/head_organ = new_commando.get_organ("head") // This appearance code is brought to you by ert.dm, basically the same code. If you change something here change somethere there too.

	if(is_leader)
		new_commando.age = rand(35, 45)
		new_commando.real_name = "[commando_leader_rank] [commando_name]"
	else
		new_commando.real_name = "[commando_name]"

	if(prob(50))
		new_commando.change_gender(MALE)
	else
		new_commando.change_gender(FEMALE)

	// All of this code down here too is also from ert.dm, I'm lazy don't blame me
	new_commando.set_species(/datum/species/human, TRUE)
	new_commando.dna.ready_dna(new_commando)
	new_commando.cleanSE() //No fat/blind/colourblind/epileptic/whatever Deathsquad.
	new_commando.overeatduration = 0

	var/hair_c = pick("#8B4513","#000000","#FF4500","#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000","#8B4513","1E90FF") // Black, brown, blue
	var/skin_tone = rand(-120, 20) // A range of skin colors (This doesn't work, result is always pale white)

	head_organ.facial_colour = hair_c
	head_organ.sec_facial_colour = hair_c
	head_organ.hair_colour = hair_c
	head_organ.sec_hair_colour = hair_c
	new_commando.change_eye_color(eye_c)
	new_commando.s_tone = skin_tone
	head_organ.h_style = random_hair_style(new_commando.gender, head_organ.dna.species.name)
	head_organ.f_style = random_facial_hair_style(new_commando.gender, head_organ.dna.species.name)

	new_commando.regenerate_icons()
	new_commando.update_body()
	new_commando.update_dna()

	//Creates mind stuff.
	new_commando.mind_initialize()
	new_commando.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
	new_commando.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
	new_commando.mind.offstation_role = TRUE
	SSticker.mode.traitors |= new_commando.mind //Adds them to current traitor list. Which is really the extra antagonist list.
	new_commando.equip_deathsquad_commando(is_leader)
	return new_commando

/mob/living/carbon/human/proc/equip_deathsquad_commando(is_leader = FALSE)
	if(is_leader)
		equipOutfit(/datum/outfit/admin/deathsquad_commando/leader)
	else
		equipOutfit(/datum/outfit/admin/deathsquad_commando)
