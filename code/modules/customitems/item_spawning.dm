/proc/EquipCustomItems(mob/living/carbon/human/M)
	if(!establish_db_connection())
		return

	// Grab the info we want.
	var/DBQuery/query = dbcon.NewQuery("SELECT cuiPath, cuiPropAdjust, cuiJobMask, cuiDescription, cuiItemName FROM [format_table_name("customuseritems")] WHERE cuiCKey='[M.ckey]' AND (cuiRealName='[sanitizeSQL(M.real_name)]' OR cuiRealName='*')")
	query.Execute()

	while(query.NextRow())
		var/path = text2path(query.item[1])
		var/propadjust = query.item[2]
		var/jobmask = query.item[3]
		var/ok = 0
		if(jobmask != "*")
			var/list/allowed_jobs = splittext(jobmask,",")
			for(var/i = 1, i <= allowed_jobs.len, i++)
				if(istext(allowed_jobs[i]))
					allowed_jobs[i] = trim(allowed_jobs[i])
			var/alt_blocked = 0
			if(M.mind.role_alt_title)
				if(!(M.mind.role_alt_title in allowed_jobs))
					alt_blocked = 1
			if(!(M.mind.assigned_role in allowed_jobs) || alt_blocked)
				continue

		var/obj/item/Item = new path()
		var/description = query.item[4]
		var/newname = query.item[5]
		if(istype(Item,/obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/I = Item
			for(var/obj/item/weapon/card/id/C in M)
				//default settings
				I.name = "[M.real_name]'s ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
				I.registered_name = M.real_name
				I.access = C.access
				I.assignment = C.assignment
				I.blood_type = C.blood_type
				I.dna_hash = C.dna_hash
				I.fingerprint_hash = C.fingerprint_hash
				qdel(C)
				ok = M.equip_or_collect(I, slot_wear_id, 0)	//if 1, last argument deletes on fail
				break
		else if(istype(M.back, /obj/item/weapon/storage)) // Try to place it in something on the mob's back
			var/obj/item/weapon/storage/S = M.back
			if(S.contents.len < S.storage_slots)
				Item.loc = M.back
				ok = 1
				to_chat(M, "<span class='notice'>Your [Item.name] has been added to your [M.back.name].</span>")
		if(ok == 0)
			for(var/obj/item/weapon/storage/S in M.contents) // Try to place it in any item that can store stuff, on the mob.
				if(S.contents.len < S.storage_slots)
					Item.loc = S
					ok = 1
					to_chat(M, "<span class='notice'>Your [Item.name] has been added to your [S.name].</span>")
					break
		if(description)
			Item.desc = description
		if(newname)
			Item.name = newname

		if(ok == 0) // Finally, since everything else failed, place it on the ground
			Item.loc = get_turf(M.loc)

		HackProperties(Item,propadjust)
		M.regenerate_icons()

// This is hacky, but since it's difficult as fuck to make a proper parser in BYOND without killing the server, here it is. - N3X
/proc/HackProperties(var/mob/living/carbon/human/M,var/obj/item/I,var/script)
	var/list/statements = splittext(script,";")
	if(statements.len == 0)
		return
	for(var/statement in statements)
		var/list/assignmentChunks = splittext(statement,"=")
		var/varname = assignmentChunks[1]
		var/list/typeChunks=splittext(script,":")
		var/desiredType=typeChunks[1]
		switch(desiredType)
			if("string")
				var/output = typeChunks[2]
				output = replacetext(output,"{REALNAME}", M.real_name)
				output = replacetext(output,"{ROLE}",     M.mind.assigned_role)
				output = replacetext(output,"{ROLE_ALT}", "[M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role]")
				I.vars[varname]=output
			if("number")
				I.vars[varname]=text2num(typeChunks[2])
			if("icon")
				if(typeChunks.len==2)
					I.vars[varname]=new /icon(typeChunks[2])
				if(typeChunks.len==3)
					I.vars[varname]=new /icon(typeChunks[2],typeChunks[3])
