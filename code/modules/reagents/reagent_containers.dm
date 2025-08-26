/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/amount_per_transfer_from_this = 5
	var/visible_transfer_rate = TRUE
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30
	var/list/list_reagents = null
	var/spawned_disease = null
	var/disease_amount = 20
	var/has_lid = FALSE // Used for containers where we want to put lids on and off
	var/temperature_min = 0 // To limit the temperature of a reagent container can atain when exposed to heat/cold
	var/temperature_max = 10000
	new_attack_chain = TRUE

/obj/item/reagent_containers/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(isliving(target))
		user.changeNext_move(CLICK_CD_MELEE)
		mob_act(target, user)
		return ITEM_INTERACT_COMPLETE
	if(normal_act(target, user))
		return ITEM_INTERACT_COMPLETE
	return ..()

// Overriden inside its subtypes. Might add the basic container shit here (eg, beaker/bucket behaviour)
/obj/item/reagent_containers/proc/mob_act(mob/target, mob/living/user)
	return FALSE

/obj/item/reagent_containers/proc/normal_act(atom/target, mob/living/user)
	return FALSE

/obj/item/reagent_containers/proc/can_set_transfer_amount(mob/user)
	if(!length(possible_transfer_amounts))
		// Nothing to configure.
		return FALSE
	return is_valid_interaction(user)

/obj/item/reagent_containers/proc/is_valid_interaction(mob/user)
	if(isrobot(user) && src.loc == user)
		// Borgs can configure their modules.
		return TRUE
	if(!Adjacent(user))
		// No configuring the beaker across the room.
		return FALSE
	if(!ishuman(user))
		// Although a funny idea, station pets changing transfer
		// amounts on random conatiners would probably be frustrating
		// for the crew.
		return FALSE
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		// I guess there's, like, a switch or a dial or something?
		// Whatever, you need to use your hands for this.
		return FALSE

	return TRUE

/obj/item/reagent_containers/AltClick(mob/user)
	if(!can_set_transfer_amount(user))
		return

	var/new_transfer_rate = tgui_input_list(user, "Amount per transfer from this:", "[src]", possible_transfer_amounts, "[amount_per_transfer_from_this]")
	if(!new_transfer_rate)
		return

	// This looks redundant, but it's not. Time elapsed while the input
	// list was open, so we need to re-check our conditions and give an
	// error if they changed.
	if(!can_set_transfer_amount(user))
		if(!Adjacent(user))
			to_chat(user, "<span class='warning'>You have moved too far away!</span>")
		if(!ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			to_chat(user, "<span class='warning'>You can't use your hands!</span>")
		return

	amount_per_transfer_from_this = new_transfer_rate
	to_chat(user, "<span class='notice'>[src] will now transfer [amount_per_transfer_from_this] units at a time.</span>")

/obj/item/reagent_containers/Initialize(mapload)
	. = ..()
	if(!reagents) // Some subtypes create their own reagents
		create_reagents(volume, temperature_min, temperature_max)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease(0)
		var/list/data = list("viruses" = list(F), "blood_color" = "#A10808", "blood_type" = BLOOD_TYPE_FAKE_BLOOD)
		reagents.add_reagent("blood", disease_amount, data)
	add_initial_reagents()

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()

/obj/item/reagent_containers/proc/add_lid()
	if(has_lid)
		container_type ^= REFILLABLE | DRAINABLE
		update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/proc/remove_lid()
	if(has_lid)
		container_type |= REFILLABLE | DRAINABLE
		update_icon(UPDATE_OVERLAYS)

/obj/item/reagent_containers/activate_self(mob/user)
	if(..() || !has_lid)
		return

	if(is_open_container())
		to_chat(usr, "<span class='notice'>You put the lid on [src].</span>")
		add_lid()
	else
		to_chat(usr, "<span class='notice'>You take the lid off [src].</span>")
		remove_lid()

/obj/item/reagent_containers/wash(mob/user, atom/source)
	if(is_open_container())
		if(reagents.total_volume >= volume)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return
		else
			reagents.add_reagent("water", min(volume - reagents.total_volume, amount_per_transfer_from_this))
			to_chat(user, "<span class='notice'>You fill [src] from [source].</span>")
			return
	..()

/obj/item/reagent_containers/examine(mob/user)
	. = ..()

	if(visible_transfer_rate)
		. += "<span class='notice'>It will transfer [amount_per_transfer_from_this] unit[amount_per_transfer_from_this != 1 ? "s" : ""] at a time.</span>"

	// Items that have no valid possible_transfer_amounts shouldn't say their transfer rate is variable
	if(possible_transfer_amounts)
		. += "<span class='notice'><b>Alt-Click</b> to change the transfer amount.</span>"
