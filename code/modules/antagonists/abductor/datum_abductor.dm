RESTRICT_TYPE(/datum/antagonist/abductor)

// Syndicate Traitors.
/datum/antagonist/abductor
	name = "Abductor"
	roundend_category = "abductors"
	job_rank = ROLE_ABDUCTOR
	special_role = SPECIAL_ROLE_ABDUCTOR_AGENT
	give_objectives = FALSE
	antag_hud_name = "abductor"
	antag_hud_type = ANTAG_HUD_ABDUCTOR
	clown_gain_text = "How are you a clown and an abductor? This is a bug!"
	clown_removal_text = "How are you a clown and an abductor? This is a bug!"
	wiki_page_name = "Abductor"
	var/datum/team/abductor/our_team

/datum/antagonist/abductor/on_gain()
	. = ..()
	owner.assigned_role = special_role
	owner.offstation_role = TRUE
	SEND_SOUND(owner.current, sound('sound/ambience/antag/abductors.ogg'))

/datum/antagonist/abductor/add_owner_to_gamemode()
	SSticker.mode.abductors |= owner

/datum/antagonist/abductor/remove_owner_from_gamemode()
	SSticker.mode.abductors -= owner

/datum/team/abductor/proc/equip_abductor()
	owner.current.equipOutfit(/datum/outfit/abductor/agent)

/datum/antagonist/abductor/scientist
	special_role = SPECIAL_ROLE_ABDUCTOR_SCIENTIST

/datum/team/abductor/abductor/equip_abductor()
	owner.current.equipOutfit(/datum/outfit/abductor/scientist)
