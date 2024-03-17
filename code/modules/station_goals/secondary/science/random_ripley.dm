/datum/station_goal/secondary/random_ripley
	name = "Random Ripley"
	department = "Robotics"
	progress_type = /datum/secondary_goal_progress/random_ripley
	abstract = FALSE
	var/list/modules = list()
	var/static/list/general_modules = list(
		/obj/item/mecha_parts/mecha_equipment/repair_droid,
		/obj/item/mecha_parts/mecha_equipment/teleporter,
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

	report_message = "One of our rapid-response teams lost a mech, and needs a replacement Ripley with \a [initial(general_module.name)] and \a [initial(engineering_module.name)]."

/datum/secondary_goal_progress/random_ripley
	var/obj/item/food/snacks/food_type
	var/list/modules
	var/sent = FALSE

/datum/secondary_goal_progress/random_ripley/configure(datum/station_goal/secondary/random_ripley/goal)
	modules = goal.modules
	personal_account = goal.personal_account

/datum/secondary_goal_progress/random_ripley/Copy()
	var/datum/secondary_goal_progress/random_ripley/copy = new
	copy.modules = modules
	copy.sent = sent
	// These ones aren't really needed in the intended use case, they're
	// just here in case someone uses this method somewhere else.
	copy.personal_account = personal_account
	return copy

/datum/secondary_goal_progress/random_ripley/update(atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest = null)
	if(!istype(AM, /obj/mecha/working/ripley))
		return
	if(!manifest)
		return COMSIG_CARGO_SELL_PRIORITY
	if(sent)
		var/datum/economy/line_item/extra_item = new
		extra_item.account = SSeconomy.cargo_account
		extra_item.credits = SSeconomy.credits_per_mech
		extra_item.reason = "We already got the mech we needed, but we'll take this one at the usual price."
		manifest.line_items += extra_item
		send_requests_console_message(extra_item.reason, "Central Command", "Robotics", "Stamped with the Central Command rubber stamp.", null, RQ_NORMALPRIORITY)
		return COMSIG_CARGO_SELL_PRIORITY

	var/remaining_needs = modules.Copy()
	for(var/component in AM)
		for(var/need in remaining_needs)
			if(istype(component, need))
				remaining_needs -= need
				break
		// We sell or skip all of these, so we can delete it.
		qdel(component)
	if(length(remaining_needs))
		var/datum/economy/line_item/wrong_item = new
		wrong_item.account = SSeconomy.cargo_account
		wrong_item.credits = SSeconomy.credits_per_mech
		wrong_item.reason = "That's not the equipment we needed, but it's still a mech"
		manifest.line_items += wrong_item
		send_requests_console_message(wrong_item.reason + ", so we sent the usual amount to your supply account.", "Central Command", "Robotics", "Stamped with the Central Command rubber stamp.", null, RQ_NORMALPRIORITY)
		return COMSIG_CARGO_SELL_PRIORITY

	sent = TRUE
	
	var/datum/economy/line_item/cargo_item = new
	cargo_item.account = SSeconomy.cargo_account
	cargo_item.credits = SSeconomy.credits_per_ripley_goal / 3
	cargo_item.reason = "Secondary goal complete: Customized Ripley."
	manifest.line_items += cargo_item

	var/datum/economy/line_item/science_item = new
	science_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	science_item.credits = SSeconomy.credits_per_ripley_goal / 3
	science_item.reason = "Secondary goal complete: Customized Ripley."
	manifest.line_items += science_item

	var/datum/economy/line_item/personal_item = new
	personal_item.account = personal_account || science_item.account
	personal_item.credits = SSeconomy.credits_per_ripley_goal / 3
	personal_item.reason = "Secondary goal complete: Customized Ripley."
	manifest.line_items += personal_item

	return COMSIG_CARGO_SELL_PRIORITY

/datum/secondary_goal_progress/random_ripley/check_complete(datum/economy/cargo_shuttle_manifest/manifest)
	return sent
