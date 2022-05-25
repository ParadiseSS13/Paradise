#define MAX_BOOK_FLAGS 3	// maximum number of times a book can be flagged before being removed from results
#define MAX_PLAYER_UPLOADS 5 //Maximum number of books that can be uploaded by a ckey
#define LIBRARY_BOOKS_PER_PAGE 25

/obj/machinery/computer/library
	name = "Library Computer"
	anchored = 1
	density = 1
	icon_keyboard = ""
	icon_screen = "computer_on"
	icon = 'icons/obj/library.dmi'
	icon_state = "computer"

	///Page Number for going through player book archives
	var/archive_page_num = 1
	var/upload_category = "Fiction"
	///Page number for TGUI Tabs
	var/logged_in = FALSE
	var/selected_report
	var/num_pages = 0
	var/num_results = 0
	var/datum/cachedbook/selected_book = new()
	var/datum/library_query/query = new()  //	var/author var/category var/title -- holder object?
	var/patron_name
	var/patron_account
	var/total_books = 0 //total inventoried books, for setting book library IDs

	var/static/list/cached_booklist = list()
	var/static/list/checkouts = list()
	var/static/list/inventory = list()
	var/static/list/forbidden
	var/checkoutperiod = 5 // In minutes

	//Search Terms

/obj/machinery/computer/library/Initialize(mapload)
	. = ..()
	if(!forbidden)
		forbidden = list(
			/obj/item/book/manual/random,
			/obj/item/book/manual/nuclear
		)
	populate_booklist()

/obj/machinery/computer/library/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/library/attack_hand(mob/user)
	if(..())
		return
	populate_booklist() //we need to build our booklist before starting to open our UI because of ASYNC or else TGUI crashes
	ui_interact(user)

/obj/machinery/computer/library/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/book))
		select_book(O)
		return
	if(istype(O, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/B = O
		B.computer = src
		to_chat(user, "Barcode Scanner Succesfully Connected to Computer")
		audible_message("[src] lets out a low, short blip.", hearing_distance = 2)
		playsound(B, 'sound/machines/terminal_select.ogg', 10, TRUE)
		return
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/ID = O
		if(ID.registered_name)
			patron_name = ID.registered_name
		else
			patron_name = null
			patron_account = null //account number should reset every scan so we don't accidently have an account number but no name
			playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
			to_chat(user, "ERROR: No name detected!")
			return //no point in continuing if the ID card has no associated name!
		playsound(src, 'sound/items/scannerbeep.ogg', 15, TRUE)
		if(ID.associated_account_number)
			patron_account = ID.associated_account_number
		else
			patron_account = null
			to_chat(user, "[src]'s screen flashes: 'WARNING! Patron without associated account number Selected'")
		return
	return ..()

/obj/machinery/computer/library/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "LibraryComputer", name, 1050, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/library/ui_data(mob/user)	//data stuff hurrr
	var/list/data = list()

	//data["loggedin"] = logged_in
	data["archive_pagenumber"] = archive_page_num
	data["num_pages"] = getmaxpages()

	data["searchcontent"] = list(
		title = query.title,
		author = query.author,
	)
	data["book_categories"] = list() //unfortunately this cannot be static data b/c of the selected variable
	for(var/c in GLOB.library_catalog.categories)
		var/datum/library_category/category = c
		var/category_info = list(
			"category_id" = category.category_id,
			"description" = category.description,
			"selected" = category.selected,
		)

		data["book_categories"] += list(category_info)
	data["selectedbook"] = list()
	var/list/selected_book_data = list(
		title = selected_book.title ? selected_book.title : "not specified",
		author = selected_book.author ? selected_book.author : "not specified",
		summary = selected_book.summary ? selected_book.summary : "no summary",
		copyright = selected_book.copyright ? selected_book.copyright : FALSE,
		)
	data["selectedbook"] = selected_book_data

	//should only be generating the cached booklist when we absolutely need to
	data["external_booklist"] = cached_booklist
	data["checkout_data"] = list()

	for(var/datum/borrowbook/b in checkouts)
		var/remaining_time = (b.duedate - world.time) / 600
		var/late = FALSE
		var/finedue = FALSE
		if(remaining_time <= 0)
			late = TRUE
			if(remaining_time <= -15)
				finedue = TRUE
		remaining_time = round(remaining_time)

		var/list/checkout_data = list(
			timeleft = remaining_time,
			islate = late,
			allow_fine = finedue,
			title = b.bookname,
			libraryid = b.libraryid,
			patron_name = b.patron_name
		)
		data["checkout_data"] += list(checkout_data)



	data["inventory_list"] = list()
	for(var/book in inventory)
		var/datum/cachedbook/CB = book
		var/list/book_data = list(
			title = CB.title  ? CB.title : "not specified",
			author = CB.author ? CB.author : "not specified",
			summary = CB.summary ? CB.summary : "no summary",
			id = PB.id,
			libraryid = PB.libraryid,
		)
		static_data["programmatic_booklist"] += list(book_data)
	// Transfer modal information if there is one
	data["selected_report"] = selected_report
	data["modal"] = ui_modal_data(src)

	return data

/obj/machinery/computer/library/ui_static_data(mob/user)
	var/list/static_data = list()

	//Report Categories will never change within a round so they don't need to sent more than once
	static_data["report_categories"] = list()
	for(var/r in GLOB.library_catalog.report_types)
		var/datum/library_category/report = r
		var/report_info = list(
			category_id = report.category_id,
			description = report.description,
		)
		static_data["report_categories"] += list(report_info)

	static_data["programmatic_booklist"] = list()
	for(var/book in GLOB.library_catalog.books)
		var/datum/programmaticbook/PB = book
		var/list/book_data = list(
			title = PB.title  ? PB.title : "not specified",
			author = PB.author ? PB.author : "Nanotrasen",
			id = PB.id,
		)
		static_data["programmatic_booklist"] += list(book_data)

	return static_data

/obj/machinery/computer/library/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(ui_act_modal(action, params))
		return

	switch(action)
		if("incrementpage") // Select Page
			archive_page_num++
			populate_booklist()
		if("incrementpagemax")
			archive_page_num = getmaxpages()
			populate_booklist()
		if("deincrementpage")
			if(archive_page_num > 1)
				archive_page_num--
				populate_booklist()
		if("deincrementpagemax")
			archive_page_num = 1
			populate_booklist()

		if("toggle_category")
			for(var/c in GLOB.library_catalog.categories)
				var/datum/library_category/category = c
				if(category.category_id == text2num(params["category_id"]))
					//you may be wondering why this is 1 & 2 and not a bool, this is because TGUI throws a hissy fit at 0 values
					if(category.selected == 2)
						category.selected = 1
					else
						category.selected = 2
					break //we don't need to keep checking after this point
		if("search")
			//search()

		if("order_external_book")
			var/datum/cachedbook/orderedbook = GLOB.library_catalog.getBookByID(params["bookid"])
			if(orderedbook)
				make_external_book(orderedbook)
		if("order_programmatic_book")
			var/datum/programmaticbook/PB = GLOB.library_catalog.getProgrammaticBookByID(params["bookid"])
			if(PB)
				make_programmatic_book(PB)
		if("set_search_parameters")
			if(params["searchtitle"])
				query.title = params["searchtitle"]
			if(params["searchauthor"])
				query.author = params["searchauthor"]
		if("edit_selected_book")
			if(params["selected_title"])
				selected_book.title = params["selected_title"]
			if(params["selected_author"])
				selected_book.author = params["selected_author"]
			if(params["selected_summary"])
				selected_book.summary = params["seleced_summary"]

		if("submitreport")
			reportbook(params["id"], params["report_type"])
		if("set_report")
			selected_report =  text2num(params["report_type"])
		if("uploadbook")
			upload_book()

	add_fingerprint(usr)

//FUCK AHHHHHHHHHHHHHHHH
/obj/machinery/computer/library/proc/ui_act_modal(action, list/params)
	. = TRUE
	var/id = params["id"] // The modal's ID
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("edit_title")
					ui_modal_input(src, id, "Please input the new title:", null, arguments, selected_book.title)
				if("edit_author")
					ui_modal_input(src, id, "Please input the new author:", null, arguments, selected_book.author)
				if("edit_summary")
					ui_modal_input(src, id, "Please input the new summary:", null, arguments, selected_book.summary)
				if("setpagenumber")
					ui_modal_input(src, id, "Please input a page number:", null, arguments, archive_page_num)
				if("expand_info")
					var/datum/programmaticbook/PB = GLOB.library_catalog.getProgrammaticBookByID(arguments["bookid"])
					if(PB)
						ui_modal_message(src, id, "", arguments = list(
							title = PB.title,
							author = PB.author,
							summary = PB.summary ? PB.summary : "No Summary Provided",
							rating = "No Rating Provided",
						))
						return //If we've succesfully opened the modal for our programmatic book, we don't need to do more logic
					var/datum/cachedbook/CB = GLOB.library_catalog.getBookByID(arguments["bookid"])
					if(CB)
						ui_modal_message(src, id, "", arguments = list(
							title = CB.title,
							author = CB.author,
							summary = CB.summary ? CB.summary : "No Summary Provided",
							rating = CB.rating ? CB.rating : "No Rating Provided",
						))
				if("report_book")
					var/datum/cachedbook/CB = GLOB.library_catalog.getBookByID(arguments["bookid"])
					ui_modal_message(src, id, "", arguments = list(
						id = CB.id,
						title = CB.title,
						ckey = CB.ckey,
					))
				else
					return FALSE
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("edit_title")
					if(!length(answer) && length(answer) <= MAX_NAME_LEN)
						return
					selected_book.title = answer
				if("edit_author")
					if(!length(answer))
						return
					selected_book.author = answer
				if("edit_summary")
					if(!length(answer))
						return
					selected_book.summary = answer
				if("setpagenumber")
					if(!length(answer))
						return
					archive_page_num = clamp(answer, 1, getmaxpages())
					populate_booklist()
				else
					return FALSE
		else
			return FALSE

/obj/machinery/computer/library/proc/serializebook(obj/item/book/B)
	var/datum/cachedbook/CB = new()
	CB.title = B.title
	CB.author = B.author
	CB.content = B.dat
	CB.summary = B.summary
	CB.rating = B.rating
	CB.copyright = B.copyright
	CB.libraryid = B.libraryid
	return CB

/obj/machinery/computer/library/proc/deserializebook(obj/item/book/B, /datum/cachedbook/CB)

/obj/machinery/computer/library/proc/select_book(obj/item/book/B)
	if(B.carved == TRUE)
		return
	selected_book.title = B.title ? B.title : "No Title"
	selected_book.author = B.author ? B.author : "No Author"
	selected_book.summary = B.summary ? B.summary : "No Summary"
	selected_book.copyright = B.copyright ? B.copyright : FALSE
	selected_book.content = B.dat

/obj/machinery/computer/library/proc/inventoryAdd(obj/item/book/B) //add book to library inventory
	for(var/datum/cachedbook/I in inventory)
		if(I.libraryid == B.libraryid)
			return FALSE
	if(!B.libraryid)
		total_books++
		B.libraryid = total_books
	var/datum/cachedbook/CB = serializebook(B)
	inventory.Add(CB)
	return TRUE

/obj/machinery/computer/library/proc/inventoryRemove(obj/item/book/B) //remove book from library inventory
	for(var/datum/cachedbook/I in inventory)
		if(I.libraryid == B.libraryid)
			inventory.Remove(I)
			return TRUE
	return FALSE

/obj/machinery/computer/library/proc/checkout(obj/item/book/B) //checkout book
	if(!B.libraryid || !patron_name) //If book isn't a library book or there isn't a selected patron: return
		return FALSE
	for(var/datum/borrowbook/O in checkouts) //is this book already checked out?
		if(O.libraryid == B.libraryid)
			return FALSE
	var/datum/borrowbook/P = new /datum/borrowbook
	P.bookname = sanitize(B.title)
	P.libraryid = B.libraryid
	P.patron_name = sanitize(patron_name)
	P.patron_account = sanitize(patron_account)
	P.getdate = world.time
	P.duedate = world.time + (checkoutperiod * 600)
	checkouts.Add(P)
	return TRUE

/obj/machinery/computer/library/proc/checkin(obj/item/book/B) //check back in a book
	if(!B.libraryid)
		return FALSE
	for(var/datum/borrowbook/O in checkouts) //is this book checked out?
		if(O.libraryid == B.libraryid)
			checkouts.Remove(O)
			return TRUE
	return FALSE

///We want to only repopulate the booklist when neccesary
/obj/machinery/computer/library/proc/populate_booklist()
	cached_booklist = list() //clear old list
	for(var/datum/cachedbook/CB in get_page(archive_page_num))
		var/list/book_data = list(
			author = CB.author,
			title = CB.title,
			category = CB.categories,
			id = CB.id
		)
		cached_booklist += list(book_data)
//flag book shit
/obj/machinery/computer/library/proc/reportbook(bookid, report_type)
	var/report_message
	if(!SSdbcore.IsConnected())
		message_admins("WARNING: a player has attempted to flag book #[bookid] as inappropriate for [report_message] but the flag was not succesfully saved to the Database. Please investigate further.")
		alert("Connection to Archive has been severed. Aborting.")
		return
	if(bookid)
		var/datum/cachedbook/B = getBookByID(bookid)
		if(B)
			GLOB.library_catalog.flag_book_by_id(usr, bookid)

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
		if(query.categories && query.categories != "") //this category query stuff is an actual clusterfuck |fix?|
			searchquery += " [!where ? "WHERE" : "AND"] category LIKE :cat"
			sql_params["cat"] = "%[query.categories]%"
			if(query.categories == "Fiction")
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

/obj/machinery/computer/library/proc/getmaxpages()
	var/book_count = get_num_results()
	var/page_count = round(book_count/LIBRARY_BOOKS_PER_PAGE)
	/*Since 'round' gets the floor value it's likely there will be 1 page more than the page count amount (almost guaranteed),
	* we double check this by reversing our math and adding one to the count in this case. */
	if((page_count * LIBRARY_BOOKS_PER_PAGE) > length(book_count))
		page_count++
	return page_count

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

/obj/machinery/computer/library/proc/upload_book()
	if(!SSdbcore.IsConnected())
		alert("Connection to Archive has been severed. Aborting.")
	else
		var/datum/db_query/query = SSdbcore.NewQuery({"
			INSERT INTO library (author, title, content, category, ckey, flagged)
			VALUES (:author, :title, :content, :category, :ckey, 0)"}, list(
				"author" = selected_book.author,
				"title" = selected_book.title,
				"content" = selected_book.content,
				"category" = upload_category,
				"ckey" = usr.ckey
			))

		if(!query.warn_execute())
			qdel(query)
			return

		qdel(query)
		log_admin("[usr.name]/[usr.key] has uploaded the book titled [selected_book.title], [length(selected_book.content)] characters in length")
		message_admins("[key_name_admin(usr)] has uploaded the book titled [selected_book.title], [length(selected_book.content)] characters in length")

/obj/machinery/computer/library/proc/make_external_book(datum/cachedbook/newbook)
	if(!newbook || !newbook.id)
		return
	var/obj/item/book/B = new(loc)
	B.name = "Book: [newbook.title]"
	B.title = newbook.title
	B.author = newbook.author
	B.summary = newbook.summary
	B.dat = newbook.content
	B.rating = newbook.rating
	B.icon_state = "book[rand(1,16)]"
	B.copyright = TRUE
	visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")

/obj/machinery/computer/library/proc/make_programmatic_book(datum/programmaticbook/newbook)
	if(!newbook || !newbook.path)
		return

	new newbook.path(loc)
	visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")

/obj/machinery/computer/library/emag_act(mob/user)
	if(density && !emagged)
		emagged = 1
		to_chat(user, "<span class='notice'>You override the library computer's printing restrictions.</span>")

#undef MAX_BOOK_FLAGS
