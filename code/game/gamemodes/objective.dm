GLOBAL_LIST_EMPTY(all_objectives)

GLOBAL_LIST_INIT(potential_theft_objectives, (subtypesof(/datum/theft_objective) - /datum/theft_objective/steal - /datum/theft_objective/number - /datum/theft_objective/unique))

/datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.
	var/martyr_compatible = 0			//If the objective is compatible with martyr objective, i.e. if you can still do it while dead.
	var/check_cryo = TRUE				 //if the objective goes cryo, do we check for a new objective or ignore it

/datum/objective/New(text)
	GLOB.all_objectives += src
	if(text)
		explanation_text = text

/datum/objective/Destroy()
	GLOB.all_objectives -= src
	return ..()

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/is_invalid_target(datum/mind/possible_target)
	if(possible_target == owner)
		return TARGET_INVALID_IS_OWNER
	for(var/datum/objective/objective in owner.objectives)
		if(istype(objective) && objective.target == possible_target)
			return TARGET_INVALID_IS_TARGET
	if(!ishuman(possible_target.current))
		return TARGET_INVALID_NOT_HUMAN
	if(possible_target.current.stat == DEAD)
		return TARGET_INVALID_DEAD
	if(!possible_target.key)
		return TARGET_INVALID_NOCKEY
	if(possible_target.current)
		var/turf/current_location = get_turf(possible_target.current)
		if(current_location && !is_level_reachable(current_location.z))
			return TARGET_INVALID_UNREACHABLE
	if(isgolem(possible_target.current))
		return TARGET_INVALID_GOLEM
	if(possible_target.offstation_role)
		return TARGET_INVALID_EVENT


/datum/objective/proc/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(is_invalid_target(possible_target))
			continue
		possible_targets[possible_target.assigned_role] += list(possible_target)

	if(possible_targets.len > 0)
		var/target_role = pick(possible_targets)
		target = pick(possible_targets[target_role])

/**
  * Called when the objective's target goes to cryo.
  */
/datum/objective/proc/on_target_cryo()
	if(!check_cryo)
		return
	if(owner?.current)
		to_chat(owner.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
		SEND_SOUND(owner.current, 'sound/ambience/alarm4.ogg')
	SSticker.mode.victims.Remove(target)
	target = null
	INVOKE_ASYNC(src, .proc/post_target_cryo)

/**
  * Called a tick after when the objective's target goes to cryo.
  */
/datum/objective/proc/post_target_cryo()
	find_target()
	if(!target)
		GLOB.all_objectives -= src
		owner?.objectives -= src
		qdel(src)
	owner?.announce_objectives()

/datum/objective/assassinate
	martyr_compatible = 1

/datum/objective/assassinate/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		if (!(target in SSticker.mode.victims))
			SSticker.mode.victims.Add(target)
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/assassinate/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return 1
		if(issilicon(target.current) || isbrain(target.current)) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return 1
		if(!target.current.ckey)
			return 1
		return 0
	return 1



/datum/objective/mutiny
	martyr_compatible = 1

/datum/objective/mutiny/find_target()
	..()
	if(target && target.current)
		explanation_text = "Exile or assassinate [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/mutiny/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return 1
		if(!target.current.ckey)
			return 1
		if(issilicon(target.current))
			return 1
		if(isbrain(target.current))
			return 1
		var/turf/T = get_turf(target.current)
		if(is_admin_level(T.z))
			return 0
		return 1
	return 1

/datum/objective/mutiny/on_target_cryo()
	// We don't want revs to get objectives that aren't for heads of staff. Letting
	// them win or lose based on cryo is silly so we remove the objective.
	qdel(src)


/datum/objective/maroon
	martyr_compatible = 1

/datum/objective/maroon/find_target()
	..()
	if(target && target.current)
		explanation_text = "Prevent from escaping alive or assassinate [target.current.real_name], the [target.assigned_role]."
		if (!(target in SSticker.mode.victims))
			SSticker.mode.victims.Add(target)
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/maroon/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return 1
		if(!target.current.ckey)
			return 1
		if(issilicon(target.current))
			return 1
		if(isbrain(target.current))
			return 1
		if(isalien(target.current))
			return 1
		var/turf/T = get_turf(target.current)
		if(is_admin_level(T.z))
			return 0
		return 1
	return 1


/datum/objective/debrain //I want braaaainssss
	martyr_compatible = 0

/datum/objective/debrain/find_target()
	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name] the [target.assigned_role]."
		if (!(target in SSticker.mode.victims))
			SSticker.mode.victims.Add(target)
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/debrain/check_completion()
	if(!target)//If it's a free objective.
		return 1
	if(!owner.current || owner.current.stat == DEAD)
		return 0
	if(!target.current || !isbrain(target.current))
		return 0
	var/atom/A = target.current
	while(A.loc)			//check to see if the brainmob is on our person
		A = A.loc
		if(A == owner.current)
			return 1
	return 0


/datum/objective/protect //The opposite of killing a dude.
	martyr_compatible = 1

/datum/objective/protect/find_target()
	var/list/datum/mind/temp_victims = SSticker.mode.victims.Copy()
	for(var/datum/objective/objective in owner.objectives)
		temp_victims.Remove(objective.target)
	temp_victims.Remove(owner)

	if (length(temp_victims))
		target = pick(temp_victims)
	else
		..()

	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/protect/check_completion()
	if(!target) //If it's a free objective.
		return TRUE
	if(target.current)
		if(target.current.stat == DEAD)
			return FALSE
		if(isbrain(target.current))
			return FALSE
		if(!iscarbon(target.current))
			return FALSE
		return TRUE
	return FALSE

/datum/objective/protect/mindslave //subtype for mindslave implants


/datum/objective/hijack
	martyr_compatible = 0 //Technically you won't get both anyway.
	explanation_text = "Hijack the shuttle by escaping on it with no loyalist Nanotrasen crew on board and free. \
	Syndicate agents, other enemies of Nanotrasen, cyborgs, pets, and cuffed/restrained hostages may be allowed on the shuttle alive."

/datum/objective/hijack/check_completion()
	if(!owner.current || owner.current.stat)
		return 0
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return 0
	if(issilicon(owner.current))
		return 0

	var/area/A = get_area(owner.current)
	if(SSshuttle.emergency.areaInstance != A)
		return 0

	return SSshuttle.emergency.is_hijacked()

/datum/objective/hijackclone
	explanation_text = "Hijack the shuttle by ensuring only you (or your copies) escape."
	martyr_compatible = 0

/datum/objective/hijackclone/check_completion()
	if(!owner.current)
		return 0
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return 0

	var/area/A = SSshuttle.emergency.areaInstance

	for(var/mob/living/player in GLOB.player_list) //Make sure nobody else is onboard
		if(player.mind && player.mind != owner)
			if(player.stat != DEAD)
				if(issilicon(player))
					continue
				if(get_area(player) == A)
					if(player.real_name != owner.current.real_name && !istype(get_turf(player.mind.current), /turf/simulated/floor/shuttle/objective_check))
						return 0

	for(var/mob/living/player in GLOB.player_list) //Make sure at least one of you is onboard
		if(player.mind && player.mind != owner)
			if(player.stat != DEAD)
				if(issilicon(player))
					continue
				if(get_area(player) == A)
					if(player.real_name == owner.current.real_name && !istype(get_turf(player.mind.current), /turf/simulated/floor/shuttle/objective_check))
						return 1
	return 0

/datum/objective/block
	explanation_text = "Do not allow any lifeforms, be it organic or synthetic to escape on the shuttle alive. AIs, Cyborgs, Maintenance drones, and pAIs are not considered alive."
	martyr_compatible = 1

/datum/objective/block/check_completion()
	if(!istype(owner.current, /mob/living/silicon))
		return 0
	if(SSticker.mode.station_was_nuked)
		return TRUE
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return 0
	if(!owner.current)
		return 0

	var/area/A = SSshuttle.emergency.areaInstance

	for(var/mob/living/player in GLOB.player_list)
		if(issilicon(player))
			continue // If they're silicon, they're not considered alive, skip them.

		if(player.mind && player.stat != DEAD)
			if(get_area(player) == A)
				return 0 // If there are any other organic mobs on the shuttle, you failed the objective.

	return 1

/datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and free."

/datum/objective/escape/check_completion()
	if(issilicon(owner.current))
		return 0
	if(isbrain(owner.current))
		return 0
	if(!owner.current || owner.current.stat == DEAD)
		return 0
	if(SSticker.force_ending) //This one isn't their fault, so lets just assume good faith
		return 1
	if(SSticker.mode.station_was_nuked) //If they escaped the blast somehow, let them win
		return 1
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return 0
	var/turf/location = get_turf(owner.current)
	if(!location)
		return 0

	if(istype(location, /turf/simulated/floor/shuttle/objective_check) || istype(location, /turf/simulated/floor/mineral/plastitanium/red/brig)) // Fails traitors if they are in the shuttle brig -- Polymorph
		return 0

	if(location.onCentcom() || location.onSyndieBase())
		return 1

	return 0


/datum/objective/escape/escape_with_identity
	var/target_real_name // Has to be stored because the target's real_name can change over the course of the round

/datum/objective/escape/escape_with_identity/find_target()
	var/list/possible_targets = list() //Copypasta because NO_DNA races, yay for snowflakes.
	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && possible_target.current.client)
			var/mob/living/carbon/human/H = possible_target.current
			if(!(NO_DNA in H.dna.species.species_traits))
				possible_targets += possible_target
	if(possible_targets.len > 0)
		target = pick(possible_targets)
	if(target && target.current)
		target_real_name = target.current.real_name
		if (!(target in SSticker.mode.victims))
			SSticker.mode.victims.Add(target)
		explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role] while wearing [target.p_their()] identification card."
	else
		explanation_text = "Free Objective"

/datum/objective/escape/escape_with_identity/check_completion()
	if(!target_real_name)
		return 1
	if(!ishuman(owner.current))
		return 0
	var/mob/living/carbon/human/H = owner.current
	if(..())
		if(H.dna.real_name == target_real_name)
			if(H.get_id_name()== target_real_name)
				return 1
	return 0

/datum/objective/die
	explanation_text = "Die a glorious death."

/datum/objective/die/check_completion()
	if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
		return 1
	if(issilicon(owner.current) && owner.current != owner.original)
		return 1
	return 0



/datum/objective/survive
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
		return 0		//Brains no longer win survive objectives. --NEO
	if(issilicon(owner.current) && owner.current != owner.original)
		return 0
	return 1

/datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."
	martyr_compatible = 1

/datum/objective/steal
	var/datum/theft_objective/steal_target
	martyr_compatible = 0
	var/theft_area

/datum/objective/steal/proc/get_location()
	if(steal_target.location_override)
		return steal_target.location_override
	var/list/obj/item/steal_candidates = get_all_of_type(steal_target.typepath, subtypes = TRUE)
	for(var/obj/item/candidate in steal_candidates)
		if(!is_admin_level(candidate.loc.z))
			theft_area = get_area(candidate.loc)
			return "[theft_area]"
	return "an unknown area"

/datum/objective/steal/find_target()
	var/list/valid_theft_objectives = list()
	for(var/thefttype in GLOB.potential_theft_objectives)
		for(var/datum/objective/steal/objective in owner.objectives)
			if(istype(objective) && istype(objective.steal_target, thefttype))
				continue
		var/datum/theft_objective/O = new thefttype
		if(O.flags & 2)
			continue
		if(owner.assigned_role in O.protected_jobs)
			continue
		valid_theft_objectives += O
	if(length(valid_theft_objectives))
		var/datum/theft_objective/O = pick(valid_theft_objectives)
		steal_target = O

		explanation_text = "Steal [steal_target]. One was last seen in [get_location()]. "
		if(islist(O.protected_jobs) && O.protected_jobs.len)
			explanation_text += "It may also be in the possession of the [jointext(O.protected_jobs, ", ")]."
		return

	explanation_text = "Free Objective."


/datum/objective/steal/proc/select_target()
	var/list/possible_items_all = GLOB.potential_theft_objectives+"custom"
	var/new_target = input("Select target:", "Objective target", null) as null|anything in possible_items_all
	if(!new_target) return
	if(new_target == "custom")
		var/datum/theft_objective/O=new
		O.typepath = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if(!O.typepath) return
		var/tmp_obj = new O.typepath
		var/custom_name = tmp_obj:name
		qdel(tmp_obj)
		O.name = sanitize(copytext_char(input("Enter target name:", "Objective target", custom_name) as text|null,1,MAX_NAME_LEN))
		if(!O.name) return
		steal_target = O
		explanation_text = "Steal [O.name]."
	else
		steal_target = new new_target
		explanation_text = "Steal [steal_target.name]."
	return steal_target

/datum/objective/steal/check_completion()
	if(!steal_target)
		return 1 // Free Objective

	if(!owner.current)
		return FALSE

	var/list/all_items = owner.current.GetAllContents()

	for(var/obj/I in all_items)
		if(istype(I, steal_target.typepath))
			return steal_target.check_special_completion(I)
		if(I.type in steal_target.altitems)
			return steal_target.check_special_completion(I)


/datum/objective/steal/exchange
	martyr_compatible = 0

/datum/objective/steal/exchange/proc/set_faction(var/faction,var/otheragent)
	target = otheragent
	var/datum/theft_objective/unique/targetinfo
	if(faction == "red")
		targetinfo = new /datum/theft_objective/unique/docs_blue
	else if(faction == "blue")
		targetinfo = new /datum/theft_objective/unique/docs_red
	explanation_text = "Acquire [targetinfo.name] held by [target.current.real_name], the [target.assigned_role] and syndicate agent"
	steal_target = targetinfo

/datum/objective/steal/exchange/backstab
/datum/objective/steal/exchange/backstab/set_faction(var/faction)
	var/datum/theft_objective/unique/targetinfo
	if(faction == "red")
		targetinfo = new /datum/theft_objective/unique/docs_red
	else if(faction == "blue")
		targetinfo = new /datum/theft_objective/unique/docs_blue
	explanation_text = "Do not give up or lose [targetinfo.name]."
	steal_target = targetinfo

/datum/objective/download
/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(10,20)
	explanation_text = "Download [target_amount] research levels."
	return target_amount


/datum/objective/download/check_completion()
	return 0



/datum/objective/capture
/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	explanation_text = "Accumulate [target_amount] capture points."
	return target_amount


/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	return 0




/datum/objective/absorb
/datum/objective/absorb/proc/gen_amount_goal(var/lowbound = 4, var/highbound = 6)
	target_amount = rand (lowbound,highbound)
	if(SSticker)
		var/n_p = 1 //autowin
		if(SSticker.current_state == GAME_STATE_SETTING_UP)
			for(var/mob/new_player/P in GLOB.player_list)
				if(P.client && P.ready && P.mind != owner)
					if(P.client.prefs && (P.client.prefs.species == "Machine")) // Special check for species that can't be absorbed. No better solution.
						continue
					n_p++
		else if(SSticker.current_state == GAME_STATE_PLAYING)
			for(var/mob/living/carbon/human/P in GLOB.player_list)
				if(NO_DNA in P.dna.species.species_traits)
					continue
				if(P.client && !(P.mind in SSticker.mode.changelings) && P.mind!=owner)
					n_p++
		target_amount = min(target_amount, n_p)

	explanation_text = "Acquire [target_amount] compatible genomes. The 'Extract DNA Sting' can be used to stealthily get genomes without killing somebody."
	return target_amount

/datum/objective/absorb/check_completion()
	if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
		return 1
	else
		return 0

/datum/objective/destroy
	martyr_compatible = 1
	var/target_real_name

/datum/objective/destroy/find_target()
	var/list/possible_targets = active_ais(1)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	if(target && target.current)
		target_real_name = target.current.real_name
		explanation_text = "Destroy [target_real_name], the AI."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/destroy/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || is_away_level(target.current.z) || !target.current.ckey)
			return 1
		return 0
	return 1

/datum/objective/steal_five_of_type
	explanation_text = "Steal at least five items!"
	var/list/wanted_items = list()

/datum/objective/steal_five_of_type/New()
	..()
	wanted_items = typecacheof(wanted_items)

/datum/objective/steal_five_of_type/check_completion()
	var/stolen_count = 0
	if(!isliving(owner.current))
		return FALSE
	var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
	for(var/obj/I in all_items) //Check for wanted items
		if(is_type_in_typecache(I, wanted_items))
			stolen_count++
	return stolen_count >= 5

/datum/objective/steal_five_of_type/summon_guns
	explanation_text = "Steal at least five guns!"
	wanted_items = list(/obj/item/gun)

/datum/objective/steal_five_of_type/summon_magic
	explanation_text = "Steal at least five magical artefacts!"
	wanted_items = list()

/datum/objective/steal_five_of_type/summon_magic/New()
	wanted_items = GLOB.summoned_magic_objectives
	..()

/datum/objective/steal_five_of_type/summon_magic/check_completion()
	var/stolen_count = 0
	if(!isliving(owner.current))
		return FALSE
	var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
	for(var/obj/I in all_items) //Check for wanted items
		if(istype(I, /obj/item/spellbook) && !istype(I, /obj/item/spellbook/oneuse))
			var/obj/item/spellbook/spellbook = I
			if(spellbook.uses) //if the book still has powers...
				stolen_count++ //it counts. nice.
		if(istype(I, /obj/item/spellbook/oneuse))
			var/obj/item/spellbook/oneuse/oneuse = I
			if(!oneuse.used)
				stolen_count++
		else if(is_type_in_typecache(I, wanted_items))
			stolen_count++
	return stolen_count >= 5

/datum/objective/blood
/datum/objective/blood/proc/gen_amount_goal(low = 150, high = 400)
	target_amount = rand(low,high)
	target_amount = round(round(target_amount/5)*5)
	explanation_text = "Накопить не менее [target_amount] единиц крови."
	return target_amount

/datum/objective/blood/check_completion()
	if(owner && owner.vampire && owner.vampire.bloodtotal && owner.vampire.bloodtotal >= target_amount)
		return 1
	else
		return 0

// /vg/; Vox Inviolate for humans :V
/datum/objective/minimize_casualties
	explanation_text = "Minimise casualties."

/datum/objective/minimize_casualties/check_completion()
	return TRUE


//Vox heist objectives.

/datum/objective/heist
/datum/objective/heist/proc/choose_target()
	return

/datum/objective/heist/kidnap
/datum/objective/heist/kidnap/choose_target()
	var/list/roles = list("Chief Engineer","Research Director","Roboticist","Chemist","Station Engineer")
	var/list/possible_targets = list()
	var/list/priority_targets = list()

	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && (possible_target.assigned_role != possible_target.special_role) && !possible_target.offstation_role)
			possible_targets += possible_target
			for(var/role in roles)
				if(possible_target.assigned_role == role)
					priority_targets += possible_target
					continue

	if(priority_targets.len > 0)
		target = pick(priority_targets)
	else if(possible_targets.len > 0)
		target = pick(possible_targets)

	if(target && target.current)
		explanation_text = "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take [target.current.p_them()] alive."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/heist/kidnap/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return 0

		var/area/shuttle/vox/A = locate() //stupid fucking hardcoding
		var/area/vox_station/B = locate() //but necessary

		for(var/mob/living/carbon/human/M in A)
			if(target.current == M)
				return 1
		for(var/mob/living/carbon/human/M in B)
			if(target.current == M)
				return 1
	else
		return 0

/datum/objective/heist/loot
/datum/objective/heist/loot/choose_target()
	var/loot = "an object"
	switch(rand(1,8))
		if(1)
			target = /obj/structure/particle_accelerator
			target_amount = 6
			loot = "a complete particle accelerator"
		if(2)
			target = /obj/machinery/the_singularitygen
			target_amount = 1
			loot = "a gravitational singularity generator"
		if(3)
			target = /obj/machinery/power/emitter
			target_amount = 4
			loot = "four emitters"
		if(4)
			target = /obj/machinery/nuclearbomb
			target_amount = 1
			loot = "a nuclear bomb"
		if(5)
			target = /obj/item/gun
			target_amount = 6
			loot = "six guns. Tasers and other non-lethal guns are acceptable"
		if(6)
			target = /obj/item/gun/energy
			target_amount = 4
			loot = "four energy guns"
		if(7)
			target = /obj/item/gun/energy/laser
			target_amount = 2
			loot = "two laser guns"
		if(8)
			target = /obj/item/gun/energy/ionrifle
			target_amount = 1
			loot = "an ion gun"

	explanation_text = "We are lacking in hardware. Steal or trade [loot]."

/datum/objective/heist/loot/check_completion()
	var/total_amount = 0

	for(var/obj/O in locate(/area/shuttle/vox))
		if(istype(O, target))
			total_amount++
		for(var/obj/I in O.contents)
			if(istype(I, target))
				total_amount++
			if(total_amount >= target_amount)
				return 1

	for(var/obj/O in locate(/area/vox_station))
		if(istype(O, target))
			total_amount++
		for(var/obj/I in O.contents)
			if(istype(I, target))
				total_amount++
			if(total_amount >= target_amount)
				return 1

	var/datum/game_mode/heist/H = SSticker.mode
	for(var/datum/mind/raider in H.raiders)
		if(raider.current)
			for(var/obj/O in raider.current.get_contents())
				if(istype(O,target))
					total_amount++
				if(total_amount >= target_amount)
					return 1

	return 0

/datum/objective/heist/salvage
/datum/objective/heist/salvage/choose_target()
	switch(rand(1,8))
		if(1)
			target = "metal"
			target_amount = 300
		if(2)
			target = "glass"
			target_amount = 200
		if(3)
			target = "plasteel"
			target_amount = 100
		if(4)
			target = "solid plasma"
			target_amount = 100
		if(5)
			target = "silver"
			target_amount = 50
		if(6)
			target = "gold"
			target_amount = 20
		if(7)
			target = "uranium"
			target_amount = 20
		if(8)
			target = "diamond"
			target_amount = 20

	explanation_text = "Ransack or trade with the station and escape with [target_amount] [target]."

/datum/objective/heist/salvage/check_completion()
	var/total_amount = 0

	for(var/obj/item/O in locate(/area/shuttle/vox))
		var/obj/item/stack/sheet/S
		if(istype(O,/obj/item/stack/sheet))
			if(O.name == target)
				S = O
				total_amount += S.get_amount()

		for(var/obj/I in O.contents)
			if(istype(I,/obj/item/stack/sheet))
				if(I.name == target)
					S = I
					total_amount += S.get_amount()

	for(var/obj/item/O in locate(/area/vox_station))
		var/obj/item/stack/sheet/S
		if(istype(O,/obj/item/stack/sheet))
			if(O.name == target)
				S = O
				total_amount += S.get_amount()

		for(var/obj/I in O.contents)
			if(istype(I,/obj/item/stack/sheet))
				if(I.name == target)
					S = I
					total_amount += S.get_amount()

	var/datum/game_mode/heist/H = SSticker.mode
	for(var/datum/mind/raider in H.raiders)
		if(raider.current)
			for(var/obj/item/O in raider.current.get_contents())
				if(istype(O,/obj/item/stack/sheet))
					if(O.name == target)
						var/obj/item/stack/sheet/S = O
						total_amount += S.get_amount()

	if(total_amount >= target_amount) return 1
	return 0


/datum/objective/heist/inviolate_crew
	explanation_text = "Do not leave any Vox behind, alive or dead."

/datum/objective/heist/inviolate_crew/check_completion()
	var/datum/game_mode/heist/H = SSticker.mode
	if(H.is_raider_crew_safe())
		return 1
	return 0

/datum/objective/heist/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."

/datum/objective/heist/inviolate_death/check_completion()
	return TRUE

// Traders
// These objectives have no check_completion, they exist only to tell Sol Traders what to aim for.

/datum/objective/trade/proc/choose_target()
	return

/datum/objective/trade/plasma/choose_target()
	explanation_text = "Acquire at least 15 sheets of plasma through trade."

/datum/objective/trade/credits/choose_target()
	explanation_text = "Acquire at least 10,000 credits through trade."

//wizard

/datum/objective/wizchaos
	explanation_text = "Wreak havoc upon the station as much you can. Send those wandless Nanotrasen scum a message!"
	completed = 1

//Space Ninja

/datum/objective/cyborg_hijack
	explanation_text = "Используя свои перчатки обратите на свою сторону хотя бы одного киборга, чтобы он помог вам в саботаже станции!"

/datum/objective/plant_explosive
	///Where we should KABOOM
	var/area/detonation_location
	var/list/area_blacklist = list(
		/area/engine/engineering, /area/engine/supermatter,
		/area/toxins/test_area, /area/turret_protected/ai)

/datum/objective/plant_explosive/proc/choose_target_area()
	for(var/sanity in 1 to 100) // 100 checks at most.
		var/area/selected_area = pick(return_sorted_areas())
		if(selected_area && is_station_level(selected_area.z) && selected_area.valid_territory) //Целью должна быть зона на станции!
			if(selected_area in area_blacklist)
				continue
			detonation_location = selected_area
			break
	if(detonation_location)
		explanation_text = "Взорвите выданную вам бомбу в [detonation_location]. Учтите, что бомбу нельзя активировать на не предназначенной для подрыва территории!"

/datum/objective/plant_explosive/Destroy()
	. = ..()
	detonation_location = null

//Цель на добычу определённой суммы денег налом
/datum/objective/get_money
	var/req_amount = 75000

/datum/objective/get_money/check_completion()
	if(!owner.current)
		return FALSE
	if(!isliving(owner.current))
		return FALSE
	var/list/all_items = owner.current.get_contents()
	var/cash_summ = 0
	for(var/obj/I in all_items) //Check for items
		if(istype(I, /obj/item/stack/spacecash))
			var/obj/item/stack/spacecash/current_cash = I
			cash_summ += current_cash.amount
	if(cash_summ >= req_amount)
		return TRUE
	return FALSE


/datum/objective/protect/ninja //subtype for the ninja
	var/list/killers_objectives = list()

/datum/objective/protect/ninja/Destroy()
	if(killers_objectives)
		for(var/datum/objective/killer_objective in killers_objectives)
			GLOB.all_objectives -= killer_objective
			killer_objective.owner?.objectives -= killer_objective
			qdel(killer_objective)
	. = ..()

/datum/objective/protect/ninja/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(is_invalid_target(possible_target))
			continue
		possible_targets += possible_target
		if(killers_objectives.len)
			for(var/datum/objective/killer_objective in killers_objectives)
				possible_targets -= killer_objective.owner

	if(possible_targets.len > 0)
		if(target)
			if(target in possible_targets)
				possible_targets -= target

		target = pick(possible_targets)
	if(target && target.current)
		explanation_text = "На [target.current.real_name], \
		[target.assigned_role == target.special_role ? (target.special_role) : (target.assigned_role)] ведут охоту. \
		[target.current.real_name] должен любой ценой дожить до конца смены и ваша работа как можно незаметнее позаботится о том, чтобы он остался жив."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/protect/ninja/on_target_cryo()
	if(!check_cryo)
		return
	if(owner?.current)
		to_chat(owner.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
		SEND_SOUND(owner.current, 'sound/ambience/alarm4.ogg')
	INVOKE_ASYNC(src, .proc/post_target_cryo)

/datum/objective/protect/ninja/post_target_cryo()
	find_target()
	if(!target)
		GLOB.all_objectives -= src
		owner?.objectives -= src
		qdel(src)
	else
		update_killers()
	owner?.announce_objectives()

/datum/objective/protect/ninja/proc/update_killers()
	if(killers_objectives)
		for(var/datum/objective/killer_objective in killers_objectives)
			killer_objective.target = target
			if(istype(killer_objective, /datum/objective/assassinate))
				killer_objective.explanation_text = "Assassinate [killer_objective.target.current.real_name], the [killer_objective.target.assigned_role]."
			else if(istype(killer_objective, /datum/objective/maroon))
				killer_objective.explanation_text = "Prevent from escaping alive or assassinate [killer_objective.target.current.real_name], the [killer_objective.target.assigned_role]."
			killer_objective.owner?.announce_objectives()

//Цель на то чтобы подставить человека заставив сб его арестовать
/datum/objective/set_up
	martyr_compatible = 1

/datum/objective/set_up/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(is_invalid_target(possible_target))
			continue
		if(ismindshielded(possible_target.current))
			continue
		possible_targets[possible_target.assigned_role] += list(possible_target)
	if(possible_targets.len > 0)
		var/target_role = pick(possible_targets)
		target = pick(possible_targets[target_role])
	if(target && target.current)
		explanation_text = "Любым способом подставьте [target.current.real_name], [target.assigned_role], чтобы его лишили свободы. Но не убили!"
	else
		explanation_text = "Free Objective"
	return target

/**
  * Called when the objective's target goes to cryo.
  */
/datum/objective/set_up/on_target_cryo()
	if(check_completion())
		completed = TRUE
		return
	if(owner?.current)
		to_chat(owner.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
		SEND_SOUND(owner.current, 'sound/ambience/alarm4.ogg')
	if(!completed)
		target = null
		INVOKE_ASYNC(src, .proc/post_target_cryo)

/datum/objective/set_up/check_completion()
	if(issilicon(target.current))
		return 0
	if(isbrain(target.current))
		return 0
	if(!target.current || target.current.stat == DEAD)
		return 0
	// Проверка по наличию криминального статуса в консоли
	var/datum/data/record/target_record = find_security_record("name", target.name)
	if(target_record)
		if(target_record.fields["criminal"] == SEC_RECORD_STATUS_INCARCERATED || target_record.fields["criminal"] == SEC_RECORD_STATUS_EXECUTE || target_record.fields["criminal"] == SEC_RECORD_STATUS_PAROLLED || target_record.fields["criminal"] == SEC_RECORD_STATUS_RELEASED)
			return 1
	// Находится ли цель в карцере/камере/перме в конце раунда
	if(istype(target.current.lastarea, /area/security/prison/cell_block) || istype(target.current.lastarea, /area/security/permabrig) || istype(target.current.lastarea, /area/security/processing))
		return 1
	// Зона СБ на шатле эвакуации
	var/turf/location = get_turf(target.current)
	if(!location)
		return 0
	if(istype(location, /turf/simulated/floor/shuttle/objective_check) || istype(location, /turf/simulated/floor/mineral/plastitanium/red/brig))
		return 1

	return 0

// Цель на то, чтобы найти обладающего информацией человека. Всё что известно ниндзя - его предполагаемая профессия.
// Для выполнения этой цели - ниндзя должен похищать людей определённой профессии пока не найдёт ТОГО САМОГО засранца обладающего инфой.
// Либо пока не похитит достаточно людей (от 3 до 8(на 100 игроков))
/datum/objective/find_and_scan
	martyr_compatible = 1
	var/list/possible_roles = list()
	// Переменные ниже наполняются устройством для сканирования
	var/list/scanned_occupants = list()
	var/scans_to_win = 3

// Задание построено так, что даже без цели - выполнимо. Замена не нужна
/datum/objective/find_and_scan/on_target_cryo()
	return

/datum/objective/find_and_scan/find_target()
	var/list/roles = list("Clown", "Mime", "Cargo Technician",
	"Shaft Miner", "Scientist", "Roboticist",
	"Medical Doctor", "Geneticist", "Security Officer",
	"Chemist", "Station Engineer", "Civilian",
	"Botanist", "Chemist", "Virologist",
	"Life Support Specialist")
	var/list/possible_targets = list()
	var/list/priority_targets = list()
	if(!possible_roles.len)
		for(var/i in 1 to 3)
			var/role = pick(roles)
			possible_roles += role
			roles -= role
	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && (possible_target.assigned_role != possible_target.special_role) && !possible_target.offstation_role)
			possible_targets += possible_target
			for(var/role in possible_roles)
				if(possible_target.assigned_role == role)
					priority_targets += possible_target
					continue

	if(priority_targets.len > 0)
		target = pick(priority_targets)
	else if(possible_targets.len > 0)
		target = pick(possible_targets)

	if(target)
		if(!(target.assigned_role in possible_roles))
			possible_roles[pick(1,2,3)] = target.assigned_role
	scans_to_win = clamp(round(possible_targets.len/10),initial(scans_to_win), 6)
	//Даже если мы не нашли цель. Эту задачу всё ещё можно будет выполнить похитив достаточно разных человек с ролями
	explanation_text = "Найдите обладающего важной информацией человека среди следующих профессий: [possible_roles[1]], [possible_roles[2]], [possible_roles[3]]. \
		Для проверки и анализа памяти человека, вам придётся похитить его и просканировать в специальном устройстве на вашей базе."

	return target

/datum/objective/vermit_hunt
	martyr_compatible = 1
	var/req_kills

/datum/objective/vermit_hunt/find_target()
	generate_changelings()
	req_kills = max(1, round(length(SSticker.mode.changelings)/2))
	explanation_text = "На объекте вашей миссии действуют паразиты так же известные как \"Генокрады\" истребите хотя бы [req_kills] из них."

/datum/objective/vermit_hunt/proc/generate_changelings()
	var/list/possible_changelings = list()
	var/datum/game_mode/changeling/temp_gameMode = new
	for(var/mob/living/player in GLOB.alive_mob_list)
		if(player.client && player.mind && player.stat != DEAD)
			if((ishuman(player) && !player.mind.special_role))
				if(player.client && (ROLE_CHANGELING in player.client.prefs.be_special) && !jobban_isbanned(player, ROLE_CHANGELING))
					possible_changelings += player.mind
	for(var/datum/mind/player in possible_changelings)
		if(player.current)
			if(ismindshielded(player.current))
				possible_changelings -= player
			if(player.current.dna.species.name in temp_gameMode.protected_species)
				possible_changelings -= player
	if(possible_changelings.len)
		var/changeling_num = max(1, round((SSticker.mode.num_players_started())/(config.traitor_scaling))+1)
		for(var/j = 0, j < changeling_num, j++)
			var/datum/mind/new_changeling_mind = pick(possible_changelings)
			new_changeling_mind.make_Changeling()
			possible_changelings.Remove(new_changeling_mind)

/datum/objective/vermit_hunt/check_completion()
	var/killed_vermits = 0
	for(var/datum/mind/player in SSticker.mode.changelings)
		if(!player || !player.current || !player.current.ckey || player.current.stat == DEAD || issilicon(player.current) || isbrain(player.current))
			killed_vermits += 1
	if(killed_vermits >= req_kills)
		return TRUE
	return FALSE

/datum/objective/research_corrupt
	explanation_text = "Используя свои перчатки, загрузите мощный вирус на любой научный сервер станции, тем самым саботировав все их исследования! \
	Учтите, что установка займёт время и ИИ скорее всего будет уведомлён о вашей попытке взлома!"

/datum/objective/ai_corrupt
	explanation_text = "Используя свои перчатки, загрузите в ИИ станции специальный вирус через консоль для смены законов которая стоит в загрузочной. \
	Подойдёт только консоль в этой зоне из-за уязвимости оставленной заранее для вируса. \
	Учтите, что установка займёт время и ИИ скорее всего будет уведомлён о вашей попытке взлома!"
