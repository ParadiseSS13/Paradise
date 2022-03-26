#define MAX_BOOK_FLAGS 3	// maximum number of times a book can be flagged before being removed from results
#define MAX_PLAYER_UPLOADS 5 //Maximum number of books that can be uploaded by a ckey

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
	var/num_pages = 0
	var/num_results = 0
	var/datum/cachedbook/selected_book = new()
	var/datum/library_query/query = new()  //	var/author var/category var/title -- holder object?
	var/patron_name
	var/patron_account
	var/total_books = 0 //total inventoried books, for setting book library IDs

	var/static/list/checkouts = list()
	var/static/list/inventory = list()
	var/checkoutperiod = 5 // In minutes

	var/static/list/category_choices

	var/static/datum/library_catalog/programmatic_books = new()

/obj/machinery/computer/library/Initialize(mapload)
	. = ..()
	if(!category_choices)
		category_choices = list() //need to populate this lol

/obj/machinery/computer/library/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/library/attack_hand(mob/user)
	if(..())
		return
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

///TGUI SHIT, DONT NEED TO WORRY BOUT
/obj/machinery/computer/library/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "LibraryComputer", name, 1050, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/library/ui_data(mob/user)	//data stuff hurrr
	var/list/data = list()

	data["loggedin"] = logged_in
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
			category = CB.categories,
			id = CB.id
		)
		data["booklist"] += list(book_data)

	data["checkout_data"] = list()

	for(var/datum/borrowbook/b in checkouts)
		var/remaining_time = (b.duedate - world.time) / 600
		var/late = "false"
		var/finedue = "false"
		if(remaining_time <= 0)
			late = "true"
			if(remaining_time <= -15)
				finedue = "true"
		remaining_time = round(remaining_time)

		var/list/checkout_data = list(
			timeleft = remaining_time,
			islate = late,
			title = b.bookname,
			libraryid = b.libraryid,
			patron_name = b.patron_name,
			allow_fine = finedue
		)
		data["checkout_data"] += list(checkout_data)

	// Transfer modal information if there is one
	data["modal"] = ui_modal_data(src)

	return data

/obj/machinery/computer/library/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	if(ui_act_modal(action, params, ui, state))
		return TRUE

	switch(action)
		if("incrementpage") // Select Page
			archive_page_num++
		else if("deincrementpage")
			archive_page_num--
		else if("search")
			//search()
		else if("orderbook")
			make_external_book(params["id"])
		else if("set_search_parameters")
			if(params["searchtitle"])
				query.title = params["searchtitle"]
			else if(params["searchauthor"])
				query.author = params["searchauthor"]
			else if(params["searchcategories"])
			//stuff
			else if(params["searchrating"])
			//stuff
		else if("edit_selected_book")
			else if(params["selected_title"])
				selected_book.title = params["selected_title"]
			else if(params["selected_author"])
				selected_book.author = params["selected_author"]
			else if(params["selected_summary"])
				selected_book.summary =["selected_summary"]
		else if("reportbook")
			flagbook(params["id"])
		else if("uploadbook")
			upload_book()
		else
			return FALSE

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
				else
					return FALSE
		else
			return FALSE


/obj/machinery/computer/library/checkout/interact(mob/user)
	var/list/forbidden = list(
		/obj/item/book/manual/random
	)

	if(!emagged)
		forbidden |= /obj/item/book/manual/nuclear

	var/manualcount = 1
	var/obj/item/book/manual/M = null

	for(var/manual_type in subtypesof(/obj/item/book/manual))
		if(!(manual_type in forbidden))
			M = new manual_type()
			QDEL_NULL(M)
		manualcount++

/obj/machinery/computer/library/checkout/Topic(href, href_list)
	if(href_list["settitle"])
		var/newtitle = input("Enter a title to search for:") as text|null
		if(newtitle)
			query.title = sanitize(newtitle)
		else
			query.title = null
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category to search for:") in (category_choices)
		if(newcategory == "Any")
			query.categories = null
		else if(newcategory)
			query.categories = sanitize(newcategory)
	if(href_list["setauthor"])
		var/newauthor = input("Enter an author to search for:") as text|null
		if(newauthor)
			query.author = sanitize(newauthor)
		else
			query.author = null

	if(href_list["search"])
		num_results = src.get_num_results()
		num_pages = CEILING(num_results/LIBRARY_BOOKS_PER_PAGE, 1)
		archive_page_num = 1
	if(href_list["del"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/cachedbook/target = getBookByID(href_list["del"]) // Sanitized in getBookByID
		var/ans = alert(usr, "Are you sure you wish to delete \"[target.title]\", by [target.author]? This cannot be undone.", "Library System", "Yes", "No")
		if(ans=="Yes")
			var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM library WHERE id=:id", list(
				"id" = text2num(target.id)
			))
			if(!query.warn_execute())
				qdel(query)
				return
			qdel(query)
			log_admin("LIBRARY: [key_name(usr)] has deleted \"[target.title]\", by [target.author] ([target.ckey])!")
			message_admins("[key_name_admin(usr)] has deleted \"[target.title]\", by [target.author] ([target.ckey])!")
			src.updateUsrDialog()
			return

	if(href_list["delbyckey"])
		if(!check_rights(R_ADMIN))
			return
		var/tckey = ckey(href_list["delbyckey"])
		var/ans = alert(usr,"Are you sure you wish to delete all books by [tckey]? This cannot be undone.", "Library System", "Yes", "No")
		if(ans=="Yes")
			var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM library WHERE ckey=:ckey", list(
				"ckey" = tckey
			))
			if(!query.warn_execute())
				qdel(query)
				return

			if(query.affected == 0)
				to_chat(usr, "<span class='danger'>Unable to find any matching rows.</span>")
				qdel(query)
				return
			qdel(query)
			log_admin("LIBRARY: [key_name(usr)] has deleted [query.affected] books written by [tckey]!")
			message_admins("[key_name_admin(usr)] has deleted [query.affected] books written by [tckey]!")
			src.updateUsrDialog()
			return

	if(href_list["flag"])
		if(!SSdbcore.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
			return
		var/id = href_list["flag"]
		if(id)
			var/datum/cachedbook/B = getBookByID(id)
			if(B)
				if((input(usr, "Are you sure you want to flag [B.title] as having inappropriate content?", "Flag Book #[B.id]") in list("Yes", "No")) == "Yes")
					GLOB.library_catalog.flag_book_by_id(usr, id)

	if(href_list["switchscreen"])
		var/obj/item/storage/bible/B = new /obj/item/storage/bible(src.loc)
		if(SSticker && ( SSticker.Bible_icon_state && SSticker.Bible_item_state) )
			B.icon_state = SSticker.Bible_icon_state
			B.item_state = SSticker.Bible_item_state
			B.name = SSticker.Bible_name
			B.deity_name = SSticker.Bible_deity_name
		else
			visible_message("<b>[src]</b>'s monitor flashes, \"Bible printer currently unavailable, please wait a moment.\"")
	var/tempvar
	if(href_list["editbook"])
		tempvar = copytext(sanitize(input("Enter the book's title:") as text|null),1,MAX_MESSAGE_LEN)
	if(href_list["uploadcategory"])
		var/newcategory = input("Choose a category: ") in list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			upload_category = newcategory
	return

///////////////////////////////////////////////////

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

/obj/machinery/computer/library/proc/flagbook(bookid, report_reason)
	if(!SSdbcore.IsConnected())
		alert("Connection to Archive has been severed. Aborting.")
		return
	if(bookid)
		var/datum/cachedbook/B = getBookByID(bookid)
		if(B)
			if((input(usr, "Are you sure you want to flag [B.title] for the reason: [report_reason]?", "Flag Book #[B.id]") in list("Yes", "No")) == "Yes")
				GLOB.library_catalog.flag_book_by_id(usr, bookid, report_reason)


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
	var/obj/item/book/B = new newbook.path(loc)

	if(!newbook.programmatic)
		B.name = "Book: [newbook.title]"
		B.title = newbook.title
		B.author = newbook.author
		B.dat = newbook.content
		B.icon_state = "book[rand(1,16)]"
		B.copyright = TRUE
	visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")


/obj/machinery/computer/library/checkout/emag_act(mob/user)
	if(density && !emagged)
		emagged = 1
		to_chat(user, "<span class='notice'>You override the library computer's printing restrictions.</span>")

#undef MAX_BOOK_FLAGS
