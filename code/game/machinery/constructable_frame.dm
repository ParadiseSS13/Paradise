/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	anchored = 1
	use_power = NO_POWER_USE
	max_integrity = 100
	var/obj/item/circuitboard/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null // user-friendly names of components
	var/state = 1

	// For pods
	var/list/connected_parts = list()
	var/pattern_idx=0

/obj/machinery/constructable_frame/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(src.loc, 5)
	if(state >= 3)
		var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(loc)
		A.amount = 5
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	return ..()

/obj/machinery/constructable_frame/obj_break(damage_flag)
	deconstruct()

// unfortunately, we have to instance the objects really quickly to get the names
// fortunately, this is only called once when the board is added and the items are immediately GC'd
// and none of the parts do much in their constructors
/obj/machinery/constructable_frame/proc/update_namelist()
	if(!req_components)
		return

	req_component_names = new()
	for(var/tname in req_components)
		var/path = tname
		var/obj/O = new path()
		req_component_names[tname] = O.name

/obj/machinery/constructable_frame/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

// update description of required components remaining
/obj/machinery/constructable_frame/proc/update_req_desc()
	if(!req_components || !req_component_names)
		return

	var/hasContent = 0
	desc = "Requires"
	for(var/i = 1 to req_components.len)
		var/tname = req_components[i]
		var/amt = req_components[tname]
		if(amt == 0)
			continue
		var/use_and = i == req_components.len
		desc += "[(hasContent ? (use_and ? ", and" : ",") : "")] [amt] [amt == 1 ? req_component_names[tname] : "[req_component_names[tname]]\s"]"
		hasContent = 1

	if(!hasContent)
		desc = "Does not require any more components."
	else
		desc += "."

/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/P, mob/user, params)
	switch(state)
		if(1)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.amount >= 5)
					playsound(src.loc, C.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, 20 * C.toolspeed, target = src))
						if(state == 1 && C.amount >= 5 && C.use(5))
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							state = 2
							icon_state = "box_1"
						else
							to_chat(user, "<span class='warning'>At some point during construction you lost some cable. Make sure you have five lengths before trying again.</span>")
							return
				else
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the frame.</span>")
					return
			else if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if(G.amount < 5)
					to_chat(user, "<span class='warning'>You do not have enough glass to build a display case.</span>")
					return
				G.use(5)
				to_chat(user, "<span class='notice'>You add the glass to the frame.</span>")
				playsound(get_turf(src), G.usesound, 50, 1)
				new /obj/structure/displaycase_frame(src.loc)
				qdel(src)
				return

			if(istype(P, /obj/item/wrench))
				playsound(src.loc, P.usesound, 75, 1)
				to_chat(user, "<span class='notice'>You dismantle the frame.</span>")
				deconstruct(TRUE)
		if(2)
			if(istype(P, /obj/item/circuitboard))
				var/obj/item/circuitboard/B = P
				if(B.board_type == "machine")
					playsound(src.loc, B.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
					circuit = P
					user.drop_item()
					P.loc = src
					icon_state = "box_2"
					state = 3
					components = list()
					req_components = circuit.req_components.Copy()
					update_namelist()
					update_req_desc()
				else
					to_chat(user, "<span class='danger'>This frame does not accept circuit boards of this type!</span>")
			if(istype(P, /obj/item/wirecutters))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 1
				icon_state = "box_0"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(src.loc,5)
				A.amount = 5

		if(3)
			if(istype(P, /obj/item/crowbar))
				playsound(src.loc, P.usesound, 50, 1)
				state = 2
				circuit.loc = src.loc
				circuit = null
				if(components.len == 0)
					to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				else
					to_chat(user, "<span class='notice'>You remove the circuit board and other components.</span>")
					for(var/obj/item/I in components)
						I.loc = src.loc
				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"

			if(istype(P, /obj/item/screwdriver))
				var/component_check = 1
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = 0
						break
				if(component_check)
					playsound(src.loc, P.usesound, 50, 1)
					var/obj/machinery/new_machine = new src.circuit.build_path(src.loc)
					new_machine.on_construction()
					for(var/obj/O in new_machine.component_parts)
						qdel(O)
					new_machine.component_parts = list()
					for(var/obj/O in src)
						O.loc = null
						new_machine.component_parts += O
					circuit.loc = null
					new_machine.RefreshParts()
					qdel(src)
					return

			if(istype(P, /obj/item/storage/part_replacer) && P.contents.len && get_req_components_amt())
				var/obj/item/storage/part_replacer/replacer = P
				var/list/added_components = list()
				var/list/part_list = list()

				//Assemble a list of current parts, then sort them by their rating!
				for(var/obj/item/stock_parts/co in replacer)
					part_list += co

				for(var/path in req_components)
					while(req_components[path] > 0 && (locate(path) in part_list))
						var/obj/item/part = (locate(path) in part_list)
						added_components[part] = path
						replacer.remove_from_storage(part, src)
						req_components[path]--
						part_list -= part

				for(var/obj/item/stock_parts/part in added_components)
					components += part
					to_chat(user, "<span class='notice'>[part.name] applied.</span>")
				replacer.play_rped_sound()

				update_req_desc()
				return

			if(istype(P, /obj/item))
				var/success
				for(var/I in req_components)
					if(istype(P, I) && (req_components[I] > 0) && (!(P.flags & NODROP) || istype(P, /obj/item/stack)))
						success=1
						playsound(src.loc, P.usesound, 50, 1)
						if(istype(P, /obj/item/stack))
							var/obj/item/stack/S = P
							var/camt = min(S.amount, req_components[I])
							var/obj/item/stack/NS = new P.type(src)
							NS.amount = camt
							NS.update_icon()
							S.use(camt)
							components += NS
							req_components[I] -= camt
							update_req_desc()
							break
						user.drop_item()
						P.forceMove(src)
						components += P
						req_components[I]--
						update_req_desc()
						return 1
				if(!success)
					to_chat(user, "<span class='danger'>You cannot add that to the machine!</span>")
					return 0

//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add MAT_METAL and MAT_GLASS to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/
/obj/item/circuitboard/vendor
	name = "circuit board (Booze-O-Mat Vendor)"
	build_path = /obj/machinery/vending/boozeomat
	board_type = "machine"
	origin_tech = "programming=1"
	frame_desc = "Requires 3 Resupply Canisters."
	req_components = list(
							/obj/item/vending_refill/boozeomat = 3)

	var/list/names_paths = list("Booze-O-Mat" = /obj/machinery/vending/boozeomat,
							"Solar's Best Hot Drinks" = /obj/machinery/vending/coffee,
							"Getmore Chocolate Corp" = /obj/machinery/vending/snack,
							"Mr. Chang" = /obj/machinery/vending/chinese,
							"Robust Softdrinks" = /obj/machinery/vending/cola,
							"ShadyCigs Deluxe" = /obj/machinery/vending/cigarette,
							"AutoDrobe" = /obj/machinery/vending/autodrobe,
							"Hatlord 9000" = /obj/machinery/vending/hatdispenser,
							"Suitlord 9000" = /obj/machinery/vending/suitdispenser,
							"Shoelord 9000" = /obj/machinery/vending/shoedispenser,
							"ClothesMate" = /obj/machinery/vending/clothing,
							"CritterCare" = /obj/machinery/vending/crittercare)

/obj/item/circuitboard/vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		set_type(null, user)


/obj/item/circuitboard/vendor/proc/set_type(typepath, mob/user)
	var/new_name = "Booze-O-Mat Vendor"
	if(!typepath)
		new_name = input("Circuit Setting", "What would you change the board setting to?") in names_paths
		typepath = names_paths[new_name]
	else
		for(var/name in names_paths)
			if(names_paths[name] == typepath)
				new_name = name
				break
	build_path = typepath
	name = "circuit board ([new_name])"
	req_components = list(text2path("/obj/item/vending_refill/[copytext("[build_path]", 24)]") = 3)
	if(user)
		to_chat(user, "<span class='notice'>You set the board to [new_name].</span>")

/obj/item/circuitboard/smes
	name = "circuit board (SMES)"
	build_path = /obj/machinery/power/smes
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	frame_desc = "Requires 5 pieces of cable, 5 Power Cells and 1 Capacitor."
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/cell = 5,
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/emitter
	name = "circuit board (Emitter)"
	build_path = /obj/machinery/power/emitter
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/power_compressor
	name = "circuit board (Power Compressor)"
	build_path = /obj/machinery/power/compressor
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/manipulator = 6)

/obj/item/circuitboard/power_turbine
	name = "circuit board (Power Turbine)"
	build_path = /obj/machinery/power/turbine
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/capacitor = 6)

/obj/item/circuitboard/thermomachine
	name = "circuit board (Freezer)"
	desc = "Use screwdriver to switch between heating and cooling modes."
	build_path = /obj/machinery/atmospherics/unary/cold_sink/freezer
	board_type = "machine"
	origin_tech = "programming=3;plasmatech=3"
	frame_desc = "Requires 2 Matter Bins, 2 Micro Lasers, 1 piece of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/thermomachine/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		if(build_path == /obj/machinery/atmospherics/unary/cold_sink/freezer)
			build_path = /obj/machinery/atmospherics/unary/heat_reservoir/heater
			name = "circuit board (Heater)"
			to_chat(user, "<span class='notice'>You set the board to heating.</span>")
		else
			build_path = /obj/machinery/atmospherics/unary/cold_sink/freezer
			name = "circuit board (Freezer)"
			to_chat(user, "<span class='notice'>You set the board to cooling.</span>")

/obj/item/circuitboard/snow_machine
	name = "circuit board (snow machine)"
	build_path = /obj/machinery/snow_machine
	board_type = "machine"
	origin_tech = "programming=2;materials=2"
	frame_desc = "Requires 1 Matter Bin and 1 Micro Laser."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/biogenerator
	name = "circuit board (Biogenerator)"
	build_path = /obj/machinery/biogenerator
	board_type = "machine"
	origin_tech = "programming=2;biotech=3;materials=3"
	frame_desc = "Requires 1 Matter Bin, 1 Manipulator, 1 piece of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/plantgenes
	name = "Plant DNA Manipulator (Machine Board)"
	build_path = /obj/machinery/plantgenes
	board_type = "machine"
	origin_tech = "programming=3;biotech=3"
	frame_desc = "Requires 1 Manipulator, 1 Micro Laser, 1 Console Screen, and 1 Scanning Module."
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/seed_extractor
	name = "circuit board (Seed Extractor)"
	build_path = /obj/machinery/seed_extractor
	board_type = "machine"
	origin_tech = "programming=1"
	frame_desc = "Requires 1 Matter Bin and 1 Manipulator."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/hydroponics
	name = "circuit board (Hydroponics Tray)"
	build_path = /obj/machinery/hydroponics/constructable
	board_type = "machine"
	origin_tech = "programming=1;biotech=2"
	frame_desc = "Requires 2 Matter Bins, 1 Manipulator, and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/microwave
	name = "circuit board (Microwave)"
	build_path = /obj/machinery/kitchen_machine/microwave
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	frame_desc = "Requires 1 Micro Laser, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/oven
	name = "circuit board (Oven)"
	build_path = /obj/machinery/kitchen_machine/oven
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	frame_desc = "Requires 2 Micro Lasers, 5 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/grill
	name = "circuit board (Grill)"
	build_path = /obj/machinery/kitchen_machine/grill
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	frame_desc = "Requires 2 Micro Lasers, 5 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/candy_maker
	name = "circuit board (Candy Maker)"
	build_path = /obj/machinery/kitchen_machine/candy_maker
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	frame_desc = "Requires 1 Manipulator, 5 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/deepfryer
	name = "circuit board (Deep Fryer)"
	build_path = /obj/machinery/cooker/deepfryer
	board_type = "machine"
	origin_tech = "programming=1"
	frame_desc = "Requires 2 Micro Lasers and 5 pieces of cable."
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/gibber
	name = "circuit board (Gibber)"
	build_path = /obj/machinery/gibber
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/tesla_coil
	name = "circuit board (Tesla Coil)"
	build_path = /obj/machinery/power/tesla_coil
	board_type = "machine"
	origin_tech = "programming=3;magnets=3;powerstorage=3"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/grounding_rod
	name = "circuit board (Grounding Rod)"
	build_path = /obj/machinery/power/grounding_rod
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;magnets=3;plasmatech=2"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/processor
	name = "circuit board (Food processor)"
	build_path = /obj/machinery/processor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/recycler
	name = "circuit board (Recycler)"
	build_path = /obj/machinery/recycler
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/smartfridge
	name = "circuit board (Smartfridge)"
	build_path = /obj/machinery/smartfridge
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1)
	var/list/fridge_names_paths = list(
							"\improper SmartFridge" = /obj/machinery/smartfridge,
							"\improper MegaSeed Servitor" = /obj/machinery/smartfridge/seeds,
							"\improper Refrigerated Medicine Storage" = /obj/machinery/smartfridge/medbay,
							"\improper Slime Extract Storage" = /obj/machinery/smartfridge/secure/extract,
							"\improper Secure Refrigerated Medicine Storage" = /obj/machinery/smartfridge/secure/medbay,
							"\improper Smart Chemical Storage" = /obj/machinery/smartfridge/secure/chemistry,
							"smart virus storage" = /obj/machinery/smartfridge/secure/chemistry/virology,
							"\improper Drink Showcase" = /obj/machinery/smartfridge/drinks
	)



/obj/item/circuitboard/smartfridge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		set_type(null, user)

/obj/item/circuitboard/smartfridge/proc/set_type(typepath, mob/user)
	var/new_name = ""
	if(!typepath)
		new_name = input("Circuit Setting", "What would you change the board setting to?") in fridge_names_paths
		typepath = fridge_names_paths[new_name]
	else
		for(var/name in fridge_names_paths)
			if(fridge_names_paths[name] == typepath)
				new_name = name
				break
	build_path = typepath
	name = new_name
	if(findtextEx(new_name, "\improper"))
		new_name = replacetext(new_name, "\improper", "")
	if(user)
		to_chat(user, "<span class='notice'>You set the board to [new_name].</span>")

/obj/item/circuitboard/monkey_recycler
	name = "circuit board (Monkey Recycler)"
	build_path = /obj/machinery/monkey_recycler
	board_type = "machine"
	origin_tech = "programming=1;biotech=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/holopad
	name = "circuit board (AI Holopad)"
	build_path = /obj/machinery/hologram/holopad
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/chem_dispenser
	name = "circuit board (Portable Chem Dispenser)"
	build_path = /obj/machinery/chem_dispenser/constructable
	board_type = "machine"
	origin_tech = "materials=4;programming=4;plasmatech=4;biotech=3"
	frame_desc = "Requires 2 Matter Bins, 1 Capacitor, 1 Manipulator, 1 Console Screen, and 1 Power Cell."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/chem_master
	name = "circuit board (Chem Master 2999)"
	build_path = /obj/machinery/chem_master/constructable
	board_type = "machine"
	origin_tech = "materials=3;programming=2;biotech=3"
	req_components = list(
							/obj/item/reagent_containers/glass/beaker = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/chem_heater
	name = "circuit board (Chemical Heater)"
	build_path = /obj/machinery/chem_heater
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;biotech=2"
	frame_desc = "Requires 1 Micro Laser and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/console_screen = 1)

//Almost the same recipe as destructive analyzer to give people choices.
/obj/item/circuitboard/experimentor
	name = "circuit board (E.X.P.E.R.I-MENTOR)"
	build_path = /obj/machinery/r_n_d/experimentor
	board_type = "machine"
	origin_tech = "magnets=1;engineering=1;programming=1;biotech=1;bluespace=2"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/destructive_analyzer
	name = "Circuit board (Destructive Analyzer)"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=2"
	frame_desc = "Requires 1 Scanning Module, 1 Manipulator, and 1 Micro-Laser."
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/autolathe
	name = "Circuit board (Autolathe)"
	build_path = /obj/machinery/autolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 3 Matter Bins, 1 Manipulator, and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 3,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/protolathe
	name = "Circuit board (Protolathe)"
	build_path = /obj/machinery/r_n_d/protolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 2 Matter Bins, 2 Manipulators, and 2 Beakers."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/soda
	name = "Circuit board (Soda Machine)"
	build_path = /obj/machinery/chem_dispenser/soda
	board_type = "machine"
	frame_desc = "Requires 2 Matter Bins, 1 Manipulators, 1 Capacitor, 1 Console Screen, and 1 Power Cell."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/beer
	name = "Circuit board (Beer Machine)"
	build_path = /obj/machinery/chem_dispenser/beer
	board_type = "machine"
	frame_desc = "Requires 2 Matter Bins, 1 Manipulators, 1 Capacitor, 1 Console Screen, and 1 Power Cell."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/cell = 1)


/obj/item/circuitboard/circuit_imprinter
	name = "Circuit board (Circuit Imprinter)"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 1 Matter Bin, 1 Manipulator, and 2 Beakers."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/pacman
	name = "Circuit Board (PACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman
	board_type = "machine"
	origin_tech = "programming=2;powerstorage=3;plasmatech=3;engineering=3"
	frame_desc = "Requires 1 Matter Bin, 1 Micro-Laser, 2 Pieces of Cable, and 1 Capacitor."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/pacman/super
	name = "Circuit Board (SUPERPACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/circuitboard/pacman/mrs
	name = "Circuit Board (MRSPACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman/mrs
	origin_tech = "programming=3;powerstorage=4;engineering=4;plasmatech=4"

/obj/item/circuitboard/rdserver
	name = "Circuit Board (R&D Server)"
	build_path = /obj/machinery/r_n_d/server
	board_type = "machine"
	origin_tech = "programming=3"
	frame_desc = "Requires 2 pieces of cable, and 1 Scanning Module."
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	build_path = /obj/machinery/mecha_part_fabricator
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Matter Bins, 1 Manipulator, 1 Micro-Laser and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/podfab
	name = "Circuit board (Spacepod Fabricator)"
	build_path = /obj/machinery/mecha_part_fabricator/spacepod
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Matter Bins, 1 Manipulators, 1 Micro-Lasers, and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/console_screen = 1)


/obj/item/circuitboard/clonepod
	name = "Circuit board (Clone Pod)"
	build_path = /obj/machinery/clonepod
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	frame_desc = "Requires 2 Manipulator, 2 Scanning Module, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 2,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/clonescanner
	name = "Circuit board (Cloning Scanner)"
	build_path = /obj/machinery/dna_scannernew
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	frame_desc = "Requires 1 Scanning Module, 1 Manipulator, 1 Micro-Laser, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 2,)

/obj/item/circuitboard/mech_recharger
	name = "circuit board (Mech Bay Recharger)"
	build_path = /obj/machinery/mech_bay_recharge_port
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	frame_desc = "Requires 1 piece of cable and 5 Capacitors."
	req_components = list(
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/capacitor = 5)

/obj/item/circuitboard/teleporter_hub
	name = "circuit board (Teleporter Hub)"
	build_path = /obj/machinery/teleport/hub
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	frame_desc = "Requires 3 Bluespace Crystals and 1 Matter Bin."
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 3,
							/obj/item/stock_parts/matter_bin = 1)

/obj/item/circuitboard/teleporter_station
	name = "circuit board (Teleporter Station)"
	build_path = /obj/machinery/teleport/station
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;bluespace=4;plasmatech=3"
	frame_desc = "Requires 2 Bluespace Crystals, 2 Capacitors and 1 Console Screen."
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 2,
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/teleporter_perma
	name = "circuit board (Permanent Teleporter)"
	build_path = /obj/machinery/teleport/perma
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	frame_desc = "Requires 3 Bluespace Crystals and 1 Matter Bin."
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 3,
							/obj/item/stock_parts/matter_bin = 1)
	var/target

/obj/item/circuitboard/teleporter_perma/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/gps))
		var/obj/item/gps/L = I
		if(L.locked_location)
			target = get_turf(L.locked_location)
			to_chat(user, "<span class='caution'>You upload the data from [L]</span>")

/obj/item/circuitboard/telesci_pad
	name = "Circuit board (Telepad)"
	build_path = /obj/machinery/telepad
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;plasmatech=4;bluespace=4"
	frame_desc = "Requires 2 Bluespace Crystals, 1 Capacitor, 1 piece of cable and 1 Console Screen."
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 2,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/quantumpad
	name = "circuit board (Quantum Pad)"
	build_path = /obj/machinery/quantumpad
	board_type = "machine"
	origin_tech = "programming=3;engineering=3;plasmatech=3;bluespace=4"
	frame_desc = "Requires 1 Bluespace Crystal, 1 Capacitor, 1 piece of cable and 1 Manipulator."
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 1,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1)

/obj/item/circuitboard/sleeper
	name = "circuit board (Sleeper)"
	build_path = /obj/machinery/sleeper
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3"
	frame_desc = "Requires 1 Matter Bin, 1 Manipulator, 1 piece of cable and 2 Console Screens."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/console_screen = 2)

/obj/item/circuitboard/sleeper/syndicate
	name = "circuit board (Sleeper Syndicate)"
	build_path = /obj/machinery/sleeper/syndie

/obj/item/circuitboard/sleeper/survival
	name = "circuit board (Sleeper Survival Pod)"
	build_path = /obj/machinery/sleeper/survival_pod


/obj/item/circuitboard/bodyscanner
	name = "circuit board (Body Scanner)"
	build_path = /obj/machinery/bodyscanner
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3"
	frame_desc = "Requires 1 Scanning Module, 2 pieces of cable and 2 Console Screens."
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/console_screen = 2)

/obj/item/circuitboard/bodyscanner_console
	name = "circuit board (Body Scanner Console)"
	build_path = /obj/machinery/body_scanconsole
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3"
	frame_desc = "Requires 2 pieces of cable and 2 Console Screens."
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/console_screen = 2)

/obj/item/circuitboard/cryo_tube
	name = "circuit board (Cryotube)"
	build_path = /obj/machinery/atmospherics/unary/cryo_cell
	board_type = "machine"
	origin_tech = "programming=4;biotech=3;engineering=4;plasmatech=3"
	frame_desc = "Requires 1 Matter Bin, 1 piece of cable and 4 Console Screens."
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/console_screen = 4)

/obj/item/circuitboard/cyborgrecharger
	name = "circuit board (Cyborg Recharger)"
	build_path = /obj/machinery/recharge_station
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=3"
	frame_desc = "Requires 2 Capacitors, 1 Power Cell and 1 Manipulator."
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/cell = 1,
							/obj/item/stock_parts/manipulator = 1)

// Telecomms circuit boards:
/obj/item/circuitboard/telecomms/receiver
	name = "Circuit Board (Subspace Receiver)"
	build_path = /obj/machinery/telecomms/receiver
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=1"
	frame_desc = "Requires 1 Subspace Ansible, 1 Hyperwave Filter, 2 Manipulators, and 1 Micro-Laser."
	req_components = list(
							/obj/item/stock_parts/subspace/ansible = 1,
							/obj/item/stock_parts/subspace/filter = 1,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/telecomms/hub
	name = "Circuit Board (Hub Mainframe)"
	build_path = /obj/machinery/telecomms/hub
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Manipulators, 2 Cable Coil and 2 Hyperwave Filter."
	req_components = list(
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/telecomms/relay
	name = "Circuit Board (Relay Mainframe)"
	build_path = /obj/machinery/telecomms/relay
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=2"
	frame_desc = "Requires 2 Manipulators, 2 Cable Coil and 2 Hyperwave Filters."
	req_components = list(
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/telecomms/bus
	name = "Circuit Board (Bus Mainframe)"
	build_path = /obj/machinery/telecomms/bus
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/telecomms/processor
	name = "Circuit Board (Processor Unit)"
	build_path = /obj/machinery/telecomms/processor
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 3 Manipulators, 1 Hyperwave Filter, 2 Treatment Disks, 1 Wavelength Analyzer, 2 Cable Coils and 1 Subspace Amplifier."
	req_components = list(
							/obj/item/stock_parts/manipulator = 3,
							/obj/item/stock_parts/subspace/filter = 1,
							/obj/item/stock_parts/subspace/treatment = 2,
							/obj/item/stock_parts/subspace/analyzer = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/subspace/amplifier = 1)

/obj/item/circuitboard/telecomms/server
	name = "Circuit Board (Telecommunication Server)"
	build_path = /obj/machinery/telecomms/server
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/telecomms/broadcaster
	name = "Circuit Board (Subspace Broadcaster)"
	build_path = /obj/machinery/telecomms/broadcaster
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=1"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil, 1 Hyperwave Filter, 1 Ansible Crystal and 2 High-Powered Micro-Lasers. "
	req_components = list(
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/subspace/filter = 1,
							/obj/item/stock_parts/subspace/crystal = 1,
							/obj/item/stock_parts/micro_laser/high = 2)

/obj/item/circuitboard/ore_redemption
	name = "circuit board (Ore Redemption)"
	build_path = /obj/machinery/mineral/ore_redemption
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/ore_redemption/golem
	name = "circuit board (Golem Ore Redemption)"
	build_path = /obj/machinery/mineral/ore_redemption/golem

/obj/item/circuitboard/mining_equipment_vendor
	name = "circuit board (Mining Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor
	board_type = "machine"
	origin_tech = "programming=1;engineering=3"
	req_components = list(
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/matter_bin = 3)

/obj/item/circuitboard/mining_equipment_vendor/golem
	name = "circuit board (Mining Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor/golem

/obj/item/circuitboard/clawgame
	name = "circuit board (Claw Game)"
	build_path = /obj/machinery/arcade/claw
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/prize_counter
	name = "circuit board (Prize Counter)"
	build_path = /obj/machinery/prize_counter
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 1)

/obj/item/circuitboard/gameboard
	name = "circuit board (Virtual Gameboard)"
	build_path = /obj/machinery/gameboard
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 3,
							/obj/item/stack/sheet/glass = 1)

//Selectable mode board, like vending machine boards
/obj/item/circuitboard/logic_gate
	name = "circuit board (Logic Connector)"
	build_path = /obj/machinery/logic_gate
	board_type = "machine"
	origin_tech = "programming=1"		//This stuff is pretty much the absolute basis of programming, so it's mostly useless for research
	req_components = list(/obj/item/stack/cable_coil = 1)

	var/list/names_paths = list(
							"NOT Gate" = /obj/machinery/logic_gate/not,
							"OR Gate" = /obj/machinery/logic_gate/or,
							"AND Gate" = /obj/machinery/logic_gate/and,
							"NAND Gate" = /obj/machinery/logic_gate/nand,
							"NOR Gate" = /obj/machinery/logic_gate/nor,
							"XOR Gate" = /obj/machinery/logic_gate/xor,
							"XNOR Gate" = /obj/machinery/logic_gate/xnor,
							"STATUS Gate" = /obj/machinery/logic_gate/status,
							"CONVERT Gate" = /obj/machinery/logic_gate/convert
	)

/obj/item/circuitboard/logic_gate/New()
	..()
	if(build_path == /obj/machinery/logic_gate)			//If we spawn the base type board (determined by the base type machine as the build path), become a random gate board
		var/new_path = names_paths[pick(names_paths)]
		set_type(new_path)

/obj/item/circuitboard/logic_gate/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		set_type(null, user)

/obj/item/circuitboard/logic_gate/proc/set_type(typepath, mob/user)
	var/new_name = "Logic Base"
	if(!typepath)
		new_name = input("Circuit Setting", "What would you change the board setting to?") in names_paths
		typepath = names_paths[new_name]
	else
		for(var/name in names_paths)
			if(names_paths[name] == typepath)
				new_name = name
				break
	build_path = typepath
	name = "circuit board ([new_name])"
	if(user)
		to_chat(user, "<span class='notice'>You set the board to [new_name].</span>")
