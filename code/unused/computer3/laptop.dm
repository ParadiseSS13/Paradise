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
	pixel_x		= 2
	pixel_y		= -3
	w_class		= 4

	var/obj/machinery/computer3/laptop/stored_computer = null

	verb/open_computer()
		set name = "open laptop"
		set category = "Object"
		set src in view(1)

		if(!istype(loc,/turf))
			usr << "[src] is too bulky!  You'll have to set it down."
			return

		if(!stored_computer)
			if(contents.len)
				for(var/obj/O in contents)
					O.loc = loc
			usr << "\The [src] crumbles to pieces."
			spawn(5)
				del src
			return


		stored_computer.loc = loc
		stored_computer.stat &= ~MAINT
		stored_computer.update_icon()
		loc = null
		usr << "You open \the [src]."

		spawn(5)
			del src

	AltClick()
		open_computer()

/obj/machinery/computer3/laptop
	name = "Laptop Computer"
	desc = "A clamshell portable computer.  It is open."

	icon_state		= "laptop"
	density			= 0
	pixel_x			= 2
	pixel_y			= -3
	show_keyboard	= 0

	var/obj/item/device/laptop/portable = null

	New(var/L, var/built = 0)
		if(!built && !battery)
			battery = new /obj/item/weapon/cell(src)
		..(L,built)

	verb/close_computer()
		set name = "close laptop"
		set category = "Object"
		set src in view(1)

		if(istype(loc,/obj/item/device/laptop))
			testing("Close closed computer")
			return
		if(!istype(loc,/turf))
			testing("Odd computer location: [loc] - close laptop")
			return

		if(stat&BROKEN)
			usr << "\The [src] is broken!  You can't quite get it closed."
			return

		if(!portable)
			portable=new
			portable.stored_computer = src

		portable.loc = loc
		loc = portable
		stat |= MAINT
		usr << "You close \the [src]."

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
					del O
		..()


	AltClick()
		close_computer()

