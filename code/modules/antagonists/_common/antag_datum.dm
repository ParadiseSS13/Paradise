GLOBAL_LIST_EMPTY(antagonists)

/datum/antagonist
	var/name = "Antagonist"
	var/roundend_category = "other antagonists"				//Section of roundend report, datums with same category will be displayed together, also default header for the section
	var/show_in_roundend = TRUE								//Set to false to hide the antagonists from roundend report
	var/datum/mind/owner						//Mind that owns this datum
	var/silent = FALSE							//Silent will prevent the gain/lose texts to show
	var/can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	var/list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with
	var/delete_on_mind_deletion = TRUE
	var/job_rank
	var/replace_banned = TRUE //Should replace jobbaned player with ghosts if granted.
	var/list/objectives = list()
	var/antag_memory = ""//These will be removed with antag datum

/datum/antagonist/New()
	GLOB.antagonists += src
	typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)

/datum/antagonist/Destroy()
	GLOB.antagonists -= src
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

//This will be called in add_antag_datum before owner assignment.
//Should return antag datum without owner.
/datum/antagonist/proc/specialization(datum/mind/new_owner)
	return src

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
/datum/antagonist/proc/create_team(datum/team/team)
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
	. = (jobban_isbanned(M, ROLE_SYNDICATE) || (job_rank && jobban_isbanned(M, job_rank)))

/datum/antagonist/proc/replace_banned_player()
	set waitfor = FALSE

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [name]?", job_rank, TRUE, 5 SECONDS)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(owner, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")
		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(owner.current)]) to replace a jobbaned player.")
		owner.current.ghostize(0)
		owner.current.key = C.key

/datum/antagonist/proc/on_removal()
	remove_innate_effects()
	if(owner)
		LAZYREMOVE(owner.antag_datums, src)
		if(!silent && owner.current)
			farewell()
		owner.objectives -= objectives
	var/datum/team/team = get_team()
	if(team)
		team.remove_member(owner)
	qdel(src)

/datum/antagonist/proc/greet()
	return

/datum/antagonist/proc/farewell()
	return


//Returns the team antagonist belongs to if any.
/datum/antagonist/proc/get_team()
	return

//Individual roundend report
/datum/antagonist/proc/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(owner.objectives.len)
		report += printobjectives(owner)
		for(var/datum/objective/objective in owner.objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(owner.objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//Displayed at the start of roundend_category section, default to roundend_category header
/datum/antagonist/proc/roundend_report_header()
	return 	"<span class='header'>The [roundend_category] were:</span><br>"

//Displayed at the end of roundend_category section
/datum/antagonist/proc/roundend_report_footer()
	return
