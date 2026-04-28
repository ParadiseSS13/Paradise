/obj/machinery/bounty_redemption
	name = "bounty redemption machine"
	desc = "An electronic deposit bin that relays demands and needs from Central Command and other potential buyers. Credits are paid out with tickets redeemable at your local ATM."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "salvage_redemption"
	anchored = TRUE
	density = TRUE
	/// Direction to take items
	var/input_dir = NORTH
	/// Direction to print rewards
	var/output_dir = SOUTH
	/// Maximum number of bounties
	var/bounty_count = 0

/obj/machinery/bounty_redemption/Initialize(mapload)
	. = ..()
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/salvage_redemption(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/bounty_redemption/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/bounty_redemption/update_icon_state()
	. = ..()
	icon_state = "salvage_redemption"
	if(panel_open)
		icon_state += "-open"
		return

/obj/machinery/bounty_redemption/process()
	if(panel_open || !has_power())
		return
	var/turf/input = get_step(src, input_dir)
	var/list/slips_to_print = list()
	for(var/datum/supply_bounty/bounty in GLOB.active_supply_bounties)
		for(var/obj/input_obj in input)
			if(!istype(input_obj, bounty.bounty_target_type))
				continue
			if(bounty.exact_type && input_obj.type != bounty.bounty_target_type)
				continue
			input_obj.visible_message(SPAN_WARN("[input_obj] disintegrates as [src] breaks it down for bluespace packaging!"), SPAN_WARN("You hear as something disintegrates."))
			qdel(input_obj)
			bounty.amount_supplied++
			if(bounty.amount_supplied == bounty.quantity)
				slips_to_print += bounty
	for(var/datum/supply_bounty/bounty in slips_to_print)
		print_slip(bounty)

/obj/machinery/bounty_redemption/RefreshParts()
	bounty_count = 0
	for(var/obj/item/stock_parts/component in component_parts)
		bounty_count += component.rating
	RefreshBounties()
	SStgui.update_uis(src)

/obj/machinery/bounty_redemption/multitool_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!has_power())
		return
	if(!I.tool_start_check(src, user, 0))
		return
	input_dir = turn(input_dir, -90)
	output_dir = turn(output_dir, -90)
	to_chat(user, SPAN_NOTICE("You change [src]'s I/O settings, setting the input to [dir2text(input_dir)] and the output to [dir2text(output_dir)]."))

/obj/machinery/bounty_redemption/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/bounty_redemption/wrench_act(mob/user, obj/item/I)
	if(default_unfasten_wrench(user, I, time = 6 SECONDS))
		return TRUE

/obj/machinery/bounty_redemption/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/bounty_redemption/proc/RefreshBounties()
	while(length(GLOB.active_supply_bounties) < bounty_count)
		var/datum/supply_bounty/new_bounty = pick(GLOB.supply_bounties)
		if(prob(5))
			new_bounty.special_reward_type = pickweight(GLOB.supply_bounty_bonuses)
		GLOB.active_supply_bounties += new_bounty

/obj/machinery/bounty_redemption/proc/print_slip(datum/supply_bounty/bounty)
	// Print the credit slip
	playsound(src, 'sound/machines/banknote_counter.ogg', 30, FALSE)
	new /obj/item/credit_redemption_slip/no_cut(get_step(get_turf(src), output_dir), bounty.reward)
	if(bounty.special_reward_type)
		new bounty.special_reward_type(get_step(get_turf(src), output_dir))
	GLOB.active_supply_bounties -= bounty
	qdel(bounty)
	RefreshBounties()
