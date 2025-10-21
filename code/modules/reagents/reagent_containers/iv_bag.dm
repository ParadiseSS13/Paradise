#define IV_DRAW 0
#define IV_INJECT 1

/obj/item/reagent_containers/iv_bag
	name = "\improper IV Bag"
	desc = "A bag with a fine needle attached at the end for injecting patients with fluids over a period of time."
	icon = 'icons/goonstation/objects/iv.dmi'
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'
	icon_state = "ivbag"
	volume = 200
	possible_transfer_amounts = list(1,5,10,15,20,25,30,50) // Everything above 10 is NOT usable on a person and is instead used for transfering to other containers
	amount_per_transfer_from_this = 1
	container_type = OPENCONTAINER
	resistance_flags = ACID_PROOF
	var/label_text
	var/mode = IV_INJECT
	var/mob/living/carbon/human/injection_target
	var/injection_action_delay = 3 SECONDS

/obj/item/reagent_containers/iv_bag/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TETHER_DESTROYED, PROC_REF(tether_snapped))

/obj/item/reagent_containers/iv_bag/Destroy()
	end_processing()
	return ..()

/obj/item/reagent_containers/iv_bag/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/pickup(mob/user)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/dropped(mob/user)
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/activate_self(mob/user)
	if(..())
		return

	mode = !mode
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/attack_hand()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/proc/on_examine(datum/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER // COMSIG_PARENT_EXAMINE
	examine_list += "<span class='notice'>[source.p_they(TRUE)] [source.p_have()] an active IV bag.</span>"

/obj/item/reagent_containers/iv_bag/proc/begin_processing(mob/target)
	injection_target = target
	if(target.viruses)
		AddComponent(/datum/component/viral_contamination, target.viruses)
	RegisterSignal(injection_target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	START_PROCESSING(SSobj, src)
	update_iv_type()

/obj/item/reagent_containers/iv_bag/proc/update_iv_type()
	var/target = injection_target
	injection_target = null
	SEND_SIGNAL(src, COMSIG_TETHER_STOP)
	injection_target = target
	if(!injection_target)
		return
	if(istype(loc, /obj/machinery/iv_drip))
		injection_target.AddComponent(/datum/component/tether, src, 2, 50, "iv_tether", "tubing")
	else
		injection_target.AddComponent(/datum/component/tether, src, 1, 5, "iv_tether", "tubing")

/obj/item/reagent_containers/iv_bag/proc/end_processing(send_signal = TRUE)
	if(injection_target)
		UnregisterSignal(injection_target, COMSIG_PARENT_EXAMINE)
	injection_target = null
	STOP_PROCESSING(SSobj, src)
	if(send_signal)
		SEND_SIGNAL(src, COMSIG_TETHER_STOP)

/obj/item/reagent_containers/iv_bag/proc/tether_snapped()
	if(!injection_target)
		return
	to_chat(injection_target, "<span class='userdanger'>[src]'s needle is ripped out of you!</span>")
	injection_target.apply_damage(3, BRUTE, pick("r_arm", "l_arm"))
	end_processing(FALSE)

/obj/item/reagent_containers/iv_bag/process()
	if(QDELETED(injection_target))
		end_processing()
		return

	if(amount_per_transfer_from_this > 10) // Prevents people from switching to illegal transfer values while the IV is already in someone, i.e. anything over 10
		visible_message("<span class='danger'>The IV bag's needle pops out of [injection_target]'s arm. The transfer amount is too high!</span>")
		end_processing()
		return

	if(mode) 	// Injecting
		if(reagents.total_volume)
			var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1) 	//The amount of reagents we'll transfer to the person
			reagents.reaction(injection_target, REAGENT_INGEST, fraction) 						//React the amount we're transfering.
			reagents.trans_to(injection_target, amount_per_transfer_from_this)
			update_icon(UPDATE_OVERLAYS)
	else		// Drawing
		if(reagents.total_volume < reagents.maximum_volume)
			injection_target.transfer_blood_to(src, amount_per_transfer_from_this)
			for(var/datum/reagent/reagent in injection_target.reagents.reagent_list) // Pull small amounts of reagents from the person while drawing blood
				if(reagent.id in GLOB.blocked_chems)
					continue
				injection_target.reagents.trans_id_to(src, reagent.id, amount_per_transfer_from_this / 10)
			update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/iv_bag/mob_act(mob/target, mob/living/user)
	. = TRUE
	if(!target.reagents)
		return FALSE

	var/mob/living/L = target
	if(istype(L))
		if(injection_target) // Removing the needle
			if(L != injection_target)
				to_chat(user, "<span class='notice'>[src] is already inserted into [injection_target]'s arm!")
				return
			if(L != user)
				L.visible_message("<span class='danger'>[user] is trying to remove [src]'s needle from [L]'s arm!</span>", \
								"<span class='userdanger'>[user] is trying to remove [src]'s needle from [L]'s arm!</span>")
				if(!do_mob(user, L, injection_action_delay))
					return
			L.visible_message("<span class='danger'>[user] removes [src]'s needle from [L]'s arm!</span>", \
								"<span class='userdanger'>[user] removes [src]'s needle from [L]'s arm!</span>")
			end_processing()
		else // Inserting the needle
			if(!L.can_inject(user, TRUE))
				return
			if(amount_per_transfer_from_this > 10) // We only want to be able to transfer 1, 5, or 10 units to people. Higher numbers are for transfering to other containers
				to_chat(user, "<span class='warning'>The IV bag can only be used on someone with a transfer amount of 1, 5 or 10.</span>")
				return
			if(L != user)
				L.visible_message("<span class='danger'>[user] is trying to insert [src]'s needle into [L]'s arm!</span>", \
									"<span class='userdanger'>[user] is trying to insert [src]'s needle into [L]'s arm!</span>")
				if(!do_mob(user, L, injection_action_delay))
					return
			L.visible_message("<span class='danger'>[user] inserts [src]'s needle into [L]'s arm!</span>", \
									"<span class='userdanger'>[user] inserts [src]'s needle into [L]'s arm!</span>")
			begin_processing(L)

/obj/item/reagent_containers/iv_bag/normal_act(atom/target, mob/living/user)
	. = TRUE
	if(!target.reagents)
		return FALSE

	if(target.is_refillable() && is_drainable()) // Transferring from IV bag to other containers
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

	else if(istype(target, /obj/item/reagent_containers/glass) && !target.is_open_container())
		to_chat(user, "<span class='warning'>You cannot fill [target] while it is sealed.</span>")
		return


/obj/item/reagent_containers/iv_bag/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/percent = round((reagents.total_volume / volume) * 10) // We round the 1's place off of our percent for easy image processing.
		var/image/filling = image('icons/goonstation/objects/iv.dmi', src, "[icon_state][percent]")

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling
	if(ismob(loc))
		switch(mode)
			if(IV_DRAW)
				. += "draw"
			if(IV_INJECT)
				. += "inject"

/obj/item/reagent_containers/iv_bag/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(is_pen(used))
		rename_interactive(user, used)
		return ITEM_INTERACT_COMPLETE

// PRE-FILLED IV BAGS BELOW

/obj/item/reagent_containers/iv_bag/salglu
	list_reagents = list("salglu_solution" = 200)

/obj/item/reagent_containers/iv_bag/salglu/Initialize(mapload)
	. = ..()
	name = "[initial(name)] - Saline Glucose"

/// Don't use this - just an abstract type to allow blood bags to have a common blood_type var for ease of creation.
/obj/item/reagent_containers/iv_bag/blood
	var/blood_type
	var/blood_species = "Synthetic humanoid"
	var/iv_blood_colour = "#A10808"
	var/one_species_only = FALSE
	amount_per_transfer_from_this = 5 // Bloodbags are set to transfer 5 units by default.

/obj/item/reagent_containers/iv_bag/blood/Initialize(mapload)
	. = ..()
	if(blood_type != null)
		name = "[initial(name)] - [blood_type]"
		reagents.add_reagent("blood", 200, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"blood_colour"=iv_blood_colour,"resistances"=null,"trace_chem"=null,"species"=blood_species,"species_only"=one_species_only))
		update_icon(UPDATE_OVERLAYS)


/obj/item/reagent_containers/iv_bag/blood/random/Initialize(mapload)
	blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-")
	return ..()

/obj/item/reagent_containers/iv_bag/blood/a_plus
	blood_type = "A+"

/obj/item/reagent_containers/iv_bag/blood/a_minus
	blood_type = "A-"

/obj/item/reagent_containers/iv_bag/blood/b_plus
	blood_type = "B+"

/obj/item/reagent_containers/iv_bag/blood/b_minus
	blood_type = "B-"

/obj/item/reagent_containers/iv_bag/blood/o_plus
	blood_type = "O+"

/obj/item/reagent_containers/iv_bag/blood/o_minus
	blood_type = "O-"

/obj/item/reagent_containers/iv_bag/blood/vox
	blood_type = "O-"
	blood_species = "Vox"
	iv_blood_colour = "#2299FC"
	one_species_only = TRUE

/obj/item/reagent_containers/iv_bag/blood/vox/Initialize(mapload)
	. = ..()
	name = "[initial(name)] - O- Vox Blood"

/obj/item/reagent_containers/iv_bag/slime
	list_reagents = list("slimejelly" = 200)

/obj/item/reagent_containers/iv_bag/slime/Initialize(mapload)
	. = ..()
	name = "[initial(name)] - Slime Jelly"

#undef IV_DRAW
#undef IV_INJECT
