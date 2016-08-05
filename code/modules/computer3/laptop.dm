/*
	Computer3 portable computer.

	Battery powered only; it does not use the APC network at all.

	When picked up, becomes an inert item.  This item can be put in a recharger,
	or set down and re-opened into the original machine.  While closed, the computer
	has the MAINT stat flag.  If you want to ignore this, you will have to bitmask it out.

	The unused(?) alt+click will toggle laptops open and closed.  If we find a better
	answer for this in the future, by all means use it.  I just don't want it limited
	to the verb, which is SIGNIFICANTLY less accessible than shutting a laptop.
	Ctrl-click would work for closing the machine, since it's anchored, but not for
	opening it back up again.  And obviously, I don't want to override shift-click.
	There's no double-click because that's used in regular click events.  Alt-click is the
	only obvious one left.
*/


/obj/item/device/laptop
	name		= "Laptop Computer"
	desc		= "A clamshell portable computer.  It is closed."
	icon		= 'icons/obj/computer3.dmi'
	icon_state	=  "laptop-closed"
	item_state	=  "laptop-inhand"
	pixel_x		= 2
	pixel_y		= -3
	w_class		= 3

	var/obj/machinery/computer3/laptop/stored_computer = null

	verb/open_computer()
		set name = "Open Laptop"
		set category = "Object"
		set src in view(1)

		if(usr.stat || usr.restrained() || usr.lying || !istype(usr, /mob/living))
			to_chat(usr, "\red You can't do that.")
			return

		if(!Adjacent(usr))
			to_chat(usr, "You can't reach it.")
			return

		if(!istype(loc,/turf))
			to_chat(usr, "[src] is too bulky!  You'll have to set it down.")
			return

		if(!stored_computer)
			if(contents.len)
				for(var/obj/O in contents)
					O.forceMove(loc)
			to_chat(usr, "\The [src] crumbles to pieces.")
			spawn(5)
				qdel(src)
			return

		if(!stored_computer.manipulating)
			stored_computer.manipulating = 1
			stored_computer.loc = loc
			stored_computer.stat &= ~MAINT
			stored_computer.update_icon()
			loc = null
			to_chat(usr, "You open \the [src].")

			spawn(5)
				stored_computer.manipulating = 0
				qdel(src)
		else
			to_chat(usr, "\red You are already opening the computer!")


	AltClick()
		if(Adjacent(usr))
			open_computer()

	Destroy()
		..()
		return QDEL_HINT_HARDDEL_NOW // Warning: GC'ing will cause the laptop to vanish when it next closes

//Quickfix until Snapshot works out how he wants to redo power. ~Z
/obj/item/device/laptop/verb/eject_id()
	set category = null
	set name = "Eject ID Card"
	set src in oview(1)

	if(stored_computer)
		stored_computer.eject_id()

/obj/machinery/computer3/laptop/verb/eject_id()
	set category = null
	set name = "Eject ID Card"
	set src in oview(1)

	var/obj/item/part/computer/cardslot/C = locate() in src.contents

	if(!C)
		to_chat(usr, "There is no card port on the laptop.")
		return

	var/obj/item/weapon/card/id/card
	if(C.reader)
		card = C.reader
		C.remove_reader(usr)
	else if(C.writer)
		card = C.writer
		C.remove_writer(usr)
	else
		to_chat(usr, "There is nothing to remove from the laptop card port.")
		return

	to_chat(usr, "You remove [card] from the laptop.")


/obj/machinery/computer3/laptop
	name = "Laptop Computer"
	desc = "A clamshell portable computer. It is open."

	icon_state		= "laptop"
	density			= 0
	pixel_x			= 2
	pixel_y			= -3
	show_keyboard	= 0

	var/manipulating = 0 // To prevent disappearing bug
	var/obj/item/device/laptop/portable = null

	New(var/L, var/built = 0)
		if(!built && !battery)
			battery = new /obj/item/weapon/stock_parts/cell(src)
		..(L,built)

	verb/close_computer()
		set name = "Close Laptop"
		set category = "Object"
		set src in view(1)

		if(usr.stat || usr.restrained() || usr.lying || !istype(usr, /mob/living))
			to_chat(usr, "\red You can't do that.")
			return

		if(!Adjacent(usr))
			to_chat(usr, "You can't reach it.")
			return

		if(istype(loc,/obj/item/device/laptop))
			testing("Close closed computer")
			return
		if(!istype(loc,/turf))
			testing("Odd computer location: [loc] - close laptop")
			return

		if(stat&BROKEN)
			to_chat(usr, "\The [src] is broken!  You can't quite get it closed.")
			return

		if(!portable)
			portable = new
			portable.stored_computer = src

		if(!manipulating)
			portable.forceMove(loc)
			forceMove(portable)
			stat |= MAINT
			to_chat(usr, "You close \the [src].")

	auto_use_power()
		if(stat&MAINT)
			return
		if(use_power && istype(battery) && battery.charge > 0)
			if(use_power == 1)
				battery.use(idle_power_usage)
			else
				battery.use(active_power_usage)
			return 1
		return 0

	use_power(var/amount, var/chan = -1)
		if(battery && battery.charge > 0)
			battery.use(amount)

	power_change()
		if( !battery || battery.charge <= 0 )
			stat |= NOPOWER
		else
			stat &= ~NOPOWER

	Destroy()
		if(istype(loc,/obj/item/device/laptop))
			var/obj/O = loc
			spawn(5)
				if(O)
					qdel(O)
		return ..()


	AltClick()
		if(Adjacent(usr))
			close_computer()
