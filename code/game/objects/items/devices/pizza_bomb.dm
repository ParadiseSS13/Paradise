/obj/item/pizza_bomb
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzabox1"
	var/timer = 10 //Adjustable timer
	var/timer_set = 0
	var/primed = 0
	var/disarmed = 0
	var/wires = list("orange", "green", "blue", "yellow", "aqua", "purple")
	var/correct_wire
	var/armer //Used for admin purposes

/obj/item/pizza_bomb/attack_self(mob/user)
	if(disarmed)
		to_chat(user, span_notice("\The [src] is disarmed."))
		return
	if(!timer_set)
		name = "pizza bomb"
		desc = "It seems inactive."
		icon_state = "pizzabox_bomb"
		timer_set = 1
		timer = (input(user, "Set a timer, from one second to ten seconds.", "Timer", "[timer]") as num) * 10
		if(!in_range(src, usr) || issilicon(usr) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || usr.restrained())
			timer_set = 0
			name = "pizza box"
			desc = "A box suited for pizzas."
			icon_state = "pizzabox1"
			return
		timer = clamp(timer, 10, 100)
		icon_state = "pizzabox1"
		to_chat(user, "<span class='notice'>You set the timer to [timer / 10] before activating the payload and closing \the [src].")
		message_admins("[key_name_admin(usr)] has set a timer on a pizza bomb to [timer/10] seconds at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>(JMP)</a>.")
		log_game("[key_name(usr)] has set the timer on a pizza bomb to [timer/10] seconds ([loc.x],[loc.y],[loc.z]).")
		armer = usr
		name = "pizza box"
		desc = "A box suited for pizzas."
		return
	if(!primed)
		name = "pizza bomb"
		desc = "OH GOD THAT'S NOT A PIZZA"
		icon_state = "pizzabox_bomb"
		audible_message(span_warning("[bicon(src)] *beep* *beep*"))
		to_chat(user, span_danger("That's no pizza! That's a bomb!"))
		message_admins("[key_name_admin(usr)] has triggered a pizza bomb armed by [armer] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>(JMP)</a>.")
		log_game("[key_name(usr)] has triggered a pizza bomb armed by [armer] ([loc.x],[loc.y],[loc.z]).")
		primed = 1
		sleep(timer)
		return go_boom()

/obj/item/pizza_bomb/proc/go_boom()
	if(disarmed)
		visible_message(span_danger("[bicon(src)] Sparks briefly jump out of the [correct_wire] wire on [src], but it's disarmed!"))
		return
	atom_say("Enjoy the pizza!")
	visible_message(span_userdanger("[src] violently explodes!"))
	explosion(src.loc,1,2,4,flame_range = 2) //Identical to a minibomb
	qdel(src)

/obj/item/pizza_bomb/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wirecutters) && primed)
		to_chat(user, span_danger("Oh God, what wire do you cut?!"))
		var/chosen_wire = input(user, "OH GOD OH GOD", "WHAT WIRE?!") in wires
		if(!in_range(src, usr) || issilicon(usr) || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.restrained())
			return
		playsound(src, I.usesound, 50, 1, 1)
		user.visible_message(span_warning("[user] cuts the [chosen_wire] wire!"), span_danger("You cut the [chosen_wire] wire!"))
		sleep(5)
		if(chosen_wire == correct_wire)
			src.audible_message(span_warning("[bicon(src)] \The [src] suddenly stops beeping and seems lifeless."))
			to_chat(user, span_notice("You did it!"))
			icon_state = "pizzabox_bomb_[correct_wire]"
			name = "pizza bomb"
			desc = "A devious contraption, made of a small explosive payload hooked up to pressure-sensitive wires. It's disarmed."
			disarmed = 1
			primed = 0
			return
		else
			to_chat(user, span_userdanger("WRONG WIRE!"))
			go_boom()
			return
	if(istype(I, /obj/item/wirecutters) && disarmed)
		if(!in_range(user, src))
			to_chat(user, span_warning("You can't see the box well enough to cut the wires out."))
			return
		user.visible_message(span_notice("[user] starts removing the payload and wires from \the [src]."))
		if(do_after(user, 40 * I.toolspeed, target = src))
			playsound(src, I.usesound, 50, 1, 1)
			user.unEquip(src)
			user.visible_message(span_notice("[user] removes the insides of \the [src]!"))
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(src.loc)
			C.amount = 3
			new /obj/item/bombcore/miniature(src.loc)
			new /obj/item/pizzabox(src.loc)
			qdel(src)
		return
	..()

/obj/item/pizza_bomb/New()
	..()
	correct_wire = pick(wires)

/obj/item/pizza_bomb/autoarm
	timer_set = 1
	timer = 30 // 3 seconds
