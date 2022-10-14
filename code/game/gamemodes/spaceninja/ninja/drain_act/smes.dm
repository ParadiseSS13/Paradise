/obj/machinery/power/smes/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || drain_act_protected)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check for batteries
	var/drain = 0 //Drain amount from batteries
	var/drain_total = 0
	add_game_logs("draining energy from [src] [COORD(src)]", ninja)

	if(charge)

		investigate_log("<font color='red'>[ninja.real_name] started draining [src] of energy </font> at [AREACOORD(src)]", INVESTIGATE_ENGINE)
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, loc)

		while(charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)

			if(charge < drain)
				drain = charge

			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE

			if (do_after(ninja,10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, 5)
				charge -= drain
				ninja_suit.cell.give(drain)
				drain_total += drain

			else
				break
		investigate_log("<font color='red'>[ninja.real_name] ended draining [src] of energy </font> at [AREACOORD(src)]. Remaining energy: [src.charge]/[src.capacity]", INVESTIGATE_ENGINE)

	return drain_total
