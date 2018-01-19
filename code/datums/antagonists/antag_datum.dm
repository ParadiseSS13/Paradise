var/global/list/antagonists = list()

/datum/antagonist
	var/name = "Antagonist"
	var/datum/mind/owner						//Mind that owns this datum
	var/silent = FALSE							//Silent will prevent the gain/lose texts to show
	var/can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	var/list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with
	var/delete_on_mind_deletion = TRUE
	var/antag_role //the antag type
	var/replace_banned = TRUE //Should replace jobbaned player with ghosts if granted.

/datum/antagonist/New(datum/mind/new_owner)
	antagonists += src
	typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)
	if(new_owner)
		owner = new_owner

/datum/antagonist/Destroy()
	antagonists -= src
	if(owner)
		LAZYREMOVE(owner.antag_datums, src)
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(datum/mind/new_owner)
	. = TRUE
	var/datum/mind/tested = new_owner || owner
	if(tested.has_antag_datum(type))
		return FALSE
	for(var/i in tested.antag_datums)
		var/datum/antagonist/A = i
		if(is_type_in_typecache(src, A.typecache_datum_blacklist))
			return FALSE

/datum/antagonist/proc/on_body_transfer(mob/living/old_body, mob/living/new_body)
	remove_innate_effects(old_body)
	apply_innate_effects(new_body)

//This handles the application of antag huds/special abilities
/datum/antagonist/proc/apply_innate_effects(mob/living/mob_override)
	return

//This handles the removal of antag huds/special abilities
/datum/antagonist/proc/remove_innate_effects(mob/living/mob_override)
	return

//Assign default team and creates one for one of a kind team antagonists
/datum/antagonist/proc/create_team(datum/objective_team/team)
	return

//Proc called when the datum is given to a mind.
/datum/antagonist/proc/on_gain()
	if(owner && owner.current)
		if(!silent)
			greet()
		apply_innate_effects()
		if(is_banned(owner.current) && replace_banned)
			replace_banned_player()

/datum/antagonist/proc/is_banned(mob/M)
	if(!M)
		return FALSE
	. = (jobban_isbanned(M,"Syndicate") || (antag_role && jobban_isbanned(M,antag_role)))

/datum/antagonist/proc/replace_banned_player()
	set waitfor = FALSE

	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as a [name]?", "[name]", null, antag_role,  0, 100)
	var/mob/dead/observer/theghost = null
	if(candidates.len)
		theghost = pick(candidates)
		to_chat(owner, "<span class='warning'> Your mob has been taken over by a ghost! Appeal your role ban if you want to avoid this in the future!</span>")
		message_admins("[key_name_admin(theghost)] has taken control of ([key_name_admin(owner.current)]) to replace a jobbaned player.")
		log_admin("[key_name_admin(theghost)] has taken control of ([key_name_admin(owner.current)]) to replace a jobbaned player.")
		owner.current.ghostize(0)
		owner.current.key = theghost.key

/datum/antagonist/proc/on_removal()
	remove_innate_effects()
	if(owner)
		LAZYREMOVE(owner.antag_datums, src)
		if(!silent && owner.current)
			farewell()
	var/datum/team/team = get_team()
	if(team)
		team.remove_member(owner)
	qdel(src)

/datum/antagonist/proc/greet()
	return

//Returns the team antagonist belongs to if any.
/datum/antagonist/proc/get_team()
	return

/datum/antagonist/proc/farewell()
	return