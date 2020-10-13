/proc/count_unique_techweb_nodes()
	var/static/list/L = typesof(/datum/techweb_node)
	return L.len

/proc/count_unique_techweb_designs()
	var/static/list/L = typesof(/datum/design)
	return L.len

/proc/node_boost_error(id, message)
	SSresearch.invalid_node_boost[id] = message

/proc/calculate_techweb_boost_list(clearall = FALSE)
	if(clearall)
		SSresearch.techweb_boost_items = list()
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		for(var/path in node.boost_item_paths)
			if(!ispath(path))
				continue
			if(length(SSresearch.techweb_boost_items[path]))
				SSresearch.techweb_boost_items[path] += list(node.id = node.boost_item_paths[path])
			else
				SSresearch.techweb_boost_items[path] = list(node.id = node.boost_item_paths[path])
		CHECK_TICK

/proc/techweb_item_boost_check(obj/item/I)			//Returns an associative list of techweb node datums with values of the boost it gives.	var/list/returned = list()
	if(SSresearch.techweb_boost_items[I.type])
		return SSresearch.techweb_boost_items[I.type]		//It should already be formatted in node datum = value.

/proc/techweb_item_point_check(obj/item/I)
	if(SSresearch.techweb_point_items[I.type])
		return SSresearch.techweb_point_items[I.type]
	return 0

/*
Uncomment for debugging, -AA

/client/verb/check_techweb_validity()
	set name = "Check Techweb Validitiy"
	var/list/all_design_ids = list()
	var/list/all_techweb_products = list()

	var/list/all_web_ids = list()

	var/list/designs_without_webs = list()
	var/list/invalid_web_designs = list()

	for(var/x in subtypesof(/datum/design))
		var/datum/design/D = new x
		if(D.build_type in list(AUTOLATHE, BIOGENERATOR, SMELTER))
			continue
		all_design_ids |= D.id

	for(var/x in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/N = new x
		all_web_ids |= N.id
		for(var/id in N.design_ids)
			all_techweb_products |= id

	for(var/id in all_design_ids)
		if(!(id in all_techweb_products))
			designs_without_webs |= id

	for(var/id in all_techweb_products)
		if(!(id in all_design_ids))
			invalid_web_designs |= id

	var/output = "<h1>Designs Without Webs</h1><br><ul>"
	for(var/id in designs_without_webs)
		output += "<li>[id]</li>"

	output += "</ul><br><h1>Invalid Web Designs</h1><br><ul>"
	for(var/id in invalid_web_designs)
		output += "<li>[id]</li>"


	output += "</ul><br><h1>Invalid Web Parents</h1><br><ul>"
	for(var/x in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/N = new x
		for(var/id in N.prereq_ids)
			if(!(id in all_web_ids))
				output += "<li>[N.id] - [id]</li>"

	output += "</ul>"
	usr << browse(output, "window=uidlog")

*/
