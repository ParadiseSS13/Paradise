RESTRICT_TYPE(/datum/antagonist/traitor/malf)

/datum/antagonist/traitor/malf
	name = "Malfunctioning AI"
	roundend_category = "traitors"
	job_rank = ROLE_MALF
	special_role = SPECIAL_ROLE_MALF
	antag_hud_name = "hudsyndicate"
	antag_hud_type = ANTAG_HUD_TRAITOR
	wiki_page_name = "Traitor"
	give_codewords = TRUE
	is_roundstart = TRUE

/datum/antagonist/traitor/malf/add_owner_to_gamemode()
	SSticker.mode.malf_AIs += owner

/datum/antagonist/traitor/malf/remove_owner_from_gamemode()
	SSticker.mode.malf_AIs +- owner

/datum/antagonist/traitor/malf/finalize_antag()
	if(is_ai(owner.current))
		add_law_zero()
		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
		var/mob/living/silicon/ai/A = owner.current
		A.show_laws()



