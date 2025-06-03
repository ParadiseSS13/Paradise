
/obj/machinery/economy/arcade
	name = "Arcade Game"
	desc = "One of the most generic arcade games ever."
	icon = 'icons/obj/arcade.dmi'
	icon_state = "clawmachine_1_on"
	idle_power_consumption = 40

	var/tokens = 0
	var/freeplay = FALSE			//for debugging and admin kindness
	var/token_price = 0
	var/window_name = "arcade"		//in case you want to change the window name for certain machines

/obj/machinery/economy/arcade/Initialize(mapload)
	. = ..()
	if(type == /obj/machinery/economy/arcade)		//if you spawn the base-type, it will replace itself with a random subtype for randomness
		var/choice = pick(subtypesof(/obj/machinery/economy/arcade))
		new choice(loc)
		return INITIALIZE_HINT_QDEL

/obj/machinery/economy/arcade/examine(mob/user)
	. = ..()
	if(freeplay)
		. += "Someone enabled freeplay on this machine!"
	else
		if(token_price)
			. += "[src] costs [token_price] credits per play."
		if(!tokens)
			. += "[src] has no available play credits. Better feed the machine!"
		else if(tokens == 1)
			. += "[src] has only 1 play credit left!"
		else
			. += "[src] has [tokens] play credits!"

/obj/machinery/economy/arcade/attack_hand(mob/user)
	if(..())
		if(in_use && src == user.machine)	//this one checks if they fell down/died and closes the game
			close_game()
		return
	if(in_use && src == user.machine)		//this one just checks if they are playing so it doesn't eat tokens
		return
	interact(user)

/obj/machinery/economy/arcade/interact(mob/user)
	if(stat & BROKEN || panel_open)
		return
	if(!tokens && !freeplay)
		to_chat(user, "\The [src] doesn't have enough credits to play! Pay first!")
		return
	if(!in_use && (tokens || freeplay))
		in_use = 1
		start_play(user)
		return
	if(in_use)
		if(src != user.machine)
			to_chat(user, "Someone else is already playing this machine, please wait your turn!")
		return

/obj/machinery/economy/arcade/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!freeplay)
		if(isspacecash(used))
			insert_cash(used, user, token_price)
			if(pay_with_cash(token_price, "Arcade Token Purchase", "DonkBook Gaming", user, account_database.vendor_account))
				tokens += 1
			return ITEM_INTERACT_COMPLETE

		if(istype(used, /obj/item/card/id))
			if(pay_with_card(used, token_price, "Arcade Token Purchase", "DonkBook Gaming", user, account_database.vendor_account))
				tokens += 1
			return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/economy/arcade/screwdriver_act(mob/living/user, obj/item/I)
	if(!anchored)
		return FALSE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	update_icon()
	return TRUE

/obj/machinery/economy/arcade/crowbar_act(mob/living/user, obj/item/I)
	if(!component_parts || !panel_open)
		return FALSE
	default_deconstruction_crowbar(user, I)
	return TRUE

/obj/machinery/economy/arcade/proc/start_play(mob/user as mob)
	user.set_machine(src)
	if(!freeplay)
		tokens -= 1

/obj/machinery/economy/arcade/proc/close_game()
	in_use = FALSE
	for(var/mob/user in viewers(world.view, src))			// I don't know who you are.
		if(user.client && user.machine == src)				// I will look for you,
			user.unset_machine()							// I will find you,
			user << browse(null, "window=[window_name]")	// And I will kill you.
	return

/obj/machinery/economy/arcade/proc/win()
	return

/obj/machinery/economy/arcade/process()
	if(in_use)
		updateUsrDialog()
		if(!in_use)
			close_game()

/obj/machinery/economy/arcade/Destroy()
	close_game()
	return ..()
