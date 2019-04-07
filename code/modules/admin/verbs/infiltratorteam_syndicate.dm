// Syndicate Infiltration Team (SIT)
// A little like Syndicate Strike Team (SST) but geared towards stealthy team missions rather than murderbone.

var/global/sent_syndicate_infiltration_team = 0

/client/proc/syndicate_infiltration_team()
	set category = "Event"
	set name = "Send Syndicate Infiltration Team"
	set desc = "Spawns a squad of syndicate infiltrators on the Syndicate Mothership if you want to run an admin event."
	if(!check_rights(R_ADMIN))
		to_chat(src, "Only administrators may use this command.")
		return
	if(!ticker)
		alert("The game hasn't started yet!")
		return
	if(alert("Do you want to send in the Syndicate Infiltration Team?",,"Yes","No")=="No")
		return
	var/spawn_dummies = 0
	if(alert("Spawn full-size team, even if there aren't enough ghosts to populate them?",,"Yes","No")=="Yes")
		spawn_dummies = 1
	var/pick_manually = 0
	if(alert("Pick the team members manually? If you select yes, you pick from ghosts. If you select no, ghosts get offered the chance to join.",,"Yes","No")=="Yes")
		pick_manually = 1
	var/list/teamsizeoptions = list(2,3,4,5,6)
	var/teamsize = input(src, "How many team members, including the team leader?") as null|anything in teamsizeoptions
	if(!(teamsize in teamsizeoptions))
		alert("Invalid team size specified. Aborting.")
		return
	var/input = null
	while(!input)
		input = sanitize(copytext(input(src, "Please specify which mission the syndicate infiltration team shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
		if(!input)
			alert("No mission specified. Aborting.")
			return
	var/tctext = input(src, "How much TC do you want to give each team member? Suggested: 20-30. They cannot trade TC.") as num
	var/tcamount = text2num(tctext)
	tcamount = between(0, tcamount, 1000)
	if(sent_syndicate_infiltration_team == 1)
		if(alert("A Syndicate Infiltration Team has already been sent. Sure you want to send another?",,"Yes","No")=="No")
			return

	var/syndicate_leader_selected = 0

	var/list/infiltrators = list()

	if(pick_manually)
		var/list/possible_ghosts = list()
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(!G.client.is_afk())
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					possible_ghosts += G
		for(var/i=teamsize,(i>0&&possible_ghosts.len),i--) //Decrease with every SIT member selected.
			var/candidate = input("Pick characters to spawn as a SIT member. This will go on until there either no more ghosts to pick from, or the slots are full.", "Active Players") as null|anything in possible_ghosts // auto-picks if only one candidate
			possible_ghosts -= candidate
			infiltrators += candidate
	else
		to_chat(src, "Polling candidates...")
		infiltrators = pollCandidates("Do you want to play as a SYNDICATE INFILTRATOR?", ROLE_TRAITOR, 1)

	if(!infiltrators.len)
		to_chat(src, "Nobody volunteered.")
		return 0

	sent_syndicate_infiltration_team = 1

	var/list/sit_spawns = list()
	var/list/sit_spawns_leader = list()
	var/list/sit_spawns_mgmt = list()
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(L.name == "Syndicate-Infiltrator")
			sit_spawns += L
		if(L.name == "Syndicate-Infiltrator-Leader")
			sit_spawns_leader += L
		if(L.name == "Syndicate-Infiltrator-Admin")
			sit_spawns_mgmt += L

	var/num_spawned = 1
	var/team_leader = null
	for(var/obj/effect/landmark/L in sit_spawns)
		if(!infiltrators.len && !spawn_dummies) break
		syndicate_leader_selected = num_spawned == 1?1:0
		var/mob/living/carbon/human/new_syndicate_infiltrator = create_syndicate_infiltrator(L, syndicate_leader_selected, tcamount, 0)
		if(infiltrators.len)
			var/mob/theguy = pick(infiltrators)
			if(theguy.key != key)
				new_syndicate_infiltrator.key = theguy.key
				new_syndicate_infiltrator.internal = new_syndicate_infiltrator.s_store
				new_syndicate_infiltrator.update_action_buttons_icon()
			infiltrators -= theguy
		to_chat(new_syndicate_infiltrator, "<span class='danger'>You are a [!syndicate_leader_selected?"Infiltrator":"<B>Lead Infiltrator</B>"] in the service of the Syndicate. \nYour current mission is: <B>[input]</B></span>")
		to_chat(new_syndicate_infiltrator, "<span class='notice'>You are equipped with an uplink implant to help you achieve your objectives. ((activate it via button in top left of screen))</span>")
		new_syndicate_infiltrator.faction += "syndicate"
		data_core.manifest_inject(new_syndicate_infiltrator)
		if(syndicate_leader_selected)
			var/obj/effect/landmark/warpto = pick(sit_spawns_leader)
			new_syndicate_infiltrator.loc = warpto.loc
			sit_spawns_leader -= warpto
			team_leader = new_syndicate_infiltrator
			to_chat(new_syndicate_infiltrator, "<span class='danger'>As team leader, it is up to you to organize your team! Give the job to someone else if you can't handle it.</span>")
		else
			to_chat(new_syndicate_infiltrator, "<span class='danger'>Your team leader is: [team_leader]. They are in charge!</span>")
		teamsize--
		to_chat(new_syndicate_infiltrator, "<span class='notice'>You have more helpful information stored in your Notes.</span>")
		new_syndicate_infiltrator.mind.store_memory("<B>Mission:</B> [input] ")
		new_syndicate_infiltrator.mind.store_memory("<B>Team Leader:</B> [team_leader] ")
		new_syndicate_infiltrator.mind.store_memory("<B>Starting Equipment:</B> <BR>- Syndicate Headset ((.h for your radio))<BR>- Chameleon Jumpsuit ((right click to Change Color))<BR> - Agent ID card ((disguise as another job))<BR> - Uplink Implant ((top left of screen)) <BR> - Dust Implant ((destroys your body on death)) <BR> - Combat Gloves ((insulated, disguised as black gloves)) <BR> - Anything bought with your uplink implant")
		var/datum/atom_hud/antag/opshud = huds[ANTAG_HUD_OPS]
		opshud.join_hud(new_syndicate_infiltrator.mind.current)
		set_antag_hud(new_syndicate_infiltrator.mind.current, "hudoperative")
		new_syndicate_infiltrator.regenerate_icons()
		num_spawned++
		if(!teamsize)
			break
	message_admins("[key_name_admin(src)] has spawned a Syndicate Infiltration Team.", 1)
	log_admin("[key_name(src)] used Spawn Syndicate Infiltration Team.")
	feedback_add_details("admin_verb","SPAWNSIT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

// ---------------------------------------------------------------------------------------------------------

/client/proc/create_syndicate_infiltrator(obj/spawn_location, syndicate_leader_selected = 0, uplink_tc = 20, is_mgmt = 0)
	var/mob/living/carbon/human/new_syndicate_infiltrator = new(spawn_location.loc)

	var/syndicate_infiltrator_name = random_name(pick(MALE,FEMALE))

	var/datum/preferences/A = new() //Randomize appearance
	A.real_name = syndicate_infiltrator_name
	A.copy_to(new_syndicate_infiltrator)
	new_syndicate_infiltrator.dna.ready_dna(new_syndicate_infiltrator)

	//Creates mind stuff.
	new_syndicate_infiltrator.mind_initialize()
	new_syndicate_infiltrator.mind.assigned_role = "Syndicate Infiltrator"
	new_syndicate_infiltrator.mind.special_role = "Syndicate Infiltrator"
	new_syndicate_infiltrator.mind.offstation_role = TRUE //they can flee to z2 so make them inelligible as antag targets
	ticker.mode.traitors |= new_syndicate_infiltrator.mind //Adds them to extra antag list
	new_syndicate_infiltrator.equip_syndicate_infiltrator(syndicate_leader_selected, uplink_tc, is_mgmt)
	return new_syndicate_infiltrator

// ---------------------------------------------------------------------------------------------------------

/mob/living/carbon/human/proc/equip_syndicate_infiltrator(syndicate_leader_selected = 0, num_tc, flag_mgmt)
	// Storage items
	equip_to_slot_or_del(new /obj/item/storage/backpack(src), slot_back)
	equip_to_slot_or_del(new /obj/item/storage/box/survival(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/clothing/under/chameleon(src), slot_w_uniform)
	if(!flag_mgmt)
		equip_to_slot_or_del(new /obj/item/flashlight(src), slot_in_backpack)
		equip_to_slot_or_del(new /obj/item/storage/belt/utility/full/multitool(src), slot_belt)

	var/obj/item/clothing/gloves/combat/G = new /obj/item/clothing/gloves/combat(src)
	G.name = "black gloves"
	equip_to_slot_or_del(G, slot_gloves)

	// Implants:
	// Uplink
	var/obj/item/implant/uplink/sit/U = new /obj/item/implant/uplink/sit(src)
	U.implant(src)
	if (flag_mgmt)
		U.hidden_uplink.uses = 500
	else
		U.hidden_uplink.uses = num_tc
	// Dust
	var/obj/item/implant/dust/D = new /obj/item/implant/dust(src)
	D.implant(src)

	// Radio & PDA
	var/obj/item/radio/R = new /obj/item/radio/headset/syndicate/syndteam(src)
	R.set_frequency(SYNDTEAM_FREQ)
	equip_to_slot_or_del(R, slot_l_ear)
	equip_or_collect(new /obj/item/pda(src), slot_in_backpack)

	// Other gear
	equip_to_slot_or_del(new /obj/item/clothing/shoes/syndigaloshes(src), slot_shoes)

	var/obj/item/card/id/syndicate/W = new(src)
	if (flag_mgmt)
		W.icon_state = "commander"
	else
		W.icon_state = "id"
	W.access = list(access_maint_tunnels,access_external_airlocks)
	W.assignment = "Civilian"
	W.access += get_access("Civilian")
	W.access += list(access_medical, access_engine, access_cargo, access_research)
	if(flag_mgmt)
		W.assignment = "Syndicate Management Consultant"
		W.access += get_syndicate_access("Syndicate Commando")
	else if(syndicate_leader_selected)
		W.access += get_syndicate_access("Syndicate Commando")
	else
		W.access += get_syndicate_access("Syndicate Operative")
	W.name = "[real_name]'s ID Card ([W.assignment])"
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	return 1
