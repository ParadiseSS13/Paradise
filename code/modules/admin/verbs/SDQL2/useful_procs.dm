// This one's for you, SDQL fans

// Give this a string and a location to create the object. Examples of using
// this function:
/*
CALL global.json_to_object_arbitrary_vars("{'type':'/obj/item/crowbar', 'color':'#FF0000','force':5000,'name':'Greytides Gravedigger'}", loc) ON /mob/living/carbon/human WHERE ckey == 'crazylemon'".
*/
// This is a bit more flexible than the serialization interface because that interface
// expects a rigid structure for the data
/proc/json_to_object_arbitrary_vars(json_data, position)
	var/data = json_decode(json_data)
	return list_to_object_arbitrary_vars(data, position)


/proc/list_to_object_arbitrary_vars(list/data, position)
	if(!islist(data))
		throw EXCEPTION("Not a list.")
	if(!("type" in data))
		throw EXCEPTION("No 'type' field in the data")
	var/path = text2path(data["type"])
	if(!path)
		throw EXCEPTION("Path not found: [path]")

	var/atom/movable/thing = new path(position)
	data -= "type"
	for(var/attribute in data)
		thing.vars[attribute] = data[attribute]

	return thing
