/obj/item/device/pizza_bomb
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "pizzabox1"
	var/timer = 10 //Adjustable timer
	var/timer_set = 0
	var/primed = 0
	var/disarmed = 0
	var/wires = list("orange", "green", "blue", "yellow", "aqua", "purple")
	var/correct_wire
	var/armer //Used for admin purposes

/obj/item/device/pizza_bomb/attack_self(mob/user)
	if(disarmed)
		to_chat(user, "<span class='notice'>\The [src] is disarmed.</span>")
		return
	if(!timer_set)
		name = "pizza bomb"
		desc = "It seems inactive."
		icon_state = "pizzabox_bomb"
		timer_set = 1
		timer = (input(user, "Set a timer, from one second to ten seconds.", "Timer", "[timer]") as num) * 10
		if(!in_range(src, usr) || issilicon(usr) || !usr.canmove || usr.restrained())
			timer_set = 0
			name = "pizza box"
			desc = "A box suited for pizzas."
			icon_state = "pizzabox1"
			return
		timer = Clamp(timer, 10, 100)
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
		audible_message("<span class='warning'>[bicon(src)] *beep* *beep*</span>")
		to_chat(user, "<span class='danger'>That's no pizza! That's a bomb!</span>")
		message_admins("[key_name_admin(usr)] has triggered a pizza bomb armed by [armer] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>(JMP)</a>.")
		log_game("[key_name(usr)] has triggered a pizza bomb armed by [armer] ([loc.x],[loc.y],[loc.z]).")
		primed = 1
		sleep(timer)
		return go_boom()

/obj/item/device/pizza_bomb/proc/go_boom()
	if(disarmed)
		visible_message("<span class='danger'>[bicon(src)] Sparks briefly jump out of the [correct_wire] wire on \the [src], but it's disarmed!")
		return
	src.audible_message("[bicon(src)] <b>[src]</b> beeps, \"Enjoy the pizza!\"")
	src.visible_message("<span class='userdanger'>\The [src] violently explodes!</span>")
	explosion(src.loc,1,2,4,flame_range = 2) //Identical to a minibomb
	qdel(src)

/obj/item/device/pizza_bomb/attackby(var/obj/item/I, var/mob/user, params)
	if(istype(I, /obj/item/weapon/wirecutters) && primed)
		to_chat(user, "<span class='danger'>Oh God, what wire do you cut?!</span>")
		var/chosen_wire = input(user, "OH GOD OH GOD", "WHAT WIRE?!") in wires
		if(!in_range(src, usr) || issilicon(usr) || !usr.canmove || usr.restrained())
			return
		playsound(src, 'sound/items/Wirecutter.ogg', 50, 1, 1)
		user.visible_message("<span class='warning'>[user] cuts the [chosen_wire] wire!</span>", "<span class='danger'>You cut the [chosen_wire] wire!</span>")
		sleep(5)
		if(chosen_wire == correct_wire)
			src.audible_message("<span class='warning'>[bicon(src)] \The [src] suddenly stops beeping and seems lifeless.</span>")
			to_chat(user, "<span class='notice'>You did it!</span>")
			icon_state = "pizzabox_bomb_[correct_wire]"
			name = "pizza bomb"
			desc = "A devious contraption, made of a small explosive payload hooked up to pressure-sensitive wires. It's disarmed."
			disarmed = 1
			primed = 0
			return
		else
			to_chat(user, "<span class='userdanger'>WRONG WIRE!</span>")
			go_boom()
			return
	if(istype(I, /obj/item/weapon/wirecutters) && disarmed)
		if(!in_range(user, src))
			to_chat(user, "<span class='warning'>You can't see the box well enough to cut the wires out.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts removing the payload and wires from \the [src].</span>")
		if(do_after(user, 40, target = src))
			playsound(src, 'sound/items/Wirecutter.ogg', 50, 1, 1)
			user.unEquip(src)
			user.visible_message("<span class='notice'>[user] removes the insides of \the [src]!</span>")
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(src.loc)
			C.amount = 3
			new /obj/item/weapon/bombcore/miniature(src.loc)
			new /obj/item/pizzabox(src.loc)
			qdel(src)
		return
	..()

/obj/item/device/pizza_bomb/New()
	..()
	correct_wire = pick(wires)