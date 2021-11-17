/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	anchored = 1
	use_power = NO_POWER_USE
	max_integrity = 250
	var/obj/item/circuitboard/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null // user-friendly names of components
	var/state = 1

	// For pods
	var/list/connected_parts = list()
	var/pattern_idx=0

/obj/machinery/constructable_frame/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 5)
		if(state >= 2)
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
				if(C.get_amount() >= 5)
					playsound(src.loc, C.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, 20 * C.toolspeed, target = src))
						if(state == 1 && C.get_amount() >= 5 && C.use(5))
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							state = 2
							icon_state = "box_1"
						else
							to_chat(user, "<span class='warning'>At some point during construction you lost some cable. Make sure you have five lengths before trying again.</span>")
							return
				else
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the frame.</span>")
				return

			if(istype(P, /obj/item/wrench))
				playsound(src.loc, P.usesound, 75, 1)
				to_chat(user, "<span class='notice'>You dismantle the frame.</span>")
				deconstruct(TRUE)
				return
		if(2)
			if(istype(P, /obj/item/circuitboard))
				var/obj/item/circuitboard/B = P
				if(B.board_type == "machine")
					playsound(src.loc, B.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
					circuit = P
					user.drop_item()
					P.loc = src
					name += " ([B.board_name])"
					icon_state = "box_2"
					state = 3
					components = list()
					req_components = circuit.req_components.Copy()
					update_namelist()
					update_req_desc()
				else
					to_chat(user, "<span class='danger'>This frame does not accept circuit boards of this type!</span>")
				return
			if(istype(P, /obj/item/wirecutters))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 1
				icon_state = "box_0"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(src.loc,5)
				A.amount = 5
				return
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
				name = initial(name)
				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"
				return

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
							var/camt = min(S.get_amount(), req_components[I])
							var/obj/item/stack/NS = new S.merge_type(src)
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
				return
	if(user.a_intent == INTENT_HARM)
		return ..()


//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, glass sheets, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add MAT_METAL and MAT_GLASS to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/
/obj/item/circuitboard/vendor
	board_name = "Booze-O-Mat Vendor"
	board_type = "machine"
	origin_tech = "programming=1"
	build_path = /obj/machinery/vending/boozeomat
	req_components = list(/obj/item/vending_refill/boozeomat = 1)

	var/static/list/vending_names_paths = list(
		"Booze-O-Mat" =							/obj/machinery/vending/boozeomat,
		"Solar's Best Hot Drinks" =				/obj/machinery/vending/coffee,
		"Getmore Chocolate Corp" =				/obj/machinery/vending/snack,
		"Mr. Chang" =							/obj/machinery/vending/chinese,
		"Robust Softdrinks" =					/obj/machinery/vending/cola,
		"ShadyCigs Deluxe" =					/obj/machinery/vending/cigarette,
		"Hatlord 9000" =						/obj/machinery/vending/hatdispenser,
		"Suitlord 9000" =						/obj/machinery/vending/suitdispenser,
		"Shoelord 9000" =						/obj/machinery/vending/shoedispenser,
		"AutoDrobe" =							/obj/machinery/vending/autodrobe,
		"ClothesMate" =							/obj/machinery/vending/clothing,
		"NanoMed Plus" =						/obj/machinery/vending/medical,
		"NanoMed" =								/obj/machinery/vending/wallmed,
		"Vendomat" =							/obj/machinery/vending/assist,
		"YouTool" =								/obj/machinery/vending/tool,
		"Engi-Vend" =							/obj/machinery/vending/engivend,
		"NutriMax" =							/obj/machinery/vending/hydronutrients,
		"MegaSeed Servitor" =					/obj/machinery/vending/hydroseeds,
		"Sustenance Vendor" =					/obj/machinery/vending/sustenance,
		"Plasteel Chef's Dinnerware Vendor" =	/obj/machinery/vending/dinnerware,
		"PTech" =								/obj/machinery/vending/cart,
		"Robotech Deluxe" =						/obj/machinery/vending/robotics,
		"Robco Tool Maker" =					/obj/machinery/vending/engineering,
		"BODA" =								/obj/machinery/vending/sovietsoda,
		"SecTech" =								/obj/machinery/vending/security,
		"CritterCare" =							/obj/machinery/vending/crittercare,
		"SecDrobe" =							/obj/machinery/vending/secdrobe,
		"DetDrobe" =							/obj/machinery/vending/detdrobe,
		"MediDrobe" =							/obj/machinery/vending/medidrobe,
		"ViroDrobe" =							/obj/machinery/vending/virodrobe,
		"ChemDrobe" =							/obj/machinery/vending/chemdrobe,
		"GeneDrobe" =							/obj/machinery/vending/genedrobe,
		"SciDrobe" =							/obj/machinery/vending/scidrobe,
		"RoboDrobe" =							/obj/machinery/vending/robodrobe,
		"EngiDrobe" =							/obj/machinery/vending/engidrobe,
		"AtmosDrobe" =							/obj/machinery/vending/atmosdrobe,
		"CargoDrobe" =							/obj/machinery/vending/cargodrobe,
		"ChefDrobe" =							/obj/machinery/vending/chefdrobe,
		"BarDrobe" =							/obj/machinery/vending/bardrobe,
		"HydroDrobe" =							/obj/machinery/vending/hydrodrobe)

/obj/item/circuitboard/vendor/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/choice = input(user, "Choose a new brand", "Select an Item") as null|anything in vending_names_paths
	if(!choice)
		return
	set_type(choice)

/obj/item/circuitboard/vendor/proc/set_type(type)
	var/obj/machinery/vending/typepath = vending_names_paths[type]
	build_path = typepath
	board_name = "[type] Vendor"
	format_board_name()
	req_components = list(initial(typepath.refill_canister) = 1)

/obj/item/circuitboard/smes
	board_name = "SMES"
	build_path = /obj/machinery/power/smes
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/cell = 5,
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/emitter
	board_name = "Emitter"
	build_path = /obj/machinery/power/emitter
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/power_compressor
	board_name = "Power Compressor"
	build_path = /obj/machinery/power/compressor
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/manipulator = 6)

/obj/item/circuitboard/power_turbine
	board_name = "Power Turbine"
	build_path = /obj/machinery/power/turbine
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/capacitor = 6)

/obj/item/circuitboard/thermomachine
	board_name = "Thermomachine"
	build_path = /obj/machinery/atmospherics/unary/thermomachine
	board_type = "machine"
	origin_tech = "programming=3;plasmatech=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/recharger
	board_name = "Recharger"
	build_path = /obj/machinery/recharger
	board_type = "machine"
	origin_tech = "powerstorage=3;materials=2"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/snow_machine
	board_name = "Snow Machine"
	build_path = /obj/machinery/snow_machine
	board_type = "machine"
	origin_tech = "programming=2;materials=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/biogenerator
	board_name = "Biogenerator"
	build_path = /obj/machinery/biogenerator
	board_type = "machine"
	origin_tech = "programming=2;biotech=3;materials=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/plantgenes
	board_name = "Plant DNA Manipulator"
	build_path = /obj/machinery/plantgenes
	board_type = "machine"
	origin_tech = "programming=3;biotech=3"
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/plantgenes/vault

/obj/item/circuitboard/seed_extractor
	board_name = "Seed Extractor"
	build_path = /obj/machinery/seed_extractor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/hydroponics
	board_name = "Hydroponics Tray"
	build_path = /obj/machinery/hydroponics/constructable
	board_type = "machine"
	origin_tech = "programming=1;biotech=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/microwave
	board_name = "Microwave"
	build_path = /obj/machinery/kitchen_machine/microwave
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/oven
	board_name = "Oven"
	build_path = /obj/machinery/kitchen_machine/oven
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/grill
	board_name = "Grill"
	build_path = /obj/machinery/kitchen_machine/grill
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/candy_maker
	board_name = "Candy Maker"
	build_path = /obj/machinery/kitchen_machine/candy_maker
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/deepfryer
	board_name = "Deep Fryer"
	build_path = /obj/machinery/cooker/deepfryer
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/gibber
	board_name = "Gibber"
	build_path = /obj/machinery/gibber
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/tesla_coil
	board_name = "Tesla Coil"
	build_path = /obj/machinery/power/tesla_coil
	board_type = "machine"
	origin_tech = "programming=3;magnets=3;powerstorage=3"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/grounding_rod
	board_name = "Grounding Rod"
	build_path = /obj/machinery/power/grounding_rod
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;magnets=3;plasmatech=2"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/processor
	board_name = "Food Processor"
	build_path = /obj/machinery/processor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/recycler
	board_name = "Recycler"
	build_path = /obj/machinery/recycler
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/smartfridge
	board_name = "Smartfridge"
	build_path = /obj/machinery/smartfridge
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1)
	var/static/list/fridge_names_paths = list(
							"SmartFridge" = /obj/machinery/smartfridge,
							"MegaSeed Servitor" = /obj/machinery/smartfridge/seeds,
							"Refrigerated Medicine Storage" = /obj/machinery/smartfridge/medbay,
							"Slime Extract Storage" = /obj/machinery/smartfridge/secure/extract,
							"Secure Refrigerated Medicine Storage" = /obj/machinery/smartfridge/secure/medbay,
							"Smart Chemical Storage" = /obj/machinery/smartfridge/secure/chemistry,
							"Smart Virus Storage" = /obj/machinery/smartfridge/secure/chemistry/virology,
							"Drink Showcase" = /obj/machinery/smartfridge/drinks,
							"Disk Compartmentalizer" = /obj/machinery/smartfridge/disks,
							"Circuit Board Storage" = /obj/machinery/smartfridge/secure/circuits,
							"AI Laws Storage" = /obj/machinery/smartfridge/secure/circuits/aiupload)

/obj/item/circuitboard/smartfridge/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/choice = input(user, "Circuit Setting", "What would you change the board setting to?") as null|anything in fridge_names_paths
	if(!choice)
		return
	set_type(user, choice)

/obj/item/circuitboard/smartfridge/proc/set_type(mob/user, type)
	if(!ispath(type))
		board_name = type
		type = fridge_names_paths[type]
	else
		for(var/name in fridge_names_paths)
			if(fridge_names_paths[name] == type)
				board_name = name
				break
	build_path = type
	format_board_name()
	if(user)
		to_chat(user, "<span class='notice'>You set the board to [board_name].</span>")

/obj/item/circuitboard/monkey_recycler
	board_name = "Monkey Recycler"
	build_path = /obj/machinery/monkey_recycler
	board_type = "machine"
	origin_tech = "programming=1;biotech=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/holopad
	board_name = "AI Holopad"
	build_path = /obj/machinery/hologram/holopad
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/chem_dispenser
	board_name = "Chem Dispenser"
	build_path = /obj/machinery/chem_dispenser
	board_type = "machine"
	origin_tech = "materials=4;programming=4;plasmatech=4;biotech=3"
	req_components = list(	/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/chem_master
	board_name = "ChemMaster 3000"
	build_path = /obj/machinery/chem_master
	board_type = "machine"
	origin_tech = "materials=3;programming=2;biotech=3"
	req_components = list(
							/obj/item/reagent_containers/glass/beaker = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/chem_master/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/new_name = "ChemMaster"
	var/new_path = /obj/machinery/chem_master

	if(build_path == /obj/machinery/chem_master)
		new_name = "CondiMaster"
		new_path = /obj/machinery/chem_master/condimaster

	build_path = new_path
	name = "circuit board ([new_name] 3000)"
	to_chat(user, "<span class='notice'>You change the circuit board setting to \"[new_name]\".</span>")

/obj/item/circuitboard/chem_master/condi_master
	board_name = "CondiMaster 3000"
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/circuitboard/chem_heater
	board_name = "Chemical Heater"
	build_path = /obj/machinery/chem_heater
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;biotech=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/reagentgrinder
	board_name = "All-In-One Grinder"
	build_path = /obj/machinery/reagentgrinder/empty
	board_type = "machine"
	origin_tech = "materials=2;engineering=2;biotech=2"
	req_components = list(
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stock_parts/matter_bin = 1)

//Almost the same recipe as destructive analyzer to give people choices.
/obj/item/circuitboard/experimentor
	board_name = "E.X.P.E.R.I-MENTOR"
	build_path = /obj/machinery/r_n_d/experimentor
	board_type = "machine"
	origin_tech = "magnets=1;engineering=1;programming=1;biotech=1;bluespace=2"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/destructive_analyzer
	board_name = "Destructive Analyzer"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/autolathe
	board_name = "Autolathe"
	build_path = /obj/machinery/autolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 3,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/autolathe/syndi
	name = "Circuit board (Syndi Autolathe)"
	build_path = /obj/machinery/autolathe/syndicate

/obj/item/circuitboard/protolathe
	board_name = "Protolathe"
	build_path = /obj/machinery/r_n_d/protolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/chem_dispenser/soda
	board_name = "Soda Machine"
	build_path = /obj/machinery/chem_dispenser/soda

/obj/item/circuitboard/chem_dispenser/beer
	board_name = "Beer Machine"
	build_path = /obj/machinery/chem_dispenser/beer

/obj/item/circuitboard/circuit_imprinter
	board_name = "Circuit Imprinter"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/pacman
	board_name = "PACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman
	board_type = "machine"
	origin_tech = "programming=2;powerstorage=3;plasmatech=3;engineering=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/pacman/super
	board_name = "SUPERPACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/circuitboard/pacman/mrs
	board_name = "MRSPACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman/mrs
	origin_tech = "programming=3;powerstorage=4;engineering=4;plasmatech=4"

/obj/item/circuitboard/rdserver
	board_name = "R&D Server"
	build_path = /obj/machinery/r_n_d/server
	board_type = "machine"
	origin_tech = "programming=3"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/mechfab
	board_name = "Exosuit Fabricator"
	build_path = /obj/machinery/mecha_part_fabricator
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/clonepod
	board_name = "Clone Pod"
	build_path = /obj/machinery/clonepod
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 2,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/clonescanner
	board_name = "Cloning Scanner"
	build_path = /obj/machinery/dna_scannernew
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stack/cable_coil = 2,)

/obj/item/circuitboard/mech_recharger
	board_name = "Mech Bay Recharger"
	build_path = /obj/machinery/mech_bay_recharge_port
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/capacitor = 5)

/obj/item/circuitboard/teleporter_hub
	board_name = "Teleporter Hub"
	build_path = /obj/machinery/teleport/hub
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 3,
							/obj/item/stock_parts/matter_bin = 1)

/obj/item/circuitboard/teleporter_station
	board_name = "Teleporter Station"
	build_path = /obj/machinery/teleport/station
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;bluespace=4;plasmatech=3"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 2,
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/teleporter_perma
	board_name = "Permanent Teleporter"
	build_path = /obj/machinery/teleport/perma
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
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
		return
	return ..()

/obj/item/circuitboard/telesci_pad
	board_name = "Telepad"
	build_path = /obj/machinery/telepad
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;plasmatech=4;bluespace=4"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 2,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/quantumpad
	board_name = "Quantum Pad"
	build_path = /obj/machinery/quantumpad
	board_type = "machine"
	origin_tech = "programming=3;engineering=3;plasmatech=3;bluespace=4"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 1,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1)

/obj/item/circuitboard/sleeper
	board_name = "Sleeper"
	build_path = /obj/machinery/sleeper
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/sleeper/syndicate
	board_name = "Sleeper - Syndicate"
	build_path = /obj/machinery/sleeper/syndie

/obj/item/circuitboard/sleeper/survival
	board_name = "Sleeper - Survival Pod"
	build_path = /obj/machinery/sleeper/survival_pod


/obj/item/circuitboard/bodyscanner
	board_name = "Body Scanner"
	build_path = /obj/machinery/bodyscanner
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/cryo_tube
	board_name = "Cryotube"
	build_path = /obj/machinery/atmospherics/unary/cryo_cell
	board_type = "machine"
	origin_tech = "programming=4;biotech=3;engineering=4;plasmatech=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 4)

/obj/item/circuitboard/cyborgrecharger
	board_name = "Cyborg Recharger"
	build_path = /obj/machinery/recharge_station
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/cell = 1,
							/obj/item/stock_parts/manipulator = 1)

// Telecomms circuit boards:
/obj/item/circuitboard/tcomms/relay
	board_name = "Telecommunications Relay"
	build_path = /obj/machinery/tcomms/relay
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=2"
	req_components = list(/obj/item/stock_parts/manipulator = 2, /obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/tcomms/core
	board_name = "Telecommunications Core"
	build_path = /obj/machinery/tcomms/core
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(/obj/item/stock_parts/manipulator = 2, /obj/item/stack/cable_coil = 2)
// End telecomms circuit boards

/obj/item/circuitboard/ore_redemption
	board_name = "Ore Redemption"
	build_path = /obj/machinery/mineral/ore_redemption
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/ore_redemption/golem
	board_name = "Ore Redemption - Golem"
	build_path = /obj/machinery/mineral/ore_redemption/golem

/obj/item/circuitboard/ore_redemption/labor
	board_name = "Ore Redemption - Labour"
	build_path = /obj/machinery/mineral/ore_redemption/labor

/obj/item/circuitboard/mining_equipment_vendor
	board_name = "Mining Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor
	board_type = "machine"
	origin_tech = "programming=1;engineering=3"
	req_components = list(
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/matter_bin = 3)

/obj/item/circuitboard/mining_equipment_vendor/golem
	board_name = "Golem Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor/golem

/obj/item/circuitboard/mining_equipment_vendor/labor
	board_name = "Labour Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor/labor

/obj/item/circuitboard/clawgame
	board_name = "Claw Game"
	build_path = /obj/machinery/arcade/claw
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/prize_counter
	board_name = "Prize Counter"
	build_path = /obj/machinery/prize_counter
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stack/cable_coil = 1)

/obj/item/circuitboard/gameboard
	board_name = "Virtual Gameboard"
	build_path = /obj/machinery/gameboard
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 3,
							/obj/item/stack/sheet/glass = 1)
