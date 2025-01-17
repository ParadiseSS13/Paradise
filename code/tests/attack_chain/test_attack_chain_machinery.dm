/datum/game_test/attack_chain_machinery
	testing_area_name = "test_attack_chain_machinery.dmm"
	var/list/machine_instances_by_type = list()

/datum/game_test/attack_chain_machinery/proc/teleport_to_first(datum/test_puppeteer/player, obj_type, dir=EAST)
	if(length(machine_instances_by_type[obj_type]))
		var/machine = machine_instances_by_type[obj_type][1]
		player.puppet.forceMove(get_step(machine, dir))
		return machine

/datum/game_test/attack_chain_machinery/New()
	. = ..()
	for(var/turf/T in available_turfs)
		for(var/obj/machinery/machine in T)
			LAZYOR(machine_instances_by_type[machine.type], machine)

/datum/game_test/attack_chain_machinery/Run()
	var/datum/test_puppeteer/player = new(src)

	// Here we fucking go. There's a lot of machines and interactions to test
	// here. The basic plan is to test one or two things within the subtype
	// interaction, And then test one or two things that should be handled by
	// the parent And possibly combat attacks if necessary.

	// DNA Scanner
	var/obj/scanner = teleport_to_first(player, /obj/machinery/dna_scannernew)
	player.spawn_obj_in_hand(/obj/item/reagent_containers/glass/beaker)
	player.click_on(scanner)
	TEST_ASSERT_LAST_CHATLOG(player, "You add a beaker")
	player.spawn_obj_in_hand(/obj/item/screwdriver)
	player.click_on(scanner)
	TEST_ASSERT_LAST_CHATLOG(player, "You open the maintenance hatch")
	player.puppet.drop_item()

	// Abductor console
	var/obj/abductor_console = teleport_to_first(player, /obj/machinery/abductor/console)
	player.spawn_obj_in_hand(/obj/item/abductor/gizmo)
	player.click_on(abductor_console)
	TEST_ASSERT_LAST_CHATLOG(player, "You link the tool")
	player.puppet.drop_item()
	player.spawn_obj_in_hand(/obj/item/weldingtool)
	player.set_intent("harm")
	player.click_on(abductor_console)
	TEST_ASSERT_LAST_CHATLOG(player, "You hit Abductor console with the welding tool!")
	player.puppet.drop_item()

	var/obj/machinery/abductor/gland_dispenser/dispenser = teleport_to_first(player, /obj/machinery/abductor/gland_dispenser)
	player.spawn_obj_in_hand(/obj/item/organ/internal/heart/gland)
	player.click_on(dispenser)
	TEST_ASSERT_EQUAL(length(dispenser.contents), 1, "did not place gland in dispenser")

	var/obj/autolathe = teleport_to_first(player, /obj/machinery/autolathe)
	player.spawn_obj_in_hand(/obj/item/disk/design_disk/golem_shell)
	player.click_on(autolathe)
	TEST_ASSERT_LAST_CHATLOG(player, "You begin to load a design")

	return
