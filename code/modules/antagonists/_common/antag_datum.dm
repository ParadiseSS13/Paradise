GLOBAL_LIST_EMPTY(antagonists)

/datum/antagonist
	/// The name of the antagonist.
	var/name = "Antagonist"
	/// Section of roundend report, datums with same category will be displayed together, also default header for the section.
	var/roundend_category = "other antagonists"
	/// Set to false to hide the antagonists from roundend report.
	var/show_in_roundend = TRUE
	/// Mind that owns this datum.
	var/datum/mind/owner
	/// Should the owner mob get a greeting text? Determines whether or not the `greet()` proc is called.
	var/silent = FALSE
	/// List of other antag datum types that this type can't coexist with.
	var/list/antag_datum_blacklist
	/// Should this datum be deleted when the owner's mind is deleted.
	var/delete_on_mind_deletion = TRUE
	/// Used to determine if the player jobbanned from this role. Things like `SPECIAL_ROLE_TRAITOR` should go here to determine the role.
	var/job_rank
	/// Should we replace the role-banned player with a ghost?
	var/replace_banned = TRUE
	/// List of objectives connected to this datum.
	var/list/objectives
	/// A list of strings which contain [targets][/datum/objective/var/target] of the antagonist's objectives. Used to prevent duplicate objectives.
	var/list/assigned_targets
	/// Antagonist datum specific information that appears in the player's notes. Information stored here will be removed when the datum is removed from the player.
	var/antag_memory
	/// The special role that will be applied to the owner's `special_role` var. i.e. `SPECIAL_ROLE_TRAITOR`, `SPECIAL_ROLE_VAMPIRE`.
	var/special_role
	/// Should we automatically give this antagonist objectives upon them gaining the datum?
	var/give_objectives = TRUE
	/// Holds the type of antagonist hud this datum will get, i.e. `ANTAG_HUD_TRAITOR`, `ANTAG_HUD_VAMPIRE`, etc.
	var/antag_hud_type
	/// Holds the name of the hud's icon in the .dmi files, i.e "hudtraitor", "hudvampire", etc.
	var/antag_hud_name
	/// If the owner is a clown, this text will be displayed to them when they gain this datum.
	var/clown_gain_text = "You are no longer clumsy."
	/// If the owner is a clown, this text will be displayed to them when they lose this datum.
	var/clown_removal_text = "You are clumsy again."
	/// The url page name for this antagonist, appended to the end of the wiki url in the form of: [GLOB.configuration.url.wiki_url]/index.php/[wiki_page_name]
	var/wiki_page_name

/datum/antagonist/New()
	GLOB.antagonists += src
	objectives = list()
	assigned_targets = list()

/datum/antagonist/Destroy(force, ...)
	QDEL_LIST(objectives)
	remove_owner_from_gamemode()
	GLOB.antagonists -= src
	if(!silent)
		farewell()
	remove_innate_effects()
	antag_memory = null
	var/datum/team/team = get_team()
	team?.remove_member(owner)
	if(owner)
		LAZYREMOVE(owner.antag_datums, src)
	restore_last_hud_and_role()
	owner = null
	return ..()

/**
 * Adds the owner to their respective gamemode's list. For example `SSticker.mode.traitors |= owner`.
 */
/datum/antagonist/proc/add_owner_to_gamemode()
	return

/**
 * Removes the owner from their respective gamemode's list. For example `SSticker.mode.traitors -= owner`.
 */
/datum/antagonist/proc/remove_owner_from_gamemode()
	return

/**
 * Loops through the owner's `antag_datums` list and determines if this one is blacklisted by any others.
 *
 * If it's in one of their blacklists, return FALSE. It cannot coexist with the datum we're trying to add here.
 */
/datum/antagonist/proc/can_be_owned(datum/mind/new_owner)
	var/datum/mind/tested = new_owner || owner
	if(tested.has_antag_datum(type))
		return FALSE
	for(var/i in tested.antag_datums)
		var/datum/antagonist/A = i
		if(LAZYIN(A.antag_datum_blacklist, type))
			return FALSE
	return TRUE

/**
 * Removes antagonist datum effects from the old body and applies it to the new one.
 *
 * Called in the`/datum/mind/proc/transfer_to()`.
 *
 * Arguments:
 * * new_body - the new body the antag mob is transferring into.
 * * old_body - the old body the antag mob is leaving.
 */
/datum/antagonist/proc/on_body_transfer(mob/living/old_body, mob/living/new_body)
	remove_innate_effects(old_body)
	apply_innate_effects(new_body)

/**
 * This handles the application of antag huds/special abilities.
 *
 * Gives the antag mob their assigned hud.
 * If they're a clown, removes their clumsy mutataion.
 *
 * Arguments:
 * * mob/living/mob_override - a mob to apply effects to. Can be null.
 */
/datum/antagonist/proc/apply_innate_effects(mob/living/mob_override)
	SHOULD_CALL_PARENT(TRUE)
	var/mob/living/L = mob_override || owner.current
	if(antag_hud_type && antag_hud_name)
		add_antag_hud(L)
	// If `mob_override` exists it means we're only transferring this datum, we don't need to show the clown any text.
	handle_clown_mutation(L, mob_override ? null : clown_gain_text, TRUE)
	return L

/**
 * This handles the removal of antag huds/special abilities.
 *
 * Removes the antag's assigned hud.
 * If they're a clown, gives them back their clumsy mutataion.
 *
 * Arguments:
 * * mob/living/mob_override - a mob to remove effects from. Can be null.
 */
/datum/antagonist/proc/remove_innate_effects(mob/living/mob_override)
	SHOULD_CALL_PARENT(TRUE)
	var/mob/living/L = mob_override || owner.current
	if(antag_hud_type && antag_hud_name)
		remove_antag_hud(L)
	// If `mob_override` exists it means we're only transferring this datum, we don't need to show the clown any text.
	handle_clown_mutation(L, mob_override ? null : clown_removal_text)
	return L

/**
 * Adds this datum's antag hud to `antag_mob`.
 *
 * Arguments:
 * * antag_mob - the mob to add the antag hud to.
 */
/datum/antagonist/proc/add_antag_hud(mob/living/antag_mob)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.join_hud(antag_mob)
	set_antag_hud(antag_mob, antag_hud_name)

/**
 * Removes this datum's antag hud from `antag_mob`.
 *
 * Arguments:
 * * antag_mob - the mob to remove the antag hud from.
 */
/datum/antagonist/proc/remove_antag_hud(mob/living/antag_mob)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.leave_hud(antag_mob)
	set_antag_hud(antag_mob, null)

/**
 * Handles adding and removing the clumsy mutation from clown antags.
 *
 * Arguments:
 * * clown - the mob in which to add or remove clumsy from.
 * * message - the chat message to display to them the clown mob
 * * granting_datum - TRUE if the datum is being applied to the clown mob.
 */
/datum/antagonist/proc/handle_clown_mutation(mob/living/carbon/human/clown, message, granting_datum = FALSE)
	if(!istype(clown) || owner.assigned_role != "Clown")
		return FALSE

	// Remove clumsy and give them an action to toggle it on and off.
	if(granting_datum)
		clown.dna.SetSEState(GLOB.clumsyblock, FALSE)
		singlemutcheck(clown, GLOB.clumsyblock, MUTCHK_FORCED)
		// Don't give them another action if they already have one.
		if(!(locate(/datum/action/innate/toggle_clumsy) in clown.actions))
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(clown)
	// Give them back the clumsy gene and remove their toggle action, but ONLY if they don't have any other antag datums.
	else if(LAZYLEN(owner.antag_datums) <= 1)
		clown.dna.SetSEState(GLOB.clumsyblock, TRUE)
		singlemutcheck(clown, GLOB.clumsyblock, MUTCHK_FORCED)
		if(locate(/datum/action/innate/toggle_clumsy) in clown.actions)
			var/datum/action/innate/toggle_clumsy/A = locate() in clown.actions
			A.Remove(clown)
	else
		return FALSE

	if(!silent && message)
		to_chat(clown, "<span class='boldnotice'>[message]</span>")
	return TRUE

/**
 * Give the antagonist their objectives. Base proc, override as needed.
 */
/datum/antagonist/proc/give_objectives()
	return

/**
 * Create and add an objective of the given type.
 *
 * If the given objective type needs a target, it will try to find a target which isn't already the target of different objective for this antag.
 * If one cannot be found, it tries one more time. If one still cannot be found, it will be added as a "Free Objective" without a target.
 *
 * Arguments:
 * * objective_type - A type path of an objective, for example: /datum/objective/steal
 * * explanation_text - the explanation text that will be passed into the objective's `New()` proc
 * * mob/target_override - a target for the objective
 */
/datum/antagonist/proc/add_objective(objective_type, explanation_text = "", mob/target_override = null)
	var/datum/objective/O = new objective_type(explanation_text)
	O.owner = owner

	if(target_override)
		O.target = target_override
		objectives += O
		return

	if(!O.needs_target)
		objectives += O
		return

	O.find_target()
	var/duplicate = FALSE

	// Steal objectives need snowflake handling here unfortunately.
	if(istype(O, /datum/objective/steal))
		var/datum/objective/steal/S = O
		// Check if it's a duplicate.
		if("[S.steal_target]" in assigned_targets)
			S.find_target() // Try again.
			if("[S.steal_target]" in assigned_targets)
				S.steal_target = null
				S.explanation_text = "Free Objective" // Still a duplicate, so just make it a free objective.
				duplicate = TRUE
		if(S.steal_target && !duplicate)
			assigned_targets += "[S.steal_target]"
	else
		if("[O.target]" in assigned_targets)
			O.find_target()
			if("[O.target]" in assigned_targets)
				O.target = null
				O.explanation_text = "Free Objective"
				duplicate = TRUE
		if(O.target && !duplicate)
			assigned_targets += "[O.target]"

	objectives += O
	return O

/**
 * Announces all objectives of this datum, and only this datum.
 */
/datum/antagonist/proc/announce_objectives()
	if(!length(objectives))
		return FALSE
	to_chat(owner.current, "<span class='notice'>Your current objectives:</span>")
	var/objective_num = 1
	for(var/objective in objectives)
		var/datum/objective/O = objective
		to_chat(owner.current, "<span><B>Objective #[objective_num++]</B>: [O.explanation_text]</span><br>")
	return TRUE

/**
 * Proc called when the datum is given to a mind.
 */
/datum/antagonist/proc/on_gain()
	owner.special_role = special_role
	add_owner_to_gamemode()
	if(give_objectives)
		give_objectives()
	if(!silent)
		greet()
		announce_objectives()
	apply_innate_effects()
	finalize_antag()
	if(wiki_page_name)
		to_chat(owner.current, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/[wiki_page_name])</span>")
	if(is_banned(owner.current) && replace_banned)
		INVOKE_ASYNC(src, .proc/replace_banned_player)
	return TRUE

/**
 * Re-sets the antag hud and `special_role` of the owner to that of the previous antag datum they had before this one was added.
 *
 * For example, if the owner has a traitor datum and a vampire datum, both at index 1 and 2 respectively,
 * After the vampire datum gets removed, it sets the owner's antag hud/role to whatever is set for traitor datum.
 */
/datum/antagonist/proc/restore_last_hud_and_role()
	if(!LAZYLEN(owner.antag_datums))
		// If they only had 1 antag datum, no need to restore anything. `remove_innate_effects()` will handle the removal of their hud.
		owner.special_role = null
		return FALSE
	var/datum/antagonist/A = owner.antag_datums[LAZYLEN(owner.antag_datums)]
	ASSERT(A)
	A.add_antag_hud(owner.current) // Restore the hud of the previous antagonist datum.
	owner.special_role = A.special_role

/**
 * Checks if the person trying to recieve this datum is role banned from it.
 */
/datum/antagonist/proc/is_banned(mob/M)
	if(!M)
		return FALSE
	return (jobban_isbanned(M, ROLE_SYNDICATE) || (job_rank && jobban_isbanned(M, job_rank)))

/**
 * Attempts to replace the role banned antag with a ghost player.
 */
/datum/antagonist/proc/replace_banned_player()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [name]?", job_rank, TRUE, 10 SECONDS)
	if(!length(candidates))
		return FALSE
	var/mob/dead/observer/C = pick(candidates)
	to_chat(owner, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")
	message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(owner.current)]) to replace a jobbaned player.")
	owner.current.ghostize(FALSE)
	owner.current.key = C.key
	return TRUE

/**
 * Displays a message and their objectives to the antag mob after the datum is added to them, i.e. "Greetings you are a traitor! etc.
 *
 * Called in `on_gain()` if silent it set to FALSE.
 */
/datum/antagonist/proc/greet()
	if(owner && owner.current)
		to_chat(owner.current, "<span class='userdanger'>You are a [special_role]!</span>")

/**
 * Displays a message to the antag mob while the datum is being deleted, i.e. "Your powers are gone and you're no longer a vampire!"
 *
 * Called in `on_removal()` if silent is set to FALSE.
 */
/datum/antagonist/proc/farewell()
	if(owner && owner.current)
		to_chat(owner.current,"<span class='userdanger'>You are no longer a [special_role]! </span>")

/**
 * Creates a new antagonist team.
 */
/datum/antagonist/proc/create_team(datum/team/team)
	return

/**
 * Returns the team the antagonist belongs to, if any.
 */
/datum/antagonist/proc/get_team()
	return

/**
 * Give the antag any final information or items.
 */
/datum/antagonist/proc/finalize_antag()
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
