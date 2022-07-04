//Deathsquad

#define MAX_COMMANDOS 14

GLOBAL_VAR_INIT(deathsquad_sent, FALSE)

/client/proc/send_deathsquad()
	var/client/proccaller = usr.client
	if(!check_rights(R_EVENT))
		return
	if(SSticker.current_state == GAME_STATE_PREGAME)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return
	if(GLOB.deathsquad_sent)
		if(alert("A Deathsquad is already being sent, are you sure you want to send another?",, "Yes", "No") != "Yes")
			return
	else
		if(alert("Do you want to send in the Deathsquad? Once enabled, this is irreversible.",, "Yes", "No") != "Yes")
			return
	message_admins("<span class='notice'>[key_name_admin(proccaller)] has started to spawn a DeathSquad.</span>")
	log_admin("[key_name_admin(proccaller)] has started to spawn a DeathSquad.")
	alert("This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned commandos have internals cameras which are viewable through a monitor inside the Spec. Ops. Office. The first one selected/spawned will be the team leader.")

	var/mission
	mission = sanitize(copytext(input(src, "Please specify which mission the Deathsquad shall undertake.", "Specify Mission", "",), 1, MAX_MESSAGE_LEN))
	if(!mission)
		if(alert("Error, no mission set. Do you want to exit the setup process?",, "Yes", "No") == "Yes")
			message_admins("[key_name_admin(proccaller)] cancelled their Deathsquad.")
			log_admin("[key_name(proccaller)] cancelled their Deathsquad.")
			return

	var/commando_number
	var/is_leader = TRUE // set to FALSE after leader is spawned
	commando_number = clamp(input(src, "How many Deathsquad Commandos would you like to send? (Recommended is 6, Max is [MAX_COMMANDOS]])", "Specify Commandos") as num|null, 1, MAX_COMMANDOS)
	if(!commando_number)
		message_admins("[key_name_admin(proccaller)] cancelled their Deathsquad.")
		log_admin("[key_name(proccaller)] cancelled their Deathsquad.")
		return
	if(GLOB.deathsquad_sent)
		if(alert("A Deathsquad leader has previously been sent with an unrestricted NAD, would you like to spawn another?",, "Yes", "No") != "Yes")
			is_leader = FALSE
	GLOB.deathsquad_sent = TRUE
	message_admins("[key_name_admin(proccaller)] has sent a Deathsquad with [commando_number] commandos.")
	log_admin("[key_name(proccaller)] has sent a Deathsquad with [commando_number] commandos.")

	// Find the nuclear auth code
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in GLOB.machines)
		temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break

	// Find ghosts willing to be DS
	var/list/commando_ghosts = list()
	if(alert("Would you like to custom pick your Deathsquad?",, "Yes", "No") == "Yes")
		var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_deathsquad")
		commando_ghosts = pollCandidatesWithVeto(src, usr, commando_number, "Join the DeathSquad?",, 21, 60 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE, source = source)
	else
		var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_deathsquad")
		commando_ghosts = SSghost_spawns.poll_candidates("Join the Deathsquad?",, GLOB.responseteam_age, 60 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE, source = source)
		if(length(commando_ghosts) > commando_number)
			commando_ghosts.Cut(commando_number + 1) //cuts the ghost candidates down to the amount requested
	if(!length(commando_ghosts))
		message_admins("[key_name_admin(proccaller)]'s Deathsquad had no volunteers and was cancelled.")
		log_admin("[key_name(proccaller)]'s Deathsquad had no volunteers and was cancelled.")
		to_chat(src, "<span class='userdanger'>Nobody volunteered to join the DeathSquad.</span>")
		return

	// Spawns commandos and equips them.
	for(var/obj/effect/landmark/spawner/ds/L in GLOB.landmarks_list) //Despite obj/effect/landmark/spawner/ds being in the exact same location and doing the exact same thing as obj/effect/landmark/spawner/ert, switching them breaks it.
		if(!commando_number)
			break
		if(!length(commando_ghosts))
			break
		var/use_ds_borg = FALSE
		var/mob/ghost_mob = pick(commando_ghosts)
		commando_ghosts -= ghost_mob
		if(!ghost_mob || !ghost_mob.key || !ghost_mob.client)
			continue

		if(!is_leader)
			var/new_dstype = alert(ghost_mob.client, "Select Deathsquad Type.", "Deathsquad Character Generation", "Organic", "Cyborg")
			if(new_dstype == "Cyborg")
				use_ds_borg = TRUE

		if(!ghost_mob || !ghost_mob.key || !ghost_mob.client) // Have to re-check this due to the above alert() call
			continue

		if(use_ds_borg)
			var/mob/living/silicon/robot/deathsquad/R = new(get_turf(L))
			var/rnum = rand(1, 1000)
			var/borgname = "Epsilon [rnum]"
			R.name = borgname
			R.custom_name = borgname
			R.real_name = R.name
			R.mind = new
			R.mind.current = R
			R.mind.set_original_mob(R)
			R.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
			R.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
			R.mind.offstation_role = TRUE
			if(!(R.mind in SSticker.minds))
				SSticker.minds += R.mind
			SSticker.mode.traitors += R.mind
			R.key = ghost_mob.key
			if(nuke_code)
				R.mind.store_memory("<b>Nuke Code:</b> <span class='warning'>[nuke_code].</span>")
			R.mind.store_memory("<b>Mission:</b> <span class='warning'>[mission].</span>")
			to_chat(R, "<span class='userdanger'>You are a Deathsquad cyborg, in the service of Central Command. \nYour current mission is: <span class='danger'>[mission]</span></span>")
		else
			var/mob/living/carbon/human/new_commando = create_deathsquad_commando(L, is_leader)
			new_commando.mind.key = ghost_mob.key
			new_commando.key = ghost_mob.key
			new_commando.update_action_buttons_icon()
			if(nuke_code)
				new_commando.mind.store_memory("<b>Nuke Code:</b> <span class='warning'>[nuke_code].</span>")
			new_commando.mind.store_memory("<b>Mission:</b> <span class='warning'>[mission].</span>")
			to_chat(new_commando, "<span class='userdanger'>You are a Deathsquad [is_leader ? "<b>TEAM LEADER</b>" : "commando"] in the service of Central Command. Check the table ahead for detailed instructions.\nYour current mission is: <span class='danger'>[mission]</span></span>")

		is_leader = FALSE
		commando_number--

	//Spawns the rest of the commando gear.
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
	var/skin_tone = rand(40, 160) // A range of skin colors

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
	SSticker.mode.traitors |= new_commando.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	new_commando.equip_deathsquad_commando(is_leader)
	return new_commando

/mob/living/carbon/human/proc/equip_deathsquad_commando(is_leader = FALSE)
	if(is_leader)
		equipOutfit(/datum/outfit/admin/deathsquad_commando/leader)
	else
		equipOutfit(/datum/outfit/admin/deathsquad_commando)
