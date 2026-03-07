/obj/item/ninja_scanner
	name = "spider scanner"
	desc = "Advanced multi-use scanning device used by the spider clan to confirm bounty completion. Scan the corpses of dead or netted crew to redeem your bounties."
	icon = 'icons/obj/device.dmi'
	icon_state = "ninja_scanner"
	slot_flags = ITEM_SLOT_BELT
	force = 9 // Can be used as a weapon in an emergency
	hitsound = 'sound/weapons/genhit1.ogg'
	new_attack_chain = TRUE

/obj/item/ninja_scanner/attack(mob/living/target, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!user.mind)
		return ..()
	var/list/obj_list = user.mind.get_all_objectives()
	if(!length(obj_list))
		to_chat(user, SPAN_WARNING("You have no objectives!"))
		return TRUE
	for(var/datum/objective/ninja/ninja_obj in obj_list)
		if(ninja_obj.completed)
			continue
		if(istype(ninja_obj, /datum/objective/ninja/kill))
			if(target.stat != DEAD)
				continue
			if(!ninja_obj.target.current || target != ninja_obj.target.current)
				continue
			user.visible_message(SPAN_DANGER("[user] begins to use [src] to scan [target]!"), \
								SPAN_NOTICE("You begin to scan [target]!"))
			if(!do_after_once(user, 8 SECONDS, target = target, allow_moving = FALSE, attempt_cancel_message = "You stop scanning [target] before completing the scan."))
				return TRUE
			ninja_obj.completed = TRUE
			to_chat(user, SPAN_NOTICE("Contract complete. Good work - your cut of the pay has been forwarded to your uplink."))
			ninja_obj.complete_objective()
			return TRUE

		if(istype(ninja_obj, /datum/objective/ninja/capture))
			var/datum/objective/ninja/capture/cap_obj = ninja_obj
			if(target.stat == DEAD)
				if(!target.ghost_can_reenter()) // Target is DNR. Reroll.
					to_chat(user, SPAN_NOTICE("Target is unrecoverable. Finding a new target..."))
					on_target_cryo()
				else
					to_chat(user, SPAN_NOTICE("Target is dead. Dead people don't talk. Esnure they are revived, then send them to us."))
				continue
			if(target != ninja_obj.target.current)
				continue
			if(!target.buckled)
				continue
			var/obj/structure/bed/energy_net/trapped_net
			for(var/obj/structure/bed/energy_net/net in target.loc)
				trapped_net = net
				break
			if(!trapped_net)
				continue
			user.visible_message(SPAN_DANGER("[user] begins to use [src] to scan [target]!"), \
								SPAN_NOTICE("You begin to scan [target]!"))
			if(!do_after_once(user, 5 SECONDS, target = target, allow_moving = FALSE, attempt_cancel_message = "You stop scanning [target] before completing the scan."))
				return TRUE
			target.unbuckle(TRUE)
			trapped_net.Destroy()
			var/target_loc = target.loc
			do_teleport(target, pick(GLOB.ninjaprisonwarp), 0, TRUE, bypass_area_flag = TRUE)
			var/mob/living/carbon/c_target = target
			if(istype(c_target))
				var/obj/item/restraints/handcuffs/cuffs = target.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
				qdel(cuffs)
				c_target.handcuffed = FALSE
				c_target.update_handcuffed()
			cap_obj.handle_capture(target, target_loc)
			ninja_obj.completed = TRUE
			to_chat(user, SPAN_NOTICE("Contract complete. Good work - your cut of the pay has been forwarded to your uplink."))
			ninja_obj.complete_objective()
			return TRUE

		if(istype(ninja_obj, /datum/objective/ninja/interrogate_ai))
			if(!is_ai(target))
				return TRUE
			var/mob/living/silicon/ai/AI = target
			user.visible_message(SPAN_DANGER("[user] begins to use [src] to upload [AI]!"), \
								SPAN_NOTICE("You begin to upload [AI]!"))
			if(!do_after_once(user, 8 SECONDS, target = AI, allow_moving = FALSE, attempt_cancel_message = "You stop uploading [AI] before completing the upload."))
				return TRUE
			var/obj/item/aicard/card = new()
			AI.take_overall_damage(50)
			AI.transfer_ai(AI_TRANS_TO_CARD, user, null, card)
			var/list/possible_spawns = GLOB.maints_loot_spawns
			while(length(possible_spawns))
				var/turf/current_turf = pick_n_take(possible_spawns)
				if(!is_station_level(current_turf))
					continue
				if(!current_turf.density)
					do_teleport(card, current_turf)
					break
				// Someone built a wall over it, check the surroundings
				var/list/open_turfs = current_turf.AdjacentTurfs(open_only = TRUE)
				if(length(open_turfs))
					do_teleport(card, pick(open_turfs))
					break
			ninja_obj.completed = TRUE
			to_chat(user, SPAN_NOTICE("Contract complete. Good work - your cut of the pay has been forwarded to your uplink."))
			ninja_obj.complete_objective()
			return TRUE
	return ..()

/obj/item/ninja_scanner/attack_obj(obj/attacked_obj, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!user.mind)
		return ..()
	var/list/obj_list = user.mind.get_all_objectives()
	if(!length(obj_list))
		to_chat(user, SPAN_WARNING("You have no objectives!"))
		return TRUE
	for(var/datum/objective/ninja/ninja_obj in obj_list)
		if(ninja_obj.completed)
			continue
		if(istype(ninja_obj, /datum/objective/ninja/hack_rnd) && istype(attacked_obj, /obj/machinery/computer/rnd_network_controller))
			if(!do_after_once(user, 12 SECONDS, target = attacked_obj, allow_moving = FALSE, attempt_cancel_message = "You stop hacking [attacked_obj] before completing the download."))
				return TRUE
			to_chat(user, SPAN_NOTICE("Contract complete. Good work - your cut of the pay has been forwarded to your uplink."))
			var/obj/machinery/computer/rnd_network_controller/rnd = attacked_obj
			rnd.research_files.known_tech = list()
			ninja_obj.completed = TRUE
			ninja_obj.complete_objective()
			return TRUE

	return ..()
