//DOOMguy strikes back

var/const/doomguy_possible = 1 //if more Commandos are needed in the future
var/global/sent_doomstrike_team = 0

/client/proc/doomstrike_team()
	if(!ticker)
		to_chat(usr, "<font color='red'>The game hasn't started yet!</font>")
		return
	if(sent_doomstrike_team == 1)
		to_chat(usr, "<font color='red'>UAC is already sending a guy.</font>")
		return
	if(alert("Do you want to send in the DOOMguy? Once enabled, this is irreversible.",,"Yes","No")!="Yes")
		return
	alert("This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned commando have internals camera which is viewable through a monitor inside the Spec. Ops. Office. Assigning the team's detailed task is recommended from there. While you will be able to manually pick the candidates from active ghosts, their assignment in the squad will be random.")

	var/input = null
	while(!input)
		input = sanitize(copytext(input(src, "Please specify which mission the DOOMguy shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
		if(!input)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	if(sent_doomstrike_team)
		to_chat(usr, "Looks like someone beat you to it.")
		return

	sent_doomstrike_team = 1

	shuttle_master.cancelEvac()
	var/commando_number = doomguy_possible //for selecting a leader
	var/leader_selected = 0 //when the leader is chosen. The last person spawned.

//Code for spawning a nuke auth code.
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in world)
		temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break

//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	var/list/candidates = list()	//candidates for being a commando out of all the active ghosts in world.
	var/list/commandos = list()			//actual commando ghosts as picked by the user.
	for(var/mob/dead/observer/G	 in player_list)
		if(!G.client.holder && !G.client.is_afk())	//Whoever called/has the proc won't be added to the list.
			if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
				candidates += G.key
	for(var/i=doomguy_possible,(i>0&&candidates.len),i--)//Decrease with every commando selected.
		var/candidate = input("Pick characters to spawn as the commandos. This will go on until there either no more ghosts to pick from or the slots are full.", "Active Players") as null|anything in candidates	//It will auto-pick a person when there is only one candidate.
		candidates -= candidate		//Subtract from candidates.
		commandos += candidate//Add their ghost to commandos.

//Spawns commandos and equips them.
	for(var/obj/effect/landmark/L in landmarks_list)
		if(commando_number<=0)	break
		if (L.name == "Commando")
			leader_selected = commando_number == 1?1:0

			var/mob/living/carbon/human/new_doomguy = create_doom_commando(L, leader_selected)

			if(commandos.len)
				new_doomguy.key = pick(commandos)
				commandos -= new_doomguy.key
				new_doomguy.internal = new_doomguy.s_store
				new_doomguy.internals.icon_state = "internal1"

			//So they don't forget their code or mission.
			if(nuke_code)
				new_doomguy.mind.store_memory("<B>Nuke Code:</B> \red [nuke_code].")
			new_doomguy.mind.store_memory("<B>Mission:</B> \red [input].")

			to_chat(new_doomguy, "\blue You are a Special Ops. [!leader_selected?"commando":"<B>LEADER</B>"] in the service of Central Command. Check the table ahead for detailed instructions.\nYour current mission is: \red<B>[input]</B>")

			commando_number--

//Spawns the rest of the commando gear.
	for (var/obj/effect/landmark/L in landmarks_list)
		if (L.name == "Commando_Manual")
			//new /obj/item/weapon/gun/energy/pulse_rifle(L.loc)
			var/obj/item/weapon/paper/P = new(L.loc)
			P.info = "<p><b>Good morning soldier!</b>. This compact guide will familiarize you with standard operating procedure. There are three basic rules to follow:<br>#1 Work hard.<br>#2 Accomplish your objective at all costs.<br>#3 Leave no witnesses.<br>You are fully equipped and stocked for your mission--before departing on the Spec. Ops. Shuttle due South, make sure that you are ready. Actual mission objective will be relayed to you by Central Command through your headsets.</p><p>In the event that the team does not accomplish their assigned objective in a timely manner, or finds no other way to do so, attached below are instructions on how to operate a Nanotrasen Nuclear Device. <b>YOU</b> provided with a nuclear authentication disk and a pin-pointer for this reason. The nuclear device itself will be present somewhere on your destination.</p><p>Hello and thank you for choosing Nanotrasen for your nuclear information needs. Today's crash course will deal with the operation of a Fission Class Nanotrasen made Nuclear Device.<br>First and foremost, <b>DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.</b> Pressing any button on the compacted bomb will cause it to extend and bolt itself into place. If this is done to unbolt it one must completely log in which at this time may not be possible.<br>To make the device functional:<br>#1 Place bomb in designated detonation zone<br> #2 Extend and anchor bomb (attack with hand).<br>#3 Insert Nuclear Auth. Disk into slot.<br>#4 Type numeric code into keypad ([nuke_code]).<br>Note: If you make a mistake press R to reset the device.<br>#5 Press the E button to log onto the device.<br>You now have activated the device. To deactivate the buttons at anytime, for example when you have already prepped the bomb for detonation, remove the authentication disk OR press the R on the keypad. Now the bomb CAN ONLY be detonated using the timer. A manual detonation is not an option.<br>Note: Toggle off the <b>SAFETY</b>.<br>Use the - - and + + to set a detonation time between 5 seconds and 10 minutes. Then press the timer toggle button to start the countdown. Now remove the authentication disk so that the buttons deactivate.<br>Note: <b>THE BOMB IS STILL SET AND WILL DETONATE</b><br>Now before you remove the disk if you need to move the bomb you can: Toggle off the anchor, move it, and re-anchor.</p><p>The nuclear authorization code is: <b>[nuke_code ? nuke_code : "None provided"]</b></p><p><b>Good luck, soldier!</b></p>"
			P.name = "DOOM Manual"
			P.icon = "pamphlet-ds"
			var/obj/item/weapon/stamp/centcom/stamp = new
			P.stamp(stamp)
			qdel(stamp)

	for (var/obj/effect/landmark/L in landmarks_list)
		if (L.name == "Commando-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)
			qdel(L)

	message_admins("\blue [key_name_admin(usr)] has spawned a CentComm strike squad.", 1)
	log_admin("[key_name(usr)] used Spawn Death Squad.")
	return 1

/client/proc/create_doom_commando(obj/spawn_location, leader_selected = 0)
	var/mob/living/carbon/human/new_doomguy = new(spawn_location.loc)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(leader_selected)
		A.age = rand(35,45)
		A.real_name = "DOOMguy"
	else
		A.real_name = "DOOMguy"
	A.copy_to(new_doomguy)

	new_doomguy.dna.ready_dna(new_doomguy)//Creates DNA.

	//Creates mind stuff.
	new_doomguy.mind_initialize()
	new_doomguy.mind.assigned_role = "MODE"
	new_doomguy.mind.special_role = "DOOMguy"
	ticker.mode.traitors |= new_doomguy.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	new_doomguy.equip_doom_commando()
	return new_doomguy

/mob/living/carbon/human/proc/equip_doom_commando()
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/alt(src)
	R.set_frequency(DTH_FREQ)
	equip_to_slot_or_del(R, slot_l_ear)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/doublebarrel/doom(src), slot_back)
	equip_to_slot_or_del(new /obj/item/clothing/under/doom(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/doom(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/doom(src), slot_head)
	equip_to_slot_or_del(new /obj/item/weapon/storage/belt/bluespace/doom(src), slot_belt)
	equip_to_slot_or_del(new /obj/item/clothing/suit/armor/doom(src), slot_wear_suit)
	var/obj/item/weapon/gun/projectile/automatic/l6_saw/doomgun = new(src)
	src.equip_to_slot_or_del(doomgun, slot_r_hand)

	var/obj/item/weapon/card/id/W = new(src)
	W.name = "DOOMguy ID Card (DOOMsquad)"
	W.access = get_centcom_access(W.assignment)
	W.assignment = "DOOMsquad"
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	return 1