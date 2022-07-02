#define COMMANDOS_POSSIBLE 6 //if more Commandos are needed in the future
GLOBAL_VAR_INIT(sent_strike_team, 0)

/datum/ui_module/ds_manager
	name = "DS Manager"
	var/squad_slots = 6
	var/safety = TRUE
	var/mission = null //default mission

/datum/ui_module/ds_manager/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "DSManager", name, 460, 260, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/ds_manager/ui_data(mob/user)
	var/list/data = list()
	data["str_security_level"] = capitalize(get_security_level())
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			data["security_level_color"] = "green"
		if(SEC_LEVEL_BLUE)
			data["security_level_color"] = "blue"
		if(SEC_LEVEL_RED)
			data["security_level_color"] = "red"
		else
			data["security_level_color"] = "purple"
	data["squad"] = squad_slots
	data["spawnpoints"] = GLOB.emergencyresponseteamspawn.len
	data["safety"] = safety
	return data

/datum/ui_module/ds_manager/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	switch(action)
		if("set_squad")
			squad_slots = text2num(params["set_squad"])
		if("toggle_safety")
			safety = !(safety)
			if (safety == FALSE)
				message_admins("<span class='notice'>[key_name_admin(usr)] is preparing to send a Deathsquad.</span>", 1)
		if("dispatch_ds")
			safety = !(safety)
			var/slots_list = list()
			if(squad_slots > 0)
				slots_list += "squad: [squad_slots]"
			var/slot_text = english_list(slots_list)
			message_admins("[key_name_admin(usr)] is dispatching a Deathsquad. Slots: [slot_text]", 1)
			log_admin("[key_name(usr)] dispatched a Deathsquad. Slots: [slot_text]")
			trigger_deathsquad(ui.user, squad_slots, mission)
		else
			return FALSE

/datum/ui_module/ds_manager/proc/trigger_deathsquad(mob/user, squad_slots, mission)

	var/list/commando_ghosts = null
	if(alert("Do you want to send in the Deathsquad? Once enabled, this is irreversible.",,"Yes","No")!="Yes")
		message_admins("[key_name_admin(usr)] cancelled their Deathsquad.", 1)
		log_admin("[key_name(usr)] cancelled their Deathsquad.")
		return
	if(alert("This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned commandos have internals cameras which are viewable through a monitor inside the Spec. Ops. Office. The first one selected/spawned will be the team leader. Are you sure?",,"Yes","No")!="Yes")
		message_admins("[key_name_admin(usr)] cancelled their Deathsquad.", 1)
		log_admin("[key_name(usr)] cancelled their Deathsquad.")
		return
	mission = sanitize(copytext(input(user, "Please specify a mission the deathsquad shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
	if(!mission)
		if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
			message_admins("[key_name_admin(usr)] cancelled their Deathsquad.", 1)
			log_admin("[key_name(usr)] cancelled their Deathsquad.")
			return
	if(alert("Would you like to custom pick your Deathsquad?",,"Yes","No")=="Yes")		// Find ghosts willing to be DS
		var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_deathsquad")
		commando_ghosts = pollCandidatesWithVeto(user.client, user, COMMANDOS_POSSIBLE, "Join the DeathSquad?",, 21, 5 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE, source = source)
	else
		var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_deathsquad")
		commando_ghosts = shuffle(SSghost_spawns.poll_candidates("Join the Deathsquad?",, GLOB.responseteam_age, 5 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE, source = source))
	if(!length(commando_ghosts))
		message_admins("[key_name_admin(usr)] 's Deathsquad had no volunteers and was cancelled.", 1)
		log_admin("[key_name(usr)] 's Deathsquad had no volunteers and was cancelled.")
		to_chat(user, "<span class='userdanger'>Nobody volunteered to join the DeathSquad.</span>")
		return
	// Find the nuclear auth code
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in GLOB.machines)
		temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break

	/* GLOB.sent_strike_team = 1 */ // TODO: PUT THIS SOMEWHERE

	// Spawns commandos and equips them.
	var/commando_number = COMMANDOS_POSSIBLE //for selecting a leader
	var/is_leader = TRUE // set to FALSE after leader is spawned

	for(var/obj/effect/landmark/spawner/ds/L in GLOB.landmarks_list) // Maybe make obj/effect/landmark/spawner/ds and obj/effect/landmark/spawner/ert the same thing?
		if(!commando_number)
			break

		if(!length(commando_ghosts))
			break

		var/use_ds_borg = FALSE
		var/mob/ghost_mob = pick(commando_ghosts)
		commando_ghosts -= ghost_mob
		if(!ghost_mob || !ghost_mob.key || !ghost_mob.client)
			to_chat(user, "This ghost is no longer available for deathsquad! (Cloned, revived, closed the game, etc.)")
			return

		if(!is_leader)
			var/new_dstype = alert(ghost_mob.client, "Select Deathsquad Type.", "DS Character Generation", "Organic", "Cyborg")
			if(new_dstype == "Cyborg")
				use_ds_borg = TRUE

		if(!ghost_mob || !ghost_mob.key || !ghost_mob.client)
			to_chat(user, "This ghost is no longer available for deathsquad! (Cloned, revived, closed the game, etc.)")
			return

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
				R.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>[nuke_code].</span>")
			R.mind.store_memory("<B>Mission:</B> <span class='warning'>[mission].</span>")
			to_chat(R, "<span class='userdanger'>You are a Special Operations cyborg, in the service of Central Command. \nYour current mission is: <span class='danger'>[mission]</span></span>")
		else
			create_death_commando(L, is_leader, ghost_mob.key, nuke_code)

		is_leader = FALSE
		commando_number--

	//Spawns the rest of the commando gear.
	for(var/obj/effect/landmark/spawner/commando_manual/L in GLOB.landmarks_list) // todo: put this in the dsquad bag
		var/obj/item/paper/P = new(L.loc)
		P.info = "<p><b>Good morning soldier!</b>. This compact guide will familiarize you with standard operating procedure. There are three basic rules to follow:<br>#1 Work as a team.<br>#2 Accomplish your objective at all costs.<br>#3 Leave no witnesses.<br>You are fully equipped and stocked for your mission--before departing on the Spec. Ops. Shuttle due South, make sure that all operatives are ready. Actual mission objective will be relayed to you by Central Command through your headsets.<br>If deemed appropriate, Central Command will also allow members of your team to equip assault power-armor for the mission. You will find the armor storage due West of your position. Once you are ready to leave, utilize the Special Operations shuttle console and toggle the hull doors via the other console.</p><p>In the event that the team does not accomplish their assigned objective in a timely manner, or finds no other way to do so, attached below are instructions on how to operate a Nanotrasen Nuclear Device. Your operations <b>LEADER</b> is provided with a nuclear authentication disk and a pin-pointer for this reason. You may easily recognize them by their rank: Lieutenant, Captain, or Major. The nuclear device itself will be present somewhere on your destination.</p><p>Hello and thank you for choosing Nanotrasen for your nuclear information needs. Today's crash course will deal with the operation of a Fission Class Nanotrasen made Nuclear Device.<br>First and foremost, <b>DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.</b> Pressing any button on the compacted bomb will cause it to extend and bolt itself into place. If this is done to unbolt it one must completely log in which at this time may not be possible.<br>To make the device functional:<br>#1 Place bomb in designated detonation zone<br> #2 Extend and anchor bomb (attack with hand).<br>#3 Insert Nuclear Auth. Disk into slot.<br>#4 Type numeric code into keypad ([nuke_code]).<br>Note: If you make a mistake press R to reset the device.<br>#5 Press the E button to log onto the device.<br>You now have activated the device. To deactivate the buttons at anytime, for example when you have already prepped the bomb for detonation, remove the authentication disk OR press the R on the keypad. Now the bomb CAN ONLY be detonated using the timer. A manual detonation is not an option.<br>Note: Toggle off the <b>SAFETY</b>.<br>Use the - - and + + to set a detonation time between 5 seconds and 10 minutes. Then press the timer toggle button to start the countdown. Now remove the authentication disk so that the buttons deactivate.<br>Note: <b>THE BOMB IS STILL SET AND WILL DETONATE</b><br>Now before you remove the disk if you need to move the bomb you can: Toggle off the anchor, move it, and re-anchor.</p><p>The nuclear authorization code is: <b>[nuke_code ? nuke_code : "None provided"]</b></p><p><b>Good luck, soldier!</b></p>"
		P.name = "Spec. Ops Manual"
		P.icon = "paper_words"
		var/obj/item/stamp/centcom/stamp = new
		P.stamp(stamp)
		qdel(stamp)

	for(var/thing in GLOB.landmarks_list) //I'm not sure this is used anymore
		var/obj/effect/landmark/L = thing
		if(L.name == "Commando-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)
			qdel(L)

	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned a CentComm DeathSquad.</span>", 1)
	log_admin("[key_name(usr)] used Spawn Death Squad.")
	return 1

// MIND CODE - VERY WIP
/datum/ui_module/ds_manager/proc/create_death_commando(obj/spawn_location, is_leader = FALSE, mob/dskey, nuke_code)
	var/mob/living/carbon/human/M = new(spawn_location.loc)
	var/commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/commando_name = pick(GLOB.commando_names)

	var/datum/character_save/S = new //Randomize appearance for the commando.
	S.randomise()
	if(is_leader)
		S.age = rand(35, 45)
		S.real_name = "[commando_leader_rank] [commando_name]"
	else
		S.real_name = "[commando_name]"
	S.copy_to(M)


	M.dna.ready_dna(M)//Creates DNA.

	M.mind.key = dskey
	M.key = dskey
	M.internal = M.l_store
	M.update_action_buttons_icon()
	if(nuke_code)
		M.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>[nuke_code].</span>")
	M.mind.store_memory("<B>Mission:</B> <span class='warning'>[mission].</span>")
	to_chat(M, "<span class='userdanger'>You are a Deathsquad [is_leader ? "<B>TEAM LEADER</B>" : "commando"] in the service of Central Command. Check the table ahead for detailed instructions.\nYour current mission is: <span class='danger'>[mission]</span></span>")

	//Creates mind stuff.
	M.mind_initialize()
	M.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
	M.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
	SSticker.mode.traitors |= M.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	M.equip_death_commando(is_leader)
	return M

/*
	var/mob/living/carbon/human/M = new(spawn_location.loc)
	var/commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/commando_name = pick(GLOB.commando_names)

	var/obj/item/organ/external/head/head_organ = M.get_organ("head")

	if(prob(50))
		M.change_gender(MALE)
	else
		M.change_gender(FEMALE)

	M.set_species(/datum/species/human, TRUE)
	M.dna.ready_dna(M)
	M.cleanSE() //No fat/blind/colourblind/epileptic/whatever Deathsquad.
	M.overeatduration = 0

	var/hair_c = pick("#8B4513","#000000","#FF4500","#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000","#8B4513","1E90FF") // Black, brown, blue
	var/skin_tone = rand(20, 160) // A range of skin colors

	head_organ.facial_colour = hair_c
	head_organ.sec_facial_colour = hair_c
	head_organ.hair_colour = hair_c
	head_organ.sec_hair_colour = hair_c
	M.change_eye_color(eye_c)
	M.s_tone = skin_tone
	head_organ.h_style = random_hair_style(M.gender, head_organ.dna.species.name)
	head_organ.f_style = random_facial_hair_style(M.gender, head_organ.dna.species.name)

	if(is_leader)
		M.real_name = "[commando_leader_rank] [commando_name]"
	else
		M.real_name = "[commando_name]"

	M.name = M.real_name
	M.mind = M
	M.mind.current = M.key
	M.mind.set_original_mob(M)
	M.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
	M.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
	M.mind.offstation_role = TRUE
	if(!(M.mind in SSticker.minds))
		SSticker.minds += M.mind
	SSticker.mode.traitors += M.mind

	M.forceMove(spawn_location)

	return M */

/mob/living/carbon/human/proc/equip_death_commando(is_leader)
	if (is_leader)
		src.equipOutfit(/datum/outfit/admin/death_commando/leader)
	else
		src.equipOutfit(/datum/outfit/admin/death_commando)

	var/obj/item/card/id/W = new(src) // Make this use Deathsquad ID
	W.name = "[real_name]'s ID Card"
	W.icon_state = "deathsquad"
	W.assignment = "Death Commando"
	W.access = get_centcom_access(W.assignment)
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	var/obj/item/radio/R = new /obj/item/radio/headset/alt(src) //todo: make this use /obj/item/radio/headset/alt/deathsquad
	R.set_frequency(DTH_FREQ)
	R.requires_tcomms = FALSE
	R.instant = TRUE
	R.freqlock = TRUE
	equip_to_slot_or_del(R, slot_l_ear)

	return 1
