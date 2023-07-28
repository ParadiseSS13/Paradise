/proc/load_whitelist()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounce("Whitelist reload blocked: Advanced ProcCall detected"))
		return

	if(!GLOB.configuration.overflow.reroute_cap || !SSdbcore.IsConnected())
		return

	var/datum/db_query/whitelist_query = SSdbcore.NewQuery({"
	SELECT ckey FROM ckey_whitelist WHERE
	is_valid=1 AND port=:port AND date_start<=NOW() AND
	(NOW()<date_end OR date_end IS NULL)
	"}, list("port" = "[world.port]"))
	if(!whitelist_query.warn_execute())
		qdel(whitelist_query)
		return

	while(whitelist_query.NextRow())
		var/ckey = whitelist_query.item[1]
		GLOB.configuration.overflow.overflow_whitelist |= ckey

	qdel(whitelist_query)

/client/proc/update_whitelist()
	set name = "Update whitelist"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	load_whitelist()

/mob/new_player/proc/check_whitelist()
	if(!GLOB.configuration.overflow.reroute_cap || !SSdbcore.IsConnected())
		return
	var/datum/db_query/whitelist_query = SSdbcore.NewQuery({"
	SELECT ckey FROM ckey_whitelist WHERE ckey=:ckey AND
	is_valid=1 AND port=:port AND date_start<=NOW() AND
	(NOW()<date_end OR date_end IS NULL)
	"}, list("ckey" = ckey, "port" = "[world.port]"))
	if(!whitelist_query.warn_execute())
		qdel(whitelist_query)
		return

	while(whitelist_query.NextRow())
		var/ckey = whitelist_query.item[1]
		GLOB.configuration.overflow.overflow_whitelist |= ckey

	qdel(whitelist_query)


/mob/new_player/Login()
	if(!(ckey in GLOB.configuration.overflow.overflow_whitelist))
		check_whitelist()
	. = ..()
