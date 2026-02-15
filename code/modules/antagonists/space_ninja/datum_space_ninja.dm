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

/datum/antagonist/space_ninja/on_gain()
	..()
	mission_goal = 4 + (length(GLOB.crew_list) / 10)
	SEND_SOUND(owner.current, sound('sound/ambience/antag/ninjaalert.ogg'))

/datum/antagonist/space_ninja/give_objectives()
	forge_objectives()

/datum/antagonist/space_ninja/exfiltrate(mob/living/carbon/human/extractor, obj/item/radio/radio)
	extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/space_ninja)
	radio.autosay("<b>--ZZZT!- Domo Ar!g@to, [extractor.real_name]. Your training paid -^%&!-ZZT!-</b>", "Spider Clan HQ", "Security")
	SSblackbox.record_feedback("tally", "successful_extraction", 1, "Space Ninja")

/datum/antagonist/space_ninja/finalize_antag()
	. = ..()
	equip_ninja()

/datum/antagonist/space_ninja/add_owner_to_gamemode()
	SSticker.mode.ninjas |= owner

/datum/antagonist/space_ninja/remove_owner_from_gamemode()
	SSticker.mode.ninjas -= owner

/datum/antagonist/space_ninja/proc/equip_ninja()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/new_ninja = owner.current
	new_ninja.delete_equipment()
	if(isvox(new_ninja))
		new_ninja.equipOutfit(/datum/outfit/space_ninja/vox)
	else
		new_ninja.equipOutfit(/datum/outfit/space_ninja)

/datum/antagonist/space_ninja/proc/forge_objectives()
	var/list/moderate_objectives = list(
		/datum/objective/ninja/capture = 20,
		/datum/objective/ninja/kill = 20,
		/datum/objective/ninja/hack_rnd = 5,
		/datum/objective/ninja/bomb_department = 3,
		/datum/objective/ninja/bomb_department/emp = 3,
		/datum/objective/ninja/bomb_department/spiders = 3,
	)
	var/list/all_ninja_objectives = list(
		/datum/objective/ninja/capture = 10,
		/datum/objective/ninja/kill = 10,
		/datum/objective/ninja/hack_rnd = 5,
		/datum/objective/ninja/bomb_department = 3,
		/datum/objective/ninja/bomb_department/emp = 3,
		/datum/objective/ninja/bomb_department/spiders = 3,
		/datum/objective/ninja/steal_supermatter = 3,
		/datum/objective/ninja/interrogate_ai = 3,
	)
	for(var/i in 1 to mission_goal)
		if(i <= mission_goal / 2) // This ensures some easier objectives are rolled to allow ninjas to work up to harder ones.
			forge_objective(moderate_objectives)
			continue
		forge_objective(all_ninja_objectives)
	add_antag_objective(/datum/objective/ninja_exfiltrate)

/datum/antagonist/space_ninja/proc/forge_objective(list/objective_list)

	var/datum/objective/ninja/new_objective = pickweight(objective_list)
	var/datum/objective/ninja/obj_item = new new_objective() // Needed to do to check validity and reroll
	if(!obj_item.check_objective_conditions())
		forge_objective(objective_list)
		qdel(obj_item)
		return
	qdel(obj_item)
	if(new_objective.onlyone)
		var/list/current_objectives = get_antag_objectives()
		for(var/datum/objective/ninja/c_objective in current_objectives)
			if(istype(c_objective, new_objective))
				forge_objective(objective_list)
				return
	add_antag_objective(new_objective)
