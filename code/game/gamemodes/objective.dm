/// Stores a reference to every [objective][/datum/objective] which currently exists.
GLOBAL_LIST_EMPTY(all_objectives)
// Used in admin procs to give them a pretty list to look at, and to also have sane reusable code.
/// Stores objective [names][/datum/objective/var/name] as list keys, and their corresponding typepaths as list values.
GLOBAL_LIST_EMPTY(admin_objective_list)

GLOBAL_LIST_INIT(potential_theft_objectives, (subtypesof(/datum/theft_objective) - /datum/theft_objective/steal - /datum/theft_objective/number - /datum/theft_objective/unique))

/datum/objective
	/**
	 * Proper name of the objective. Not player facing, only shown to admins when adding objectives.
	 * Leave as null (or override to null) if you don't want admins to see that objective as a viable one to add (such as the mindslave objective).
	 */
	var/name
	/**
	 * Owner of the objective.
	 * Note that it's fine to set this directly, but when needing to check completion of the objective or otherwise check conditions on the owner of the objective,
	 * always use `get_owners()`, and check against ALL the owners. `get_owners()` accounts for objectives that may be team based and therefore have multiple owners.
	 */
	var/datum/mind/owner
	/// The target of the objective.
	var/datum/mind/target
	/// The team the objective belongs to, if any.
	var/datum/team/team
	/// What the owner is supposed to do to complete the objective.
	var/explanation_text = "Nothing"
	/// If the objective should have `find_target()` called for it.
	var/needs_target = TRUE
	/// If they are focused on a particular number. Steal objectives have their own counter.
	var/target_amount = 0
	/// If the objective has been completed.
	var/completed = FALSE
	/// If the objective is compatible with martyr objective, i.e. if you can still do it while dead.
	var/martyr_compatible = FALSE

	var/datum/objective_holder/holder

/datum/objective/New(text, datum/team/team_to_join)
	. = ..()
	SHOULD_CALL_PARENT(TRUE)
	GLOB.all_objectives += src
	if(text)
		explanation_text = text
	if(team_to_join)
		team = team_to_join

/datum/objective/Destroy()
	GLOB.all_objectives -= src
	owner = null
	target = null
	team = null
	return ..()

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/found_target()
	return target

/**
 * This is for objectives that need to register signals, so place them in here. Makes it easier for add_objective to call it.
 */
/datum/objective/proc/establish_signals()
	return

/**
 * Get all owners of the objective, including ones from the objective's team, if it has one.
 *
 * Use this over directly referencing `owner` in most cases.
 */
/datum/objective/proc/get_owners()
	. = length(team?.members) ? team.members.Copy() : list()
	if(owner)
		. += owner

/datum/proc/is_invalid_target(datum/mind/possible_target) // Originally an Objective proc. Changed to a datum proc to allow for the proc to be run on minds, before the objective is created
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

/datum/objective/is_invalid_target(datum/mind/possible_target)
	. = ..()
	if(.)
		return
	for(var/datum/mind/M in get_owners())
		if(possible_target == M)
			return TARGET_INVALID_IS_OWNER
		if(possible_target in M.targets)
			return TARGET_INVALID_IS_TARGET
	if(SEND_SIGNAL(src, COMSIG_OBJECTIVE_CHECK_VALID_TARGET, possible_target) & OBJECTIVE_INVALID_TARGET)
		return TARGET_INVALID_BLACKLISTED


/datum/objective/proc/find_target(list/target_blacklist)
	if(!needs_target)
		return

	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(is_invalid_target(possible_target) || (possible_target in target_blacklist))
			continue

		possible_targets += possible_target


	if(possible_targets.len > 0)
		target = pick(possible_targets)

	SEND_SIGNAL(src, COMSIG_OBJECTIVE_TARGET_FOUND, target)

/**
  * Called when the objective's target goes to cryo.
  */
/datum/objective/proc/on_target_cryo()
	var/list/owners = get_owners()
	for(var/datum/mind/M in owners)
		to_chat(M.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
		SEND_SOUND(M.current, sound('sound/ambience/alarm4.ogg'))
	target = null
	INVOKE_ASYNC(src, PROC_REF(post_target_cryo), owners)

/**
  * Called a tick after when the objective's target goes to cryo.
  */
/datum/objective/proc/post_target_cryo(list/owners)
	find_target()
	if(!target)
		holder.remove_objective(src)
		// even if we have to remove the objective, still announce it
	for(var/datum/mind/M in owners)
		var/list/messages = M.prepare_announce_objectives(FALSE)
		to_chat(M.current, chat_box_red(messages.Join("<br>")))

// Borgs, brains, AIs, etc count as dead for traitor objectives
/datum/objective/proc/is_special_dead(mob/target_current, check_silicon = TRUE)
	if(check_silicon && issilicon(target_current))
		return TRUE
	return isbrain(target_current) || istype(target_current, /mob/living/simple_animal/spiderbot)

/datum/objective/assassinate
	name = "Assassinate"
	martyr_compatible = 1

/datum/objective/assassinate/find_target(list/target_blacklist)
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/assassinate/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return TRUE
		if(is_special_dead(target.current)) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return TRUE
		if(!target.current.ckey)
			return TRUE
		return FALSE
	return TRUE

/datum/objective/assassinateonce
	name = "Assassinate once"
	martyr_compatible = TRUE
	var/won = FALSE

/datum/objective/assassinateonce/find_target(list/target_blacklist)
	..()
	if(target?.current)
		explanation_text = "Teach [target.current.real_name], the [target.assigned_role], a lesson they will not forget. The target only needs to die once for success."
		establish_signals()
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/assassinateonce/establish_signals()
	RegisterSignal(target.current, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(check_midround_completion))

/datum/objective/assassinateonce/check_completion()
	return won || completed || !target?.current?.ckey

/datum/objective/assassinateonce/proc/check_midround_completion()
	won = TRUE
	UnregisterSignal(target.current, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING))

/datum/objective/assassinateonce/on_target_cryo()
	if(won)
		return
	return ..()


/datum/objective/mutiny
	name = "Mutiny"
	martyr_compatible = TRUE

/datum/objective/mutiny/find_target(list/target_blacklist)
	..()
	if(target && target.current)
		explanation_text = "Assassinate or exile [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/mutiny/is_invalid_target(datum/mind/possible_target)
	. = ..()
	if(.)
		return
	if(!(possible_target in SSticker.mode.get_all_heads()))
		return TARGET_INVALID_NOTHEAD

/datum/objective/mutiny/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || !ishuman(target.current) || !target.current.ckey || !target.current.client)
			return TRUE
		var/turf/T = get_turf(target.current)
		if(T && !is_station_level(T.z))			//If they leave the station they count as dead for this
			return TRUE
		return FALSE
	return TRUE

/datum/objective/mutiny/on_target_cryo()
	// We don't want revs to get objectives that aren't for heads of staff. Letting
	// them win or lose based on cryo is silly so we remove the objective.
	if(team)
		team.remove_team_objective(src)
		return
	qdel(src)

/datum/objective/maroon
	name = "Maroon"
	martyr_compatible = 1

/datum/objective/maroon/find_target(list/target_blacklist)
	..()
	if(target && target.current)
		explanation_text = "Prevent [target.current.real_name], the [target.assigned_role] from escaping alive."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/maroon/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return TRUE
		if(!target.current.ckey)
			return TRUE
		if(is_special_dead(target.current))
			return TRUE
		var/turf/T = get_turf(target.current)
		if(is_admin_level(T.z))
			return FALSE
		return TRUE
	return TRUE


/datum/objective/debrain //I want braaaainssss
	name = "Debrain"
	martyr_compatible = 0

/datum/objective/debrain/is_invalid_target(datum/mind/possible_target)
	. = ..()
	if(.)
		return
	// If the target is a changeling, then it's an invalid target. Since changelings can not be debrained.
	if(ischangeling(possible_target.current))
		return TARGET_INVALID_CHANGELING

/datum/objective/debrain/find_target(list/target_blacklist)
	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name] the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/debrain/check_completion()
	if(!target) // If it's a free objective.
		return TRUE
	if(!target.current || !isbrain(target.current))
		return FALSE
	for(var/datum/mind/M in get_owners())
		if(QDELETED(M.current))
			continue // Maybe someone who's alive has the brain.
		if(target.current in M.current.GetAllContents())
			return TRUE
	return FALSE


/datum/objective/protect //The opposite of killing a dude.
	name = "Protect"
	martyr_compatible = 1

/datum/objective/protect/find_target(list/target_blacklist)
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
		if(is_special_dead(target.current))
			return FALSE
		return TRUE
	return FALSE

/datum/objective/protect/mindslave //subytpe for mindslave implants
	needs_target = FALSE // To be clear, this objective should have a target, but it will always be manually set to the mindslaver through the mindslave antag datum.

// This objective should only be given to a single owner. We can use `owner` and not `get_owners()`.
/datum/objective/protect/mindslave/on_target_cryo()
	if(owner?.current)
		SEND_SOUND(owner.current, sound('sound/ambience/alarm4.ogg'))
		owner.remove_antag_datum(/datum/antagonist/mindslave)
		to_chat(owner.current, "<BR><span class='userdanger'>You notice that your master has entered cryogenic storage, and revert to your normal self.</span>")
		log_admin("[key_name(owner.current)]'s mindslave master has cryo'd, and is no longer a mindslave.")
		message_admins("[key_name_admin(owner.current)]'s mindslave master has cryo'd, and is no longer a mindslave.") //Since they were on antag hud earlier, this feels important to log
		qdel(src)

/datum/objective/hijack
	name = "Hijack"
	martyr_compatible = 0 //Technically you won't get both anyway.
	explanation_text = "Hijack the shuttle by escaping on it with no loyalist Nanotrasen crew on board and free. \
	Syndicate agents, other enemies of Nanotrasen, cyborgs, pets, and cuffed/restrained hostages may be allowed on the shuttle alive. \
	Alternatively, hack the shuttle console multiple times (by alt clicking on it) until the shuttle directions are corrupted."
	needs_target = FALSE

/datum/objective/hijack/check_completion()
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return FALSE
	for(var/datum/mind/M in get_owners())
		if(QDELETED(M.current) || M.current.stat != CONSCIOUS || issilicon(M.current) || get_area(M.current) != SSshuttle.emergency.areaInstance)
			return FALSE
	return SSshuttle.emergency.is_hijacked()

/datum/objective/hijackclone
	name = "Hijack (with clones)"
	explanation_text = "Hijack the shuttle by ensuring only you (or your copies) escape."
	martyr_compatible = 0
	needs_target = FALSE

// This objective should only be given to a single owner, because the "copies" can only copy one person.
// We're fine to use `owner` instead of `get_owners()`.
/datum/objective/hijackclone/check_completion()
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME || !owner.current)
		return FALSE

	var/area/A = SSshuttle.emergency.areaInstance

	for(var/mob/living/player in GLOB.player_list) //Make sure nobody else is onboard
		if(player.mind && player.mind != owner)
			if(player.stat != DEAD)
				if(issilicon(player))
					continue
				if(get_area(player) == A)
					if(player.real_name != owner.current.real_name && !istype(get_turf(player.mind.current), /turf/simulated/floor/mineral/plastitanium/red/brig))
						return FALSE

	for(var/mob/living/player in GLOB.player_list) //Make sure at least one of you is onboard
		if(player.mind && player.mind != owner)
			if(player.stat != DEAD)
				if(issilicon(player))
					continue
				if(get_area(player) == A)
					if(player.real_name == owner.current.real_name && !istype(get_turf(player.mind.current), /turf/simulated/floor/mineral/plastitanium/red/brig))
						return TRUE
	return FALSE

/datum/objective/block
	name = "Silicon hijack"
	explanation_text = "Hijack the shuttle with no loyalist Nanotrasen crew on board and free. \
	Syndicate agents, other enemies of Nanotrasen, cyborgs, pets, and cuffed/restrained hostages may be allowed on the shuttle alive. \
	Using the doomsday device successfully is also an option."
	martyr_compatible = 1
	needs_target = FALSE

/datum/objective/block/check_completion()
	for(var/datum/mind/M in get_owners())
		if(!M.current || !issilicon(M.current))
			return FALSE
	if(SSticker.mode.station_was_nuked)
		return TRUE
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return FALSE
	if(!SSshuttle.emergency.is_hijacked(TRUE))
		return FALSE
	return TRUE

/datum/objective/escape
	name = "Escape"
	explanation_text = "Escape on the shuttle or an escape pod alive and free."
	needs_target = FALSE

/datum/objective/escape/check_completion()
	var/list/owners = get_owners()
	for(var/datum/mind/M in owners)
		// These are mandatory conditions, they should come before the freebie conditions below.
		if(QDELETED(M.current) || M.current.stat == DEAD || is_special_dead(M.current))
			return FALSE

	if(SSticker.force_ending) // This one isn't their fault, so lets just assume good faith.
		return TRUE
	if(SSticker.mode.station_was_nuked) // If they escaped the blast somehow, let them win.
		return TRUE
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return FALSE

	for(var/datum/mind/M in owners)
		var/turf/location = get_turf(M.current)
		if(istype(location, /turf/simulated/floor/mineral/plastitanium/red/brig))
			return FALSE
		if(!location.onCentcom() && !location.onSyndieBase())
			return FALSE

	return TRUE


/datum/objective/escape/escape_with_identity
	name = null
	/// Stored because the target's `[mob/var/real_name]` can change over the course of the round.
	var/target_real_name
	/// If the objective has an assassinate objective tied to it.
	var/has_assassinate_objective = FALSE

/datum/objective/escape/escape_with_identity/New(text, datum/team/team_to_join, datum/objective/assassinate/assassinate)
	..()
	if(!assassinate)
		return
	target = assassinate.target
	target_real_name = assassinate.target.current.real_name
	explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role] while wearing [target.p_their()] identification card."
	has_assassinate_objective = TRUE
	RegisterSignal(assassinate, COMSIG_OBJECTIVE_TARGET_FOUND, PROC_REF(assassinate_found_target))
	RegisterSignal(assassinate, COMSIG_OBJECTIVE_CHECK_VALID_TARGET, PROC_REF(assassinate_checking_target))

/datum/objective/escape/escape_with_identity/is_invalid_target(datum/mind/possible_target)
	if(..() || !possible_target.current.client)
		return TRUE
	// If the target is geneless, then it's an invalid target.
	return HAS_TRAIT(possible_target.current, TRAIT_GENELESS)

/datum/objective/escape/escape_with_identity/find_target(list/target_blacklist)
	..()
	if(target && target.current)
		target_real_name = target.current.real_name
		explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role] while wearing [target.p_their()] identification card."
	else
		explanation_text = "Free Objective"

/datum/objective/escape/escape_with_identity/proc/assassinate_checking_target(datum/source, datum/mind/possible_target)
	SIGNAL_HANDLER
	if(!possible_target.current.client || HAS_TRAIT(possible_target.current, TRAIT_GENELESS))
		// Stop our linked assassinate objective from choosing a clientless/geneless target.
		return OBJECTIVE_INVALID_TARGET
	return OBJECTIVE_VALID_TARGET

/datum/objective/escape/escape_with_identity/proc/assassinate_found_target(datum/source, datum/mind/new_target)
	SIGNAL_HANDLER
	if(new_target)
		target_real_name = new_target.current.real_name
		return
	// The assassinate objective was unable to find a new target after the old one cryo'd as was qdel'd. We're on our own.
	find_target()
	has_assassinate_objective = FALSE

/datum/objective/escape/escape_with_identity/on_target_cryo()
	if(has_assassinate_objective)
		return // Our assassinate objective will handle this.
	..()

/datum/objective/escape/escape_with_identity/post_target_cryo()
	if(has_assassinate_objective)
		return // Our assassinate objective will handle this.
	..()

// This objective should only be given to a single owner since only 1 person can have the ID card of the target.
// We're fine to use `owner` instead of `get_owners()`.
/datum/objective/escape/escape_with_identity/check_completion()
	if(!target_real_name)
		return TRUE
	if(!ishuman(owner.current))
		return FALSE
	var/mob/living/carbon/human/H = owner.current
	if(..())
		if(H.dna.real_name == target_real_name)
			if(H.get_id_name() == target_real_name)
				return TRUE
	return FALSE

/datum/objective/survive
	name = "Survive"
	explanation_text = "Stay alive until the end."
	needs_target = FALSE

/datum/objective/survive/check_completion()
	for(var/datum/mind/M in get_owners())
		if(QDELETED(M.current) || M.current.stat == DEAD || is_special_dead(M.current, check_silicon = FALSE))
			return FALSE
		if(issilicon(M.current) && !M.is_original_mob(M.current))
			return FALSE
	return TRUE

/datum/objective/nuclear
	name = "Nuke station"
	explanation_text = "Destroy the station with a nuclear device."
	martyr_compatible = 1
	needs_target = FALSE

/datum/objective/steal
	name = "Steal Item"
	var/datum/theft_objective/steal_target
	martyr_compatible = 0
	var/theft_area

/datum/objective/steal/found_target()
	return steal_target

/datum/objective/steal/proc/get_location()
	return steal_target.location_override || "an unknown area"

/datum/objective/steal/find_target(list/target_blacklist)
	var/potential = GLOB.potential_theft_objectives.Copy()
	while(!steal_target && length(potential))
		var/thefttype = pick_n_take(potential)
		if(locate(thefttype) in target_blacklist)
			continue
		var/datum/theft_objective/O = new thefttype
		var/has_invalid_owner = FALSE
		for(var/datum/mind/M in get_owners())
			if((M.assigned_role in O.protected_jobs) || (O in M.targets))
				has_invalid_owner = TRUE
				break
		if(has_invalid_owner)
			continue
		if(!O.check_objective_conditions())
			continue
		if(O.flags & 2) // THEFT_FLAG_UNIQUE
			continue

		steal_target = O
		explanation_text = "Steal [steal_target]. One was last seen in [get_location()]. "
		if(length(O.protected_jobs) && O.job_possession)
			explanation_text += "It may also be in the possession of the [english_list(O.protected_jobs, and_text = " or ")]."
		if(steal_target.special_equipment)
			give_kit(steal_target.special_equipment)
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
		O.name = sanitize(copytext(input("Enter target name:", "Objective target", custom_name) as text|null,1,MAX_NAME_LEN))
		if(!O.name) return
		steal_target = O
		explanation_text = "Steal [O.name]."
	else
		steal_target = new new_target
		explanation_text = "Steal [steal_target.name]."
		if(steal_target.special_equipment)
			give_kit(steal_target.special_equipment)
	return steal_target

/datum/objective/steal/check_completion()
	if(!steal_target)
		return TRUE // Free Objective

	for(var/datum/mind/M in get_owners())
		if(!M.current)
			continue
		for(var/obj/I in M.current.GetAllContents())
			if((istype(I, steal_target.typepath) || (I.type in steal_target.altitems)) && steal_target.check_special_completion(I))
				return TRUE
	return FALSE

/datum/objective/steal/proc/give_kit(obj/item/item_path)
	var/I = new item_path
	var/list/slots = list(
		"backpack" = SLOT_HUD_IN_BACKPACK,
		"left pocket" = SLOT_HUD_LEFT_STORE,
		"right pocket" = SLOT_HUD_RIGHT_STORE,
		"left hand" = SLOT_HUD_LEFT_HAND,
		"right hand" = SLOT_HUD_RIGHT_HAND,
	)
	for(var/datum/mind/M in get_owners())
		var/mob/living/carbon/human/H = M.current
		var/where = H.equip_in_one_of_slots(I, slots)
		if(where)
			to_chat(H, "<br><br><span class='info'>In your [where] is a box containing <b>items and instructions</b> to help you with your steal objective.</span><br>")
		else
			to_chat(H, "<span class='userdanger'>Unfortunately, you weren't able to get a stealing kit. This is very bad and you should adminhelp immediately (press F1).</span>")
			message_admins("[ADMIN_LOOKUPFLW(H)] Failed to spawn with their [item_path] theft kit.")
			qdel(I)


/datum/objective/absorb
	name = "Absorb DNA"
	needs_target = FALSE

/datum/objective/absorb/New(text, datum/team/team_to_join)
	. = ..()
	gen_amount_goal()

/datum/objective/absorb/proc/gen_amount_goal(lowbound = 6, highbound = 8)
	target_amount = rand (lowbound,highbound)
	if(SSticker)
		var/n_p = 1 //autowin
		if(SSticker.current_state == GAME_STATE_SETTING_UP)
			for(var/mob/new_player/P in GLOB.player_list)
				if(P.client && P.ready && !(P.mind in get_owners()))
					if(P.client.prefs && (P.client.prefs.active_character.species == "Machine")) // Special check for species that can't be absorbed. No better solution.
						continue
					n_p++
		else if(SSticker.current_state == GAME_STATE_PLAYING)
			for(var/mob/living/carbon/human/P in GLOB.player_list)
				if(HAS_TRAIT(P, TRAIT_GENELESS))
					continue
				if(P.client && !(P.mind in SSticker.mode.changelings) && !(P.mind in get_owners()))
					n_p++
		target_amount = min(target_amount, n_p)

	explanation_text = "Acquire [target_amount] compatible genomes. The 'Extract DNA Sting' can be used to stealthily get genomes without killing somebody."
	return target_amount

/datum/objective/absorb/check_completion()
	for(var/datum/mind/M in get_owners())
		var/datum/antagonist/changeling/cling = M?.has_antag_datum(/datum/antagonist/changeling)
		if(cling?.absorbed_dna && (cling.absorbed_count >= target_amount))
			return TRUE
	return FALSE

/datum/objective/destroy
	name = "Destroy AI"
	martyr_compatible = 1
	var/target_real_name

/datum/objective/destroy/find_target(list/target_blacklist)
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
			return TRUE
		return FALSE
	return TRUE

/datum/objective/destroy/post_target_cryo(list/owners)
	holder.replace_objective(src, /datum/objective/assassinate)

/datum/objective/steal_five_of_type
	name = "Steal Five Items"
	explanation_text = "Steal at least five items!"
	needs_target = FALSE
	var/list/wanted_items = list()

/datum/objective/steal_five_of_type/New()
	..()
	wanted_items = typecacheof(wanted_items)

/datum/objective/steal_five_of_type/check_completion()
	var/stolen_count = 0
	var/list/owners = get_owners()
	var/list/all_items = list()
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue
		all_items += M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
	for(var/obj/I in all_items) //Check for wanted items
		if(is_type_in_typecache(I, wanted_items))
			stolen_count++
	return stolen_count >= 5

/datum/objective/steal_five_of_type/summon_guns
	name = "Steal Five Guns"
	explanation_text = "Steal at least five guns!"
	wanted_items = list(/obj/item/gun)

/datum/objective/steal_five_of_type/summon_magic
	name = "Steal Five Artefacts"
	explanation_text = "Steal at least five magical artefacts!"
	wanted_items = list()

/datum/objective/steal_five_of_type/summon_magic/New()
	wanted_items = GLOB.summoned_magic_objectives
	..()

/datum/objective/steal_five_of_type/summon_magic/check_completion()
	var/stolen_count = 0
	var/list/owners = get_owners()
	var/list/all_items = list()
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue
		all_items += M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
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
	name = "Spread blood"
	needs_target = FALSE

/datum/objective/blood/New()
	gen_amount_goal()
	. = ..()

/datum/objective/blood/proc/gen_amount_goal(low = 150, high = 400)
	target_amount = rand(low,high)
	target_amount = round(round(target_amount/5)*5)
	explanation_text = "Accumulate at least [target_amount] total units of blood."
	return target_amount

/datum/objective/blood/check_completion()
	for(var/datum/mind/M in get_owners())
		var/datum/antagonist/vampire/V = M.has_antag_datum(/datum/antagonist/vampire)
		if(V.bloodtotal >= target_amount)
			return TRUE
		else
			return FALSE


// Traders
// These objectives have no check_completion, they exist only to tell Sol Traders what to aim for.

/datum/objective/trade
	needs_target = FALSE
	completed = TRUE

/datum/objective/trade/plasma
	explanation_text = "Acquire at least 15 sheets of plasma through trade."

/datum/objective/trade/credits
	explanation_text = "Acquire at least 10,000 credits through trade."

//wizard

/datum/objective/wizchaos
	explanation_text = "Wreak havoc upon the station as much you can. Send those wandless Nanotrasen scum a message!"
	needs_target = FALSE
	completed = TRUE
