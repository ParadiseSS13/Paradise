/datum/spell/summonitem
	name = "Instant Summons"
	desc = "This spell can be used to recall a previously marked item to your hand from anywhere in the universe."
	clothes_req = FALSE
	invocation = "GAR YOK"
	invocation_type = "whisper"
	level_max = 0 //cannot be improved
	cooldown_min = 100

	var/obj/marked_item
	/// List of objects which will result in the spell stopping with the recursion search
	var/static/list/blacklisted_summons = list(/obj/machinery/computer/cryopod = TRUE, /obj/machinery/atmospherics = TRUE, /obj/structure/disposalholder = TRUE, /obj/machinery/disposal = TRUE)
	action_icon_state = "summons"

/datum/spell/summonitem/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/summonitem/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		var/list/hand_items = list(target.get_active_hand(),target.get_inactive_hand())
		var/butterfingers = FALSE
		var/message

		if(!marked_item) //linking item to the spell
			message = "<span class='notice'>"
			for(var/obj/item in hand_items)
				if(istype(item, /obj/item/organ/internal/brain)) //Yeah, sadly this doesn't work due to the organ system.
					break
				if(istype(item, /obj/item/disk/nuclear)) //Let's not make nukies suffer with this bullshit.
					to_chat(user, "<span class='notice'>[item] has some built in protections against such summoning magic.</span>")
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
					message = "<span class='caution'>You aren't holding anything that can be marked for recall.</span>"
				else
					message = "<span class='notice'>You must hold the desired item in your hands to mark it for recall.</span>"

		else if(marked_item && (marked_item in hand_items)) //unlinking item to the spell
			message = "<span class='notice'>You remove the mark on [marked_item] to use elsewhere.</span>"
			name = "Instant Summons"
			marked_item = 		null

		else if(marked_item && !marked_item.loc) //the item was destroyed at some point
			message = "<span class='warning'>You sense your marked item has been destroyed!</span>"
			name = "Instant Summons"
			marked_item = 		null

		else	//Getting previously marked item
			var/obj/item_to_retrieve = marked_item
			var/visible_item = TRUE //Items that silently disappear will have the message suppressed
			var/infinite_recursion = 0 //I don't want to know how someone could put something inside itself but these are wizards so let's be safe

			while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
				if(istype(item_to_retrieve.loc, /obj/item/organ/internal/headpocket))
					var/obj/item/organ/internal/headpocket/pocket = item_to_retrieve.loc
					if(pocket.owner)
						to_chat(pocket.owner, "<span class='warning'>Your [pocket.name] suddenly feels lighter. How strange!</span>")
					visible_item = FALSE
					break
				if(istype(item_to_retrieve.loc, /obj/item/storage/hidden_implant)) //The implant should be left alone
					var/obj/item/storage/S = item_to_retrieve.loc
					for(var/mob/M in S.mobs_viewing)
						to_chat(M, "<span class='warning'>[item_to_retrieve] suddenly disappears!</span>")
					visible_item = FALSE
					break
				if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
					var/mob/M = item_to_retrieve.loc

					if(issilicon(M) || !M.transfer_item_to(item_to_retrieve, target.loc)) //Items in silicons warp the whole silicon
						M.visible_message("<span class='warning'>[M] suddenly disappears!</span>", "<span class='danger'>A force suddenly pulls you away!</span>")
						M.loc.visible_message("<span class='caution'>[M] suddenly appears!</span>")
						item_to_retrieve = null
						break

					if(ishuman(M)) //Edge case housekeeping
						var/mob/living/carbon/human/C = M
						for(var/X in C.bodyparts)
							var/obj/item/organ/external/part = X
							if(item_to_retrieve in part.embedded_objects)
								part.remove_embedded_object(item_to_retrieve)
								to_chat(C, "<span class='warning'>[item_to_retrieve] that was embedded in your [part] has mysteriously vanished. How fortunate!</span>")
								if(!C.has_embedded_objects())
									C.clear_alert("embeddedobject")
								break
							if(item_to_retrieve == part.hidden)
								visible_item = FALSE
								part.hidden = null
								to_chat(C, "<span class='warning'>Your [part.name] suddenly feels emptier. How weird!</span>")
								break

				else
					if(istype(item_to_retrieve.loc, /obj/machinery/atmospherics/portable/)) //Edge cases for moved machinery
						var/obj/machinery/atmospherics/portable/P = item_to_retrieve.loc
						P.disconnect()
						P.update_icon()
					if(is_type_in_typecache(item_to_retrieve.loc, blacklisted_summons))
						break
					item_to_retrieve = item_to_retrieve.loc
					if(istype(item_to_retrieve, /obj/item/storage/backpack/modstorage))
						var/obj/item/storage/backpack/modstorage/bag = item_to_retrieve
						if(bag.source && bag.source.mod)
							item_to_retrieve = bag.source.mod //Grab the modsuit.

				infinite_recursion += 1

			if(!item_to_retrieve)
				return

			if(!isturf(target.loc))
				to_chat(target, "<span class='caution'>You attempt to cast the spell, but it fails! Perhaps you aren't available?</span>")
				return
			if(visible_item)
				item_to_retrieve.loc.visible_message("<span class='warning'>[item_to_retrieve] suddenly disappears!</span>")
			var/list/heres_disky = item_to_retrieve.search_contents_for(/obj/item/disk/nuclear)
			heres_disky += item_to_retrieve.loc.search_contents_for(/obj/item/disk/nuclear) //So if you mark another item in a bag, we don't pull
			for(var/obj/item/disk/nuclear/N in heres_disky)
				N.forceMove(get_turf(item_to_retrieve))
				N.visible_message("<span class='warning'>As [item_to_retrieve] vanishes, [N] remains behind!</span>")
				break //If you have 2 nads, well, congrats? Keeps message from doubling up
			if(target.hand) //left active hand
				if(!target.equip_to_slot_if_possible(item_to_retrieve, ITEM_SLOT_LEFT_HAND, FALSE, TRUE))
					if(!target.equip_to_slot_if_possible(item_to_retrieve, ITEM_SLOT_RIGHT_HAND, FALSE, TRUE))
						butterfingers = TRUE
			else			//right active hand
				if(!target.equip_to_slot_if_possible(item_to_retrieve, ITEM_SLOT_RIGHT_HAND, FALSE, TRUE))
					if(!target.equip_to_slot_if_possible(item_to_retrieve, ITEM_SLOT_LEFT_HAND, FALSE, TRUE))
						butterfingers = TRUE
			if(butterfingers)
				item_to_retrieve.loc = target.loc
				item_to_retrieve.loc.visible_message("<span class='caution'>[item_to_retrieve] suddenly appears!</span>")
				playsound(get_turf(target),'sound/magic/summonitems_generic.ogg', 50, 1)
			else
				item_to_retrieve.loc.visible_message("<span class='caution'>[item_to_retrieve] suddenly appears in [target]'s hand!</span>")
				playsound(get_turf(target),'sound/magic/summonitems_generic.ogg', 50, 1)

		if(message)
			to_chat(target, message)
