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
	if(!SSticker)
		alert("The game hasn't started yet!")
		return
	if(sent_syndicate_strike_team == 1)
		alert("The Syndicate are already sending a team, Mr. Dumbass.")
		return
	if(alert("Do you want to send in the Syndicate Strike Team? Once enabled, this is irreversible.",,"Yes","No")=="No")
		return
	alert("This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned syndicates have internals cameras which are viewable through a monitor inside the Syndicate Mothership Bridge. Assigning the team's detailed task is recommended from there. The first one selected/spawned will be the team leader.")

	message_admins("<span class='notice'>[key_name_admin(usr)] has started to spawn a Syndicate Strike Team.</span>", 1)

	var/input = null
	while(!input)
		input = sanitize(copytext(input(src, "Please specify which mission the syndicate strike team shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
		if(!input)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	if(sent_syndicate_strike_team)
		to_chat(src, "Looks like someone beat you to it.")
		return

	var/syndicate_commando_number = syndicate_commandos_possible //for selecting a leader
	var/is_leader = TRUE // set to FALSE after leader is spawned

	// Find the nuclear auth code
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in world)
		temp_code = text2num(N.r_code)
		if(temp_code)//if it's actually a number. It won't convert any non-numericals.
			nuke_code = N.r_code
			break

	// Find ghosts willing to be SST
	var/list/commando_ghosts = pollCandidatesWithVeto(src, usr, syndicate_commandos_possible, "Join the Syndicate Strike Team?",, 21, 600, 1, role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE)
	if(!commando_ghosts.len)
		to_chat(usr, "<span class='userdanger'>Nobody volunteered to join the SST.</span>")
		return

	sent_syndicate_strike_team = 1

	//Spawns commandos and equips them.
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)

		if(syndicate_commando_number <= 0)
			break

		if(L.name == "Syndicate-Commando")

			if(!commando_ghosts.len)
				break

			var/mob/ghost_mob = pick(commando_ghosts)
			commando_ghosts -= ghost_mob

			if(!ghost_mob || !ghost_mob.key || !ghost_mob.client)
				continue

			var/mob/living/carbon/human/new_syndicate_commando = create_syndicate_death_commando(L, is_leader)

			if(!new_syndicate_commando)
				continue

			new_syndicate_commando.key = ghost_mob.key
			new_syndicate_commando.internal = new_syndicate_commando.s_store
			new_syndicate_commando.update_action_buttons_icon()

			//So they don't forget their code or mission.
			if(nuke_code)
				new_syndicate_commando.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>[nuke_code]</span>.")
			new_syndicate_commando.mind.store_memory("<B>Mission:</B> <span class='warning'>[input]</span>.")

			to_chat(new_syndicate_commando, "<span class='notice'>You are an Elite Syndicate [is_leader ? "<B>TEAM LEADER</B>" : "commando"] in the service of the Syndicate. \nYour current mission is: <span class='userdanger'>[input]</span></span>")
			new_syndicate_commando.faction += "syndicate"
			var/datum/atom_hud/antag/opshud = huds[ANTAG_HUD_OPS]
			opshud.join_hud(new_syndicate_commando.mind.current)
			set_antag_hud(new_syndicate_commando.mind.current, "hudoperative")
			new_syndicate_commando.regenerate_icons()
			is_leader = FALSE
			syndicate_commando_number--

	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned a Syndicate strike squad.</span>", 1)
	log_admin("[key_name(usr)] used Spawn Syndicate Squad.")
	feedback_add_details("admin_verb","SDTHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/create_syndicate_death_commando(obj/spawn_location, is_leader = FALSE)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(GLOB.last_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(is_leader)
		A.age = rand(35,45)
		A.real_name = "[syndicate_commando_leader_rank] [syndicate_commando_name]"
	else
		A.real_name = "[syndicate_commando_rank] [syndicate_commando_name]"
	A.copy_to(new_syndicate_commando)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.assigned_role = SPECIAL_ROLE_SYNDICATE_DEATHSQUAD
	new_syndicate_commando.mind.special_role = SPECIAL_ROLE_SYNDICATE_DEATHSQUAD
	new_syndicate_commando.mind.offstation_role = TRUE
	SSticker.mode.traitors |= new_syndicate_commando.mind	//Adds them to current traitor list. Which is really the extra antagonist list.
	new_syndicate_commando.equip_syndicate_commando(is_leader)
	qdel(spawn_location)
	return new_syndicate_commando

/mob/living/carbon/human/proc/equip_syndicate_commando(is_leader = FALSE, full_gear = FALSE)
	var/obj/item/radio/R = new /obj/item/radio/headset/syndicate/alt/syndteam(src)
	R.set_frequency(SYNDTEAM_FREQ)
	equip_to_slot_or_del(R, slot_l_ear)
	equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(src), slot_w_uniform)
	if(!full_gear)
		equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(src), slot_gloves)

	equip_to_slot_or_del(new /obj/item/storage/backpack/security(src), slot_back)
	equip_to_slot_or_del(new /obj/item/storage/box/survival_syndi(src), slot_in_backpack)

	equip_to_slot_or_del(new /obj/item/gun/projectile/revolver(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/ammo_box/a357(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/combat/nanites(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/grenade/plastic/x4(src), slot_in_backpack)
	if(is_leader)
		equip_to_slot_or_del(new /obj/item/pinpointer(src), slot_in_backpack)
		equip_to_slot_or_del(new /obj/item/disk/nuclear/unrestricted(src), slot_in_backpack)
	else
		equip_to_slot_or_del(new /obj/item/grenade/plastic/x4(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/card/emag(src), slot_r_store)
	equip_to_slot_or_del(new /obj/item/melee/energy/sword/saber/red(src), slot_l_store)

	if(full_gear)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(src), slot_wear_mask)
		equip_to_slot_or_del(new /obj/item/clothing/suit/space/hardsuit/syndi/elite/sst(src), slot_wear_suit)
		equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(src), slot_glasses)
		equip_to_slot_or_del(new /obj/item/storage/belt/military/sst(src), slot_belt)
		equip_to_slot_or_del(new /obj/item/tank/jetpack/oxygen/harness(src), slot_s_store)
		equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/syndie/advance(src), slot_shoes)
		equip_to_slot_or_del(new /obj/item/gun/projectile/automatic/l6_saw(src), slot_r_hand)
		equip_to_slot_or_del(new /obj/item/ammo_box/magazine/mm556x45(src), slot_in_backpack)

	var/obj/item/implant/dust/D = new /obj/item/implant/dust(src)
	D.implant(src)
	var/obj/item/card/id/syndicate/W = new(src) //Untrackable by AI
	W.name = "[real_name]'s ID Card"
	W.icon_state = "syndie"
	W.assignment = "Syndicate Commando"
	W.access += get_syndicate_access(W.assignment)
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	return 1
