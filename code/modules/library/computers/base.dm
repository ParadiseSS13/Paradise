#define MAX_BOOK_FLAGS	3	// maximum number of times a book can be flagged before being removed from results

/obj/machinery/computer/library
	name = "visitor computer"
	anchored = 1
	density = 1
	icon_keyboard = ""
	icon_screen = "computer_on"
	var/screenstate = 0
	var/page_num = 1
	var/num_pages = 0
	var/num_results = 0
	var/datum/library_query/query = new()

	icon = 'icons/obj/library.dmi'
	icon_state = "computer"

/obj/machinery/computer/library/proc/interact_check(var/mob/user)
	if(stat & (BROKEN | NOPOWER))
		return 1

	if(!Adjacent(user))
		if(!issilicon(user) && !isobserver(user))
			user.unset_machine()
			user << browse(null, "window=library")
			return 1

	user.set_machine(src)
	return 0

/obj/machinery/computer/library/proc/get_page(var/page_num)
	var/searchquery = ""
	var/where = 0
	if(query)
		if(query.title && query.title != "")
			searchquery += " WHERE title LIKE '%[sanitizeSQL(query.title)]%'"
			where = 1
		if(query.author && query.author != "")
			searchquery += " [!where ? "WHERE" : "AND"] author LIKE '%[sanitizeSQL(query.author)]%'"
			where = 1
		if(query.category && query.category != "")
			searchquery += " [!where ? "WHERE" : "AND"] category LIKE '%[sanitizeSQL(query.category)]%'"
			if(query.category == "Fiction")
				searchquery += " AND category NOT LIKE '%Non-Fiction%'"
			where = 1
	searchquery += " [!where ? "WHERE" : "AND"] flagged < [MAX_BOOK_FLAGS]"
	var/sql = "SELECT id, author, title, category, ckey, flagged FROM [format_table_name("library")] [searchquery] LIMIT [(page_num - 1) * LIBRARY_BOOKS_PER_PAGE], [LIBRARY_BOOKS_PER_PAGE]"

	// Pagination
	var/DBQuery/_query = dbcon.NewQuery(sql)
	_query.Execute()
	if(_query.ErrorMsg())
		log_to_dd(_query.ErrorMsg())

	var/list/results = list()
	while(_query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      =_query.item[1],
			"author"  =_query.item[2],
			"title"   =_query.item[3],
			"category"=_query.item[4],
			"ckey"    =_query.item[5],
			"flagged" =text2num(_query.item[6])
		))
		results += CB
	return results

/obj/machinery/computer/library/proc/get_num_results()
	var/sql = "SELECT COUNT(*) FROM [format_table_name("library")]"

	var/DBQuery/_query = dbcon.NewQuery(sql)
	_query.Execute()
	while(_query.NextRow())
		return text2num(_query.item[1])
	return 0

/obj/machinery/computer/library/proc/get_pagelist()
	var/pagelist = "<div class='pages'>"
	var/start = max(1, page_num - 3)
	var/end = min(num_pages, page_num + 3)
	for(var/i = start to end)
		var/dat = "<a href='?src=[UID()];page=[i]'>[i]</a>"
		if(i == page_num)
			dat = "<font size=3><b>[dat]</b></font>"
		if(i != end)
			dat += " "
		pagelist += dat
	pagelist += "</div>"
	return pagelist

/obj/machinery/computer/library/proc/getBookByID(var/id as text)
	return library_catalog.getBookByID(id)