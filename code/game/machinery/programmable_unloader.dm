
// TODO: Check access
// TODO: Renameable circuit boards
// TODO: Disks?  Disassembly?

/obj/machinery/programmable
	name = "Programmable Unloader"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1.0

	var/debug = 0	// When set, this WILL spam people around the machine.
						// Identifies profile used and on which item.

	var/on = 1
	var/indir = 8
	var/outdir = 4
	var/turf/input = null
	var/turf/output = null
	var/typename = "Unloader"
	var/ident = "#1"

	var/const/workmax = 20
	var/datum/cargoprofile/default = new()
	var/list/profiles = list(new/datum/cargoprofile/cargo(),new/datum/cargoprofile/boxes(),new/datum/cargoprofile/supplies(),
							new/datum/cargoprofile/exotics(),new/datum/cargoprofile/tools(),new/datum/cargoprofile/weapons(),
							new/datum/cargoprofile/pressure(),new/datum/cargoprofile/chemical(),
							new/datum/cargoprofile/food(),new/datum/cargoprofile/clothing(),new/datum/cargoprofile/trash())
	var/list/overrides = list(new/datum/cargoprofile/cargo/unload(),new/datum/cargoprofile/in_stacker())
	var/list/emag_overrides = list(new/datum/cargoprofile/people(),new/datum/cargoprofile/unary/shredder(),new/datum/cargoprofile/unary/trainer())
	var/list/types = list()

	anchored = 1
	var/unwrenched = 0
	use_power = 1
	var/sleep = 0 // When set, the machine will skip the next however-many updates (to avoid spam)
	var/open = 0
	var/circuit_removed = 0



/obj/machinery/programmable/New()
	..()
	if(default)
		default.master = src
		if(!default.enabled)
			default.enabled = 1
	for(var/datum/cargoprofile/p in emag_overrides + overrides + profiles)
		p.master = src
	input = get_step(src.loc,indir)
	output = get_step(src.loc,outdir)
	var/count = 0
	for(var/obj/machinery/programmable/other in world)
		if(other.typename == typename)
			count++
	ident = "#[count]"
	name = "[typename] [ident]"

/obj/machinery/programmable/RefreshParts()
	//This is called when the machine was constructed.
	//Unfortunately, it puts machine parts in our contents list, which we're using.
	//Fortunately, we aren't likely to ever need the components list, circuitboard excepted.

	for(var/obj/O in contents)
		if(istype(O,/obj/item/weapon/circuitboard/programmable))//retrieve settings here

			var/obj/item/weapon/circuitboard/programmable/C = O

			default = C.default
			emagged = C.emagged
			profiles = C.profiles
			overrides = C.overrides
			emag_overrides = C.emag_overrides

			//unary and binary methods (one vs two locales) don't mix

			if(istype(src,/obj/machinery/programmable/unary))
				for(var/datum/cargoprofile/P in profiles)
					if(!istype(P,/datum/cargoprofile/unary) && !P.universal)
						profiles -= P
				for(var/datum/cargoprofile/P in overrides)
					if(!istype(P,/datum/cargoprofile/unary) && !P.universal)
						overrides -= P
				for(var/datum/cargoprofile/P in emag_overrides)
					if(!istype(P,/datum/cargoprofile/unary) && !P.universal)
						emag_overrides -= P
			else
				for(var/datum/cargoprofile/P in profiles)
					if(istype(P,/datum/cargoprofile/unary) && !P.universal)
						profiles -= P
				for(var/datum/cargoprofile/P in overrides)
					if(istype(P,/datum/cargoprofile/unary) && !P.universal)
						overrides -= P
				for(var/datum/cargoprofile/P in emag_overrides)
					if(istype(P,/datum/cargoprofile/unary) && !P.universal)
						emag_overrides -= P
			if(default)
				default.master = src
			for(var/datum/cargoprofile/p in emag_overrides + overrides + profiles)
				p.master = src

			qdel(C)
		else
			qdel(O)

/obj/machinery/programmable/attack_hand(mob/user as mob)
	if(stat) // moved, or something else
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/programmable/proc/printlist(var/list/L)
	var/dat
	for(var/datum/cargoprofile/p in L)
		dat += "[p.name]: <A href='?src=[UID()];operation=[p.id]'>[p.enabled?"<B>YES</B>":"NO"]</A><BR>"
	return dat

/obj/machinery/programmable/proc/buildMenu()
	var/dat
	dat += "<B>PROGRAMMABLE UNLOADER</B><BR><TT>"
	dat += "POWER: <A href='?src=[UID()];operation=start'>[on ? "ON" : "OFF"]</A><BR>"
	dat += "INLET: <A href='?src=[UID()];operation=inlet'>[capitalize(dir2text(indir))]</A> "
	dat += "OUTLET: <A href='?src=[UID()];operation=outlet'>[capitalize(dir2text(outdir))]</A>"
	dat += " (<A href='?src=[UID()];operation=swapdir'>SWAP</A>)</TT><HR>"
	if(default)
		dat += "MAIN PROGRAM: "
		dat += "<TT>[default.name]: <A href='?src=[UID()];operation=default'>[default.enabled ? "<B>YES</B>" : "NO"]</A><BR>"
	if(profiles.len)
		if(!default || !default.enabled)
			dat += printlist(profiles)
		dat += "</TT>"
	if(overrides.len)
		dat += "<HR>OVERRIDES:<BR><TT>"
		dat += printlist(overrides)
	dat += "</TT>"
	return dat

/obj/machinery/programmable/interact(mob/user as mob)
	var/dat = buildMenu()
	user << browse("<HEAD><TITLE>Unloader</TITLE></HEAD>[dat]", "window=progreload")
	onclose(user, "progreload")
	return

/obj/machinery/programmable/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	add_fingerprint(usr)
	switch(href_list["operation"])
		if("start")
			on = (on ? 0 : 1)
			if(on) use_power = 1
			else use_power = 0
			updateUsrDialog()
			return
		if("inlet")
			indir *= 2 // N S E W
			if(indir > 8)
				indir = 1 // W N
			if(indir == src.outdir)
				indir *= 2
				if(indir > 8)
					indir = 1
			input = get_step(src,indir) // todo: check for glasswalls / no path to target?
			updateUsrDialog()
			return
		if("outlet")
			outdir *= 2
			if(outdir > 8)
				outdir = 1
			if(outdir == indir)
				outdir *= 2
				if(outdir > 8)
					outdir = 1
			output = get_step(src,outdir) // todo: check for walls / glasswalls / invalid output locations
			updateUsrDialog()
			return
		if("swapdir")
			var/temp = outdir
			outdir = indir
			indir = temp
			input = get_step(src,indir)
			output = get_step(src,outdir)
			updateUsrDialog()
			return
		if("default")
			default.enabled = (default.enabled ? 0 : 1)
			updateUsrDialog()
			return
	var/which = href_list["operation"]
	for(var/datum/cargoprofile/p in overrides + profiles)
		if(which == p.id)
			p.enabled = (p.enabled? 0 : 1)
			updateUsrDialog()
			return

/obj/machinery/programmable/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I,/obj/item/weapon/wrench)) // code borrowed from pipe dispenser
		if(unwrenched==0)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			to_chat(user, "\blue You begin to unfasten \the [src] from the floor...")
			if(do_after(user, 40, target = src))
				user.visible_message( \
					"[user] unfastens \the [src].", \
					"\blue You have unfastened \the [src]. Now it can be pulled somewhere else.", \
					"You hear ratchet.")
				src.anchored = 0
				src.stat |= MAINT
				src.unwrenched = 1
				if(usr.machine==src)
					usr << browse(null, "window=pipedispenser")
		else /* unwrenched */
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			to_chat(user, "\blue You begin to fasten \the [src] to the floor...")
			if(do_after(user, 20, target = src))
				user.visible_message( \
					"[user] fastens \the [src].", \
					"\blue You fastened \the [src] into place.", \
					"You hear ratchet.")
				src.anchored = 1
				src.input = get_step(src.loc,src.indir)
				src.output = get_step(src.loc,src.outdir)
				if(!open && !circuit_removed)
					src.stat &= ~MAINT
				src.unwrenched = 0
				power_change()
	if(istype(I,/obj/item/weapon/screwdriver))
		if(open)
			open = 0
			if(!unwrenched && !circuit_removed)
				src.stat &= ~MAINT
			to_chat(user, "You close \the [src]'s maintenance panel.")
		else
			open = 1
			src.stat |= MAINT
			to_chat(user, "You open \the [src]'s maintenance panel.")
	if(istype(I,/obj/item/weapon/crowbar))
		if(open)
			to_chat(user, "\blue You begin to pry out the [src]'s circuits.")
			if(do_after(user,40, target = src))
				to_chat(user, "\blue You remove the circuitboard.")
				circuit_removed = 1
				use_power = 0
				on = 0

				var/obj/item/weapon/circuitboard/programmable/P = new(src.loc)
				P.emagged = src.emagged
				P.default = src.default
				src.default = null
				P.profiles = src.profiles
				src.profiles = null
				P.overrides = src.overrides
				src.overrides = null
				P.emag_overrides = src.emag_overrides
				src.emag_overrides = null
				return
		else
			..(I,user)

	if(istype(I,/obj/item/weapon/circuitboard/programmable))
		if(!open)
			to_chat(user, "You have to open the machine first!")
			return
		if(!circuit_removed)
			to_chat(user, "There is already a circuitboard present!")
			return
		circuit_removed = 0
		I.loc = src
		RefreshParts()

/obj/machinery/programmable/emag_act(user as mob)
	if(emagged)
		return
	to_chat(user, "You swipe the unloader with your card.  After a moment's grinding, it beeps in a sinister fashion.")
	playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
	emagged = 1
	overrides += emag_overrides

	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	return

/obj/machinery/programmable/process()
	if(!output || !input)
		return

	if(!on || stat || sleep)
		if(sleep > 0) // prevent input or output errors from happening every tick
			sleep--
		use_power = 0

		//Do not let things get stuck inside.  That's broken behavior.
		for(var/obj/O in contents)
			O.loc = loc
		for(var/mob/M in contents)
			M.loc = loc
			if(M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
				to_chat(M, "\blue The machine turns off, and you fall out.")

		return

	//Normal output reaction
	if(contents.len)
		for(var/atom/movable/A in contents)
			var/datum/cargoprofile/p = types[A.type]
			if(p)
				p.outlet_reaction(A,output)
			else
				A.loc = output // may have been dropped by a mob, etc

	if(types.len > 50)
		types = list() // good luck mr. garbage collector


	var/work = 0
	for(var/mob/M in input.contents)
		for(var/datum/cargoprofile/p in overrides + default)
			if(p.enabled && p.mobcheck && p.contains(M))
				var/done = p.inlet_reaction(M,input,workmax - work)
				if(done)
					work += done
					if(src.debug)
						visible_message("[p.name]:[M.name] ([done])")
				break

	if(sleep)
		return // something stopped the machine

	for(var/obj/A in input.contents)// I fully expect this to cause unreasonable lag
		if(!A)
			break
		if(work > workmax)
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0) // Beep if the machine is full - testing only probably
			break

		var/done = 0 // work done        - testing only
		var/aname    // target item name - testing only

		for(var/datum/cargoprofile/p in overrides)
			if(p.enabled && p.contains(A))
				aname = A.name // in case of deletion
				done = p.inlet_reaction(A,input,workmax - work)
				if(done)
					work += done
					if(src.debug)
						visible_message("[p.name]:[aname] ([done])")

				else
					break
		if(sleep)
			break // Something stopped the machine
		if(!A || A.loc != input || done)
			continue // next item

		if(default && default.enabled)
			if(default.contains(A))
				aname = A.name
				done = default.inlet_reaction(A,input,workmax - work)
				if(done)
					work += done
					if(src.debug)
						visible_message("[default.name]: [aname] ([done])")
				continue
		for(var/datum/cargoprofile/p in profiles)
			if(p.enabled && p.contains(A))
				aname = A.name
				done = p.inlet_reaction(A,input,workmax - work)
				if(done)
					work += done
					if(src.debug)
						visible_message("[p.name]:[aname] ([done])")
				else
					break
	if(work)
		use_power = 2
	else
		use_power = 1
//----------------------------------------------------------------------------
//      Specialty machines
//----------------------------------------------------------------------------

//Uses the inlet stacking profile.  Ejects only full stacks.
/obj/machinery/programmable/stacker
	name = "Stacking & Spooling Machine"
	default = new/datum/cargoprofile/in_stacker()
	profiles = list()
	overrides = list()
	emag_overrides = list()
	typename = "Stacking and Spooling Machine"


/obj/machinery/programmable/unloader
	name = "Cargo Unloader"
	default = new/datum/cargoprofile/cargo/unload()
	profiles = list()
	overrides = list()
	emag_overrides = list()
	typename = "Cargo Unloader"

/obj/machinery/programmable/delivery
	name = "Finished robot delivery"
	default = new/datum/cargoprofile/finished()
	profiles = list()
	overrides = list()
	emag_overrides = list()
	typename = "Robot Delivery"

/obj/machinery/programmable/crate_handler
	name = "Crate Handler"
	default = null
	profiles = list(new/datum/cargoprofile/cargo/unload(),new/datum/cargoprofile/cargo(),new/datum/cargoprofile/cargo/empty(),new/datum/cargoprofile/cargo/full())
	overrides = list()
	emag_overrides = list()
	typename = "Crate Handler"

//----------------------------------------------------------------------------
//      Unary machine: Input and output in the same location
//      Be careful with this, it could easily be running the same
//      computations every round needlessly
//----------------------------------------------------------------------------
/obj/machinery/programmable/unary
	name = "Programmable Processor"
	default = null
	profiles = list()
	overrides = list(new/datum/cargoprofile/unary/stacker(),new/datum/cargoprofile/unary/trainer())
	emag_overrides = list(new/datum/cargoprofile/unary/shredder())
	indir = 1
	outdir = 1
	typename = "Processor"

	New()
		..()
		outdir = indir
		output = input
	buildMenu()
		var/dat
		dat += "<B>PROGRAMMABLE PROCESSOR</B><BR><TT>"
		dat += "POWER: <A href='?src=[UID()];operation=start'>[on ? "ON" : "OFF"]</A><BR>"
		dat += "INLET: <A href='?src=[UID()];operation=inlet'>[capitalize(dir2text(indir))]</A><BR>"
		if(default)
			dat += "MAIN PROGRAM: "
			dat += "<TT>[default.name]: <A href='?src=[UID()];operation=default'>[default.enabled ? "<B>YES</B>" : "NO"]</A><BR>"
		if(profiles.len)
			if(!default || !default.enabled)
				dat += printlist(profiles)
			dat += "</TT>"
		if(overrides.len)
			dat += "<HR>OVERRIDES:<BR><TT>"
			dat	+= printlist(overrides)
		dat += "</TT>"
		return dat
	Topic(href, href_list)
		switch(href_list["operation"])
			if("inlet")
				indir *= 2 // N S E W
				if(indir > 8)
					indir = 1 // W N
				outdir = indir
				input = get_step(src,indir) // todo: check for glasswalls / no path to target?
				output = input
				updateUsrDialog()
				return
		return ..()

/obj/machinery/programmable/unary/stacker
	name = "Stacking Machine"
	default = new/datum/cargoprofile/unary/stacker()
	profiles = list()
	overrides = list()
	emag_overrides = list()
	typename = "Stacking Machine"

/obj/machinery/programmable/unary/shredder
	name = "Paper Shredder"
	default = new/datum/cargoprofile/unary/shredder()
	profiles = list()
	overrides = list()
	emag_overrides = list(new/datum/cargoprofile/unary/gibber())
	typename = "Paper Shredder"

/obj/machinery/programmable/unary/trainer
	name =  "\improper Boxing Trainer"
	default = new/datum/cargoprofile/unary/trainer()
	profiles = list()
	overrides = list()
	emag_overrides = list()
	typename = "Boxing Trainer"

	attack_hand(mob/user as mob) //How did I type this with boxing gloves on?
		if(!istype(user,/mob/living/carbon/human))
			return ..()

		var/mob/living/carbon/human/H = user
		if(H.gloves && istype(H.gloves, /obj/item/clothing/gloves/boxing))
			var/newsleep = 0
			if(H.loc != input)
				to_chat(H, "The boxing machine refuses to acknowledge you unless you face it head on!")
				return
			var/damage = 0
			if(H.a_intent != I_HARM)
				damage += rand(0,5)
			else
				damage += rand(0,10)
			if(!damage)
				playsound(H.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("[H] tries to punch \the [src], but whiffs")
				return

			playsound(loc, "punch", 25, 1, -1)
			if(HULK in H.mutations)			damage += 5

			if(damage < 5)
				visible_message("[H] gives \the [src] a weak punch.")
				if(prob(10))
					visible_message("\blue \The [src] feints at [H], as though mocking \him.")
			else if(damage < 10)
				visible_message("[H] hits \the [src] with a solid [pick("punch","jab","smack")].")
			else if(damage < 15)
				visible_message("[pick("Whoa!","Nice!","Gasp!")] [H] hits [src] with a powerful [pick("punch","jab","uppercut","left hook", "right hook")].")
			else if(damage < 20)
				visible_message("[pick("WHOA!","ACK!","Jeez!")]  [H] hits [src] so hard, the whole machine rocks band and forth for a moment.")
			else
				visible_message("Holy moly!  [H] hits \the [src] so hard it stops working.")
				stat |= BROKEN
				return
			while(damage >= 5)
				if(prob(50))
					newsleep++
				damage -= 5
			if(newsleep)
				if(emagged)
					visible_message("\red \The [src]'s lights glow a bloodthirsty red.  It refuses to stop!")
					sleep = 0
				else
					sleep += newsleep
					visible_message("\blue \The [src]'s lights dim for a moment and it beeps, signifying a valid hit.")
					playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
			return

		else
			return ..()

//----------------------------------------------------------------------------
//      For construction
//----------------------------------------------------------------------------
/obj/item/weapon/circuitboard/programmable
	name = "Circuit board (Programmable Unloader)"
	build_path = "/obj/machinery/programmable"
	board_type = "machine"
	origin_tech = "engineering=3;programming=6"
	frame_desc = "Requires 2 Manipulators, 1 Scanning Module, 1 Cable."
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1)

	//Customization of the machine
	var/datum/cargoprofile/default = new/datum/cargoprofile()
	var/list/profiles = list()
	var/list/overrides = list()
	var/list/emag_overrides = list()

	var/emagged = 0
	var/hacking = 0

	proc/resetlists()
		profiles = list(new/datum/cargoprofile/cargo(),new/datum/cargoprofile/boxes(),new/datum/cargoprofile/supplies(),
							new/datum/cargoprofile/exotics(),new/datum/cargoprofile/tools(),new/datum/cargoprofile/weapons(),new/datum/cargoprofile/finished(),
							new/datum/cargoprofile/pressure(),new/datum/cargoprofile/pressure/full(),new/datum/cargoprofile/pressure/empty(),
							new/datum/cargoprofile/chemical(),new/datum/cargoprofile/organics(),new/datum/cargoprofile/food(),
							new/datum/cargoprofile/clothing(),new/datum/cargoprofile/trash())
		overrides = list(new/datum/cargoprofile/cargo/unload(),new/datum/cargoprofile/in_stacker(),
							new/datum/cargoprofile/unary/stacker(),new/datum/cargoprofile/unary/trainer())
		emag_overrides = list(new/datum/cargoprofile/people(),new/datum/cargoprofile/unary/shredder())

	New()
		..()
		resetlists()

	attackby(obj/item/I as obj, mob/user as mob, params)
		if(istype(I,/obj/item/device/multitool))
			hacking = (hacking?0:1)
			if(hacking)
				to_chat(user, "You unlock the data port on the board.  You can now use a PDA to alter its data.")
			else
				to_chat(user, "You relock the data port.")
		if(istype(I,/obj/item/device/pda))
			if(!hacking)
				to_chat(user, "It looks like you can't access the board's data port.  You'll have to open it with a multitool.")
			else
				user.set_machine(src)
				interact(user)
		if(istype(I,/obj/item/weapon/card/emag) && !emagged)
			if(!hacking)
				to_chat(user, "There seems to be a data port on the card, but it's locked.  A multitool could open it.")
			else
				emagged = 1
				overrides += emag_overrides
				to_chat(user, "You swipe the card in the card's data port.  The lights flicker, then flash once.")

	proc/format(var/datum/cargoprofile/P,var/level)
		// PROFILE=0 OVERRIDE=1 MAIN=2
		if(P == null)
			return "NONE<BR>"
		var/dat = "[P.name]"
		if(level == 0 || (level == 1 && !default))
			dat += " <A href='?src=[UID()];operation=promote;id=[P.id];level=[level]'>PROMOTE</A>"
		if(level > 0)
			dat += " <A href='?src=[UID()];operation=demote;id=[P.id];level=[level]'>DEMOTE</A>"
		dat += " <A href='?src=[UID()];operation=delete;id=[P.id];level=[level]'>REMOVE</A>"
		dat += "<BR>"
		return dat

	interact(mob/user as mob)
		var/dat
		dat = "MAIN FUNCTION<BR><TT>"
		dat += format(default,2)
		dat += "</TT>- CAUTION -<BR>\[<A href='?src=[UID()];operation=deleteall'>DELETE NON-MAIN ALGORITHMS</A>\]<BR>"
		dat += "\[<A href='?src=[UID()];operation=reset'>MASTER RESET</A>\]<HR>"

		dat += "OVERRIDES:<BR><TT>"
		for(var/datum/cargoprofile/P in overrides)
			dat += format(P,1)
		dat += "</TT><BR>"
		dat += "- CAUTION -<BR>\[<A href='?src=[UID()];operation=deleteoverrides'>DELETE ALL OVERRIDES</A>\]<HR>"

		dat += "</TT> TERTIARY PROFILES:<BR><TT>"
		for(var/datum/cargoprofile/P in profiles)
			dat += format(P,0)
		dat += "</TT><BR>"
		dat += "- CAUTION -<BR>\[<A href='?src=[UID()];operation=deleteprofiles'>DELETE TERTIARY PROFILES</A>\]"

		user << browse("<HEAD><TITLE>Circuit Reprogramming</TITLE></HEAD>[dat]", "window=progcircuit")
		onclose(user, "progcircuit")

	Topic(href, href_list)
		if(..())
			return
		usr.set_machine(src)
		var/id = href_list["id"]
		var/level = text2num(href_list["level"])
		switch(href_list["operation"])
			if("promote")
				if(level == 0)
					for(var/datum/cargoprofile/T in profiles)
						if(T.id == id)
							overrides += T
							profiles -= T
							//updateUsrDialog()
							interact(usr)
							return

				if(level == 1)
					if(default) return
					for(var/datum/cargoprofile/T in overrides)
						if(T.id == id)
							default = T
							overrides -= T

							if(default.dedicated_path)
								build_path = "[default.dedicated_path]"
							else
								if(istype(default,/datum/cargoprofile/unary))
									build_path = "/obj/machinery/programmable/unary"
								else
									build_path = "/obj/machinery/programmable"

							//updateUsrDialog()
							interact(usr)
							return

			if("demote")
				if(level == 2)
					overrides += default
					default = null
					//updateUsrDialog()
					interact(usr)
					return
				if(level == 1)
					for(var/datum/cargoprofile/T in overrides)
						if(T.id == id)
							profiles += T
							overrides -= T
							//updateUsrDialog()
							interact(usr)
							return
			if("delete")
				if(level == 2)
					default = null
					//updateUsrDialog()
					interact(usr)
					return
				if(level == 1)
					for(var/datum/cargoprofile/T in overrides)
						if(T.id ==  id)
							overrides -= T
							//updateUsrDialog()
							interact(usr)
							return
				if(level == 0)
					for(var/datum/cargoprofile/T in profiles)
						if(T.id ==  id)
							profiles -= T
							//updateUsrDialog()
							interact(usr)
							return
			if("deleteall")
				for(var/datum/cargoprofile/T in profiles)
					profiles -= T
				for(var/datum/cargoprofile/T in overrides)
					overrides -= T
				//updateUsrDialog()
				interact(usr)
				return
			if("deleteoverrides")
				for(var/datum/cargoprofile/T in overrides)
					overrides -= T
				interact(usr)
				return
			if("deleteprofiles")
				for(var/datum/cargoprofile/T in profiles)
					profiles -= T
				interact(usr)
				return
			if("reset")
				resetlists()
				interact(usr)
				return

		//End switch
