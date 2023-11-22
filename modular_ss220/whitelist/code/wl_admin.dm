/datum/controller/subsystem/dbcore/NewQuery(sql_query, arguments, disable_replace = FALSE)
	if(GLOB.configuration.overflow.reroute_cap != 0.5)
		return ..()

	if(disable_replace)
		return ..()

	var/regex/r = regex("\\b(admin)\\b")
	sql_query = r.Replace(sql_query, "admin_wl")
	. = ..()
