#define MAX_BOOK_FLAGS 3	// maximum number of times a book can be flagged before being removed from results


/obj/machinery/computer/library
	name = "Library Computer"
	anchored = 1
	density = 1
	icon_keyboard = ""
	icon_screen = "computer_on"
	var/screenstate = 0
	///Page Number for going through player book archives
	var/archive_page_num = 1
	///Page number for TGUI Tabs
	var/logged_in = FALSE
	var/num_pages = 0
	var/num_results = 0
	var/datum/cachedbook/selected_book = new()
	var/datum/library_query/query = new() //	var/author var/category var/title -- holder object?

	var/static/datum/library_catalog/programmatic_books = new()
	icon = 'icons/obj/library.dmi'
	icon_state = "computer"

/obj/machinery/computer/library/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/library/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/library/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/book))
		var/obj/item/book/B = O
		selected_book.title = B.title
		selected_book.author = B.author
		selected_book.summary = B.summary
	return ..()

///TGUI SHIT, DONT NEED TO WORRY BOUT
/obj/machinery/computer/library/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "LibraryComputer", name, 1050, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/library/ui_data(mob/user)
	var/list/data = list()

	data["pagestate"] = current_page
	data["archive_pagenumber"] = archive_page_num
	data["num_pages"] = num_pages

	data["selectedbook"] = list()
	var/list/selected_book_data = list(
		title = selected_book.title ? selected_book.title : "not specified",
		author = selected_book.author ? selected_book.author : "not specified",
		summary = selected_book.summary ? selected_book.summary : "no summary",
		copyright = selected_book.copyright,
		)
	data["selectedbook"] = selected_book_data

	//should only be getting booklist when we opening up the page
	data["booklist"] = list()
	for(var/datum/cachedbook/CB in get_page(archive_page_num))
		var/list/book_data = list(
			author = CB.author,
			title = CB.title,
			category = CB.category,
			id = CB.id
		)
		data["booklist"] += list(book_data)

	//data stuff hurrr

	return data

/obj/machinery/computer/library/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("page") // Select Page
			current_page = params["page"]
		else
			return FALSE

	add_fingerprint(usr)

//Not sure what the fuck this does yet
/obj/machinery/computer/library/proc/get_page(archive_page_num)
	var/searchquery = ""
	var/where = 0
	var/list/sql_params = list() //what we're gonna send to get shit?
	if(query) //query isn't null, should never be null? Sanitization I guess...
		if(query.title && query.title != "") //query is set by the user setting the filter values
			searchquery += " WHERE title LIKE :title" //query command
			sql_params["title"] = "%[query.title]%" //defining this part of what we're gonna send using the search query we're building
			where = 1 //what the fuck is where supposed to do?
		if(query.author && query.author != "")
			searchquery += " [!where ? "WHERE" : "AND"] author LIKE :author"
			sql_params["author"] = "%[query.author]%"
			where = 1
		if(query.category && query.category != "") //this category query stuff is an actual clusterfuck |fix?|
			searchquery += " [!where ? "WHERE" : "AND"] category LIKE :cat"
			sql_params["cat"] = "%[query.category]%"
			if(query.category == "Fiction")
				searchquery += " AND category NOT LIKE '%Non-Fiction%'"
			where = 1

	// This one doesnt take player input directly, so it doesnt require params
	searchquery += " [!where ? "WHERE" : "AND"] flagged < [MAX_BOOK_FLAGS]"
	// This does though
	var/sql = "SELECT id, author, title, category, ckey, flagged FROM library [searchquery] LIMIT :lowerlimit, :upperlimit" //start at LL, find UL #
	sql_params["lowerlimit"] = text2num((archive_page_num - 1) * LIBRARY_BOOKS_PER_PAGE)
	sql_params["upperlimit"] = LIBRARY_BOOKS_PER_PAGE

	// Pagination
	var/datum/db_query/select_query = SSdbcore.NewQuery(sql, sql_params) //querying our beautiful SQL

	if(!select_query.warn_execute()) //sanity checks
		qdel(select_query)
		return

	var/list/results = list() //taking our beautiful SQL result and throwing them in our cachedbook datum object thing for later use
	while(select_query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      =select_query.item[1],
			"author"  =select_query.item[2],
			"title"   =select_query.item[3],
			"category"=select_query.item[4],
			"ckey"    =select_query.item[5],
			"flagged" =text2num(select_query.item[6])
		))
		results += CB
	qdel(select_query)
	return results

/obj/machinery/computer/library/proc/get_num_results() //how many books in the DB?
	var/sql = "SELECT COUNT(id) FROM library" //how many books we got in this damn DB?

	var/datum/db_query/count_query = SSdbcore.NewQuery(sql)
	if(!count_query.warn_execute())
		qdel(count_query)
		return

	while(count_query.NextRow())
		var/value = text2num(count_query.item[1])
		qdel(count_query)
		return value
	qdel(count_query)
	return 0

/obj/machinery/computer/library/proc/get_pagelist()
	var/pagelist = "<div class='pages'>"
	var/start = max(1, archive_page_num - 3)
	var/end = min(num_pages, archive_page_num + 3)
	for(var/i = start to end)
		var/dat = "<a href='?src=[UID()];page=[i]'>[i]</a>"
		if(i == archive_page_num)
			dat = "<font size=3><b>[dat]</b></font>"
		if(i != end)
			dat += " "
		pagelist += dat
	pagelist += "</div>"
	return pagelist

/obj/machinery/computer/library/proc/getBookByID(id as text)
	return GLOB.library_catalog.getBookByID(id)

#undef MAX_BOOK_FLAGS
