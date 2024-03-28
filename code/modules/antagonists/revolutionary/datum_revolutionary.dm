RESTRICT_TYPE(/datum/antagonist/rev)

/datum/antagonist/rev
	name = "Revolutionary"
	roundend_category = "revs"
	job_rank = ROLE_REV
	special_role = SPECIAL_ROLE_REV
	give_objectives = FALSE
	antag_hud_name = "hudrevolutionary"
	antag_hud_type = ANTAG_HUD_REV
	clown_gain_text = "Your newfound purpose has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	clown_removal_text = "As you feel your sense of purpose fade, you return to your own clumsy, clownish self."
	wiki_page_name = "Revolution"
	var/converted = TRUE

/datum/antagonist/rev/on_gain()
	create_team() // make sure theres a global rev team
	owner.has_been_rev = TRUE
	..()

	SEND_SOUND(owner.current, sound('sound/ambience/antag/revalert.ogg'))

/datum/antagonist/rev/greet()
	return "<span class='userdanger'>You are now a revolutionary! Help your cause. \
				Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, \
				and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</span>"

/datum/antagonist/rev/farewell()
	if(owner && owner.current)
		to_chat(owner.current,"<span class='userdanger'>You have been brainwashed! You are no longer a [special_role]!</span>")


/datum/antagonist/rev/add_owner_to_gamemode()
	SSticker.mode.revolutionaries |= owner

/datum/antagonist/rev/remove_owner_from_gamemode()
	SSticker.mode.revolutionaries -= owner

/datum/antagonist/rev/create_team(team)
	return SSticker.mode.get_rev_team()

/datum/antagonist/rev/get_team()
	return SSticker.mode.rev_team

/datum/antagonist/rev/give_objectives()
	var/datum/team/revolution/revolting = get_team()
	revolting.update_team_objectives()

/datum/antagonist/rev/proc/promote()
	var/datum/mind/old_owner = owner
	owner.remove_antag_datum(/datum/antagonist/rev, FALSE, silent_removal = TRUE)

	var/datum/antagonist/rev/head/new_revhead = new()
	new_revhead.silent = TRUE
	old_owner.add_antag_datum(new_revhead, SSticker.mode.get_rev_team())
	new_revhead.silent = FALSE
	to_chat(old_owner.current, "<span class='userdanger'>You have proved your devotion to the revolution! You are a head revolutionary now!</span>")

