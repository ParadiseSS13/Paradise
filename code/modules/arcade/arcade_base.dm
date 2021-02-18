
/obj/machinery/arcade
	name = "Arcade Game"
	desc = "One of the most generic arcade games ever."
	icon = 'icons/obj/arcade.dmi'
	icon_state = "clawmachine_on"
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	var/tokens = 0
	var/freeplay = TRUE				//for debugging and admin kindness
	var/token_price = 0
	var/last_winner = null			//for letting people who to hunt down and steal prizes from
	var/window_name = "arcade"		//in case you want to change the window name for certain machines

/obj/machinery/arcade/New()
	..()
	if(type == /obj/machinery/arcade)		//if you spawn the base-type, it will replace itself with a random subtype for randomness
		var/choice = pick(subtypesof(/obj/machinery/arcade))
		new choice(loc)
		qdel(src)

/obj/machinery/arcade/examine(mob/user)
	. = ..()
	if(freeplay)
		. += "Someone enabled freeplay on this machine!"
	else
		if(token_price)
			. += "\The [src.name] costs [token_price] credits per play."
		if(!tokens)
			. += "\The [src.name] has no available play credits. Better feed the machine!"
		else if(tokens == 1)
			. += "\The [src.name] has only 1 play credit left!"
		else
			. += "\The [src.name] has [tokens] play credits!"

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
	if(istype(O, /obj/item/screwdriver) && anchored)
		playsound(src.loc, O.usesound, 50, 1)
		panel_open = !panel_open
		to_chat(user, "You [panel_open ? "open" : "close"] the maintenance panel.")
		update_icon()
		return
	if(panel_open && component_parts && istype(O, /obj/item/crowbar))
		default_deconstruction_crowbar(user, O)
		return
	return ..()

/obj/machinery/arcade/update_icon()
	return

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
