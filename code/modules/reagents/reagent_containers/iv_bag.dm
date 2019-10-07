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

/obj/item/reagent_containers/iv_bag/Destroy()
	end_processing()
	return ..()

/obj/item/reagent_containers/iv_bag/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/iv_bag/pickup(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/iv_bag/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/iv_bag/attack_self(mob/user)
	..()
	mode = !mode
	update_icon()

/obj/item/reagent_containers/iv_bag/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/iv_bag/proc/begin_processing(mob/target)
	injection_target = target
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/iv_bag/proc/end_processing()
	injection_target = null
	STOP_PROCESSING(SSobj, src)

/obj/item/reagent_containers/iv_bag/process()
	if(!injection_target)
		end_processing()
		return

	if(amount_per_transfer_from_this > 10) // Prevents people from switching to illegal transfer values while the IV is already in someone, i.e. anything over 10
		visible_message("<span class='danger'>The IV bag's needle pops out of [injection_target]'s arm. The transfer amount is too high!</span>")
		end_processing()
		return

	if(get_dist(get_turf(src), get_turf(injection_target)) > 1)
		to_chat(injection_target, "<span class='userdanger'>The [src]'s' needle is ripped out of you!</span>")
		injection_target.apply_damage(3, BRUTE, pick("r_arm", "l_arm"))
		end_processing()
		return

	if(mode) 	// Injecting
		if(reagents.total_volume)
			var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1) 	//The amount of reagents we'll transfer to the person
			reagents.reaction(injection_target, INGEST, fraction) 						//React the amount we're transfering.
			reagents.trans_to(injection_target, amount_per_transfer_from_this)
			update_icon()
	else		// Drawing
		if(reagents.total_volume < reagents.maximum_volume)
			injection_target.transfer_blood_to(src, amount_per_transfer_from_this)
			for(var/datum/reagent/x in injection_target.reagents.reagent_list) // Pull small amounts of reagents from the person while drawing blood
				injection_target.reagents.trans_to(src, amount_per_transfer_from_this/10)
			update_icon()

/obj/item/reagent_containers/iv_bag/attack(mob/living/M, mob/living/user, def_zone)
	return

/obj/item/reagent_containers/iv_bag/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(!target.reagents)
		return

	if(isliving(target))
		var/mob/living/L = target
		if(injection_target) // Removing the needle
			if(L != injection_target)
				to_chat(user, "<span class='notice'>[src] is already inserted into [injection_target]'s arm!")
				return
			if(L != user)
				L.visible_message("<span class='danger'>[user] is trying to remove [src]'s needle from [L]'s arm!</span>", \
								"<span class='userdanger'>[user] is trying to remove [src]'s needle from [L]'s arm!</span>")
				if(!do_mob(user, L))
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
				if(!do_mob(user, L))
					return
			L.visible_message("<span class='danger'>[user] inserts [src]'s needle into [L]'s arm!</span>", \
									"<span class='userdanger'>[user] inserts [src]'s needle into [L]'s arm!</span>")
			begin_processing(L)

	else if(target.is_refillable() && is_drainable()) // Transferring from IV bag to other containers
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


/obj/item/reagent_containers/iv_bag/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/percent = round((reagents.total_volume / volume) * 10) // We round the 1's place off of our percent for easy image processing.
		var/image/filling = image('icons/goonstation/objects/iv.dmi', src, "[icon_state][percent]")

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
	if(ismob(loc))
		switch(mode)
			if(IV_DRAW)
				overlays += "draw"
			if(IV_INJECT)
				overlays += "inject"

/obj/item/reagent_containers/iv_bag/proc/set_label(new_label)
	name = "[initial(name)] ([new_label])"

/obj/item/reagent_containers/iv_bag/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen) || istype(I, /obj/item/flashlight/pen))
		var/tmp_label = sanitize(input(user, "Enter a label for [name]","Label",label_text))
		if(length(tmp_label) > MAX_NAME_LEN)
			to_chat(user, "<span class='warning'>The label can be at most [MAX_NAME_LEN] characters long.</span>")
		else
			to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
			set_label(tmp_label)

// PRE-FILLED IV BAGS BELOW

/obj/item/reagent_containers/iv_bag/salglu
	name = "\improper IV Bag (Saline Glucose)"
	list_reagents = list("salglu_solution" = 200)

/obj/item/reagent_containers/iv_bag/blood // Don't use this - just an abstract type to allow blood bags to have a common blood_type var for ease of creation.
	var/blood_type
	amount_per_transfer_from_this = 5 // Bloodbags are set to transfer 5 units by default.

/obj/item/reagent_containers/iv_bag/blood/New()
	..()
	if(blood_type != null)
		set_label(blood_type)
		reagents.add_reagent("blood", 200, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))
		update_icon()


/obj/item/reagent_containers/iv_bag/blood/random/New()
	blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-")
	..()

/obj/item/reagent_containers/iv_bag/blood/APlus
	blood_type = "A+"

/obj/item/reagent_containers/iv_bag/blood/AMinus
	blood_type = "A-"

/obj/item/reagent_containers/iv_bag/blood/BPlus
	blood_type = "B+"

/obj/item/reagent_containers/iv_bag/blood/BMinus
	blood_type = "B-"

/obj/item/reagent_containers/iv_bag/blood/OPlus
	blood_type = "O+"

/obj/item/reagent_containers/iv_bag/blood/OMinus
	blood_type = "O-"
