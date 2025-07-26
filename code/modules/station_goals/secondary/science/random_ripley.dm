/datum/station_goal/secondary/random_ripley
	name = "Random Ripley"
	department = "Robotics"
	progress_type = /datum/secondary_goal_progress/random_ripley
	should_send_crate = FALSE
	weight = 1
	var/list/modules = list()
	var/static/list/general_modules = list(
		/obj/item/mecha_parts/mecha_equipment/repair_droid,
		/obj/item/mecha_parts/mecha_equipment/generator/nuclear,
		/obj/item/mecha_parts/mecha_equipment/generator,
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay,
		/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster,
		/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster,
		/obj/item/mecha_parts/mecha_equipment/thrusters,
		/obj/item/mecha_parts/mecha_equipment/gravcatapult
	)
	var/static/list/engineering_modules = list(
		/obj/item/mecha_parts/mecha_equipment/cable_layer,
		/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma,
		/obj/item/mecha_parts/mecha_equipment/drill,
		/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,
		/obj/item/mecha_parts/mecha_equipment/rcd,
		/obj/item/mecha_parts/mecha_equipment/mining_scanner,
		/obj/item/mecha_parts/mecha_equipment/extinguisher
	)

/datum/station_goal/secondary/random_ripley/randomize_params()
	var/obj/item/mecha_parts/general_module = pick(general_modules)
	modules += general_module
	var/obj/item/mecha_parts/engineering_module = pick(engineering_modules)
	modules += engineering_module

	report_message = list("One of our rapid-response teams lost a mech, and needs a replacement Ripley with \a [initial(general_module.name)] and \a [initial(engineering_module.name)].",
						"You must label the mech properly. Use your ID card on a hand labeller to configure it.")
	admin_desc = "Ripley with [initial(general_module.name)] and [initial(engineering_module.name)]"


/datum/secondary_goal_progress/random_ripley
	var/obj/item/food/food_type
	var/list/modules
	var/sent = FALSE

/datum/secondary_goal_progress/random_ripley/configure(datum/station_goal/secondary/random_ripley/goal)
	..()
	modules = goal.modules

/datum/secondary_goal_progress/random_ripley/Copy()
	var/datum/secondary_goal_progress/random_ripley/copy = ..()
	copy.modules = modules
	copy.sent = sent
	// These ones aren't really needed in the intended use case, they're
	// just here in case someone uses this method somewhere else.
	copy.personal_account = personal_account
	return copy

/datum/secondary_goal_progress/random_ripley/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	// Not labelled for this goal? Ignore.
	if(!check_goal_label(AM))
		return
	if(!istype(AM, /obj/mecha/working/ripley))
		return
	if(!manifest)
		return COMSIG_CARGO_SELL_PRIORITY | COMSIG_CARGO_IS_SECURED
	if(sent)
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "extra mech"))
		SSblackbox.record_feedback("nested tally", "secondary goals", SSeconomy.credits_per_mech, list(goal_name, "extra mech credits"))
		var/datum/economy/line_item/extra_item = new
		extra_item.account = SSeconomy.cargo_account
		extra_item.credits = SSeconomy.credits_per_mech
		extra_item.reason = "We already got the mech we needed, but we'll take this one at the usual price."
		extra_item.requests_console_department = "Robotics"
		manifest.line_items += extra_item
		return COMSIG_CARGO_SELL_PRIORITY | COMSIG_CARGO_IS_SECURED

	var/remaining_needs = modules.Copy()
	for(var/component in AM)
		for(var/need in remaining_needs)
			if(istype(component, need))
				remaining_needs -= need
				break
		// We sell or skip all of these, so we can delete it.
		qdel(component)
	if(length(remaining_needs))
		if(manifest)
			SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "incorrect mech"))
			SSblackbox.record_feedback("nested tally", "secondary goals", SSeconomy.credits_per_mech, list(goal_name, "incorrect mech credits"))
			var/datum/economy/line_item/wrong_item = new
			wrong_item.account = SSeconomy.cargo_account
			wrong_item.credits = SSeconomy.credits_per_mech
			wrong_item.reason = "That's not the equipment we needed, but it's still a mech, so we'll take it at the usual price."
			wrong_item.requests_console_department = "Robotics"
			manifest.line_items += wrong_item
		return COMSIG_CARGO_SELL_PRIORITY | COMSIG_CARGO_IS_SECURED

	sent = TRUE
	return COMSIG_CARGO_SELL_PRIORITY | COMSIG_CARGO_IS_SECURED

/datum/secondary_goal_progress/random_ripley/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	if(sent)
		SSblackbox.record_feedback("nested tally", "secondary goals", 1, list(goal_name, "correct mech"))
		three_way_reward(manifest, "Robotics", GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE), SSeconomy.credits_per_ripley_goal, "Secondary goal complete: Customized Ripley.")
	return sent
