/obj/effect/landmark/human
	mob_type = /mob/living/carbon/human
	//Human specific stuff.
	var/mob_species = null //Set to make them a mutant race such as lizard or skeleton. Uses the datum typepath instead of the ID.
	var/uniform = null //Set this to an object path to have the slot filled with said object on the corpse.
	var/r_hand = null
	var/l_hand = null
	var/suit = null
	var/shoes = null
	var/gloves = null
	var/l_ear = null
	var/r_ear = null
	var/radio = null
	var/glasses = null
	var/mask = null
	var/helmet = null
	var/belt = null
	var/pocket1 = null
	var/pocket2 = null
	var/back = null
	var/has_id = 0     //Just set to 1 if you want them to have an ID
	var/id_job = null // Needs to be in quotes, such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/id_access = null //This is for access. See access.dm for which jobs give what access. Again, put in quotes. Use "Captain" if you want it to be all access.
	var/id_icon = null //For setting it to be a gold, silver, centcom etc ID
	var/husk = null
	var/outfit_type = null // Will start with this if exists then apply specific slots
var/list/implants = list()

/obj/effect/landmark/attack_ghost(mob/user)
	if(ticker.current_state != GAME_STATE_PLAYING || !loc)
		return
	if(!uses)
		to_chat(user, "<span class='warning'>This spawner is out of charges!</span>")
		return
	if(jobban_type && jobban_isbanned(user, jobban_type))
		to_chat(user, "<span class='warning'>You are banned from this role.</span>")
		return
	var/ghost_role = alert("Become [mob_name]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role == "No" || !loc)
		return
	log_game("[user.ckey] became [mob_name]")
	create(ckey = user.ckey)

/obj/effect/landmark/spawn_atom_to_world()
	//We no longer need to spawn mobs, deregister ourself
	SSobj.atom_spawners -= src
	if(roundstart)
		create()
	else
		poi_list |= src

/obj/effect/landmark/New()
	..()
	if(roundstart)
		//Add to the atom spawners register for roundstart atom spawning
		SSobj.atom_spawners += src

	if(instant)
		create()
	else
		poi_list |= src

/obj/effect/landmark/Destroy()
	poi_list.Remove(src)
	..()

/obj/effect/landmark/proc/special(mob/M)
	return

/obj/effect/landmark/proc/equip(mob/M)
	return

/obj/effect/landmark/proc/create(ckey)
	var/mob/living/M = new mob_type(get_turf(src)) //living mobs only
	if(!random)
		M.real_name = mob_name ? mob_name : M.name
		M.gender = mob_gender
	if(faction)
		M.faction = list(faction)
	if(death)
		M.death(1) //Kills the new mob

	M.adjustOxyLoss(oxy_damage)
	M.adjustBruteLoss(brute_damage)
	equip(M)

	if(ckey)
		M.ckey = ckey
		to_chat(M, "[flavour_text]")
		var/datum/mind/MM = M.mind
		if(objectives)
			for(var/objective in objectives)
				MM.objectives += new/datum/objective(objective)
		special(M)
		MM.name = M.real_name
		MM.special_role = name
		if(MM.assigned_role)
			MM.assigned_role = assigned_role
	if(uses > 0)
		uses--
	if(!permanent && !uses)
qdel(src)

/obj/effect/landmark/human/equip(mob/living/carbon/human/H)
	if(mob_species)
		H.set_species(mob_species)
	if(husk)
		H.Drain()
	if(outfit_type)
		H.equipOutfit(outfit_type)
	if(uniform)
		H.equip_to_slot_or_del(new uniform(H), slot_w_uniform)
	if(suit)
		H.equip_to_slot_or_del(new suit(H), slot_wear_suit)
	if(shoes)
		H.equip_to_slot_or_del(new shoes(H), slot_shoes)
	if(gloves)
		H.equip_to_slot_or_del(new gloves(H), slot_gloves)
	if(radio)
		H.equip_to_slot_or_del(new radio(H), slot_l_ear)
	if(glasses)
		H.equip_to_slot_or_del(new glasses(H), slot_glasses)
	if(mask)
		H.equip_to_slot_or_del(new mask(H), slot_wear_mask)
	if(helmet)
		H.equip_to_slot_or_del(new helmet(H), slot_head)
	if(belt)
		H.equip_to_slot_or_del(new belt(H), slot_belt)
	if(pocket1)
		H.equip_to_slot_or_del(new pocket1(H), slot_r_store)
	if(pocket2)
		H.equip_to_slot_or_del(new pocket2(H), slot_l_store)
	if(back)
		H.equip_to_slot_or_del(new back(H), slot_back)
	if(l_hand)
		H.equip_to_slot_or_del(new l_hand(H), slot_l_hand)
	if(r_hand)
		H.equip_to_slot_or_del(new r_hand(H), slot_r_hand)
	if(has_id)
		var/obj/item/weapon/card/id/W = new(H)
		if(id_icon)
			W.icon_state = id_icon
		if(id_access)
			var/datum/job/jobdatum
			for(var/jobtype in typesof(/datum/job))
				var/datum/job/J = new jobtype
				if(J.title == id_access)
					jobdatum = J
					break
			if(jobdatum)
				W.access = jobdatum.get_access()
			else
				W.access = list()

		if(id_job)
			W.assignment = id_job

		W.update_label(H.real_name)
		H.equip_to_slot_or_del(W, slot_wear_id)

	for(var/I in implants)
		var/obj/item/weapon/implant/X = new I
		X.implant(H)