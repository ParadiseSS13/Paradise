/datum/action/changeling/evolutionary_mastery
	name = "Evolutionary Mastery"
	desc = "Tweak your genome on the fly to best suite your current situation"
	button_icon_state = "absorb_dna"
	chemical_cost = 0
	power_type = CHANGELING_INNATE_POWER

/datum/action/changeling/evolutionary_mastery/try_to_sting(mob/user, mob/target)
	ui_interact(user)

/datum/action/changeling/evolutionary_mastery/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "GeneReactorMenu", "Evolutionary Mastery", 480, 574, master_ui, state)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/action/changeling/evolutionary_mastery/ui_data(mob/user)
	var/list/data = list()

	var/list/stats = list()
	for(var/stat in cling.stat_changes)
		stats += list(list(
			"name" = stat,
			"value" = cling.stat_changes[stat]["value"],
			"gene_damage" = cling.stat_changes[stat]["gene_damage"]
		))
	data["stats"] = stats

	return data

/datum/action/changeling/evolutionary_mastery/ui_act(action, list/params)
	if(..())
		return
	var/mob/living/carbon/human/H = cling.owner.current
	if(!istype(H))
		return FALSE
	var/value = clamp(round(text2num(params["value"]), 0.01), -2, 2)
	. = TRUE

	switch(action)
		if("stat_change")
			cling.adjust_stats(params["stat_key"], value)
		if("stat_reset")
			for(var/stat in cling.stat_changes)
				cling.adjust_stats(stat, 0)

/datum/antagonist/changeling/proc/adjust_stats(stat, value)
	if(!istype(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current

	var/old_value = stat_changes[stat]["value"]
	var/difference = value - old_value
	stat_changes[stat]["value"] = value

	switch(stat)
		if(CLING_STAT_SPEED)
			H.dna.species.speed_mod -= difference
		if(CLING_STAT_ARMOUR)
			H.dna.species.armor += 30 * difference
		if(CLING_STAT_STRENGTH)
			H.physiology.melee_bonus += difference * 5
