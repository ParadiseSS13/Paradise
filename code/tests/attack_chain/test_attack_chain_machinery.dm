/datum/game_test/room_test/attack_chain_machinery
	testing_area_name = "test_attack_chain_machinery.dmm"
	var/list/machine_instances_by_type = list()

/datum/game_test/room_test/attack_chain_machinery/proc/teleport_to_first(datum/test_puppeteer/player, obj_type, dir=EAST)
	if(length(machine_instances_by_type[obj_type]))
		var/machine = machine_instances_by_type[obj_type][1]
		player.puppet.forceMove(get_step(machine, dir))
		return machine
	TEST_FAIL("could not find [obj_type] to teleport puppet to")

/datum/game_test/room_test/attack_chain_machinery/New()
	. = ..()
	for(var/turf/T in available_turfs)
		for(var/obj/machinery/machine in T)
			LAZYOR(machine_instances_by_type[machine.type], machine)

/datum/game_test/room_test/attack_chain_machinery/Run()
	var/datum/test_puppeteer/player = new(src)

	// Here we fucking go. There's a lot of machines and interactions to test
	// here. The basic plan is to test one or two things within the subtype
	// interaction, And then test one or two things that should be handled by
	// the parent And possibly combat attacks if necessary.

	// DNA Scanner
	var/obj/scanner = teleport_to_first(player, /obj/machinery/dna_scannernew)
	var/area/admin_area = get_area(player.puppet)
	player.spawn_obj_in_hand(/obj/item/reagent_containers/glass/beaker)
	player.click_on(scanner)
	TEST_ASSERT_LAST_CHATLOG(player, "You add a beaker")
	var/obj/screwdriver = player.spawn_obj_in_hand(/obj/item/screwdriver)
	player.click_on(scanner)
	TEST_ASSERT_LAST_CHATLOG(player, "You open the maintenance hatch")
	player.put_away(screwdriver)

	// Abductor console
	var/obj/abductor_console = teleport_to_first(player, /obj/machinery/abductor/console)
	var/obj/gizmo = player.spawn_obj_in_hand(/obj/item/abductor/gizmo)
	player.click_on(abductor_console)
	TEST_ASSERT_LAST_CHATLOG(player, "You link the tool")
	qdel(gizmo)
	var/obj/welder = player.spawn_obj_in_hand(/obj/item/weldingtool)
	player.set_intent("harm")
	player.click_on(abductor_console)
	TEST_ASSERT_LAST_CHATLOG(player, "You hit Abductor console with the welding tool!")
	player.set_intent("help")
	player.put_away(welder)

	// Abductor replacement organ storage
	var/obj/machinery/abductor/gland_dispenser/dispenser = teleport_to_first(player, /obj/machinery/abductor/gland_dispenser)
	var/obj/gland = player.spawn_obj_in_hand(/obj/item/organ/internal/heart/gland)
	player.click_on(dispenser)
	TEST_ASSERT(gland in dispenser.contents, "did not place gland in dispenser")

	// Autolathe
	var/obj/machinery/autolathe/autolathe = teleport_to_first(player, /obj/machinery/autolathe)
	autolathe.disk_design_load_delay = 0
	var/obj/design_disk = player.spawn_obj_in_hand(/obj/item/disk/design_disk/golem_shell)
	player.click_on(autolathe)
	TEST_ASSERT_LAST_CHATLOG(player, "You begin to load a design")
	qdel(design_disk)
	player.retrieve(screwdriver)
	player.click_on(autolathe)
	TEST_ASSERT_LAST_CHATLOG(player, "You open the maintenance hatch")
	player.put_away(screwdriver)
	var/obj/rped = player.spawn_obj_in_hand(/obj/item/storage/part_replacer/tier4)
	player.click_on(autolathe)
	TEST_ASSERT_LAST_CHATLOG(player, "micro-manipulator replaced with femto-manipulator")
	qdel(rped)

	var/obj/machinery/nuclearbomb/nuke = teleport_to_first(player, /obj/machinery/nuclearbomb/undeployed)
	var/obj/disk = player.spawn_obj_in_hand(/obj/item/disk/nuclear/unrestricted)
	player.click_on(nuke)
	TEST_ASSERT_LAST_CHATLOG(player, "You need to deploy")
	nuke.extended = TRUE
	player.click_on(nuke)
	TEST_ASSERT(disk in nuke.contents, "Disk not inserted into nuke")
	player.retrieve(screwdriver)
	player.click_on(nuke)
	TEST_ASSERT_LAST_CHATLOG(player, "You unscrew the control panel")
	player.put_away(screwdriver)

	var/obj/camera = teleport_to_first(player, /obj/machinery/camera)
	player.retrieve(screwdriver)
	player.click_on(camera) // with screwdriver
	TEST_ASSERT_LAST_CHATLOG(player, "panel open")
	player.put_away(screwdriver)
	player.spawn_obj_in_hand(/obj/item/stack/sheet/mineral/plasma)
	player.click_on(camera)
	TEST_ASSERT_LAST_CHATLOG(player, "You attach the solid plasma")
	var/obj/knife = player.spawn_obj_in_hand(/obj/item/kitchen/knife)
	player.set_intent("harm")
	player.click_on(camera)
	TEST_ASSERT_LAST_CHATLOG(player, "You hit the security camera with the kitchen knife")
	player.set_intent("help")
	player.put_away(knife)

	var/obj/chem_dispenser = teleport_to_first(player, /obj/machinery/chem_dispenser)
	player.retrieve(screwdriver)
	player.click_on(chem_dispenser)
	TEST_ASSERT_LAST_CHATLOG(player, "You open the maintenance hatch")
	player.puppet.swap_hand()
	player.spawn_obj_in_hand(/obj/item/reagent_containers/glass/beaker)
	player.click_on(chem_dispenser)
	TEST_ASSERT_LAST_CHATLOG(player, "Close the maintenance panel first")
	player.puppet.swap_hand()
	player.click_on(chem_dispenser)
	player.puppet.swap_hand()
	player.click_on(chem_dispenser)
	TEST_ASSERT_LAST_CHATLOG(player, "You set the beaker on the machine")
	player.put_away(screwdriver)

	var/obj/upload_console = teleport_to_first(player, /obj/machinery/computer/aiupload)
	var/obj/ai_module = player.spawn_obj_in_hand(/obj/item/ai_module/asimov)
	player.click_on(upload_console)
	TEST_ASSERT_LAST_CHATLOG(player, "No AI selected")
	qdel(ai_module)
	player.retrieve(knife)
	player.set_intent("harm")
	player.click_on(upload_console)
	TEST_ASSERT_LAST_CHATLOG(player, "AI upload console with the kitchen knife")
	player.put_away(knife)

	var/obj/machinery/cell_charger/cell_charger = teleport_to_first(player, /obj/machinery/cell_charger)
	var/obj/cell = player.spawn_obj_in_hand(/obj/item/stock_parts/cell)
	player.click_on(cell_charger)
	TEST_ASSERT_LAST_CHATLOG(player, "You insert a cell into the charger")
	var/obj/cell2 = player.spawn_obj_in_hand(/obj/item/stock_parts/cell)
	player.click_on(cell_charger)
	TEST_ASSERT_LAST_CHATLOG(player, "already a cell in the charger")
	qdel(cell2)
	player.click_on(cell_charger)
	TEST_ASSERT_NULL(cell_charger.charging, "cell charger still charging")
	qdel(cell)
	player.retrieve(screwdriver)
	player.click_on(cell_charger)
	player.put_away(screwdriver)
	rped = player.spawn_obj_in_hand(/obj/item/storage/part_replacer/tier4)
	player.click_on(cell_charger)
	TEST_ASSERT_LAST_CHATLOG(player, "replaced with quadratic capacitor")
	qdel(rped)

	player.puppet.forceMove(top_right.loc)
	var/turf/wall = player.change_turf_nearby(/turf/simulated/wall, EAST)
	player.spawn_obj_in_hand(/obj/item/mounted/frame/firealarm)
	admin_area.requires_power = TRUE
	player.click_on(wall)
	admin_area.requires_power = FALSE
	player.spawn_obj_in_hand(/obj/item/firealarm_electronics)
	var/obj/firealarm_frame = player.find_nearby(/obj/machinery/firealarm)
	player.click_on(firealarm_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You insert the circuit")
	var/obj/cables = player.spawn_obj_in_hand(/obj/item/stack/cable_coil/ten)
	player.click_on(firealarm_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You wire")
	qdel(cables)
	player.retrieve(screwdriver)
	player.click_on(firealarm_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You close the panel")
	player.put_away(screwdriver)

	var/obj/protolathe = teleport_to_first(player, /obj/machinery/r_n_d/protolathe)
	var/obj/item/reagent_containers/bottle = player.spawn_obj_in_hand(/obj/item/reagent_containers/glass/bottle/ammonia)
	player.click_on(protolathe)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer 10 units of the solution to Protolathe.")

	var/obj/imprinter = teleport_to_first(player, /obj/machinery/r_n_d/circuit_imprinter)
	bottle.amount_per_transfer_from_this = 5
	player.click_on(imprinter)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer 5 units of the solution to Circuit Imprinter.")
