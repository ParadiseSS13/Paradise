//HONKsquad

#define HONKSQUAD_POSSIBLE 6 //if more Commandos are needed in the future
GLOBAL_VAR_INIT(sent_honksquad, 0)
GLOBAL_VAR_INIT(sent_clownsequritysquad, 0)

/client/proc/honksquad()
	if(!SSticker)
		to_chat(usr, "<font color='red'>The game hasn't started yet!</font>")
		return
	if(world.time < 6000)
		to_chat(usr, "<font color='red'>There are [(6000-world.time)/10] seconds remaining before it may be called.</font>")
		return
	if(alert("Do you want to send in the HONKsquad? Once enabled, this is irreversible.",,"Yes","No")!="Yes")
		return
	var/is_security_clowns = FALSE
	if(alert("Какую группу вы хотите послать?",,"ХОНК-сквад","ХОНК-смотрители")=="ХОНК-смотрители")
		is_security_clowns = TRUE
		GLOB.sent_clownsequritysquad += 1
	else
		GLOB.sent_honksquad += 1

	if(GLOB.sent_honksquad > 1 && !is_security_clowns || GLOB.sent_clownsequritysquad > 1 && is_security_clowns)
		to_chat(usr, "<font color='red'>Clown Planet has already dispatched that HONKsquad.</font>")
		return
	alert("This 'mode' will go on until proper levels of HONK have been restored. You may also admin-call the evac shuttle when appropriate. Assigning the team's detailed task is recommended from there. While you will be able to manually pick the candidates from active ghosts, their assignment in the squad will be random.")

	var/input = null
	while(!input)
		input = sanitize(copytext_char(input(src, "Please specify which mission the HONKsquad shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
		if(!input)
			if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
				return


	var/honksquad_number = HONKSQUAD_POSSIBLE //for selecting a leader
	var/honk_leader_selected = 0 //when the leader is chosen. The last person spawned.


//Generates a list of HONKsquad from active ghosts. Then the user picks which characters to respawn as the commandos.
	var/list/candidates = list()	//candidates for being a commando out of all the active ghosts in world.
	var/list/commandos = list()			//actual commando ghosts as picked by the user.
	for(var/mob/dead/observer/G	 in GLOB.player_list)
		if(!G.client.holder && !G.client.is_afk())	//Whoever called/has the proc won't be added to the list.
			if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
				candidates += G.key
	for(var/i=HONKSQUAD_POSSIBLE,(i>0&&candidates.len),i--)//Decrease with every commando selected.
		var/candidate = input("Pick characters to spawn as the HONKsquad. This will go on until there either no more ghosts to pick from or the slots are full.", "Active Players") as null|anything in candidates	//It will auto-pick a person when there is only one candidate.
		candidates -= candidate		//Subtract from candidates.
		commandos += candidate//Add their ghost to commandos.

//Spawns HONKsquad and equips them.
	for(var/thing in GLOB.landmarks_list)
		var/obj/effect/landmark/L = thing
		if(honksquad_number<=0)	break
		if(L.name == "HONKsquad")
			honk_leader_selected = (honksquad_number == HONKSQUAD_POSSIBLE ? 1 : 0)

			var/mob/living/carbon/human/new_honksquad = is_security_clowns ? create_honksquad_security(L, honk_leader_selected) : create_honksquad(L, honk_leader_selected)

			if(commandos.len)
				new_honksquad.key = pick(commandos)
				commandos -= new_honksquad.key
				new_honksquad.internal = new_honksquad.s_store
				new_honksquad.update_action_buttons_icon()

			//So they don't forget their code or mission.
			new_honksquad.mind.store_memory("<B>Mission:</B> <span class='warning'>[input].</span>")

			to_chat(new_honksquad, "<span class='notice'>You are a HONKsquad. [!honk_leader_selected ? "commando" : "<B>LEADER</B>"] in the service of Clown Planet. You are called in cases of exteme low levels of HONK. You are NOT authorized to kill.\nYour current mission is: <span class='danger'>[input]</span></span>")

			honksquad_number--


	log_and_message_admins("used Spawn HONKsquad.")
	return 1

/client/proc/create_honksquad(obj/spawn_location, honk_leader_selected = 0)
	var/mob/living/carbon/human/new_honksquad = new(spawn_location.loc)
	var/honksquad_leader_rank = pick("Лейтенант", "Капитан", "Майор")
	var/honksquad_rank = pick("Младший Сержант", "Сержант", "Старший Сержант", "Старшина", "Прапорщик", "Старший Прапорщик")
	var/honksquad_name = pick(GLOB.clown_names)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	if(honk_leader_selected)
		A.age = rand(35,45)
		A.real_name = "[honksquad_leader_rank] [honksquad_name]"
	else
		A.real_name = "[honksquad_rank] [honksquad_name]"
	var/rankName = honk_leader_selected ? honksquad_leader_rank : honksquad_rank
	A.copy_to(new_honksquad)

	new_honksquad.dna.ready_dna(new_honksquad)//Creates DNA.

	//Creates mind stuff.
	new_honksquad.mind_initialize()
	new_honksquad.mind.assigned_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.special_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.offstation_role = TRUE
	new_honksquad.add_language("Clownish")
	SSticker.mode.traitors |= new_honksquad.mind//Adds them to current traitor list. Which is really the extra antagonist list.
	new_honksquad.equip_honksquad(honk_leader_selected, rankName)
	return new_honksquad

/mob/living/carbon/human/proc/equip_honksquad(honk_leader_selected = 0, var/rankName)

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
	equip_to_slot_or_del(new /obj/item/clown_recorder(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/stamp/clown(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/toy/crayon/rainbow(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/reagent_containers/spray/waterflower(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/reagent_containers/food/pill/patch/jestosterone(src), slot_r_store)
	if(prob(50))
		equip_to_slot_or_del(new /obj/item/gun/energy/clown(src), slot_in_backpack)
	else
		equip_to_slot_or_del(new /obj/item/gun/throw/piecannon(src), slot_in_backpack)
	src.mutations.Add(CLUMSY)
	var/obj/item/implant/sad_trombone/S = new/obj/item/implant/sad_trombone(src)
	S.implant(src)


	var/obj/item/card/id/I = new(src)
	apply_to_card(I, src, list(ACCESS_CLOWN), "[rankName] ХОНК-отряда", "HONKsquad", "clownsquad")
	I.rank = "HONKsquad"
	I.icon_state = "clownsquad"
	equip_to_slot_or_del(I, slot_wear_id)

	return 1

/client/proc/create_honksquad_security(obj/spawn_location, honk_leader_selected = 0)
	var/mob/living/carbon/human/new_honksquad = new(spawn_location.loc)

	new_honksquad.dna.ready_dna(new_honksquad)//Creates DNA.

	//Creates mind stuff.
	new_honksquad.mind_initialize()
	new_honksquad.mind.assigned_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.special_role = SPECIAL_ROLE_HONKSQUAD
	new_honksquad.mind.offstation_role = TRUE
	SSticker.mode.traitors |= new_honksquad.mind//Adds them to current traitor list. Which is really the extra antagonist list.

	//экипируем уже готовы пресетом
	if(honk_leader_selected)
		new_honksquad.equipOutfit(/datum/outfit/admin/clown_security/warden)
	else
		if(prob(25))
			new_honksquad.equipOutfit(/datum/outfit/admin/clown_security/physician)
		else
			new_honksquad.equipOutfit(/datum/outfit/admin/clown_security)

	return new_honksquad
