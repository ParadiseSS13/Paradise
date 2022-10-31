/obj/item/pizza_bomb
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzabox1"
	/// An adjustable timer set by the armer
	var/timer = 1 SECONDS
	/// The box will explode next opening
	var/timer_set = FALSE
	/// Is the box open
	var/open = FALSE
	/// Bomb is counting down
	var/primed = FALSE
	/// Has the bomb been disarmed
	var/disarmed = FALSE

	/// Wires inside the pizza bomb
	var/wires = list("orange", "green", "blue", "yellow", "aqua", "purple")
	/// The wire that disarms the bomb
	var/correct_wire

	/// Used for admin tracking the activator of the bomb
	var/armer
	/// Used for tracking who opened the primed Pizza bomb
	var/opener

/obj/item/pizza_bomb/Initialize(mapload)
	. = ..()
	correct_wire = pick(wires)

/obj/item/pizza_bomb/Destroy()
	armer = null
	opener = null
	. = ..()

/obj/item/pizza_bomb/attack_self(mob/user)
	if(disarmed)
		to_chat(user, "<span class='notice'>\The [src] is disarmed.</span>")
		return

	if(!timer_set)
		open = TRUE
		timer_set = TRUE
		update_appearance()

		timer = (input(user, "Set a timer, from one second to ten seconds.", "Timer", "[timer]") as num) SECONDS
		if(!in_range(src, user) || issilicon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || user.restrained())
			open = FALSE
			timer_set = FALSE
			update_appearance()
			return

		armer = user
		open = FALSE
		update_appearance()

		timer = clamp(timer, 1 SECONDS, 10 SECONDS)
		to_chat(user, "<span class='notice'>You set the timer to [timer / 10] before activating the payload and closing \the [src].")

		message_admins("[key_name_admin(armer)] has set a timer on a pizza bomb to [timer / 10] seconds at [ADMIN_JMP(loc)]")
		log_game("[key_name(armer)] has set the timer on a pizza bomb to [timer / 10] seconds ([loc.x],[loc.y],[loc.z]).")
		return

	if(!primed)
		opener = user
		primed = TRUE
		open = TRUE

		update_appearance()

		audible_message("<span class='warning'>[bicon(src)] *beep* *beep*</span>")
		to_chat(user, "<span class='danger'>That's no pizza! That's a bomb!</span>")

		message_admins("[key_name_admin(opener)] has triggered a pizza bomb armed by [key_name_admin(armer)] at [ADMIN_JMP(loc)].")
		log_game("[key_name(opener)] has triggered a pizza bomb armed by [key_name(armer)] ([loc.x],[loc.y],[loc.z]).")

		addtimer(CALLBACK(src, .proc/go_boom), timer)

/obj/item/pizza_bomb/proc/go_boom()
	if(disarmed)
		visible_message("<span class='danger'>[bicon(src)] Sparks briefly jump out of the [correct_wire] wire on [src], but it's disarmed!</span>")
		return
	atom_say("Enjoy the pizza!")
	visible_message("<span class='userdanger'>[src] violently explodes!</span>")

	message_admins("A pizza bomb set by [key_name_admin(armer)] and opened by [key_name_admin(opener)] has detonated at [ADMIN_JMP(loc)].")
	log_game("Pizza bomb set by [key_name(armer)] and opened by [key_name(opener)]) detonated at ([loc.x],[loc.y],[loc.z]).")

	explosion(loc, 1, 2, 4, flame_range = 2) //Identical to a minibomb
	qdel(src)

/obj/item/pizza_bomb/wirecutter_act(mob/living/user, obj/item/I)
	if(!primed && !disarmed)
		return
	. = TRUE

	if(primed)
		to_chat(user, "<span class='danger'>Oh God, what wire do you cut?!</span>")
		var/chosen_wire = input(user, "OH GOD OH GOD", "WHAT WIRE?!") in wires
		if(!in_range(src, usr) || issilicon(usr) || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.restrained())
			return
		I.play_tool_sound(user, I.tool_volume)
		user.visible_message("<span class='warning'>[user] cuts the [chosen_wire] wire!</span>", "<span class='danger'>You cut the [chosen_wire] wire!</span>")
		if(chosen_wire == correct_wire) // They disarmed it, even if they're off by 0.5 seconds, let them live
			disarmed = TRUE
			primed = FALSE
		addtimer(CALLBACK(src, .proc/cut_wire, user), 0.5 SECONDS)

	else if(disarmed)
		if(!in_range(user, src))
			to_chat(user, "<span class='warning'>You can't see the box well enough to cut the wires out.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts removing the payload and wires from \the [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
		if(do_after(user, 40 * I.toolspeed, target = src))
			user.unEquip(src)
			user.visible_message("<span class='notice'>[user] removes the insides of \the [src]!</span>")
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(loc)
			C.amount = 3
			new /obj/item/bombcore/miniature(loc)
			new /obj/item/pizzabox(loc)
			qdel(src)

/obj/item/pizza_bomb/update_name(updates)
	. = ..()
	if(open)
		name = "pizza bomb"
	else
		name = initial(name)

/obj/item/pizza_bomb/update_desc(updates)
	. = ..()
	if(primed)
		desc = "OH GOD THAT'S NOT A PIZZA"
		return

	var/working_desc
	if(open)
		working_desc += "A devious contraption, made of a small explosive payload hooked up to pressure-sensitive wires."
	if(disarmed)
		working_desc += "It's disarmed."
	else if(!timer_set)
		working_desc += "It seems inactive."
	else
		desc = initial(desc)
		return
	desc = working_desc

/obj/item/pizza_bomb/update_icon_state()
	. = ..()
	if(disarmed)
		icon_state = "pizzabox_bomb_[correct_wire]"
	else if(primed)
		icon_state = "pizzabox_bomb_active"
	else if(open)
		icon_state = "pizzabox_bomb"
	else
		icon_state = initial(icon_state)

/obj/item/pizza_bomb/proc/cut_wire(mob/user)
	update_appearance()
	if(primed)
		to_chat(user, "<span class='userdanger'>WRONG WIRE!</span>")
		go_boom()
		return
	audible_message("<span class='warning'>[bicon(src)] \The [src] suddenly stops beeping and seems lifeless.</span>")
	to_chat(user, "<span class='notice'>You disarmed the [src]!</span>")

/obj/item/pizza_bomb/autoarm
	timer_set = TRUE
	timer = 3 SECONDS
	armer = "Auto-armed pizzabomb"
