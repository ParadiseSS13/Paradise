//HONKsquad

var/const/honksquad_possible = 6 //if more Commandos are needed in the future
var/global/sent_honksquad = 0

/client/proc/honksquad()
	if(!SSticker)
		to_chat(usr, "<font color='red'>The game hasn't started yet!</font>")
		return
	if(world.time < 6000)
		to_chat(usr, "<font color='red'>There are [(6000-world.time)/10] seconds remaining before it may be called.</font>")
		return
	if(sent_honksquad == 1)
		to_chat(usr, "<font color='red'>Clown Planet has already dispatched a HONKsquad.</font>")
		return
	if(alert("Do you want to send in the HONKsquad? Once enabled, this is irreversible.",,"Yes","No")!="Yes")
		return
	alert("This 'mode' will go on until proper levels of HONK have been restored. You may also admin-call the evac shuttle when appropriate. Assigning the team's detailed task is recommended from there. While you will be able to manually pick the candidates from active ghosts, their assignment in the squad will be random.")

	var/input = null
	while(!input)
		input = sanitize(copytext(input(src, "Please specify which mission the HONKsquad shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
		if(!input)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return

	if(sent_honksquad)
		to_chat(usr, "Looks like someone beat you to it. HONK.")
		return

	sent_honksquad = 1


	var/honksquad_number = honksquad_possible //for selecting a leader
	var/honk_leader_selected = 0 //when the leader is chosen. The last person spawned.


//Generates a list of HONKsquad from active ghosts. Then the user picks which characters to respawn as the commandos.
	var/list/candidates = list()	//candidates for being a commando out of all the active ghosts in world.
	var/list/commandos = list()			//actual commando ghosts as picked by the user.
	for(var/mob/dead/observer/G	 in GLOB.player_list)
		if(!G.client.holder && !G.client.is_afk())	//Whoever called/has the proc won't be added to the list.
			if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
				candidates += G.key
	for(var/i=honksquad_possible,(i>0&&candidates.len),i--)//Decrease with every commando selected.
		var/candidate = input("Pick characters to spawn as the HONKsquad. This will go on until there either no more ghosts to pick from or the slots are full.", "Active Players") as null|anything in candidates	//It will auto-pick a person when there is only one candidate.
		candidates -= candidate		//Subtract from candidates.
		commandos += candidate//Add their ghost to commandos.

//Spawns HONKsquad and equips them.
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(honksquad_number<=0)	break
		if(L.name == "HONKsquad")
			honk_leader_selected = honksquad_number == 1?1:0

			var/mob/living/carbon/human/new_honksquad = create_honksquad(L, honk_leader_selected)

			if(commandos.len)
				new_honksquad.key = pick(commandos)
				commandos -= new_honksquad.key
				new_honksquad.internal = new_honksquad.s_store
				new_honksquad.update_action_buttons_icon()

			//So they don't forget their code or mission.
			new_honksquad.mind.store_memory("<B>Mission:</B> <span class='warning'>[input].</span>")

			to_chat(new_honksquad, "<span class='notice'>You are a HONKsquad. [!honk_leader_selected ? "commando" : "<B>LEADER</B>"] in the service of Clown Planet. You are called in cases of exteme low levels of HONK. You are NOT authorized to kill.\nYour current mission is: <span class='danger'>[input]</span></span>")

			honksquad_number--


	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned a HONKsquad.</span>", 1)
	log_admin("[key_name(usr)] used Spawn HONKsquad.")
	return 1

/client/proc/create_honksquad(obj/spawn_location, honk_leader_selected = 0)
	var/mob/living/carbon/human/new_honksquad = new(spawn_location.loc)
	var/honksquad_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/honksquad_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/honksquad_name = pick(GLOB.clown_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(honk_leader_selected)
		A.age = rand(35,45)
		A.real_name = "[honksquad_leader_rank] [honksquad_name]"
	else
		A.real_name = "[honksquad_rank] [honksquad_name]"
	A.copy_to(new_honksquad)

	new_honksquad.dna.ready_dna(new_honksquad)//Creates DNA.

	//Creates mind stuff.
	new_honksquad.mind_initialize()
	new_honksquad.mind.assigned_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.special_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.offstation_role = TRUE
	new_honksquad.add_language("Clownish")
	SSticker.mode.traitors |= new_honksquad.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	new_honksquad.equip_honksquad(honk_leader_selected)
	return new_honksquad

/mob/living/carbon/human/proc/equip_honksquad(honk_leader_selected = 0)

	var/obj/item/radio/R = new /obj/item/radio/headset(src)
	R.set_frequency(1442)
	equip_to_slot_or_del(R, slot_l_ear)
	equip_to_slot_or_del(new /obj/item/storage/backpack/clown(src), slot_back)
	equip_to_slot_or_del(new /obj/item/storage/box/survival(src), slot_in_backpack)
	if(src.gender == FEMALE)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat/sexy(src), slot_wear_mask)
		equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown/sexy(src), slot_w_uniform)
	else
		equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(src), slot_w_uniform)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/pda/clown(src), slot_wear_pda)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/grown/banana(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/bikehorn(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/stamp/clown(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/toy/crayon/rainbow(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/reagent_containers/spray/waterflower(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/reagent_containers/food/pill/patch/jestosterone(src), slot_r_store)
	if(prob(50))
		equip_to_slot_or_del(new /obj/item/gun/energy/clown(src), slot_in_backpack)
	else
		equip_to_slot_or_del(new /obj/item/gun/throw/piecannon(src), slot_in_backpack)
	src.mutations.Add(CLUMSY)



	var/obj/item/card/id/W = new(src)
	W.name = "[real_name]'s ID Card"
	W.icon_state = "centcom_old"
	W.access = list(access_clown)//They get full station access.
	W.assignment = "HONKsquad"
	W.registered_name = real_name
	equip_to_slot_or_del(W, slot_wear_id)

	return 1
