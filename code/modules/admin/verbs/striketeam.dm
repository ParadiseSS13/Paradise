//Deathsquad

#define COMMANDOS_POSSIBLE 6 //if more Commandos are needed in the future
GLOBAL_VAR_INIT(sent_strike_team, 0)

/client/proc/deathsquad_spawn()
	set name = "Dispatch Deathsquad"
	set category = "Event"
	set desc = "Send in Special Operations to the clean up the station."

	if(!check_rights(R_EVENT))
		return

	if(!SSticker)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(SSticker.current_state == GAME_STATE_PREGAME)
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return

	var/datum/ui_module/ds_manager/E = new()
	E.ui_interact(usr)

	/* if(GLOB.sent_strike_team == 1)
		to_chat(usr, "<span class='userdanger'>CentComm is already sending a team.</span>")
		return */

	if(GLOB.sent_strike_team == 1)
		if(alert("Someone is already sending a deathsquad, are you sure you want to send another?",,"Yes","No")!="Yes") //todo: use this var properly
			alert("coder hasnt coded this yet, yell at them")
		return

/proc/trigger_deathsquad(leader_slot, squad_slots, mission, commando_ghosts)

	// Find the nuclear auth code
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in GLOB.machines)
		temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break

	// GLOB.sent_strike_team = 1

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
		if(!(!ghost_mob || !ghost_mob.key || !ghost_mob.client))
			to_chat("This ghost is no longer available for deathsquad! (Cloned, revived, closed the game, etc.)")

		if(!is_leader)
			var/new_dstype = alert(ghost_mob.client, "Select Deathsquad Type.", "DS Character Generation", "Organic", "Cyborg")
			if(new_dstype == "Cyborg")
				use_ds_borg = TRUE

		if(!(!ghost_mob || !ghost_mob.key || !ghost_mob.client)) // Have to re-check this due to the above alert() call
			to_chat("This ghost is no longer available for deathsquad! (Cloned, revived, closed the game, etc.)")

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
			var/mob/living/carbon/human/M = create_death_commando(L, is_leader)
			M.mind.key = ghost_mob.key
			M.key = ghost_mob.key
			M.internal = M.s_store
			M.update_action_buttons_icon()
			if(nuke_code)
				M.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>[nuke_code].</span>")
			M.mind.store_memory("<B>Mission:</B> <span class='warning'>[mission].</span>")
			to_chat(M, "<span class='userdanger'>You are a Deathsquad [is_leader ? "<B>TEAM LEADER</B>" : "commando"] in the service of Central Command. Check the table ahead for detailed instructions.\nYour current mission is: <span class='danger'>[mission]</span></span>")

		is_leader = FALSE
		commando_number--

	//Spawns the rest of the commando gear.
	for(var/obj/effect/landmark/spawner/commando_manual/L in GLOB.landmarks_list)
		//new /obj/item/gun/energy/pulse_rifle(L.loc)
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

/client/proc/create_death_commando(obj/spawn_location, is_leader = FALSE)
	var/mob/living/carbon/human/M = new(spawn_location.loc)
	var/commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/commando_name = pick(GLOB.commando_names)

	var/obj/item/organ/external/head/head_organ = M.get_organ("head")

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

	//Creates mind stuff.
	M.mind_initialize()
	M.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
	M.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
	M.mind.offstation_role = TRUE
	SSticker.mode.traitors |= M.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	M.equip_death_commando(is_leader)

	M.forceMove(spawn_location)

	return M

/mob/living/carbon/human/proc/equip_death_commando()
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
