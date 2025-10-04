#define MACHINE_FRAME_EMPTY 1
#define MACHINE_FRAME_WIRED 2
#define MACHINE_FRAME_CIRCUITBOARD 3

/obj/structure/machine_frame
	name = "machine frame"
	desc = "The standard frame for most station machines. Its appearance and function is controlled by the inserted board."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = TRUE
	anchored = TRUE

	pressure_resistance = 15
	max_integrity = 250
	layer = BELOW_OBJ_LAYER
	armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 70)
	atom_say_verb = "beeps"
	receive_ricochet_chance_mod = 0.3

	var/obj/item/circuitboard/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/state = MACHINE_FRAME_EMPTY
	var/frame_type = "machine"
	var/extra_desc

/obj/structure/machine_frame/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 5)
		if(state >= MACHINE_FRAME_WIRED)
			var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(loc)
			A.amount = 5
		if(circuit)
			circuit.forceMove(loc)
			circuit = null
	return ..()

/obj/structure/machine_frame/obj_break(damage_flag)
	deconstruct()

/obj/structure/machine_frame/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

/obj/structure/machine_frame/examine(mob/user)
	. = ..()
	if(extra_desc)
		. += "<span class='notice'>[extra_desc]</span>"

/obj/structure/machine_frame/update_name(updates)
	. = ..()
	if(circuit)
		name = "[initial(name)] ([circuit.board_name])"
		return
	name = initial(name)

/obj/structure/machine_frame/update_desc(updates)
	. = ..()
	if(!circuit)
		extra_desc = null
		return
	if(!req_components)
		extra_desc = "Does not require any more components."
		return

	var/list/needed_components = list()
	for(var/obj/component as anything in req_components)
		var/amt = req_components[component]
		if(amt <= 0)
			continue
		needed_components += "[amt] [component.name]\s"

	if(!length(needed_components))
		extra_desc = "Does not require any more components."
		return
	extra_desc = "Requires [english_list(needed_components)]."

/obj/structure/machine_frame/update_icon_state()
	. = ..()
	switch(state)
		if(MACHINE_FRAME_EMPTY)
			icon_state = "box_0"
		if(MACHINE_FRAME_WIRED)
			icon_state = "box_1"
		if(MACHINE_FRAME_CIRCUITBOARD)
			icon_state = "box_2"
		else
			icon_state = "box_0"

/obj/structure/machine_frame/item_interaction(mob/living/user, obj/item/P, list/modifiers)
	// Allow the borg gripper to pass the attack to the item it's holding.
	if(istype(P, /obj/item/gripper))
		return ..()

	switch(state)
		if(MACHINE_FRAME_EMPTY)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(src.loc, C.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, 20 * C.toolspeed, target = src))
						if(state == MACHINE_FRAME_EMPTY && C.get_amount() >= 5 && C.use(5))
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							state = MACHINE_FRAME_WIRED
							update_icon(UPDATE_ICON_STATE)
						else
							to_chat(user, "<span class='warning'>At some point during construction you lost some cable. Make sure you have five lengths before trying again.</span>")
							return ITEM_INTERACT_COMPLETE
				else
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the frame.</span>")
				return ITEM_INTERACT_COMPLETE

			if(iswrench(P))
				P.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You dismantle the frame.</span>")
				deconstruct(TRUE)
				return ITEM_INTERACT_COMPLETE
		if(MACHINE_FRAME_WIRED)
			// see wirecutter_act()

			if(istype(P, /obj/item/circuitboard))
				var/obj/item/circuitboard/B = P
				if(B.board_type == frame_type)
					if(!B.build_path)
						to_chat(user, "<span class='warning'>This is not a functional machine board!</span>")
						return ITEM_INTERACT_COMPLETE
					playsound(src.loc, B.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
					circuit = P
					user.drop_item()
					P.forceMove(src)
					state = MACHINE_FRAME_CIRCUITBOARD
					components = list()
					req_components = circuit.req_components?.Copy()
					update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)
				else
					to_chat(user, "<span class='danger'>This frame does not accept circuit boards of this type!</span>")
				return ITEM_INTERACT_COMPLETE

		if(MACHINE_FRAME_CIRCUITBOARD)
			// see crowbar_act()

			if(istype(P, /obj/item/storage/part_replacer) && length(P.contents) && get_req_components_amt())
				var/obj/item/storage/part_replacer/replacer = P
				var/list/added_components = list()
				var/list/part_list = list()

				//Assemble a list of current parts, then sort them by their rating!
				for(var/obj/item/stock_parts/co in replacer)
					part_list += co

				for(var/obj/item/reagent_containers/glass/beaker/be in replacer)
					part_list += be

				for(var/path in req_components)
					while(req_components[path] > 0 && (locate(path) in part_list))
						var/obj/item/part = (locate(path) in part_list)
						added_components[part] = path
						replacer.remove_from_storage(part, src)
						req_components[path]--
						part_list -= part

				for(var/obj/item/part in added_components)
					components += part
					to_chat(user, "<span class='notice'>[part.name] applied.</span>")
				replacer.play_rped_sound()

				update_appearance(UPDATE_DESC)
				return ITEM_INTERACT_COMPLETE

			if(isitem(P))
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
							update_appearance(UPDATE_DESC)
							break
						user.drop_item()
						P.forceMove(src)
						components += P
						req_components[I]--
						update_appearance(UPDATE_DESC)
						return ITEM_INTERACT_COMPLETE
				if(!success)
					to_chat(user, "<span class='danger'>You cannot add that to the machine!</span>")
					return ITEM_INTERACT_COMPLETE
				return ITEM_INTERACT_COMPLETE
	if(user.a_intent == INTENT_HARM)
		return ..()

/obj/structure/machine_frame/wirecutter_act(mob/living/user, obj/item/I)
	if(state != MACHINE_FRAME_WIRED)
		return

	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You remove the cables.</span>")
	state = MACHINE_FRAME_EMPTY
	new /obj/item/stack/cable_coil(loc, 5)
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/machine_frame/crowbar_act(mob/living/user, obj/item/I)
	if(state != MACHINE_FRAME_CIRCUITBOARD)
		return

	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	state = MACHINE_FRAME_WIRED
	circuit.forceMove(loc)
	circuit = null
	if(length(components) == 0)
		to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
	else
		to_chat(user, "<span class='notice'>You remove the circuit board and other components.</span>")
		for(var/obj/item/comp in components)
			comp.forceMove(loc)

	req_components = null
	components = null
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)


/obj/structure/machine_frame/screwdriver_act(mob/living/user, obj/item/I)
	if(state != MACHINE_FRAME_CIRCUITBOARD)
		return
	. = TRUE

	var/component_check = 1
	for(var/R in req_components)
		if(req_components[R] > 0)
			component_check = 0
			break
	if(!component_check)
		return TRUE
	I.play_tool_sound(src)
	var/obj/machinery/new_machine = new circuit.build_path(loc)
	new_machine.on_construction()
	for(var/obj/O in new_machine.component_parts)
		qdel(O)
	new_machine.component_parts = list()
	for(var/obj/O in src)
		O.moveToNullspace()
		new_machine.component_parts += O
	circuit.moveToNullspace()
	new_machine.RefreshParts()
	qdel(src)

#undef MACHINE_FRAME_EMPTY
#undef MACHINE_FRAME_WIRED
#undef MACHINE_FRAME_CIRCUITBOARD

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
	build_path = /obj/machinery/economy/vending/boozeomat
	req_components = list(/obj/item/vending_refill/boozeomat = 1)

	var/static/list/station_vendors = list(
		"Booze-O-Mat" =							/obj/machinery/economy/vending/boozeomat,
		"Solar's Best Hot Drinks" =				/obj/machinery/economy/vending/coffee,
		"Getmore Chocolate Corp" =				/obj/machinery/economy/vending/snack,
		"Mr. Chang" =							/obj/machinery/economy/vending/chinese,
		"Robust Softdrinks" =					/obj/machinery/economy/vending/cola,
		"ShadyCigs Deluxe" =					/obj/machinery/economy/vending/cigarette,
		"Hatlord 9000" =						/obj/machinery/economy/vending/hatdispenser,
		"Suitlord 9000" =						/obj/machinery/economy/vending/suitdispenser,
		"Shoelord 9000" =						/obj/machinery/economy/vending/shoedispenser,
		"AutoDrobe" =							/obj/machinery/economy/vending/autodrobe,
		"ClothesMate" =							/obj/machinery/economy/vending/clothing,
		"NanoMed Plus" =						/obj/machinery/economy/vending/medical,
		"NanoMed" =								/obj/machinery/economy/vending/wallmed,
		"Vendomat" =							/obj/machinery/economy/vending/assist,
		"YouTool" =								/obj/machinery/economy/vending/tool,
		"Engi-Vend" =							/obj/machinery/economy/vending/engivend,
		"NutriMax" =							/obj/machinery/economy/vending/hydronutrients,
		"MegaSeed Servitor" =					/obj/machinery/economy/vending/hydroseeds,
		"Sustenance Vendor" =					/obj/machinery/economy/vending/sustenance,
		"Plasteel Chef's Dinnerware Vendor" =	/obj/machinery/economy/vending/dinnerware,
		"PTech" =								/obj/machinery/economy/vending/cart,
		"Robotech Deluxe" =						/obj/machinery/economy/vending/robotics,
		"Robco Tool Maker" =					/obj/machinery/economy/vending/engineering,
		"BODA" =								/obj/machinery/economy/vending/sovietsoda,
		"SecTech" =								/obj/machinery/economy/vending/security,
		"CritterCare" =							/obj/machinery/economy/vending/crittercare,
		"SecDrobe" =							/obj/machinery/economy/vending/secdrobe,
		"DetDrobe" =							/obj/machinery/economy/vending/detdrobe,
		"MediDrobe" =							/obj/machinery/economy/vending/medidrobe,
		"ViroDrobe" =							/obj/machinery/economy/vending/virodrobe,
		"ChemDrobe" =							/obj/machinery/economy/vending/chemdrobe,
		"GeneDrobe" =							/obj/machinery/economy/vending/genedrobe,
		"SciDrobe" =							/obj/machinery/economy/vending/scidrobe,
		"RoboDrobe" =							/obj/machinery/economy/vending/robodrobe,
		"EngiDrobe" =							/obj/machinery/economy/vending/engidrobe,
		"AtmosDrobe" =							/obj/machinery/economy/vending/atmosdrobe,
		"CargoDrobe" =							/obj/machinery/economy/vending/cargodrobe,
		"ExploreDrobe" =						/obj/machinery/economy/vending/exploredrobe,
		"ChefDrobe" =							/obj/machinery/economy/vending/chefdrobe,
		"BarDrobe" =							/obj/machinery/economy/vending/bardrobe,
		"HydroDrobe" =							/obj/machinery/economy/vending/hydrodrobe,
		"JaniDrobe" =							/obj/machinery/economy/vending/janidrobe,
		"LawDrobe" =							/obj/machinery/economy/vending/lawdrobe,
		"TrainDrobe" =							/obj/machinery/economy/vending/traindrobe,
		"Castivend" =							/obj/machinery/economy/vending/smith,
		"CrewVend 3000" =						/obj/machinery/economy/vending/custom)
	var/static/list/unique_vendors = list(
		"ShadyCigs Ultra" =						/obj/machinery/economy/vending/cigarette/beach,
		"SyndiMed Plus" =						/obj/machinery/economy/vending/wallmed/syndicate)

/obj/item/circuitboard/vendor/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/choice = tgui_input_list(user, "Choose a new brand", "Select an Item", station_vendors)
	if(!choice)
		return
	set_type(choice)

/obj/item/circuitboard/vendor/proc/set_type(type)
	var/static/list/buildable_vendors = station_vendors + unique_vendors
	var/obj/machinery/economy/vending/typepath = buildable_vendors[type]
	build_path = typepath
	board_name = "[type] Vendor"
	format_board_name()
	if(initial(typepath.refill_canister))
		req_components = list(initial(typepath.refill_canister) = 1)
	else
		req_components = list()

/obj/item/circuitboard/slot_machine
	board_name = "Slot Machine"
	icon_state = "generic"
	build_path = /obj/machinery/economy/slot_machine
	board_type = "machine"
	req_components = list(
							/obj/item/stack/cable_coil = 3,
							/obj/item/stock_parts/cell = 1,
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/bottler
	board_name = "Bottler"
	icon_state = "service"
	build_path = /obj/machinery/bottler
	board_type = "machine"
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/smes
	board_name = "SMES"
	icon_state = "engineering"
	build_path = /obj/machinery/power/smes
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/cell = 5,
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/emitter
	board_name = "Emitter"
	icon_state = "engineering"
	build_path = /obj/machinery/power/emitter
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/power_compressor
	board_name = "Power Compressor"
	icon_state = "engineering"
	build_path = /obj/machinery/power/compressor
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/manipulator = 6)

/obj/item/circuitboard/power_turbine
	board_name = "Power Turbine"
	icon_state = "engineering"
	build_path = /obj/machinery/power/turbine
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/capacitor = 6)

/obj/item/circuitboard/thermomachine
	board_name = "Thermomachine"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/unary/thermomachine
	board_type = "machine"
	origin_tech = "programming=3;plasmatech=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/space_heater
	board_name = "Space Heater"
	icon_state = "engineering"
	build_path = /obj/machinery/space_heater
	board_type = "machine"
	origin_tech = "programming=3;plasmatech=3"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/recharger
	board_name = "Recharger"
	icon_state = "security"
	build_path = /obj/machinery/recharger
	board_type = "machine"
	origin_tech = "powerstorage=3;materials=2"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/snow_machine
	board_name = "Snow Machine"
	icon_state = "generic"
	build_path = /obj/machinery/snow_machine
	board_type = "machine"
	origin_tech = "programming=2;materials=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/biogenerator
	board_name = "Biogenerator"
	icon_state = "service"
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
	icon_state = "service"
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
	icon_state = "service"
	build_path = /obj/machinery/seed_extractor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/hydroponics
	board_name = "Hydroponics Tray"
	icon_state = "service"
	build_path = /obj/machinery/hydroponics/constructable
	board_type = "machine"
	origin_tech = "programming=1;biotech=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/microwave
	board_name = "Microwave"
	icon_state = "service"
	build_path = /obj/machinery/kitchen_machine/microwave
	board_type = "machine"
	origin_tech = "programming=2;magnets=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/deepfryer
	board_name = "Deep Fryer"
	icon_state = "service"
	build_path = /obj/machinery/cooking/deepfryer
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/gibber
	board_name = "Gibber"
	icon_state = "service"
	build_path = /obj/machinery/gibber
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/tesla_coil
	board_name = "Tesla Coil"
	icon_state = "engineering"
	build_path = /obj/machinery/power/tesla_coil
	board_type = "machine"
	origin_tech = "programming=3;magnets=3;powerstorage=3"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/grounding_rod
	board_name = "Grounding Rod"
	icon_state = "engineering"
	build_path = /obj/machinery/power/grounding_rod
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;magnets=3;plasmatech=2"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/processor
	board_name = "Food Processor"
	icon_state = "service"
	build_path = /obj/machinery/processor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/recycler
	board_name = "Recycler"
	icon_state = "service"
	build_path = /obj/machinery/recycler
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/washing_machine
	board_name = "Washing Machine"
	icon_state = "generic"
	build_path = /obj/machinery/washing_machine
	board_type = "machine"
	origin_tech = "programming=1"

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
							"Identification Card Compartmentalizer" = /obj/machinery/smartfridge/id,
							"Circuit Board Storage" = /obj/machinery/smartfridge/secure/circuits,
							"AI Laws Storage" = /obj/machinery/smartfridge/secure/circuits/aiupload)

/obj/item/circuitboard/smartfridge/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/choice = tgui_input_list(user, "Circuit Setting", "What would you change the board setting to?", fridge_names_paths)
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
	icon_state = "science"
	build_path = /obj/machinery/monkey_recycler
	board_type = "machine"
	origin_tech = "programming=1;biotech=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/holopad
	board_name = "AI Holopad"
	icon_state = "generic"
	build_path = /obj/machinery/hologram/holopad
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/chem_dispenser
	board_name = "Chem Dispenser"
	icon_state = "medical"
	build_path = /obj/machinery/chem_dispenser
	board_type = "machine"
	origin_tech = "materials=4;programming=4;plasmatech=4;biotech=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1
	)

/obj/item/circuitboard/chem_master
	board_name = "ChemMaster 3000"
	icon_state = "medical"
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
	icon_state = "service"
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/circuitboard/chem_heater
	board_name = "Chemical Heater"
	icon_state = "medical"
	build_path = /obj/machinery/chem_heater
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;biotech=2"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/reagentgrinder
	board_name = "All-In-One Grinder"
	icon_state = "service"
	build_path = /obj/machinery/reagentgrinder/empty
	board_type = "machine"
	origin_tech = "materials=2;engineering=2;biotech=2"
	req_components = list(
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stock_parts/matter_bin = 1)

/obj/item/circuitboard/scientific_analyzer // fucking US spelling
	board_name = "Scientific Analyzer"
	icon_state = "science"
	build_path = /obj/machinery/r_n_d/scientific_analyzer
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/autolathe
	board_name = "Autolathe"
	icon_state = "engineering"
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

/obj/item/circuitboard/autolathe/trapped
	board_name = "Modified Autolathe"
	build_path = /obj/machinery/autolathe/trapped

/obj/item/circuitboard/protolathe
	board_name = "Protolathe"
	icon_state = "science"
	build_path = /obj/machinery/r_n_d/protolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/dish_drive
	board_name = "Dish Drive"
	icon_state = "service"
	build_path = /obj/machinery/dish_drive
	board_type = "machine"
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stack/sheet/glass = 1)
	var/suction = TRUE
	var/transmit = TRUE

/obj/item/circuitboard/dish_drive/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Its suction function is [suction ? "enabled" : "disabled"]. Use it in-hand to switch.</span>"
	. += "<span class='notice'>Its disposal auto-transmit function is [transmit ? "enabled" : "disabled"]. Alt-click it to switch.</span>"

/obj/item/circuitboard/dish_drive/attack_self__legacy__attackchain(mob/living/user)
	suction = !suction
	to_chat(user, "<span class='notice'>You [suction ? "enable" : "disable"] the board's suction function.</span>")

/obj/item/circuitboard/dish_drive/AltClick(mob/living/user)
	if(!user.Adjacent(src))
		return
	transmit = !transmit
	to_chat(user, "<span class='notice'>You [transmit ? "enable" : "disable"] the board's automatic disposal transmission.</span>")

/obj/item/circuitboard/chem_dispenser/soda
	board_name = "Soda Machine"
	icon_state = "service"
	build_path = /obj/machinery/chem_dispenser/soda

/obj/item/circuitboard/chem_dispenser/beer
	board_name = "Beer Machine"
	icon_state = "service"
	build_path = /obj/machinery/chem_dispenser/beer

/obj/item/circuitboard/circuit_imprinter
	board_name = "Circuit Imprinter"
	icon_state = "science"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/pacman
	board_name = "PACMAN-type Generator"
	icon_state = "engineering"
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
	icon_state = "science"
	build_path = /obj/machinery/r_n_d/server
	board_type = "machine"
	origin_tech = "programming=3"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/mechfab
	board_name = "Exosuit Fabricator"
	icon_state = "science"
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
	icon_state = "medical"
	build_path = /obj/machinery/clonepod
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 2,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/clonescanner
	board_name = "Cloning Scanner"
	icon_state = "medical"
	build_path = /obj/machinery/clonescanner
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stack/cable_coil = 2,)

/obj/item/circuitboard/dna_scanner
	board_name = "DNA Modifier"
	icon_state = "medical"
	build_path = /obj/machinery/dna_scannernew
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(/obj/item/stock_parts/scanning_module = 1,
						/obj/item/stock_parts/manipulator = 1,
						/obj/item/stock_parts/micro_laser = 1,
						/obj/item/stack/sheet/glass = 1,
						/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/mech_recharger
	board_name = "Mech Bay Recharger"
	icon_state = "science"
	build_path = /obj/machinery/mech_bay_recharge_port
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/capacitor = 5)

/obj/item/circuitboard/teleporter_hub
	board_name = "Teleporter Hub"
	icon_state = "engineering"
	build_path = /obj/machinery/teleport/hub
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 3,
							/obj/item/stock_parts/matter_bin = 1)

/obj/item/circuitboard/teleporter_station
	board_name = "Teleporter Station"
	icon_state = "engineering"
	build_path = /obj/machinery/teleport/station
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;bluespace=4;plasmatech=3"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 2,
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/teleporter_perma
	board_name = "Permanent Teleporter"
	icon_state = "engineering"
	build_path = /obj/machinery/teleport/perma
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 3,
							/obj/item/stock_parts/matter_bin = 1)
	var/target

/obj/item/circuitboard/teleporter_perma/attackby__legacy__attackchain(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/gps))
		var/obj/item/gps/L = I
		if(L.locked_location)
			target = get_turf(L.locked_location)
			to_chat(user, "<span class='caution'>You upload the data from [L]</span>")
		return
	return ..()

/obj/item/circuitboard/telesci_pad
	board_name = "Telepad"
	icon_state = "science"
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
	icon_state = "science"
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
	icon_state = "medical"
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
	icon_state = "generic"
	build_path = /obj/machinery/sleeper/syndie

/obj/item/circuitboard/sleeper/survival
	board_name = "Sleeper - Survival Pod"
	icon_state = "generic"
	build_path = /obj/machinery/sleeper/survival_pod

/obj/item/circuitboard/bodyscanner
	board_name = "Body Scanner"
	icon_state = "medical"
	build_path = /obj/machinery/bodyscanner
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/cryo_tube
	board_name = "Cryotube"
	icon_state = "medical"
	build_path = /obj/machinery/atmospherics/unary/cryo_cell
	board_type = "machine"
	origin_tech = "programming=4;biotech=3;engineering=4;plasmatech=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stack/sheet/glass = 4)

/obj/item/circuitboard/pandemic
	board_name = "PanD.E.M.I.C. 2200"
	icon_state = "medical"
	board_type = "machine"
	build_path = /obj/machinery/pandemic
	req_components = list(/obj/item/stock_parts/manipulator = 1, /obj/item/stock_parts/micro_laser = 1)
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/cell_charger
	board_name = "Cell Charger"
	icon_state = "engineering"
	build_path = /obj/machinery/cell_charger
	board_type = "machine"
	origin_tech = "powerstorage=3;materials=2"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/cyborgrecharger
	board_name = "Cyborg Recharger"
	icon_state = "science"
	build_path = /obj/machinery/recharge_station
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/cell = 1,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/anomaly_refinery
	board_name = "Anomaly Refinery"
	icon_state = "science"
	build_path = /obj/machinery/anomaly_refinery
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;"
	req_components = list(
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stack/cable_coil = 2
						)

// Telecomms circuit boards:
/obj/item/circuitboard/tcomms/relay
	board_name = "Telecommunications Relay"
	icon_state = "engineering"
	build_path = /obj/machinery/tcomms/relay
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=2"
	req_components = list(/obj/item/stock_parts/manipulator = 2, /obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/tcomms/core
	board_name = "Telecommunications Core"
	icon_state = "engineering"
	build_path = /obj/machinery/tcomms/core
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(/obj/item/stock_parts/manipulator = 2, /obj/item/stack/cable_coil = 2)
// End telecomms circuit boards

/obj/item/circuitboard/salvage_redemption
	board_name = "Salvage Redemption"
	icon_state = "supply"
	build_path = /obj/machinery/salvage_redemption
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/scanning_module = 3,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/smart_hopper
	board_name = "Ore Redemption"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/smart_hopper
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/matter_bin = 3,
							/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/magma_crucible
	board_name = "Magma Crucible"
	icon_state = "supply"
	build_path = /obj/machinery/magma_crucible
	board_type = "machine"
	origin_tech = "programming=1;engineering=4"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/casting_basin
	board_name = "Casting Basin"
	icon_state = "supply"
	build_path = /obj/machinery/smithing/casting_basin
	board_type = "machine"
	origin_tech = "programming=1;engineering=4"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/sheet/glass = 1
						)

/obj/item/circuitboard/power_hammer
	board_name = "Power Hammer"
	icon_state = "supply"
	build_path = /obj/machinery/smithing/power_hammer
	board_type = "machine"
	origin_tech = "programming=1;engineering=4"
	req_components = list(
							/obj/item/stock_parts/manipulator = 4,
							/obj/item/stack/sheet/plasteel = 1)

/obj/item/circuitboard/lava_furnace
	board_name = "Lava Furnace"
	icon_state = "supply"
	build_path = /obj/machinery/smithing/lava_furnace
	board_type = "machine"
	origin_tech = "programming=1;engineering=4"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 4,
							/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/kinetic_assembler
	board_name = "Kinetic Assembler"
	icon_state = "supply"
	build_path = /obj/machinery/smithing/kinetic_assembler
	board_type = "machine"
	origin_tech = "programming=1;engineering=4"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 3,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/scientific_assembler
	board_name = "Scientific Assembler"
	icon_state = "supply"
	build_path = /obj/machinery/smithing/scientific_assembler
	board_type = "machine"
	origin_tech = "programming=1;engineering=4"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stock_parts/manipulator = 3,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/ore_redemption
	board_name = "Ore Redemption"
	icon_state = "supply"
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
	icon_state = "supply"
	build_path = /obj/machinery/mineral/equipment_vendor
	board_type = "machine"
	origin_tech = "programming=1;engineering=3"
	req_components = list(
							/obj/item/stack/sheet/glass = 1,
							/obj/item/stock_parts/matter_bin = 3)

/obj/item/circuitboard/mining_equipment_vendor/golem
	board_name = "Golem Equipment Vendor"
	icon_state = "generic"
	build_path = /obj/machinery/mineral/equipment_vendor/golem

/obj/item/circuitboard/mining_equipment_vendor/labor
	board_name = "Labour Equipment Vendor"
	icon_state = "generic"
	build_path = /obj/machinery/mineral/equipment_vendor/labor

/obj/item/circuitboard/mining_equipment_vendor/explorer
	board_name = "Explorer Equipment Vendor"
	build_path = /obj/machinery/mineral/equipment_vendor/explorer

/obj/item/circuitboard/clawgame
	board_name = "Claw Game"
	icon_state = "generic"
	build_path = /obj/machinery/economy/arcade/claw
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/prize_counter
	board_name = "Prize Counter"
	icon_state = "generic"
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
	icon_state = "generic"
	build_path = /obj/machinery/gameboard
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 3,
							/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/merch
	board_name = "Nanotrasen Merchandise Vendor"
	icon_state = "generic"
	build_path = /obj/machinery/economy/merch
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1)

/obj/item/circuitboard/suit_storage_unit
	board_name = "Suit Storage Unit"
	icon_state = "generic"
	build_path = /obj/machinery/suit_storage_unit
	board_type = "machine"
	origin_tech = "materials=2;engineering=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 3,
							/obj/item/stack/sheet/rglass = 5)

/obj/item/circuitboard/suit_storage_unit/industrial
	board_name = "Industrial Suit Storage Unit"
	icon_state = "engineering"
	build_path = /obj/machinery/suit_storage_unit/industrial
	origin_tech = "materials=3;engineering=4"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 3,
							/obj/item/stack/sheet/plasteel = 5
	)

/obj/item/circuitboard/processing_node
	board_name = "Processing Node"
	icon_state = "science"
	build_path = /obj/machinery/ai_node/processing_node
	board_type = "machine"
	origin_tech = "programming=4"
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stack/sheet/mineral/gold = 1,
							/obj/item/stack/sheet/mineral/silver = 1,
							/obj/item/stack/sheet/mineral/diamond = 1,
							/obj/item/stack/cable_coil = 5
	)

/obj/item/circuitboard/network_node
	board_name = "Network Node"
	icon_state = "science"
	build_path = /obj/machinery/ai_node/network_node
	board_type = "machine"
	origin_tech = "programming=4"
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stack/sheet/mineral/gold = 1,
							/obj/item/stack/sheet/mineral/silver = 1,
							/obj/item/stack/cable_coil = 5
	)

/obj/item/circuitboard/autochef
	board_name = "Autochef"
	icon_state = "generic"
	board_type = "machine"
	build_path = /obj/machinery/autochef
	origin_tech = "programming=3;bluespace=3;materials=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

// Detective machines
/obj/item/circuitboard/dnaforensics
	name = "circuit board (DNA analyzer)"
	build_path = /obj/machinery/dnaforensics
	board_type = "machine"
	origin_tech = "programming=2;combat=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1)


/obj/item/circuitboard/microscope
	name = "circuit board (Microscope)"
	build_path = /obj/machinery/microscope
	board_type = "machine"
	origin_tech = "programming=2;combat=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)
