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

/world/IsBanned(key, address, computer_id, type, check_ipintel, check_2fa, check_guest, log_info, check_tos)
	var/ckey = ckey(key)

	if(GLOB.configuration.overflow.reroute_cap != 0.5 || !ckey || (ckey in GLOB.configuration.overflow.overflow_whitelist))
		return ..()

	var/list/denied_entry = list("reason"="no-whitelist", "desc"="\nПричина: Вас ([key]) нет в вайтлисте этого сервера. Приобрести доступ возможно у одного из стримеров Банды за баллы канала или записаться самостоятельно с помощью команды в дискорде, доступной сабам бусти, начиная со второго тира.")
	var/datum/db_query/whitelist_query = SSdbcore.NewQuery({"
	SELECT ckey FROM ckey_whitelist WHERE ckey=:ckey AND
	is_valid=1 AND port=:port AND date_start<=NOW() AND
	(NOW()<date_end OR date_end IS NULL)
	"}, list("ckey" = ckey, "port" = "[world.port]"))

	if(!whitelist_query.warn_execute())
		qdel(whitelist_query)
		return denied_entry

	while(whitelist_query.NextRow())
		var/ckey_from_db = whitelist_query.item[1]
		GLOB.configuration.overflow.overflow_whitelist |= ckey_from_db
		qdel(whitelist_query)
		return ..()

	qdel(whitelist_query)
	return denied_entry
