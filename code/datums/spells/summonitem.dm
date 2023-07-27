/obj/effect/proc_holder/spell/summonitem
	name = "Instant Summons"
	desc = "This spell can be used to recall a previously marked item to your hand from anywhere in the universe."
	school = "transmutation"
	base_cooldown = 10 SECONDS
	cooldown_min = 10 SECONDS
	clothes_req = FALSE
	invocation = "GAR YOK"
	invocation_type = "whisper"
	level_max = 0 //cannot be improved

	var/obj/marked_item
	/// List of objects which will result in the spell stopping with the recursion search
	var/static/list/blacklisted_summons = list(/obj/machinery/computer/cryopod = TRUE, /obj/machinery/atmospherics = TRUE, /obj/structure/disposalholder = TRUE, /obj/machinery/disposal = TRUE)
	action_icon_state = "summons"


/obj/effect/proc_holder/spell/summonitem/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/summonitem/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		var/list/hand_items = list(target.get_active_hand(), target.get_inactive_hand())
		var/message

		if(!marked_item) //linking item to the spell
			message = "<span class='notice'>"
			for(var/obj/item in hand_items)
				if(istype(item, /obj/item/organ/internal/brain)) //Yeah, sadly this doesn't work due to the organ system.
					break
				if(ABSTRACT in item.flags)
					continue
				if(NODROP in item.flags)
					message += "This feels very redundant, but you go through with it anyway.<br>"
				marked_item = 		item
				message += "You mark [item] for recall.</span>"
				name = "Recall [item]"
				break

			if(!marked_item)
				if(hand_items)
					message = span_caution("You aren't holding anything that can be marked for recall.")
				else
					message = span_notice("You must hold the desired item in your hands to mark it for recall.")

		else if(marked_item && (marked_item in hand_items)) //unlinking item to the spell
			message = span_notice("You remove the mark on [marked_item] to use elsewhere.")
			name = "Instant Summons"
			marked_item = 		null

		else if(marked_item && !marked_item.loc) //the item was destroyed at some point
			message = span_warning("You sense your marked item has been destroyed!")
			name = "Instant Summons"
			marked_item = 		null

		else	//Getting previously marked item
			var/obj/item_to_retrieve = marked_item
			var/infinite_recursion = 0 //I don't want to know how someone could put something inside itself but these are wizards so let's be safe

			while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
				if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
					var/mob/M = item_to_retrieve.loc

					if(issilicon(M) || !M.drop_item_ground(item_to_retrieve)) //Items in silicons warp the whole silicon
						var/turf/target_turf = get_turf(target)
						if(!target_turf)
							return

						M.visible_message(span_warning("[M] suddenly disappears!"), span_danger("A force suddenly pulls you away!"))
						M.forceMove(target_turf)
						M.loc.visible_message(span_caution("[M] suddenly appears!"))
						item_to_retrieve = null
						break

					if(ishuman(M)) //Edge case housekeeping
						var/mob/living/carbon/human/C = M
						/*if(C.internal_bodyparts_by_name  && item_to_retrieve in C.internal_bodyparts_by_name ) //This won't work, as we use organ datums instead of objects. --DZD
							C.internal_bodyparts_by_name  -= item_to_retrieve
							if(istype(marked_item, /obj/item/brain)) //If this code ever runs I will be happy
								var/obj/item/brain/B = new /obj/item/brain(target.loc)
								B.transfer_identity(C)
								C.death()
								add_attack_logs(target, C, "Magically debrained INTENT: [uppertext(target.a_intent)]")*/
						for(var/X in C.bodyparts)
							var/obj/item/organ/external/part = X
							if(item_to_retrieve in part.embedded_objects)
								part.embedded_objects -= item_to_retrieve
								to_chat(C, span_warning("The [item_to_retrieve] that was embedded in your [part] has mysteriously vanished. How fortunate!"))
								if(!C.has_embedded_objects())
									C.clear_alert("embeddedobject")
								break

				else
					if(istype(item_to_retrieve.loc,/obj/machinery/portable_atmospherics/)) //Edge cases for moved machinery
						var/obj/machinery/portable_atmospherics/P = item_to_retrieve.loc
						P.disconnect()
						P.update_icon()
					if(is_type_in_typecache(item_to_retrieve.loc, blacklisted_summons))
						break
					item_to_retrieve = item_to_retrieve.loc

				infinite_recursion += 1

			if(!item_to_retrieve)
				return

			var/turf/target_turf = get_turf(target)
			if(!target_turf)
				return

			item_to_retrieve.loc.visible_message(span_warning("The [item_to_retrieve.name] suddenly disappears!"))
			playsound(target_turf, 'sound/magic/summonitems_generic.ogg', 50, TRUE)

			if(!target.put_in_active_hand(item_to_retrieve) && !target.put_in_inactive_hand(item_to_retrieve))
				item_to_retrieve.loc = target_turf
				item_to_retrieve.loc.visible_message(span_caution("The [item_to_retrieve.name] suddenly appears!"))
			else
				item_to_retrieve.loc.visible_message(span_caution("The [item_to_retrieve.name] suddenly appears in [target]'s hand!"))

		if(message)
			to_chat(target, message)
