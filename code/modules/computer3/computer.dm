/obj/machinery/computer3
	name = "computer"
	icon = 'icons/obj/computer3.dmi'
	icon_state = "frame"
	density = 1
	anchored = 1.0

	idle_power_usage	= 20
	active_power_usage	= 50

	var/allow_disassemble	= 1
	var/legacy_icon			= 0 // if 1, use old style icons
	var/show_keyboard		= 1

	// These is all you should need to change when creating a new computer.
	// If there is no default program, the OS will run instead.
	// If there is no hard drive, but there is a default program, the OS rom on
	// the circuitboard will be overridden.

	// For these, typepaths are used, NOT objects

	var/default_prog		= null											// the program running when spawned
	var/list/spawn_files	= list()										// files added when spawned
	var/list/spawn_parts	= list(/obj/item/part/computer/storage/hdd/big)	// peripherals to spawn

	// Computer3 components - put an object in them in New() when not built
	// I used to have a more pliable /list, but the ambiguities
	// there in how many of what you had was killing me, especially
	// when you had to search the list to find what you had.

	// Mostly decorative, holds the OS rom
	var/obj/item/part/computer/circuitboard/circuit

	// Storage
	var/obj/item/part/computer/storage/hdd/hdd				= null
	var/obj/item/part/computer/storage/removable/floppy		= null
	// Networking
	var/obj/item/part/computer/networking/radio/radio		= null	// not handled the same as other networks
	var/obj/item/part/computer/networking/cameras/camnet	= null	// just plain special
	var/obj/item/part/computer/networking/net				= null	// Proximity, area, or cable network

	// Card reader - note the HoP reader is a subtype
	var/obj/item/part/computer/cardslot/cardslot			= null

	// Misc & special purpose
	var/obj/item/part/computer/ai_holder/cradle				= null
	var/obj/item/part/computer/toybox/toybox				= null
	var/mob/living/silicon/ai/occupant						= null


	// Legacy variables
	// camera networking - overview (???)
	var/mapping = 0
	var/last_pic = 1.0

	// Purely graphical effect
	var/icon/kb							= null

	// These are necessary in order to consolidate all computer types into one
	var/datum/wires/wires				= null
	var/powernet						= null

	// Used internally
	var/datum/file/program/program		= null	// the active program (null if defaulting to os)
	var/datum/file/program/os			= null	// the base code of the machine (os or hardcoded program)

	// If you want the computer to have a UPS, add a battery during construction.  This is useful for things like
	// the comms computer, solar trackers, etc, that should function when all else is off.
	// Laptops will require batteries and have no mains power.

	var/obj/item/weapon/stock_parts/cell/battery	= null // uninterruptible power supply aka battery


	verb/ResetComputer()
		set name = "Reset Computer"
		set category = "Object"
		set src in view(1)

		if(usr.stat || usr.restrained() || usr.lying || !istype(usr, /mob/living))
			to_chat(usr, "\red You can't do that.")
			return

		if(!Adjacent(usr))
			to_chat(usr, "You can't reach it.")
			return

		Reset()

	New(var/L, var/built = 0)
		..()
		spawn(2)
			power_change()

		if(show_keyboard)
			var/kb_state = "kb[rand(1,15)]"
			kb = image('icons/obj/computer3.dmi',icon_state=kb_state)
			overlays += kb

		if(!built)
			if(!circuit || !istype(circuit))
				circuit = new(src)
			if(circuit.OS)
				os = circuit.OS
				circuit.OS.computer = src
			else
				os = null

			// separated into its own function because blech
			spawn_parts()

			if(default_prog) // Add the default software if applicable
				var/datum/file/program/P = new default_prog
				if(hdd)
					hdd.addfile(P,1)
					program = P
					if(!os)
						os = P
				else if(floppy)
					floppy.inserted = new(floppy)
					floppy.files = floppy.inserted.files
					floppy.addfile(P)
					program = P
				else
					circuit.OS = P
					circuit.OS.computer = src
					os = circuit.OS
					circuit.name = "Circuitboard ([P])"


			if(hdd)		// Spawn files
				for(var/typekey in spawn_files)
					hdd.addfile(new typekey,1)

		if(program)
			program.execute(os)
		update_icon()


	proc/update_spawn_files()
		for(var/typekey in spawn_files)
			hdd.addfile(new typekey,1)

	proc/spawn_parts()
		for(var/typekey in spawn_parts)

			if(ispath(typekey,/obj/item/part/computer/storage/removable))
				if(floppy) continue
				floppy = new typekey(src)
				floppy.init(src)
				continue
			if(ispath(typekey,/obj/item/part/computer/storage/hdd))
				if(hdd) continue
				hdd = new typekey(src)
				hdd.init(src)
				continue

			if(ispath(typekey,/obj/item/part/computer/networking/cameras))
				if(camnet) continue
				camnet = new typekey(src)
				camnet.init(src)
				continue
			if(ispath(typekey,/obj/item/part/computer/networking/radio))
				if(radio) continue
				radio = new typekey(src)
				radio.init(src)
				continue
			if(ispath(typekey,/obj/item/part/computer/networking))
				if(net) continue
				net = new typekey(src)
				net.init(src)
				continue

			if(ispath(typekey,/obj/item/part/computer/cardslot))
				if(cardslot) continue
				cardslot = new typekey(src)
				cardslot.init(src)
				continue
			if(ispath(typekey,/obj/item/part/computer/ai_holder))
				if(cradle) continue
				cradle = new typekey(src)
				cradle.init(src)
			if(ispath(typekey,/obj/item/part/computer/toybox))
				if(toybox) continue
				toybox = new typekey(src)
				toybox.init(src)
				continue

			if(ispath(typekey,/obj/item/weapon/stock_parts/cell))
				if(battery) continue
				battery = new typekey(src)
				continue

	proc/Reset(var/error = 0)
		for(var/mob/living/M in range(1))
			M << browse(null,"window=\ref[src]")
		if(program)
			program.Reset()
			program		= null
		req_access	= os.req_access
		update_icon()

		// todo does this do enough

	emp_act(severity)
		if(prob(20/severity)) set_broken()
		..()


	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if(prob(25))
					qdel(src)
					return
				if(prob(50))
					for(var/x in verbs)
						verbs -= x
					set_broken()
			if(3.0)
				if(prob(25))
					for(var/x in verbs)
						verbs -= x
					set_broken()
			else
		return


	blob_act()
		if(prob(75))
			set_broken()
			density = 0

	/*
		Computers have the capability to use a battery backup.
		Note that auto_use_power's return value is strictly whether
		or not it is successfully powered.

		This allows laptops, and also allows you to create computers that
		remain active when:

		* the APC is destroy'd, emag'd, malf'd, emp'd, ninja'd etc
		* the computer was built in an unpowered zone
		* the station power is out, cables are cut, etc

		By default, most computers will NOT spawn with a battery backup, and
		SHOULD not.  Players can take apart a computer to insert the battery
		if they want to ensure, for example, the AI upload remains when the
		power is cut off.

		Make sure to use use_power() a bunch in peripherals code
	*/
	auto_use_power()
		if(!powered(power_channel))
			if(battery && battery.charge > 0)
				if(use_power == 1)
					battery.use(idle_power_usage)
				else
					battery.use(active_power_usage)
				return 1
			return 0
		if(src.use_power == 1)
			use_power(idle_power_usage,power_channel)
		else if(src.use_power >= 2)
			use_power(active_power_usage,power_channel)
		return 1

	use_power(var/amount, var/chan = -1)
		if(chan == -1)
			chan = power_channel

		var/area/A = get_area(loc)
		if(istype(A) && A.powered(chan))
			A.use_power(amount, chan)
		else if(battery && battery.charge > 0)
			battery.use(amount)

	power_change()
		if( !powered(power_channel) && (!battery || battery.charge <= 0) )
			stat |= NOPOWER
		else
			stat &= ~NOPOWER

	process()
		auto_use_power()
		power_change()
		update_icon()
		if(stat & (NOPOWER|BROKEN))
			return

		if(program)
			program.process()
			return

		if(os)
			program = os
			os.process()
			return


	proc/set_broken()
		icon_state = "computer_b"
		stat |= BROKEN
		crit_fail = 1
		if(program)
			program.error = BUSTED_ASS_COMPUTER
		if(os)
			os.error = BUSTED_ASS_COMPUTER

	attackby(I as obj, mob/user as mob, params)
		if(istype(I, /obj/item/weapon/screwdriver) && allow_disassemble)
			disassemble(user)
			return

		/*
			+++++++++++
			|IMPORTANT| If you add a peripheral, put it in this list
			+++++++++++ --------------------------------------------
		*/
		var/list/peripherals = list(hdd,floppy,radio,net,cardslot,cradle) //camnet, toybox removed

		var/list/p_list = list()
		for(var/obj/item/part/computer/C in peripherals)
			if(!isnull(C) && C.allow_attackby(I,user))
				p_list += C
		if(p_list.len)
			var/obj/item/part/computer/P = null
			if(p_list.len == 1)
				P = p_list[1]
			else
				P = input(user,"Which component?") as null|anything in p_list

			if(P)
				P.attackby(I,user, params)
				return
		..()

	attack_hand(var/mob/user as mob)
		if(stat)
			Reset()
			return

		// I don't want to deal with computers that you can't walk up to and use
		// there is still cardauth anyway
		//if(!allowed(user))
		//	return

		if(program)
			if(program.computer != src) // floppy disk may have been removed, etc
				Reset()
				attack_hand(user)
				return
			if(program.error)
				Crash(program.error)
				return
			user.set_machine(src)
			program.attack_hand(user) // will normally translate to program/interact()
			return

		if(os)
			program = os
			user.set_machine(src)
			os.attack_hand(user)
			return

		to_chat(user, "\The [src] won't boot!")

	attack_ai(var/mob/user as mob) // copypasta because server racks lose attack_hand()
		if(stat)
			Reset()
			return

		if(program)
			if(program.computer != src) // floppy disk may have been removed, etc
				Reset()
				attack_ai(user)
				return
			if(program.error)
				Crash(program.error)
				return
			user.set_machine(src)
			program.attack_hand(user) // will normally translate to program/interact()
			return

		if(os)
			program = os
			user.set_machine(src)
			os.attack_hand(user)
			return

		to_chat(user, "\The [src] won't boot!")

	interact()
		if(stat)
			Reset()
			return
		if(!allowed(usr) || !usr in view(1))
			usr.unset_machine()
			return

		if(program)
			program.interact()
			return

		if(os)
			program = os
			os.interact()
			return

	update_icon()
		if(legacy_icon)
			icon_state = initial(icon_state)
			// Broken
			if(stat & BROKEN)
				icon_state += "b"

			// Powered
			else if(stat & NOPOWER)
				icon_state = initial(icon_state)
				icon_state += "0"
			return
		if(stat)
			overlays.Cut()
			return
		if(program)
			overlays = list(program.overlay)
			if(show_keyboard)
				overlays += kb
			name = "[program.name] [initial(name)]"
		else if(os)
			overlays = list(os.overlay)
			if(show_keyboard)
				overlays += kb
			name = initial(name)
		else
			var/global/image/generic = image('icons/obj/computer3.dmi',icon_state="osod") // orange screen of death
			overlays = list(generic)
			if(show_keyboard)
				overlays += kb
			name = initial(name) + " (orange screen of death)"

	//Returns percentage of battery charge remaining. Returns -1 if no battery is installed.
	proc/check_battery_status()
		if(battery)
			var/obj/item/weapon/stock_parts/cell/B = battery
			return round(B.charge / (B.maxcharge / 100))
		else
			return -1



/obj/machinery/computer3/wall_comp
	name			= "terminal"
	icon			= 'icons/obj/computer3.dmi'
	icon_state		= "wallframe"
	density			= 0
	pixel_y			= -3
	show_keyboard	= 0
