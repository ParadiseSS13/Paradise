//STRIKE TEAMS

var/const/commandos_possible = 6 //if more Commandos are needed in the future
var/global/sent_strike_team = 0

/client/proc/strike_team()
	if(!SSticker)
		to_chat(usr, "<span class='userdanger'>The game hasn't started yet!</span>")
		return
	if(sent_strike_team == 1)
		to_chat(usr, "<span class='userdanger'>CentComm is already sending a team.</span>")
		return
	if(alert("Do you want to send in the CentComm death squad? Once enabled, this is irreversible.",,"Yes","No")!="Yes")
		return
	alert("This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned commandos have internals cameras which are viewable through a monitor inside the Spec. Ops. Office. The first one selected/spawned will be the team leader.")

	message_admins("<span class='notice'>[key_name_admin(usr)] has started to spawn a CentComm DeathSquad.</span>", 1)

	var/input = null
	while(!input)
		input = sanitize(copytext(input(src, "Please specify which mission the death commando squad shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
		if(!input)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	if(sent_strike_team)
		to_chat(usr, "Looks like someone beat you to it.")
		return

	// Find the nuclear auth code
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in world)
		temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break

	// Find ghosts willing to be DS
	var/list/commando_ghosts = pollCandidatesWithVeto(src, usr, commandos_possible, "Join the DeathSquad?",, 21, 600, 1, role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE)
	if(!commando_ghosts.len)
		to_chat(usr, "<span class='userdanger'>Nobody volunteered to join the DeathSquad.</span>")
		return

	sent_strike_team = 1

	// Spawns commandos and equips them.
	var/commando_number = commandos_possible //for selecting a leader
	var/is_leader = TRUE // set to FALSE after leader is spawned

	for(var/obj/effect/landmark/L in GLOB.landmarks_list)

		if(commando_number <= 0)
			break

		if(L.name == "Commando")

			if(!commando_ghosts.len)
				break

			var/use_ds_borg = FALSE
			var/mob/ghost_mob = pick(commando_ghosts)
			commando_ghosts -= ghost_mob
			if(!ghost_mob || !ghost_mob.key || !ghost_mob.client)
				continue

			if(!is_leader)
				var/new_dstype = alert(ghost_mob.client, "Select Deathsquad Type.", "DS Character Generation", "Organic", "Cyborg")
				if(new_dstype == "Cyborg")
					use_ds_borg = TRUE

			if(!ghost_mob || !ghost_mob.key || !ghost_mob.client) // Have to re-check this due to the above alert() call
				continue

			if(use_ds_borg)
				var/mob/living/silicon/robot/deathsquad/R = new()
				R.forceMove(get_turf(L))
				var/rnum = rand(1,1000)
				var/borgname = "Epsilon [rnum]"
				R.name = borgname
				R.custom_name = borgname
				R.real_name = R.name
				R.mind = new
				R.mind.current = R
				R.mind.original = R
				R.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
				R.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
				R.mind.offstation_role = TRUE
				if(!(R.mind in SSticker.minds))
					SSticker.minds += R.mind
				SSticker.mode.traitors += R.mind
				R.key = ghost_mob.key
				if(nuke_code)
					R.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>[nuke_code].</span>")
				R.mind.store_memory("<B>Mission:</B> <span class='warning'>[input].</span>")
				to_chat(R, "<span class='userdanger'>You are a Special Operations cyborg, in the service of Central Command. \nYour current mission is: <span class='danger'>[input]</span></span>")
			else
				var/mob/living/carbon/human/new_commando = create_death_commando(L, is_leader)
				new_commando.mind.key = ghost_mob.key
				new_commando.key = ghost_mob.key
				new_commando.internal = new_commando.s_store
				new_commando.update_action_buttons_icon()
				if(nuke_code)
					new_commando.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>[nuke_code].</span>")
				new_commando.mind.store_memory("<B>Mission:</B> <span class='warning'>[input].</span>")
				to_chat(new_commando, "<span class='userdanger'>You are a Special Ops [is_leader ? "<B>TEAM LEADER</B>" : "commando"] in the service of Central Command. Check the table ahead for detailed instructions.\nYour current mission is: <span class='danger'>[input]</span></span>")

			is_leader = FALSE
			commando_number--

	//Spawns the rest of the commando gear.
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(L.name == "Commando_Manual")
			//new /obj/item/gun/energy/pulse_rifle(L.loc)
			var/obj/item/paper/P = new(L.loc)
			P.info = "<p><b>Good morning soldier!</b>. This compact guide will familiarize you with standard operating procedure. There are three basic rules to follow:<br>#1 Work as a team.<br>#2 Accomplish your objective at all costs.<br>#3 Leave no witnesses.<br>You are fully equipped and stocked for your mission--before departing on the Spec. Ops. Shuttle due South, make sure that all operatives are ready. Actual mission objective will be relayed to you by Central Command through your headsets.<br>If deemed appropriate, Central Command will also allow members of your team to equip assault power-armor for the mission. You will find the armor storage due West of your position. Once you are ready to leave, utilize the Special Operations shuttle console and toggle the hull doors via the other console.</p><p>In the event that the team does not accomplish their assigned objective in a timely manner, or finds no other way to do so, attached below are instructions on how to operate a Nanotrasen Nuclear Device. Your operations <b>LEADER</b> is provided with a nuclear authentication disk and a pin-pointer for this reason. You may easily recognize them by their rank: Lieutenant, Captain, or Major. The nuclear device itself will be present somewhere on your destination.</p><p>Hello and thank you for choosing Nanotrasen for your nuclear information needs. Today's crash course will deal with the operation of a Fission Class Nanotrasen made Nuclear Device.<br>First and foremost, <b>DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.</b> Pressing any button on the compacted bomb will cause it to extend and bolt itself into place. If this is done to unbolt it one must completely log in which at this time may not be possible.<br>To make the device functional:<br>#1 Place bomb in designated detonation zone<br> #2 Extend and anchor bomb (attack with hand).<br>#3 Insert Nuclear Auth. Disk into slot.<br>#4 Type numeric code into keypad ([nuke_code]).<br>Note: If you make a mistake press R to reset the device.<br>#5 Press the E button to log onto the device.<br>You now have activated the device. To deactivate the buttons at anytime, for example when you have already prepped the bomb for detonation, remove the authentication disk OR press the R on the keypad. Now the bomb CAN ONLY be detonated using the timer. A manual detonation is not an option.<br>Note: Toggle off the <b>SAFETY</b>.<br>Use the - - and + + to set a detonation time between 5 seconds and 10 minutes. Then press the timer toggle button to start the countdown. Now remove the authentication disk so that the buttons deactivate.<br>Note: <b>THE BOMB IS STILL SET AND WILL DETONATE</b><br>Now before you remove the disk if you need to move the bomb you can: Toggle off the anchor, move it, and re-anchor.</p><p>The nuclear authorization code is: <b>[nuke_code ? nuke_code : "None provided"]</b></p><p><b>Good luck, soldier!</b></p>"
			P.name = "Spec. Ops Manual"
			P.icon = "pamphlet-ds"
			var/obj/item/stamp/centcom/stamp = new
			P.stamp(stamp)
			qdel(stamp)

	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(L.name == "Commando-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)
			qdel(L)

	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned a CentComm DeathSquad.</span>", 1)
	log_admin("[key_name(usr)] used Spawn Death Squad.")
	return 1

/client/proc/create_death_commando(obj/spawn_location, is_leader = FALSE)
	var/mob/living/carbon/human/new_commando = new(spawn_location.loc)
	var/commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/commando_name = pick(GLOB.last_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(is_leader)
		A.age = rand(35,45)
		A.real_name = "[commando_leader_rank] [commando_name]"
	else
		A.real_name = "[commando_rank] [commando_name]"
	A.copy_to(new_commando)


	new_commando.dna.ready_dna(new_commando)//Creates DNA.

	//Creates mind stuff.
	new_commando.mind_initialize()
	new_commando.mind.assigned_role = SPECIAL_ROLE_DEATHSQUAD
	new_commando.mind.special_role = SPECIAL_ROLE_DEATHSQUAD
	SSticker.mode.traitors |= new_commando.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	new_commando.equip_death_commando(is_leader)
	return new_commando

/mob/living/carbon/human/proc/equip_death_commando(is_leader = FALSE)

	var/obj/item/radio/R = new /obj/item/radio/headset/alt(src)
	R.set_frequency(DTH_FREQ)
	equip_to_slot_or_del(R, slot_l_ear)
	if(is_leader)
		equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(src), slot_w_uniform)
	else
		equip_to_slot_or_del(new /obj/item/clothing/under/color/green(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/advance(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/suit/space/deathsquad(src), slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(src), slot_gloves)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad(src), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(src), slot_glasses)

	equip_to_slot_or_del(new /obj/item/storage/backpack/security(src), slot_back)
	equip_to_slot_or_del(new /obj/item/storage/box(src), slot_in_backpack)

	equip_to_slot_or_del(new /obj/item/ammo_box/a357(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/combat/nanites(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/storage/box/flashbangs(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/flashlight(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/pinpointer(src), slot_in_backpack)
	if(is_leader)
		equip_to_slot_or_del(new /obj/item/disk/nuclear/unrestricted(src), slot_in_backpack)
	else
		equip_to_slot_or_del(new /obj/item/grenade/plastic/x4(src), slot_in_backpack)


	equip_to_slot_or_del(new /obj/item/melee/energy/sword/saber(src), slot_l_store)
	equip_to_slot_or_del(new /obj/item/shield/energy(src), slot_r_store)
	equip_to_slot_or_del(new /obj/item/tank/emergency_oxygen/double/full(src), slot_s_store)
	equip_to_slot_or_del(new /obj/item/gun/projectile/revolver/mateba(src), slot_belt)
	equip_to_slot_or_del(new /obj/item/gun/energy/pulse(src), slot_r_hand)

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(src)
	L.implant(src)

	var/obj/item/card/id/W = new(src)
	W.name = "[real_name]'s ID Card"
	W.icon_state = "deathsquad"
	W.assignment = "Death Commando"
	W.access = get_centcom_access(W.assignment)
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	return 1
