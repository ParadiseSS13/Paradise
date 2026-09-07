///a heretic that got soultrapped by cultists. does nothing, other than signify they suck
/datum/antagonist/soultrapped_heretic
	name = "\improper Soultrapped Heretic"
	roundend_category = "Heretics"
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic"


// always failure obj
/datum/objective/heretic_trapped

/datum/objective/heretic_trapped/New(text, datum/team/team_to_join, datum/mind/_owner)
	name = "soultrapped failure"
	explanation_text = "Help the cult. Kill the cult. Help the crew. Kill the crew. Help your wielder. Kill your wielder. Kill everyone. Rattle your chains. Break your bindings."
	..()

/datum/antagonist/soultrapped_heretic/add_owner_to_gamemode()
	return

/datum/antagonist/soultrapped_heretic/remove_owner_from_gamemode()
	return

/datum/antagonist/soultrapped_heretic/on_gain()
	..()
	addtimer(CALLBACK(src, PROC_REF(do_objective)), 2 SECONDS)

/datum/antagonist/soultrapped_heretic/proc/do_objective()
	var/datum/objective/epic_fail = new /datum/objective/heretic_trapped()
	epic_fail.completed = FALSE
	epic_fail.needs_target = FALSE
	add_antag_objective(epic_fail)


/datum/antagonist/soultrapped_heretic/greet()
	var/list/messages = list(SPAN_WARNING("You are the trapped soul of the Heretic you once were. You may attempt to convince your wielders to unbind you, granting you some degree of freedom, and them access to some of your powers. \
	You were enslaved by the cult, but are not a member of it, and retain what remains of your free will. Besides this, there is little to be done but commentary. Try not to get trapped in a locker."))
	return messages
