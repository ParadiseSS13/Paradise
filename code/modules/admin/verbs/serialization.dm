USER_VERB(serialize_datum, R_ADMIN|R_DEBUG, "Serialize Marked Datum", \
		"Turns your marked object into a JSON string you can later use to re-create the object", \
		VERB_CATEGORY_DEBUG)
	if(!istype(client.holder.marked_datum, /atom/movable))
		to_chat(client, "The marked datum is not an atom/movable!")
		return

	var/atom/movable/AM = client.holder.marked_datum

	var/json_data = json_encode(AM.serialize())

	var/choice = alert(client, "Would you like to store this on your PC or server side?", "Storage Location", "PC", "Server", "Cancel")
	if(!choice || choice == "Cancel")
		return

	if(choice == "PC")
		to_chat(client, chat_box_examine(json_data))

	if(choice == "Server")
		// Right, get their slot names
		var/list/slots = list("--NEW--")
		var/datum/db_query/dbq = SSdbcore.NewQuery("SELECT slotname FROM json_datum_saves WHERE ckey=:ckey", list("ckey" = client.ckey))
		if(!dbq.warn_execute())
			qdel(dbq)
			return

		while(dbq.NextRow())
			slots += dbq.item[1]

		qdel(dbq)

		var/slot_choice = input(client, "Select a slot to update, or create a new one.", "Slot Selection") as null|anything in slots

		if(!slot_choice)
			return

		if(slot_choice == "--NEW--")
			// New slot, save to DB
			var/chosen_slot_name = input(client, "Name your slot", "Slot name") as null|text
			if(!chosen_slot_name || length(chosen_slot_name) == 0)
				return

			// Sanitize the name
			var/clean_name = sanitize(copytext(chosen_slot_name, 1, 32)) // 32 chars is your max

			// And save
			var/datum/db_query/dbq2 = SSdbcore.NewQuery("INSERT INTO json_datum_saves (ckey, slotname, slotjson) VALUES(:ckey, :slotname, :slotjson)", list(
				"ckey" = client.ckey,
				"slotname" = clean_name,
				"slotjson" = json_data
			))
			if(!dbq2.warn_execute())
				qdel(dbq2)
				return

			qdel(dbq2)
			to_chat(client, "Successfully saved <code>[clean_name]</code>. You can spawn it from <code>Debug > Spawn Saved JSON Datum</code>.")

		else
			// Existing slot, warn first
			var/confirmation = alert(client, "Are you sure you want to update '[slot_choice]'? This cannot be undone!", "You sure?", "Yes", "No")
			if(confirmation != "Yes")
				return

			// Now update
			var/datum/db_query/dbq2 = SSdbcore.NewQuery("UPDATE json_datum_saves SET slotjson=:slotjson WHERE slotname=:slotname AND ckey=:ckey", list(
				"slotjson" = json_data,
				"ckey" = client.ckey,
				"slotname" = slot_choice
			))
			if(!dbq2.warn_execute())
				qdel(dbq2)
				return

			qdel(dbq2)
			to_chat(client, "Successfully updated <code>[slot_choice]</code>. You can spawn it from <code>Debug > Spawn Saved JSON Datum</code>.")

USER_VERB(deserialize_json, R_SPAWN, "Deserialize JSON datum", "Creates an object from a JSON string", VERB_CATEGORY_DEBUG)
	var/json_text = input(client, "Enter the JSON code:","Text") as message|null
	if(json_text)
		json_to_object(json_text, get_turf(client.mob))
		message_admins("[key_name_admin(client)] spawned an atom from a custom JSON object.")
		log_admin("[key_name(client)] spawned an atom from a custom JSON object, JSON Text: [json_text]")

USER_VERB(spawn_json, R_SPAWN, "Spawn Saved JSON Datum", "Spawns a JSON datums saved server side", VERB_CATEGORY_DEBUG)
	// Right, get their slot names
	var/list/slots = list()
	var/datum/db_query/dbq = SSdbcore.NewQuery("SELECT slotname, id FROM json_datum_saves WHERE ckey=:ckey", list("ckey" = client.ckey))
	if(!dbq.warn_execute())
		qdel(dbq)
		return

	while(dbq.NextRow())
		slots[dbq.item[1]] += dbq.item[2]
	qdel(dbq)


	var/datum/browser/popup = new(client, "jsonspawnmenu", "JSON Spawn Menu", 400, 300)

	// Cache this to reduce proc jumps
	var/holder_uid = client.holder.UID()

	var/list/rows = list()
	rows += "<table><tr><th scope='col' width='90%'>Slot</th><th scope='col' width='10%'>Actions</th></tr>"
	for(var/slotname in slots)
		rows += "<tr><td>[slotname]</td><td><a href='byond://?src=[holder_uid];spawnjsondatum=[slots[slotname]]'>Spawn</a>&nbsp;&nbsp;<a href='byond://?src=[holder_uid];deletejsondatum=[slots[slotname]]'>Delete</a></td></tr>"

	rows += "</table>"

	popup.set_content(rows.Join(""))
	popup.open(FALSE)

