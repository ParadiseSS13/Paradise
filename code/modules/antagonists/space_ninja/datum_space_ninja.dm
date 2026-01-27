RESTRICT_TYPE(/datum/antagonist/space_ninja)

// Spider Clan Space Ninja
/datum/antagonist/space_ninja
	name = "Space Ninja"
	roundend_category = "ninjas"
	job_rank = ROLE_NINJA
	special_role = SPECIAL_ROLE_NINJA
	antag_hud_name = "hud_ninja"
	antag_hud_type = ANTAG_HUD_NINJA
	clown_gain_text = "Your spider clan training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	clown_removal_text = "You lose your spider clan training and return to your own clumsy, clownish self."
	wiki_page_name = "Space Ninja"
	var/give_uplink = TRUE
	blurb_r = 200
	blurb_a = 0.75
	boss_title = "Spider Clan Daimyo"
	/// Number of missions needed to complete
	var/mission_goal = 4

/datum/antagonist/space_ninja/give_objectives()
	forge_objectives()

// POLTODO: Exfil
/datum/antagonist/space_ninja/exfiltrate(mob/living/carbon/human/extractor, obj/item/radio/radio)
	if(isplasmaman(extractor))
		extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/syndicate/plasmaman)
	else
		extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/syndicate)

	radio.autosay("<b>--ZZZT!- Domo Ar!g@to, [extractor.real_name]. Your training paid -^%&!-ZZT!-</b>", "Spider Clan HQ", "Security")
	SSblackbox.record_feedback("tally", "successful_extraction", 1, "Space Ninja")

/datum/antagonist/space_ninja/finalize_antag()
	. = ..()
	equip_ninja()

/datum/antagonist/space_ninja/proc/equip_ninja()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/new_ninja = owner.current
	new_ninja.equipOutfit(/datum/outfit/space_ninja)

/datum/antagonist/space_ninja/proc/forge_objectives()
	var/iteration = 1

/datum/antagonist/space_ninja/proc/forge_new_objective()
