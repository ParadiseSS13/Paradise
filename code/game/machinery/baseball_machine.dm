/obj/machinery/baseball_machine
	name = "baseball pitching machine"
	desc = "Hey batter batter!"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE				//this turret uses and requires power
	idle_power_usage = 50		//when inactive, this turret takes up constant 50 Equipment power
	active_power_usage = 300	//when active, this turret takes up constant 300 Equipment power
	power_channel = EQUIP	//drains power from the EQUIPMENT channel
	var/baseball_count = 15 // starts with 15 baseballs so we don't just spawn INFINITE amounts of baseballs
	var/active = FALSE

/obj/machinery/baseball_machine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(default_unfasten_wrench(user, I))
		return

	if(istype(I, /obj/item/beach_ball/holoball/baseball))
		if(!user.drop_item())
			return
		visible_message("<span class='notice'>[src] loads the baseball machine with a baseball.</span>")
		qdel(I)
		baseball_count++

/obj/machinery/baseball_machine/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(user.incapacitated())
		return
	visible_message("<span class='notice'>[user] [active ? "turns off" : "turns on"] the baseball machine </span>")
	active = !active
	update_icon()

/obj/machinery/baseball_machine/process()
	if(!active)
		return
	shoot_baseball()

/obj/machinery/baseball_machine/proc/shoot_baseball()
	if(!baseball_count)
		atom_say("Out of baseballs. Please insert more baseballs to continue.")
		active = FALSE
		update_icon()
		return FALSE // returns false if ball was not fired
	var/obj/item/beach_ball/holoball/bball = new /obj/item/beach_ball/holoball/baseball(get_turf(src))
	bball.throw_at(get_edge_target_turf(src, dir), 20, 1)
	baseball_count--
	return TRUE

/obj/machinery/baseball_machine/update_icon()
	if(active)
		icon_state = "target_prism"
	else
		icon_state = "turretCover"

/obj/machinery/baseball_machine/AltClick(mob/user)
	rotate(user)

/obj/machinery/baseball_machine/verb/rotate(mob/user)
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if(user.incapacitated())
		return
	if(!Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do that!</span>")
		return
	dir = turn(dir, 90)
	to_chat(user, "<span class='notice'>You rotate [src].</span>")