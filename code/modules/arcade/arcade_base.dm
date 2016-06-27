
/obj/machinery/arcade
	name = "Arcade Game"
	desc = "One of the most generic arcade games ever."
	icon = 'icons/obj/arcade.dmi'
	icon_state = "clawmachine_on"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 40
	var/tokens = 0
	var/freeplay = 0				//for debugging and admin kindness
	var/token_price = 0
	var/last_winner = null			//for letting people who to hunt down and steal prizes from
	var/window_name = "arcade"		//in case you want to change the window name for certain machines

/obj/machinery/arcade/New()
	..()
	var/choice = pick(subtypesof(/obj/machinery/arcade))
	new choice(loc)
	qdel(src)

/obj/machinery/arcade/examine(mob/user)
	..(user)
	if(freeplay)
		to_chat(user, "Someone enabled freeplay on this machine!")
	else
		if(token_price)
			to_chat(user, "\The [src.name] costs [token_price] credits per play.")
		if(!tokens)
			to_chat(user, "\The [src.name] has no available play credits. Better feed the machine!")
		else if(tokens == 1)
			to_chat(user, "\The [src.name] has only 1 play credit left!")
		else
			to_chat(user, "\The [src.name] has [tokens] play credits!")

/obj/machinery/arcade/attack_hand(mob/user as mob)
	if(..())
		if(in_use && src == user.machine)	//this one checks if they fell down/died and closes the game
			src.close_game()
		return
	if(in_use && src == user.machine)		//this one just checks if they are playing so it doesn't eat tokens
		return
	interact(user)

/obj/machinery/arcade/interact(mob/user as mob)
	if(stat & BROKEN || panel_open)
		return
	if(!tokens && !freeplay)
		to_chat(user, "\The [src.name] doesn't have enough credits to play! Pay first!")
		return
	if(!in_use && (tokens || freeplay))
		in_use = 1
		start_play(user)
		return
	if(in_use)
		if(src != user.machine)
			to_chat(user, "Someone else is already playing this machine, please wait your turn!")
		return

/obj/machinery/arcade/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/weapon/screwdriver) && anchored)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		panel_open = !panel_open
		to_chat(user, "You [panel_open ? "open" : "close"] the maintenance panel.")
		update_icon()
		return
	if(!freeplay)
		if(istype(O, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/C = O
			if(pay_with_card(C))
				tokens += 1
			return
		else if(istype(O, /obj/item/weapon/spacecash))
			var/obj/item/weapon/spacecash/C = O
			if(pay_with_cash(C, user))
				tokens += 1
			return
	if(panel_open&& component_parts && istype(O, /obj/item/weapon/crowbar))
		default_deconstruction_crowbar(O)

/obj/machinery/arcade/update_icon()
	return

/obj/machinery/arcade/proc/pay_with_cash(var/obj/item/weapon/spacecash/cashmoney, var/mob/user)
	if(cashmoney.get_total() < token_price)
		to_chat(user, "[bicon(cashmoney)] <span class='warning'>That is not enough money.</span>")
		return 0
	visible_message("<span class='info'>[usr] inserts a credit chip into [src].</span>")
	var/left = cashmoney.get_total() - token_price
	user.unEquip(cashmoney)
	qdel(cashmoney)
	if(left)
		dispense_cash(left, src.loc, user)
	return 1

/obj/machinery/arcade/proc/pay_with_card(var/obj/item/weapon/card/id/I, var/mob/user)
	visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
	var/datum/money_account/customer_account = attempt_account_access_nosec(I.associated_account_number)
	if (!customer_account)
		to_chat(user, "Error: Unable to access account. Please contact technical support if problem persists.")
		return 0

	if(customer_account.suspended)
		to_chat(user, "Unable to access account: account suspended.")
		return 0

	// Have the customer punch in the PIN before checking if there's enough money. Prevents people from figuring out acct is
	// empty at high security levels
	if(customer_account.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
		var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
		customer_account = attempt_account_access(I.associated_account_number, attempt_pin, 2)

		if(!customer_account)
			to_chat(user, "Unable to access account: incorrect credentials.")
			return 0

	if(token_price > customer_account.money)
		to_chat(user, "Insufficient funds in account.")
		return 0
	else
		// Okay to move the money at this point

		// debit money from the purchaser's account
		customer_account.money -= token_price

		// create entry in the purchaser's account log
		var/datum/transaction/T = new()
		T.target_name = "[src.name]"
		T.purpose = "Purchase of [src.name] credit"
		if(token_price > 0)
			T.amount = "([token_price])"
		else
			T.amount = "[token_price]"
		T.source_terminal = src.name
		T.date = current_date_string
		T.time = worldtime2text()
		customer_account.transaction_log.Add(T)
		return 1

/obj/machinery/arcade/proc/start_play(mob/user as mob)
	user.set_machine(src)
	if(!freeplay)
		tokens -= 1

/obj/machinery/arcade/proc/close_game()
	in_use = 0
	for(var/mob/user in viewers(world.view, src))			// I don't know who you are.
		if(user.client && user.machine == src)				// I will look for you,
			user.unset_machine()							// I will find you,
			user << browse(null, "window=[window_name]")	// And I will kill you.
	return

/obj/machinery/arcade/proc/win()
	return

/obj/machinery/arcade/process()
	if(in_use)
		src.updateUsrDialog()
		if(!in_use)
			src.close_game()

/obj/machinery/arcade/Destroy()
	src.close_game()
	return ..()