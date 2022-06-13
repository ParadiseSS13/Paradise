GLOBAL_VAR_INIT(enable_sync, FALSE)

/*
* Returns a byond list that can be passed to the "deserialize" proc
* to bring a new instance of this atom to its original state
*
* If we want to store this info, we can pass it to `json_encode` or some other
* interface that suits our fancy, to make it into an easily-handled string
*/
/datum/proc/serialize()
	var/data = list("type" = "[type]")
	return data

/*
* This is given the byond list from above, to bring this atom to the state
* described in the list.
* This will be called after `New` but before `initialize`, so linking and stuff
* would probably be handled in `initialize`
*
* Also, this should only be called by `list_to_object` in persistence.dm - at least
* with current plans - that way it can actually initialize the type from the list
*/
/datum/proc/deserialize(list/data)
	return

/atom
	// This var isn't actually used for anything, but is present so that
	// DM's map reader doesn't forfeit on reading a JSON-serialized map
	var/map_json_data
	var/synced = FALSE

// This is so specific atoms can override these, and ignore certain ones
/atom/proc/vars_to_save()
 	return list("color","dir","icon_state","name","pixel_x","pixel_y") //

/atom/proc/map_important_vars()
	// A list of important things to save in the map editor
 	return list("color","dir","icon_state","layer","name","pixel_x","pixel_y") //

/area/map_important_vars()
	// Keep the area default icons, to keep things nice and legible
	return list("name")

// No need to save any state of an area by default
/area/vars_to_save()
	return list("name", "lightswitch", "power_equip", "power_light", "power_environ")

/atom/serialize()
	var/list/data = ..()
	for(var/thing in vars_to_save())
		data[thing] = vars[thing] // Can't check initial() because it doesn't work on a list index
	return data


/atom/deserialize(list/data)
	for(var/thing in vars_to_save())
		if(thing in data)
			vars[thing] = data[thing]
	..()

/*
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0
	var/sleeping_agent = 0
	var/agent_b = 0
	var/temperature = 0 //in Kelvin
*/

/datum/gas_mixture/proc/vars_to_save()
 	return list("oxygen","carbon_dioxide","nitrogen","toxins","sleeping_agent","agent_b","temperature")

/datum/gas_mixture/serialize()
	var/list/data = ..()
	for(var/thing in vars_to_save())
		data[thing] = vars[thing] // Can't check initial() because it doesn't work on a list index
	return data

/datum/gas_mixture/deserialize(list/data)
	for(var/thing in vars_to_save())
		if(thing in data)
			vars[thing] = data[thing]
	..()

/atom
	var/db_uid = -1
	var/db_dirty = FALSE

/atom/proc/check_for_sync()
	if (!GLOB.enable_sync || !synced)
		return

	if (!isturf(loc))
		var/atom/A = loc
		del_from_db()
		try
			while(!isturf(A.loc))
				A = A.loc
			if (istype(A, /obj))
				var/obj/O = A
				if (O && O.db_uid > 0)
					O.check_for_sync()
		catch
			return
		return
	if (db_dirty)
		return

	//to_chat(world, "DB >> registered [type] for sync")
	LAZYADD(GLOB.changed_objects, src)
	db_dirty = TRUE


/obj/proc/serialize_contents()
	var/list/content_list = list()
	for(var/thing in contents)
		var/atom/movable/AM = thing
		content_list.len++
		content_list[content_list.len] = AM.serialize()
	return content_list

/obj/proc/deserialize_contents(list/content_data)
	// clear existing
	for(var/thing in contents)
		qdel(thing)
	// deserialize list
	for(var/thing in content_data)
		if(islist(thing))
			list_to_object(thing, src)
		else if(thing == null)
			log_runtime(EXCEPTION("Null entry found in storage/deserialize."), src)
		else
			log_runtime(EXCEPTION("Non-list thing found in storage/deserialize."), src, list("Thing: [thing]"))

/atom/proc/sync_to_db()
	if (!GLOB.enable_sync || !synced)
		return

	try
		if (!isturf(loc) || (x == 0 && y == 0 && z == 0))
			return

		var/datum/db_query/query = null
		var/data = sanitizeSQL("[json_encode(serialize())]")

		if (!data)
			return

		if (db_uid <= 0)
			to_chat(world, "DB >> new obj [type]")
			query = SSdbcore.NewQuery({"
				INSERT INTO rs_world_objects (
					data,
					x,y,z)
				VALUES (
					'[data]',
					[x],[y],[z])
			"})
			query.Execute()
			db_uid = text2num(query.last_insert_id)
			qdel(query)
		else
			// update in database
			//to_chat(world, "DB >> update obj [type] as [db_uid]")
			query = SSdbcore.NewQuery({"
				UPDATE rs_world_objects
				SET
					data = '[data]',
					x = [x],
					y = [y],
					z = [z]
				WHERE
					uid = [db_uid]
				"})
			query.Execute()
			qdel(query)
		db_dirty = FALSE

	catch
		del_from_db()
		return

/atom/proc/del_from_db()
	if(db_uid > 0)
		db_delete("rs_world_objects", "uid = [db_uid]")
		db_uid = -1

/mob/serialize()
	var/list/data = ..()
	data["ckey"] = ckey
	return data

/mob/deserialize(list/data)
	ckey = data["ckey"]
	..()

/turf/del_from_db()
	db_uid = -1
	return

/turf/check_for_sync()
	if (!GLOB.enable_sync)
		return

	//to_chat(world, "DB >> check [type] for sync")
	if (LAZYIN(GLOB.changed_objects, src))
		//to_chat(world, "DB >> skipping [type] for sync as registered")
		return

	//to_chat(world, "DB >> registered [type] for sync")
	LAZYADD(GLOB.changed_objects, src)


/turf/sync_to_db()
	if (!GLOB.enable_sync)
		return

	try
		var/data = json_encode(serialize())
		if (!data) return

		to_chat(world, "DB >> new turf [type] at [x],[y],[z]")
		var/datum/db_query/save_turf = SSdbcore.NewQuery({"
				REPLACE INTO rs_world_turfs (
					x,y,z,
					data
				)
				VALUES (
					[x],[y],[z],
					'[data]'
				)"})
		save_turf.Execute()
		qdel(save_turf)
		db_dirty = FALSE
		db_saved = TRUE
	catch
		return

/turf/simulated/sync_to_db()
	if (!air)
		..()
		return

	if (!GLOB.enable_sync)
		return

	try
		var/data = json_encode(serialize())
		if (!data) return

		to_chat(world, "DB >> new sim turf [type] at [x],[y],[z]")
		var/datum/db_query/save_turf = SSdbcore.NewQuery({"
				REPLACE INTO rs_world_turfs (
					x,y,z,
					data,
					air
				)
				VALUES (
					[x],[y],[z],
					'[json_encode(serialize())]',
					'[json_encode(air.serialize())]'
				)"})
		save_turf.Execute()
		qdel(save_turf)
		db_dirty = FALSE
		db_saved = TRUE
	catch
		return

/turf/simulated/proc/sync_air_to_db()
	if (!db_saved)
		return FALSE
	var/datum/db_query/query = SSdbcore.NewQuery({"
		UPDATE rs_world_turfs SET
			air = '[json_encode(air.serialize())]'
		WHERE
			x = [x] AND
			y = [y] AND
			z = [z]

	"})
	query.Execute()
	qdel(query)
	return TRUE


/datum/gas_mixture/deserialize(list/data)
	for(var/thing in vars_to_save())
		if(thing in data)
			vars[thing] = data[thing]
	..()
/*
Whoops, forgot to put documentation here.
What this does, is take a JSON string produced by running
BYOND's native `json_encode` on a list from `serialize` above, and
turns that string into a new instance of that object.

You can also easily get an instance of this string by calling "Serialize Marked Datum"
in the "Debug" tab.

If you're clever, you can do neat things with SDQL and this, though be careful -
some objects, like humans, are dependent that certain extra things are defined
in their list
*/
/proc/json_to_object(json_data, loc)
	var/data = json_decode(json_data)
	return list_to_object(data, loc)

/proc/list_to_object(list/data, loc)
	if (!data)
		return null
	if(!islist(data))
		throw EXCEPTION("You didn't give me a list, bucko")
	if(!("type" in data))
		throw EXCEPTION("No 'type' field in the data")
	var/path = text2path(data["type"])
	if(!path)
		throw EXCEPTION("Path not found: [path]")

	var/atom/movable/thing = new path(loc)
	thing.deserialize(data)
	return thing

/proc/list_to_datum(list/data)
	if (!data)
		return null
	if(!islist(data))
		throw EXCEPTION("You didn't give me a list, bucko")
	if(!("type" in data))
		throw EXCEPTION("No 'type' field in the data")
	var/path = text2path(data["type"])
	if(!path)
		throw EXCEPTION("Path not found: [path]")

	var/datum/D = new path()
	D.deserialize(data)
	return D
