
SUBSYSTEM_DEF(research)
	name = "Research"
	flags = SS_KEEP_TIMING
	priority = FIRE_PRIORITY_RESEARCH
	wait = 1 SECONDS
	init_order = INIT_ORDER_RESEARCH
	var/list/invalid_design_ids = list()		//associative id = number of times
	var/list/invalid_node_ids = list()			//associative id = number of times
	var/list/invalid_node_boost = list()		//associative id = error message
	var/list/obj/machinery/r_n_d/server/servers = list()
	var/datum/techweb/science/science_tech
	var/datum/techweb/admin/admin_tech
	var/list/techweb_nodes = list()				//associative id = node datum
	var/list/techweb_categories = list()		//category name = list(node.id = node)
	var/list/techweb_designs = list()			//associative id = node datum
	var/list/techweb_nodes_starting = list()	//associative id = node datum
	var/list/techweb_boost_items = list()		//associative double-layer path = list(id = point_discount)
	var/list/techweb_nodes_hidden = list()		//Nodes that should be hidden by default.
	var/list/techweb_point_items = list(
		/obj/item/assembly/signaler/anomaly = 25000 // Anomaly cores are worth 10 nodes
	)		//path = value
	var/list/errored_datums = list()
	//----------------------------------------------
	var/single_server_income = 40.7 // AA TODO: Maybe reduce this since we will have extra point gain methods
	var/multiserver_calculation = FALSE
	var/last_income = 0
	//^^^^^^^^ ALL OF THESE ARE PER SECOND! ^^^^^^^^

	//Aiming for 1.5 hours to max R&D
	//[88nodes * 5000points/node] / [1.5hr * 90min/hr * 60s/min]
	//Around 450000 points max???

	/// Associative list of id:name for the UI item names
	var/list/id_name_cache = list()

	/// Points target for scientists to hit
	var/points_target = 0

	/// High-complexity chem chosen for the chem research machine
	var/complex_research_chem_id

/datum/controller/subsystem/research/Initialize()
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	science_tech = new /datum/techweb/science
	admin_tech = new /datum/techweb/admin
	autosort_categories()
	generate_design_name_cache()
	// Setup point target for scientist job
	points_target = rand(20000, 40000)
	// Setup ID for a complex chem for the complicated
	setup_complex_chem()
	return ..()

/datum/controller/subsystem/research/fire()
	handle_research_income()

/datum/controller/subsystem/research/proc/handle_research_income()
	var/bitcoins = 0
	if(multiserver_calculation)
		var/eff = calculate_server_coefficient()
		for(var/obj/machinery/r_n_d/server/miner in servers)
			bitcoins += (miner.mine() * eff)	//SLAVE AWAY, SLAVE.
	else
		for(var/obj/machinery/r_n_d/server/miner in servers)
			if(miner.working)
				bitcoins = single_server_income
				break			//Just need one to work.
	var/income_time_difference = world.time - last_income
	bitcoins *= income_time_difference / 10
	science_tech.research_points += bitcoins
	last_income = world.time

/datum/controller/subsystem/research/proc/calculate_server_coefficient()	//Diminishing returns.
	var/amt = servers.len
	if(!amt)
		return 0
	var/coeff = 100
	coeff = sqrt(coeff / amt)
	return coeff

/datum/controller/subsystem/research/proc/autosort_categories()
	for(var/i in techweb_nodes)
		var/datum/techweb_node/I = techweb_nodes[i]
		if(techweb_categories[I.category])
			techweb_categories[I.category][I.id] = I
		else
			techweb_categories[I.category] = list(I.id = I)

/datum/controller/subsystem/research/proc/generate_design_name_cache()
	for(var/design in subtypesof(/datum/design))
		var/datum/design/D = new design()
		var/atom/A = D.build_path
		id_name_cache[D.id] = initial(A.name)

/datum/controller/subsystem/research/proc/initialize_all_techweb_nodes(clearall = FALSE)
	if(islist(techweb_nodes) && clearall)
		QDEL_LIST(techweb_nodes)
	if(islist(techweb_nodes_starting && clearall))
		QDEL_LIST(techweb_nodes_starting)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/TN = path
		if(isnull(initial(TN.id)))
			continue
		TN = new path
		if(returned[initial(TN.id)])
			stack_trace("WARNING: Techweb node ID clash with ID [initial(TN.id)] detected!")
			errored_datums[TN] = initial(TN.id)
			continue
		returned[initial(TN.id)] = TN
		if(TN.starting_node)
			techweb_nodes_starting[TN.id] = TN
	techweb_nodes = returned
	verify_techweb_nodes()				//Verify all nodes have ids and such.
	calculate_techweb_nodes()
	calculate_techweb_boost_list()
	verify_techweb_nodes()		//Verify nodes and designs have been crosslinked properly.

/datum/controller/subsystem/research/proc/initialize_all_techweb_designs(clearall = FALSE)
	if(islist(SSresearch.techweb_designs) && clearall)
		QDEL_LIST(SSresearch.techweb_designs)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/design))
		var/datum/design/DN = path
		if(isnull(initial(DN.id)))
			stack_trace("WARNING: Design with null ID detected. Build path: [initial(DN.build_path)]")
			continue
		else if(initial(DN.id) == DESIGN_ID_IGNORE)
			continue
		DN = new path
		if(returned[initial(DN.id)])
			stack_trace("WARNING: Design ID clash with ID [initial(DN.id)] detected!")
			SSresearch.errored_datums[DN] = initial(DN.id)
			continue
		returned[initial(DN.id)] = DN
	SSresearch.techweb_designs = returned
	verify_techweb_designs()

/datum/controller/subsystem/research/proc/get_techweb_node_by_id(id)
	if(SSresearch.techweb_nodes[id])
		return SSresearch.techweb_nodes[id]

/datum/controller/subsystem/research/proc/get_techweb_design_by_id(id)
	if(SSresearch.techweb_designs[id])
		return SSresearch.techweb_designs[id]

/datum/controller/subsystem/research/proc/research_node_id_error(id)
	if(SSresearch.invalid_node_ids[id])
		SSresearch.invalid_node_ids[id]++
	else
		SSresearch.invalid_node_ids[id] = 1

/datum/controller/subsystem/research/proc/design_id_error(id)
	if(SSresearch.invalid_design_ids[id])
		SSresearch.invalid_design_ids[id]++
	else
		SSresearch.invalid_design_ids[id] = 1


/datum/controller/subsystem/research/proc/verify_techweb_nodes()
	for(var/n in techweb_nodes)
		var/datum/techweb_node/N = techweb_nodes[n]
		if(!istype(N))
			stack_trace("WARNING: Invalid research node with ID [n] detected and removed.")
			techweb_nodes -= n
			research_node_id_error(n)
		for(var/p in N.prereq_ids)
			var/datum/techweb_node/P = techweb_nodes[p]
			if(!istype(P))
				stack_trace("WARNING: Invalid research prerequisite node with ID [p] detected in node [N.display_name]\[[N.id]\] removed.")
				N.prereq_ids  -= p
				research_node_id_error(p)
		for(var/d in N.design_ids)
			var/datum/design/D = techweb_designs[d]
			if(!istype(D))
				stack_trace("WARNING: Invalid research design with ID [d] detected in node [N.display_name]\[[N.id]\] removed.")
				N.designs -= d
				design_id_error(d)
		for(var/p in N.prerequisites)
			var/datum/techweb_node/P = N.prerequisites[p]
			if(!istype(P))
				stack_trace("WARNING: Invalid research prerequisite node with ID [p] detected in node [N.display_name]\[[N.id]\] removed.")
				N.prerequisites -= p
				research_node_id_error(p)
		for(var/u in N.unlocks)
			var/datum/techweb_node/U = N.unlocks[u]
			if(!istype(U))
				stack_trace("WARNING: Invalid research unlock node with ID [u] detected in node [N.display_name]\[[N.id]\] removed.")
				N.unlocks -= u
				research_node_id_error(u)
		for(var/d in N.designs)
			var/datum/design/D = N.designs[d]
			if(!istype(D))
				stack_trace("WARNING: Invalid research design with ID [d] detected in node [N.display_name]\[[N.id]\] removed.")
				N.designs -= d
				design_id_error(d)
		for(var/p in N.boost_item_paths)
			if(!ispath(p))
				N.boost_item_paths -= p
				node_boost_error(N.id, "[p] is not a valid path.")
		CHECK_TICK

/datum/controller/subsystem/research/proc/verify_techweb_designs()
	for(var/d in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_designs[d]
		if(!istype(D))
			stack_trace("WARNING: Invalid research design with ID [d] detected and removed.")
			SSresearch.techweb_designs -= d
		CHECK_TICK

/datum/controller/subsystem/research/proc/calculate_techweb_nodes()
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		node.prerequisites = list()
		node.unlocks = list()
		node.designs = list()
		for(var/i in node.prereq_ids)
			node.prerequisites[i] = SSresearch.techweb_nodes[i]
		for(var/i in node.design_ids)
			node.designs[i] = SSresearch.techweb_designs[i]
		if(node.hidden)
			SSresearch.techweb_nodes_hidden[node.id] = node
		CHECK_TICK
	generate_techweb_unlock_linking()

/datum/controller/subsystem/research/proc/generate_techweb_unlock_linking()
	for(var/node_id in SSresearch.techweb_nodes)						//Clear all unlock links to avoid duplication.
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		node.unlocks = list()
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		for(var/prereq_id in node.prerequisites)
			var/datum/techweb_node/prereq_node = node.prerequisites[prereq_id]
			prereq_node.unlocks[node.id] = node

// Yes. I absolutely hate this hacky mess, but I cant think of any other way to do this. Dont hurt me.
/datum/controller/subsystem/research/proc/setup_complex_chem()
	// List of reagents which have recursive recipes
	var/list/recursive_reagent_blacklist = list("water", "ice")

	// Need 2 lists
	var/list/id_cache_1 = list()
	var/list/id_cache_2 = list()

	// We want all reactions, otherwise it could end up picking a chem which isnt possible to make
	for(var/cr_path in subtypesof(/datum/chemical_reaction))
		var/datum/chemical_reaction/CR = new cr_path()
		if(CR.result in recursive_reagent_blacklist)
			continue
		id_cache_2 |= CR.result

	// Complexity of 4. Currently yields (ginsonic, fliptonium, degreaser, hair_dye, super_hairgrownium, initropidril, capulettium_plus, rotatium) as of 2020-10-16
	for(var/i in 1 to 4)
		// Setup lists
		id_cache_1 = id_cache_2.Copy()
		id_cache_2.Cut()

		for(var/cr_path in subtypesof(/datum/chemical_reaction))
			var/datum/chemical_reaction/CR = new cr_path()
			if(CR.result in recursive_reagent_blacklist)
				continue
			for(var/reagent in CR.required_reagents)
				// If one of our required reagents is in the first list
				if(reagent in id_cache_1)
					if(CR.result)
						id_cache_2 |= CR.result

	// Set the chem
	complex_research_chem_id = pick(id_cache_2)
