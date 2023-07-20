/datum/antagonist/rev
	name = "Revolutionary"
	roundend_category = "revs"
	job_rank = ROLE_REV
	special_role = SPECIAL_ROLE_REV
	give_objectives = FALSE
	antag_hud_name = "hudrevolutionary"
	antag_hud_type = ANTAG_HUD_REV
	clown_gain_text = "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	// clown_removal_text = "You lose your syndicate training and return to your own clumsy, clownish self." // contra todo
	wiki_page_name = "Revolution"
	var/converted = TRUE

/datum/antagonist/rev/on_gain()
	create_team() // make sure theres a global rev team
	..()

/datum/antagonist/rev/greet()
	to_chat(owner.current, "<span class='userdanger'>You are now a revolutionary! Help your cause. \
				Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, \
				and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</span>")

/datum/antagonist/rev/add_owner_to_gamemode()
	SSticker.mode.revolutionaries |= owner

/datum/antagonist/rev/remove_owner_from_gamemode()
	SSticker.mode.revolutionaries -= owner

/datum/antagonist/rev/create_team(team)
	return SSticker.mode.get_rev_team()

/datum/antagonist/rev/get_team()
	return SSticker.mode.get_rev_team()

// /datum/antagonist/rev/add_antag_hud(mob/living/antag_mob) // contra todo remove?
// 	var/is_contractor = LAZYACCESS(GLOB.contractors, owner)
// 	if(locate(/datum/objective/hijack) in owner.get_all_objectives())
// 		antag_hud_name = is_contractor ? "hudhijackcontractor" : "hudhijack"
// 	else
// 		antag_hud_name = is_contractor ? "hudcontractor" : "hudsyndicate"
// 	return ..()

// /datum/antagonist/rev/give_objectives()
// 	return ..() // for now

// /datum/antagonist/rev/finalize_antag()
// 	if(give_codewords)
// 		give_codewords()
// 	if(isAI(owner.current))
// 		add_law_zero()
// 		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
// 		var/mob/living/silicon/ai/A = owner.current
// 		A.show_laws()
// 	else
// 		if(give_uplink)
// 			give_uplink()
// 		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/rev/proc/promote()
	var/datum/mind/old_owner = owner
	silent = TRUE
	owner.remove_antag_datum(/datum/antagonist/rev, FALSE)

	var/datum/antagonist/rev/head/new_revhead = new()
	new_revhead.silent = TRUE
	old_owner.add_antag_datum(new_revhead, SSticker.mode.get_rev_team())
	new_revhead.silent = FALSE
	to_chat(old_owner.current, "<span class='userdanger'>You have proved your devotion to revolution! You are a head revolutionary now!</span>")

