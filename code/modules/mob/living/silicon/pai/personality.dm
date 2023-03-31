/datum/pai_save
	/// Client that owns the pAI
	var/client/owner
	/// pAI's name
	var/pai_name
	/// pAI's description
	var/description
	/// pAI's role
	var/role
	/// pAI's OOC comments
	var/ooc_comments

/datum/pai_save/New(client/C)
	..()
	owner = C

/datum/pai_save/Destroy(force, ...)
	owner = null
	GLOB.paiController.pai_candidates -= src
	return ..()

// This proc seems useless but its used by client data loading
/datum/pai_save/proc/get_query()
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT pai_name, description, preferred_role, ooc_comments FROM pai_saves WHERE ckey=:ckey", list(
		"ckey" = owner.ckey
	))
	return query

// Loads our data up
/datum/pai_save/proc/load_data(datum/db_query/Q)
	while(Q.NextRow())
		pai_name = Q.item[1]
		description = Q.item[2]
		role = Q.item[3]
		ooc_comments = Q.item[4]

// Reload save from DB if the user edits it
/datum/pai_save/proc/reload_save()
	var/datum/db_query/Q = get_query()
	if(!Q.warn_execute())
		qdel(Q)
		return
	load_data(Q)
	qdel(Q)

// Save their save to the DB
/datum/pai_save/proc/save_to_db()
	var/datum/db_query/query = SSdbcore.NewQuery({"
		INSERT INTO pai_saves (ckey, pai_name, description, preferred_role, ooc_comments)
			VALUES (:ckey, :pai_name, :description, :preferred_role, :ooc_comments)
			ON DUPLICATE KEY UPDATE pai_name=:pai_name2, description=:description2, preferred_role=:preferred_role2, ooc_comments=:ooc_comments2
		"}, list(
		"ckey" = owner.ckey,
		"pai_name" = pai_name,
		"description" = description,
		"preferred_role" = role,
		"ooc_comments" = ooc_comments,
		"pai_name2" = pai_name,
		"description2" = description,
		"preferred_role2" = role,
		"ooc_comments2" = ooc_comments
	))

	query.warn_execute()
	qdel(query)
