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
	var/list/teamsizeoptions = list(1,2,3,4,5)
	var/teamsize = input(src, "How many team members, not counting the team leader?") as null|anything in teamsizeoptions
	if (!(teamsize in teamsizeoptions))
		alert("Invalid team size specified. Aborting.")
		return
	var/input = null
	while(!input)
		input = sanitize(copytext(input(src, "Please specify which mission the syndicate infiltration team shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
		if(!input)
			alert("No mission specified. Aborting.")
			return
	var/list/tcoptions = list(0,5,10,15,20,25,30,35,40,50,60,80,100)
	var/tcamount = input(src, "How much TC do you want to give each team member? Suggested: 20-30. They cannot trade TC.") as null|anything in tcoptions
	if (!(tcamount in tcoptions))
		alert("Invalid TC amount specified. Aborting.")
		return
	if(sent_syndicate_infiltration_team == 1)
		if(alert("A Syndicate Infiltration Team has already been sent. Sure you want to send another?",,"Yes","No")=="No")
			return

	var/syndicate_leader_selected = 0
	//var/list/infiltrators = pollCandidates("Do you want to play as a SYNDICATE INFILTRATOR?", ROLE_TRAITOR, 7)
	var/list/infiltrators = pollCandidates("Do you want to play as a SYNDICATE INFILTRATOR?")

	if (!infiltrators.len)
		to_chat(src, "Nobody volunteered.")
		return 0

	sent_syndicate_infiltration_team = 1

	var/list/sit_spawns = list()
	var/list/sit_spawns_leader = list()
	for(var/obj/effect/landmark/L in landmarks_list)
		if (L.name == "Syndicate-Infiltrator")
			sit_spawns += L
		if (L.name == "Syndicate-Infiltrator-Leader")
			sit_spawns_leader += L

	var/num_spawned = 1
	var/team_leader = null
	for(var/obj/effect/landmark/L in sit_spawns)
		if (!infiltrators.len && !spawn_dummies) break
		syndicate_leader_selected = num_spawned == 1?1:0
		var/mob/living/carbon/human/new_syndicate_infiltrator = create_syndicate_infiltrator(L, syndicate_leader_selected, tcamount)
		if(infiltrators.len)
			var/mob/theguy = pick(infiltrators)
			new_syndicate_infiltrator.key = theguy.key
			infiltrators -= theguy
			new_syndicate_infiltrator.internal = new_syndicate_infiltrator.s_store
			new_syndicate_infiltrator.internals.icon_state = "internal1"
		to_chat(new_syndicate_infiltrator, "<span class='danger'>You are a [!syndicate_leader_selected?"Infiltrator":"<B>Lead Infiltrator</B>"] in the service of the Syndicate. \nYour current mission is: <B>[input]</B></span>")
		to_chat(new_syndicate_infiltrator, "<span class='notice'>You are equipped with an uplink implant to help you achieve your objectives. ((activate it via button in top left of screen))</span>")
		new_syndicate_infiltrator.faction += "syndicate"
		data_core.manifest_inject(new_syndicate_infiltrator)
		if (syndicate_leader_selected)
			var/obj/effect/landmark/warpto = pick(sit_spawns_leader)
			new_syndicate_infiltrator.loc = warpto.loc
			sit_spawns_leader -= warpto
			team_leader = new_syndicate_infiltrator
			to_chat(new_syndicate_infiltrator, "<span class='danger'>As team leader, it is up to you to organize your team! Give the job to someone else if you can't handle it. Only your ID opens the exit door.</span>")
		else
			to_chat(new_syndicate_infiltrator, "<span class='danger'>Your team leader is: [team_leader]. They are in charge!</span>")
			teamsize--
		to_chat(new_syndicate_infiltrator, "<span class='notice'>You have more helpful information stored in your Notes.</span>")
		new_syndicate_infiltrator.mind.store_memory("<B>Mission:</B> [input] ")
		new_syndicate_infiltrator.mind.store_memory("<B>Team Leader:</B> [team_leader] ")
		new_syndicate_infiltrator.mind.store_memory("<B>Starting Equipment:</B> <BR>- Chameleon Jumpsuit ((right click to Change Color))<BR> - Agent ID card ((disguise as another job))<BR> - Uplink Implant ((top left of screen)) <BR> - Dust Implant ((destroys your body on death)) <BR> - Combat Gloves ((insulated, disguised as black gloves)) <BR> - Anything bought with your uplink implant")
		new_syndicate_infiltrator.regenerate_icons()
		num_spawned++
		if (!teamsize)
			break

	message_admins("[key_name_admin(usr)] has spawned a Syndicate Infiltration Team.", 1)
	log_admin("[key_name(usr)] used Spawn Syndicate Infiltration Team.")
	feedback_add_details("admin_verb","SPAWNSIT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

// ---------------------------------------------------------------------------------------------------------

/client/proc/create_syndicate_infiltrator(obj/spawn_location, syndicate_leader_selected = 0, uplink_tc = 20)
	var/mob/living/carbon/human/new_syndicate_infiltrator = new(spawn_location.loc)

	var/syndicate_infiltrator_name = random_name(pick(MALE,FEMALE))

	var/datum/preferences/A = new() //Randomize appearance
	A.real_name = syndicate_infiltrator_name
	A.copy_to(new_syndicate_infiltrator)

	new_syndicate_infiltrator.dna.ready_dna(new_syndicate_infiltrator) //Creates DNA.

	//Creates mind stuff.
	new_syndicate_infiltrator.mind_initialize()
	new_syndicate_infiltrator.mind.assigned_role = "MODE"
	new_syndicate_infiltrator.mind.special_role = "Syndicate Infiltrator"
	ticker.mode.traitors |= new_syndicate_infiltrator.mind //Adds them to extra antag list
	new_syndicate_infiltrator.equip_syndicate_infiltrator(syndicate_leader_selected, uplink_tc)
	qdel(spawn_location)
	return new_syndicate_infiltrator

// ---------------------------------------------------------------------------------------------------------

/mob/living/carbon/human/proc/equip_syndicate_infiltrator(syndicate_leader_selected = 0, num_tc)
	// Storage items
	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(src), slot_back)
	equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/clothing/under/chameleon(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full/multitool(src), slot_belt)

	var/obj/item/clothing/gloves/combat/G = new /obj/item/clothing/gloves/combat(src)
	G.name = "black gloves"
	equip_to_slot_or_del(G, slot_gloves)

	// Implants:
	// Uplink
	var/obj/item/weapon/implant/uplink/U = new /obj/item/weapon/implant/uplink(src)
	U.implant(src)
	U.hidden_uplink.uses = num_tc
	// Storage
	//var/obj/item/weapon/implant/storage/T = new /obj/item/weapon/implant/storage(src)
	//T.implant(src)
	// Dust
	var/obj/item/weapon/implant/dust/D = new /obj/item/weapon/implant/dust(src)
	D.implant(src)

	// Radio & PDA
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(src)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	equip_to_slot_or_del(R, slot_l_ear)
	equip_or_collect(new /obj/item/device/pda(src), slot_wear_pda)

	// Other gear
	equip_to_slot_or_del(new /obj/item/clothing/shoes/syndigaloshes(src), slot_shoes)

	var/obj/item/weapon/card/id/syndicate/W = new(src) //Untrackable by AI
	W.name = "[real_name]'s ID Card (Civilian)"
	W.icon_state = "id"
	W.access = list(access_maint_tunnels,access_external_airlocks)
	W.assignment = "Civilian"
	W.access += get_access("Civilian")
	W.access += list(access_medical, access_engine, access_cargo, access_research)
	if (syndicate_leader_selected)
		W.access += get_syndicate_access("Syndicate Commando")
	else
		W.access += get_syndicate_access("Syndicate Operative")
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	return 1
