/obj/structure/cable/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || drain_act_protected)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check
	var/drain = 0 //Drain amount
	var/gained_total = 0
	var/drain_total = 0
	add_game_logs("draining energy from [src] [COORD(src)]", ninja)
	var/datum/powernet/wire_powernet = powernet

	var/turf/cable_turf = get_turf(src)
	if(cable_turf.transparent_floor || cable_turf.intact)
		to_chat(ninja, span_danger("You can't interact with something that's under the floor!"))
		return INVALID_DRAIN
	if(wire_powernet.avail <= 0 || wire_powernet.load <= 0)	// Если в проводах нет тока, то и начать сосать его мы не можем!
		return INVALID_DRAIN

	while(!maxcapacity && src)
		drain = (round((rand(ninja_gloves.mindrain, ninja_gloves.maxdrain))/2))
		var/drained = 0
		if(wire_powernet && do_after(ninja ,10, target = src))
			drained = min(drain, delayed_surplus())
			add_delayedload(drained)
			for(var/obj/machinery/power/terminal/affected_terminal in wire_powernet.nodes)
				if(istype(affected_terminal.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/affected_apc = affected_terminal.master
					if(affected_apc.operating && affected_apc.cell && affected_apc.cell.charge > 0)
						affected_apc.cell.use(10)
						drain += 1
						drained += 10
		else
			break

		ninja_suit.cell.give(drain)
		if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
			ninja_suit.cell.charge = ninja_suit.cell.maxcharge
			maxcapacity = TRUE
		gained_total += drain
		drain_total += drained
		ninja_suit.spark_system.start()

	to_chat(ninja, span_notice("Energy net lost <B>[drain_total]</B> amount of energy because of the overload caused by you."))
	return gained_total
