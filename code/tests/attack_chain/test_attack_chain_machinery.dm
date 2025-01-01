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

	// Here we fucking go.

	var/obj/scanner = teleport_to_first(player, /obj/machinery/dna_scannernew)
	player.spawn_obj_in_hand(/obj/item/reagent_containers/glass/beaker)
	player.click_on(scanner)

	return scanner
