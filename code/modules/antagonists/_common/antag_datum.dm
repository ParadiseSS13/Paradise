RESTRICT_TYPE(/datum/antagonist)

GLOBAL_LIST_EMPTY(antagonists)

#define SUCCESSFUL_DETACH "dont touch this string numbnuts"

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
	/// Used to determine if the player jobbanned from this role. Things like `SPECIAL_ROLE_TRAITOR` should go here to determine the role.
	var/job_rank
	/// Should we replace the role-banned player with a ghost?
	var/replace_banned = TRUE
	/// List of objectives connected to this datum.
	VAR_PRIVATE/datum/objective_holder/objective_holder
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
	/// The spawn class to use for gain/removal clown text
	var/clown_text_span_class = "boldnotice"
	/// If the antagonist can have their spoken voice be something else, this is the "voice" that they will appear as.
	var/mimicking = ""
	/// The url page name for this antagonist, appended to the end of the wiki url in the form of: [GLOB.configuration.url.wiki_url]/index.php/[wiki_page_name]
	var/wiki_page_name
	/// The organization, if any, this antag is associated with
	var/datum/antag_org/organization

	//Blurb stuff
	/// Intro Blurbs text colour
	var/blurb_text_color = COLOR_BLACK
	/// Intro Blurbs outline width
	var/blurb_text_outline_width = 0
	/// Intro Blurb Font
	var/blurb_font = "Courier New"
	//Backgrount
	var/blurb_r = 0
	var/blurb_g = 0
	var/blurb_b = 0
	var/blurb_a = 0

	/// Do we have delayed objective giving?
	var/delayed_objectives = FALSE
	/// The title of the players "boss", used for exfil strings
	var/boss_title = "Operations"
	/// If the antagonist has been chosen for either side on an exchange objective
	var/in_exchange = FALSE

/datum/antagonist/New()
	GLOB.antagonists += src
	objective_holder = new(src)

/datum/antagonist/Destroy(force, ...)
	qdel(objective_holder)
	GLOB.antagonists -= src
	if(!QDELETED(owner) && detach_from_owner() != SUCCESSFUL_DETACH)
		stack_trace("[src] ([type]) failed to detach from owner! This is very bad!")

	return ..()

/**
 * Removes owner's dependencies on this antag datum.
 * For example: removal of antag datum from owner's `antag_datums`, antag datum related teams etc.
 * If your `/datum/antagonist`  subtype adds more dependencies on `owner` - they should be cleared there.
 */
/datum/antagonist/proc/detach_from_owner()
	SHOULD_CALL_PARENT(TRUE)

	remove_owner_from_gamemode()
	if(!silent)
		farewell()
	remove_innate_effects()
	antag_memory = null
	var/datum/team/team = get_team()
	team?.remove_member(owner)
	LAZYREMOVE(owner.antag_datums, src)
	restore_last_hud_and_role()
	owner = null
	return SUCCESSFUL_DETACH

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
 * Selects and set the organization this antag is associated with.
 * Base proc, override as needed
 */
/datum/antagonist/proc/select_organization()
	return

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
/datum/antagonist/proc/add_antag_objective(datum/objective/objective_to_add, explanation_text, mob/target_override)
	if(ispath(objective_to_add))
		objective_to_add = new objective_to_add()

	// Roll to see if we target a specific department or random one
	if(organization && prob(organization.focus))
		if(organization.targeted_departments)
			objective_to_add.target_department = pick(organization.targeted_departments)
			objective_to_add.steal_list = organization.theft_targets

	if(objective_to_add.owner)
		stack_trace("[objective_to_add], [objective_to_add.type] was assigned as an objective to [owner] (mind), but already had an owner: [objective_to_add.owner] (mind). Overriding.")
	objective_to_add.owner = owner

	return objective_holder.add_objective(objective_to_add, explanation_text, target_override)

/**
 * Complement to add_antag_objective that removes the objective.
 * Currently unused.
 */
/datum/antagonist/proc/remove_antag_objective(datum/objective/O)
	return objective_holder.remove_objective(O)

/**
 * Do we have any objectives at all, including from a team.
 * Faster than get_antag_objectives()
 */
/datum/antagonist/proc/has_antag_objectives(include_team = TRUE)
	. = FALSE
	. |= objective_holder.has_objectives()
	if(!. && include_team)
		var/datum/team/team = get_team()
		if(istype(team))
			. |= team.objective_holder.has_objectives()

/**
 * Get all of this antagonist's objectives, including from the team.
 */
/datum/antagonist/proc/get_antag_objectives(include_team = TRUE)
	. = list()
	. |= objective_holder.get_objectives()
	if(include_team)
		var/datum/team/team = get_team()
		if(istype(team))
			. |= team.objective_holder.get_objectives()

/**
 * Proc called when the datum is given to a mind.
 */
/datum/antagonist/proc/on_gain()
	owner.special_role = special_role
	add_owner_to_gamemode()
	select_organization()
	if(give_objectives)
		give_objectives()
	var/list/messages = list()
	if(!silent)
		messages.Add(greet())
		messages.Add(owner.prepare_announce_objectives())
	apply_innate_effects()
	var/finalized = finalize_antag()
	if(length(finalized) || istext(finalized))
		messages.Add(finalized)
	if(wiki_page_name)
		messages.Add("<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/[wiki_page_name])</span>")
	if(length(messages))
		to_chat(owner.current, chat_box_red(messages.Join("<br>")))
	if(is_banned(owner.current) && replace_banned)
		INVOKE_ASYNC(src, PROC_REF(replace_banned_player))
	owner.current.create_log(MISC_LOG, "[owner.current] was made into \an [special_role]")
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
 * Checks if the person trying to receive this datum is role banned from it.
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
		message_admins("[owner] ([owner.key]) has been converted into [name] with an active antagonist jobban for said role since no ghost has volunteered to take [owner.p_their()] place.")
		to_chat(owner.current, "<span class='biggerdanger'>You have been converted into [name] with an active jobban. Your body was offered up but there were no ghosts to take over. You will be allowed to continue as [name], but any further violations of the rules on your part are likely to result in a permanent ban.</span>")
		return FALSE
	var/mob/dead/observer/C = pick(candidates)
	to_chat(owner.current, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")
	message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(owner.current)]) to replace a jobbaned player.")
	owner.current.ghostize(GHOST_FLAGS_OBSERVE_ONLY)
	owner.current.key = C.key
	dust_if_respawnable(C)
	return TRUE

/**
 * Displays a message and their objectives to the antag mob after the datum is added to them, i.e. "Greetings you are a traitor! etc.
 *
 * Called in `on_gain()` if silent it set to FALSE.
 */
/datum/antagonist/proc/greet()
	var/list/messages = list()
	. = messages
	if(owner && owner.current)
		messages.Add("<span class='userdanger'>You are a [special_role]!</span>")

/**
 * Displays a message to the antag mob while the datum is being deleted, i.e. "Your powers are gone and you're no longer a vampire!"
 *
 * Called in `on_removal()` if silent is set to FALSE.
 */
/datum/antagonist/proc/farewell()
	if(owner && owner.current)
		to_chat(owner.current,"<span class='userdanger'>You are no longer a [special_role]!</span>")

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

/**
 * Create and assign a full set of randomized, basic human traitor objectives.
 * can_hijack - If you want the 5% chance for the antagonist to be able to roll hijack, only true for traitors
 */
/datum/antagonist/proc/forge_basic_objectives(can_hijack = FALSE)
	// Hijack objective.
	if(can_hijack && prob(5) && !(locate(/datum/objective/hijack) in owner.get_all_objectives()))
		add_antag_objective(/datum/objective/hijack)
		return // Hijack should be their only objective (normally), so return.

	// Will give normal steal/kill/etc. type objectives.
	for(var/i in 1 to GLOB.configuration.gamemode.traitor_objectives_amount)
		forge_single_human_objective()

	var/can_succeed_if_dead = TRUE
	for(var/datum/objective/O in owner.get_all_objectives())
		if(!O.martyr_compatible) // Check if our current objectives can co-exist with martyr.
			can_succeed_if_dead = FALSE
			break

	// Give them an escape objective if they don't have one already.
	if(!(locate(/datum/objective/escape) in owner.get_all_objectives()) && (!can_succeed_if_dead || prob(80)))
		add_antag_objective(/datum/objective/escape)

#define KILL_OBJECTIVE "KILL"
#define THEFT_OBJECTIVE "STEAL"
#define PROTECT_OBJECTIVE "PROTECT"
#define INCRIMINATE_OBJECTIVE "INCRIMINATE"

#define DESTROY_OBJECTIVE "DESTROY"
#define DEBRAIN_OBJECTIVE "DEBRAIN"
#define MAROON_OBJECTIVE "MAROON"
#define ASS_ONCE_OBJECTIVE "ASS_ONCE"
#define ASS_OBJECTIVE "ASS"

/**
 * Create and assign a single randomized human traitor objective.
 * Step one: Seperate your objectives into objectives that lead to people dying, and objectives that do not.
 * Objectives that lead to people dying should take up HALF of the pick weight, and non lethal should be the OTHER half.
 * After that, add it to the switch list.
 * The kill objective pool weight has been done by putting the old code through a million or so runs to figure out averages, to keep it consistant.
 */
/datum/antagonist/proc/forge_single_human_objective()
	var/datum/objective/objective_to_add
	var/list/static/the_objective_list = list(KILL_OBJECTIVE = 47, THEFT_OBJECTIVE = 42, INCRIMINATE_OBJECTIVE = 5, PROTECT_OBJECTIVE = 6)
	var/list/the_nonstatic_kill_list = list(DEBRAIN_OBJECTIVE = 50, MAROON_OBJECTIVE = 285, ASS_ONCE_OBJECTIVE = 199, ASS_OBJECTIVE = 466)

	// If our org has an objectives list, give one to us if we pass a roll on the org's focus
	if(organization && length(organization.objectives) && prob(organization.focus))
		objective_to_add = pick(organization.objectives)
	else
		var/objective_to_decide_further = pickweight(the_objective_list)
		switch(objective_to_decide_further)
			if(KILL_OBJECTIVE)
				if(length(active_ais()))
					the_nonstatic_kill_list += list(DESTROY_OBJECTIVE = round((100 / length(GLOB.player_list)) * 10))
				var/the_kill_objective = pickweight(the_nonstatic_kill_list)
				switch(the_kill_objective)
					if(DESTROY_OBJECTIVE)
						objective_to_add = /datum/objective/destroy

					if(DEBRAIN_OBJECTIVE)
						objective_to_add = /datum/objective/debrain

					if(MAROON_OBJECTIVE)
						objective_to_add = /datum/objective/maroon

					if(ASS_ONCE_OBJECTIVE)
						objective_to_add = /datum/objective/assassinateonce

					if(ASS_OBJECTIVE)
						objective_to_add = /datum/objective/assassinate

			if(THEFT_OBJECTIVE)
				objective_to_add = /datum/objective/steal
			if(INCRIMINATE_OBJECTIVE)
				objective_to_add = /datum/objective/incriminate

			if(PROTECT_OBJECTIVE)
				objective_to_add = /datum/objective/protect

	if(delayed_objectives)
		objective_to_add = new /datum/objective/delayed(objective_to_add)
	add_antag_objective(objective_to_add)

#undef KILL_OBJECTIVE
#undef THEFT_OBJECTIVE
#undef PROTECT_OBJECTIVE
#undef INCRIMINATE_OBJECTIVE

#undef DESTROY_OBJECTIVE
#undef DEBRAIN_OBJECTIVE
#undef MAROON_OBJECTIVE
#undef ASS_ONCE_OBJECTIVE
#undef ASS_OBJECTIVE


//Individual roundend report
/datum/antagonist/proc/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(objective_holder.has_objectives())
		report += printobjectives(owner)
		for(var/datum/objective/objective in objective_holder.get_objectives())
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives_complete)
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

// Called when the owner is cryo'd, for when you want things to happen on cryo and not deletion
/datum/antagonist/proc/on_cryo()
	return

/// This is the custom blurb message used on login for an antagonist.
/datum/antagonist/proc/custom_blurb()
	return FALSE

/datum/antagonist/proc/exfiltrate(mob/living/carbon/human/extractor, obj/item/radio/radio)
	return

/datum/antagonist/proc/prepare_exfiltration(mob/user, obj/item/wormhole_jaunter/extraction/extraction_type = null)
	// No extraction for certian steals/hijack
	var/objectives = user.mind.get_all_objectives()
	for(var/datum/objective/goal in objectives)
		if(!goal.is_valid_exfiltration())
			to_chat(user, "<span class='warning'>The [boss_title] has deemed your objectives too delicate for an early extraction.</span>")
			return

	if(world.time < 60 MINUTES) // 60 minutes of no exfil
		to_chat(user, "<span class='warning'>The [boss_title] is still preparing an exfiltration portal. Please wait another [round((36000 - world.time) / 600)] minutes before trying again.</span>")
		return
	var/mob/living/L = user
	if(!istype(L))
		return
	var/obj/item/wormhole_jaunter/extraction/extractor = new extraction_type()
	L.put_in_active_hand(extractor)

/datum/antagonist/proc/start_exchange()
	if(in_exchange)
		return
	var/list/possible_opponents = SSticker.mode.traitors + SSticker.mode.vampires + SSticker.mode.changelings + SSticker.mode.mindflayers
	possible_opponents -= owner
	var/datum/mind/opponent = pick(possible_opponents)
	var/datum/antagonist/other_antag = opponent.has_antag_datum(/datum/antagonist)
	if(other_antag)
		assign_exchange_objective(other_antag)

/datum/antagonist/proc/assign_exchange_objective(datum/antagonist/other_team)
	if(!owner.current)
		return
	if(other_team == src)
		return
	in_exchange = TRUE
	other_team.in_exchange = TRUE
	var/list/teams_list = list(EXCHANGE_TEAM_RED, EXCHANGE_TEAM_BLUE)
	var/our_team = pick_n_take(teams_list)
	var/datum/objective/steal/exchange/red/red_team = new()
	var/datum/objective/steal/exchange/blue/blue_team = new()
	switch(our_team)
		if(EXCHANGE_TEAM_RED)
			add_antag_objective(red_team)
			other_team.add_antag_objective(blue_team)
		if(EXCHANGE_TEAM_BLUE)
			add_antag_objective(blue_team)
			other_team.add_antag_objective(red_team)
	red_team.pair_up(blue_team, TRUE)

#undef SUCCESSFUL_DETACH
