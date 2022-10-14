/obj/mecha/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || drain_act_protected)
		return INVALID_DRAIN

	var/maxcapacity = FALSE //Safety check
	var/drain = 0 //Drain amount
	var/drain_total = 0
	add_game_logs("draining energy from [src] [COORD(src)]", ninja)
	if(occupant)
		to_chat(occupant, "[icon2base64(src, occupant)][span_danger("Warning: Unauthorized access through sub-route 4, block H, detected.")]")
	if(get_charge())
		while(cell.charge > 0 && !maxcapacity)
			drain = rand(ninja_gloves.mindrain, ninja_gloves.maxdrain)
			if(cell.charge < drain)
				drain = cell.charge
			if(ninja_suit.cell.charge + drain > ninja_suit.cell.maxcharge)
				drain = ninja_suit.cell.maxcharge - ninja_suit.cell.charge
				maxcapacity = TRUE
			if(do_after(ninja, 10, target = src))
				spark_system.start()
				playsound(loc, "sparks", 50, TRUE, 5)
				cell.use(drain)
				ninja_suit.cell.give(drain)
				drain_total += drain
			else
				break

	return drain_total
