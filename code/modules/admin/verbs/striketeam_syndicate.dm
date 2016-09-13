//STRIKE TEAMS

var/const/syndicate_commandos_possible = 6 //if more Commandos are needed in the future
var/global/sent_syndicate_strike_team = 0
/client/proc/syndicate_strike_team()
	set category = "Event"
	set name = "Spawn Syndicate Strike Team"
	set desc = "Spawns a squad of commandos in the Syndicate Mothership if you want to run an admin event."
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!ticker)
		alert("The game hasn't started yet!")
		return
	if(sent_syndicate_strike_team == 1)
		alert("The Syndicate are already sending a team, Mr. Dumbass.")
		return
	if(alert("Do you want to send in the Syndicate Strike Team? Once enabled, this is irreversible.",,"Yes","No")=="No")
		return
	alert("This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned syndicates have internals cameras which are viewable through a monitor inside the Syndicate Mothership Bridge. Assigning the team's detailed task is recommended from there. While you will be able to manually pick the candidates from active ghosts, their assignment in the squad will be random.")

	var/input = null
	while(!input)
		input = sanitize(copytext(input(src, "Please specify which mission the syndicate strike team shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
		if(!input)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	if(sent_syndicate_strike_team)
		to_chat(src, "Looks like someone beat you to it.")
		return

	sent_syndicate_strike_team = 1

	//if(emergency_shuttle.can_recall())
	//	emergency_shuttle.recall()	//why, exactly? Admins can do this themselves.

	var/syndicate_commando_number = syndicate_commandos_possible //for selecting a leader
	var/syndicate_leader_selected = 0 //when the leader is chosen. The last person spawned.

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
	for(var/i=commandos_possible,(i>0&&candidates.len),i--)//Decrease with every commando selected.
		var/candidate = input("Pick characters to spawn as the commandos. This will go on until there either no more ghosts to pick from or the slots are full.", "Active Players") as null|anything in candidates	//It will auto-pick a person when there is only one candidate.
		candidates -= candidate		//Subtract from candidates.
		commandos += candidate//Add their ghost to commandos.

//Spawns commandos and equips them.
	for(var/obj/effect/landmark/L in landmarks_list)
		if(syndicate_commando_number<=0)	break
		if(L.name == "Syndicate-Commando")
			syndicate_leader_selected = syndicate_commando_number == 1?1:0

			var/mob/living/carbon/human/new_syndicate_commando = create_syndicate_death_commando(L, syndicate_leader_selected)

			if(commandos.len)
				new_syndicate_commando.key = pick(commandos)
				commandos -= new_syndicate_commando.key
				new_syndicate_commando.internal = new_syndicate_commando.s_store
				new_syndicate_commando.update_internals_hud_icon(1)

			//So they don't forget their code or mission.
			if(nuke_code)
				new_syndicate_commando.mind.store_memory("<B>Nuke Code:</B> \red [nuke_code].")
			new_syndicate_commando.mind.store_memory("<B>Mission:</B> \red [input].")

			to_chat(new_syndicate_commando, "\blue You are an Elite Syndicate. [!syndicate_leader_selected?"commando":"<B>LEADER</B>"] in the service of the Syndicate. \nYour current mission is: <span class='danger'>[input]</span>")
			new_syndicate_commando.faction += "syndicate"
			syndicate_commando_number--

	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "Syndicate-Commando-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)
			qdel(L)

	message_admins("\blue [key_name_admin(usr)] has spawned a Syndicate strike squad.", 1)
	log_admin("[key_name(usr)] used Spawn Syndicate Squad.")
	feedback_add_details("admin_verb","SDTHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/create_syndicate_death_commando(obj/spawn_location, syndicate_leader_selected = 0)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(last_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(syndicate_leader_selected)
		A.age = rand(35,45)
		A.real_name = "[syndicate_commando_leader_rank] [syndicate_commando_name]"
	else
		A.real_name = "[syndicate_commando_rank] [syndicate_commando_name]"
	A.copy_to(new_syndicate_commando)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.assigned_role = "MODE"
	new_syndicate_commando.mind.special_role = SPECIAL_ROLE_SYNDICATE_DEATHSQUAD
	ticker.mode.traitors |= new_syndicate_commando.mind	//Adds them to current traitor list. Which is really the extra antagonist list.
	new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)
	qdel(spawn_location)
	return new_syndicate_commando

/mob/living/carbon/human/proc/equip_syndicate_commando(syndicate_leader_selected = 0)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt/syndteam(src)
	R.set_frequency(SYNDTEAM_FREQ)
	equip_to_slot_or_del(R, slot_l_ear)
	equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/syndie/advance(src), slot_shoes)
	if(!syndicate_leader_selected)
		equip_to_slot_or_del(new /obj/item/clothing/suit/space/syndicate/black/strike(src), slot_wear_suit)
	else
		equip_to_slot_or_del(new /obj/item/clothing/suit/space/syndicate/black/red/strike(src), slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(src), slot_gloves)
	if(!syndicate_leader_selected)
		equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/syndicate/black/strike(src), slot_head)
	else
		equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/syndicate/black/red/strike(src), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(src), slot_glasses)

	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(src), slot_back)
	equip_to_slot_or_del(new /obj/item/ammo_box/magazine/mm556x45)

	equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m45(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/hypospray/combat/nanites(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/grenade/plastic/x4(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), slot_in_backpack)
	if(!syndicate_leader_selected)
		equip_to_slot_or_del(new /obj/item/weapon/grenade/plastic/x4(src), slot_in_backpack)
		equip_to_slot_or_del(new /obj/item/weapon/card/emag(src), slot_in_backpack)
	else
		equip_to_slot_or_del(new /obj/item/weapon/pinpointer(src), slot_in_backpack)
		equip_to_slot_or_del(new /obj/item/weapon/disk/nuclear(src), slot_in_backpack)

	equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/saber(src), slot_l_store)
	equip_to_slot_or_del(new /obj/item/weapon/grenade/empgrenade(src), slot_r_store)
	equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double/full(src), slot_s_store)
	equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/pistol/m1911(src), slot_belt)

	equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/l6_saw(src), slot_r_hand)

	var/obj/item/weapon/card/id/syndicate/W = new(src) //Untrackable by AI
	W.name = "[real_name]'s ID Card"
	W.icon_state = "syndie"
	W.access = get_all_accesses()//They get full station access because obviously the syndicate has HAAAX, and can make special IDs for their most elite members.
	W.assignment = "Syndicate Commando"
	W.access += get_syndicate_access(W.assignment)
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	return 1
