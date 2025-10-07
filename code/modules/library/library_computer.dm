///Defines how many player books appear on the player book archive TGUI tab
#define LIBRARY_BOOKS_PER_PAGE 25
///Login state for our computer, this state grants full access to functions
#define LOGIN_FULL   1
///Login state for our computer, this state grants basic access to functions
#define LOGIN_PUBLIC 2
///Wait time before printing another book, used to prevent spam
#define PRINTING_COOLDOWN (5 SECONDS)

/**
  * # Library Computer
  *
  * This is the player facing machine that handles all library functions
  *
  * This holds all procs for handling book checkins/checkout, book fines, book obj creation/modification
  * the object also holds static lists for book inventory and checkouts. NO SQL CALLS OR QUERIES ARE MADE HERE, all
  * of those are handled by the global library catalog that we will reference, and it should stay that way :)
  */
/obj/machinery/computer/library
	name = "Library Computer"
	desc = "Used by dusty librarians for their dusty books."
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null

	//We define a required access only to lock library specific actions like ordering/managing books to librarian access+
	req_one_access = list(ACCESS_LIBRARY)
	///Page Number for going through player book archives
	var/archive_page_num = 1
	///report category_id we have selected
	var/selected_report
	///Total number of pages for the parameters have set for our booklist
	var/num_pages = 0
	///total inventoried books, used for setting book library IDs
	var/total_books = 0
	///list for storing player inputs and selections, helpful for cutting down on single variable declarations
	var/datum/library_user_data/user_data = new()
	///This list temporarily stores the player books we grab from the DB in datums, we only update it when we need to for performance reasons
	var/list/cached_booklist = list()
	///Static List of borrowbook datums, used to track book checkouts acrossed the library system
	var/static/list/checkouts = list()
	///Static List of book datums to track what books the librarian has added to the library inventory
	var/static/list/inventory = list()
	///How Long a book is allowed to be checked out for
	var/checkoutperiod = 15 MINUTES
	///Wait period for printing books
	var/print_cooldown = 5 SECONDS


/obj/machinery/computer/library/Initialize(mapload)
	. = ..()
	END_OF_TICK(CALLBACK(src, PROC_REF(populate_booklist)))

/obj/machinery/computer/library/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/library/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/library/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/computer/library/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/book))
		select_book(used)
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/B = used
		if(!B.connect(src))
			playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
			to_chat(user, "<span class='warning'>ERROR: No Connection Established!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>Barcode Scanner Successfully Connected to Computer.</span>")
		audible_message("[src] lets out a low, short blip.", hearing_distance = 2)
		playsound(B, 'sound/machines/terminal_select.ogg', 10, TRUE)
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/card/id))
		var/obj/item/card/id/ID = used //at some point, this should be moved over to its own proc (select_patron()???)
		if(ID.registered_name)
			user_data.patron_name = ID.registered_name
		else
			user_data.patron_name = null
			user_data.patron_account = null //account number should reset every scan so we don't accidently have an account number but no name
			playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
			to_chat(user, "<span class='notice'>ERROR: No name detected!</span>")
			return ITEM_INTERACT_COMPLETE //no point in continuing if the ID card has no associated name!
		playsound(src, 'sound/items/scannerbeep.ogg', 15, TRUE)
		if(ID.associated_account_number)
			user_data.patron_account = ID.associated_account_number
		else
			user_data.patron_account = null
			to_chat(user, "<span class='notice'>[src]'s screen flashes: 'WARNING! Patron without associated account number Selected'</span>")
		return ITEM_INTERACT_COMPLETE

	if(default_unfasten_wrench(user, used, time = 60))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/computer/library/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/library/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LibraryComputer", name)
		ui.open()

/*
 * # UI Data for TGUI
 *
 * Hey friends, this proc is where we stuff our massive amounts of data into our data list to be sent to our TGUI
 * a few things about the library UI in specific, under no circumstance can any proc be called in ui_data that causes
 * our code to sleep or wait, this will crash our TGUI interface upon first opening. This means you cannot call any of our
 * procs that call a library_catalog proc that makes an SQL Query.
 */
/obj/machinery/computer/library/ui_data(mob/user)
	var/list/data = list()

	data["archive_pagenumber"] = archive_page_num
	data["num_pages"] = num_pages
	var/selected_categories = list()
	selected_categories = user_data.search_categories

	data["login_state"] = allowed(user)

	data["searchcontent"] = list(
		"title" = user_data.search_title,
		"author" = user_data.search_author,
		"ratingmin" = user_data.search_rating["min"],
		"ratingmax" = user_data.search_rating["max"],
		"categories" = selected_categories,
		"ckey" = user_data.search_ckey,
	)

	var/list/selected_book_data = list(
		"title" = user_data.selected_book.title ? user_data.selected_book.title : "not specified",
		"author" = user_data.selected_book.author ? user_data.selected_book.author : "not specified",
		"summary" = user_data.selected_book.summary ? user_data.selected_book.summary : "no summary",
		"copyright" = user_data.selected_book.copyright ? user_data.selected_book.copyright : FALSE,
		"categories" = user_data.selected_book.categories ? user_data.selected_book.categories : list()
	)

	data["selectedbook"] = selected_book_data

	//should only be generating the cached booklist when we absolutely need to
	data["external_booklist"] = cached_booklist
	data["checkout_data"] = list()

	for(var/datum/borrowbook/b in checkouts)
		var/remaining_time = (b.duedate - world.time) / 600
		var/late = FALSE
		if(remaining_time <= 0) //if remaining time is less than zero, you're late
			late = TRUE
		remaining_time = round(remaining_time)

		var/list/checkout_data = list(
			"timeleft" = remaining_time,
			"islate" = late,
			"title" = b.bookname,
			"libraryid" = b.libraryid,
			"patron_name" = b.patron_name
		)
		data["checkout_data"] += list(checkout_data)

	data["inventory_list"] = list()
	for(var/book in inventory)
		var/checked_out = FALSE
		var/datum/cachedbook/CB = book
		for(var/datum/borrowbook/checkout in checkouts)
			if(CB.libraryid == checkout.libraryid)
				checked_out = TRUE
				break
		var/list/book_data = list(
			"title" = CB.title  ? CB.title : "not specified",
			"author" = CB.author ? CB.author : "not specified",
			"summary" = CB.summary ? CB.summary : "no summary",
			"id" = CB.id,
			"libraryid" = CB.libraryid,
			"checked_out" = checked_out,
		)
		data["inventory_list"] += list(book_data)
	data["user_ckey"] = user?.ckey
	data["selected_report"] = selected_report
	data["selected_rating"] = user_data.selected_rating
	data["modal"] = ui_modal_data(src)

	return data

/obj/machinery/computer/library/ui_static_data(mob/user)
	var/list/static_data = list()
	//Book Categories will never change within a round so they don't need to sent more than once
	static_data["book_categories"] = list()
	for(var/datum/library_category/category in GLOB.library_catalog.categories)
		var/category_info = list(
			"category_id" = category.category_id,
			"description" = category.description,
		)
		static_data["book_categories"] += list(category_info)

	//Report Categories will never change within a round so they don't need to sent more than once
	static_data["report_categories"] = list()
	for(var/r in GLOB.library_catalog.report_types)
		var/datum/library_category/report = r
		var/report_info = list(
			"category_id" = report.category_id,
			"description" = report.description,
		)
		static_data["report_categories"] += list(report_info)

	static_data["programmatic_booklist"] = list()
	for(var/book in GLOB.library_catalog.books)
		var/datum/programmatic_book/PB = book
		var/list/book_data = list(
			"title" = PB.title  ? PB.title : "not specified",
			"author "= PB.author ? PB.author : "Nanotrasen",
			"id" = PB.id,
		)
		static_data["programmatic_booklist"] += list(book_data)

	return static_data

/obj/machinery/computer/library/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(ui_act_modal(action, params))
		return

	add_fingerprint(usr)

	switch(action)
		//Page Switching
		if("incrementpage")
			archive_page_num = clamp(archive_page_num + 1, 1, num_pages)
			populate_booklist()
		if("incrementpagemax")
			archive_page_num = num_pages
			populate_booklist()
		if("deincrementpage")
			archive_page_num = clamp(archive_page_num - 1, 1, num_pages)
			populate_booklist()
		if("deincrementpagemax")
			archive_page_num = 1
			populate_booklist()
		//Search Tools' Buttons
		if("toggle_search_category")
			var/category_id = text2num(params["category_id"])
			if(category_id in user_data.search_categories)
				user_data.search_categories -= category_id
				populate_booklist()
			else
				user_data.search_categories += category_id
				populate_booklist()
		if("clear_search")
			user_data.clear_search()
			populate_booklist()
		if("find_users_books")
			user_data.clear_search() //we need to clear out other search params first
			user_data.search_ckey = params["user_ckey"]
			populate_booklist()
		if("clear_ckey_search")
			user_data.search_ckey = null
			populate_booklist()

		//Order Buttons
		if("order_external_book")
			var/datum/cachedbook/orderedbook = GLOB.library_catalog.get_book_by_id(params["bookid"])
			if(orderedbook && print_cooldown <= world.time)
				make_external_book(orderedbook)
				print_cooldown = world.time + PRINTING_COOLDOWN
		if("order_programmatic_book")
			var/datum/programmatic_book/PB = GLOB.library_catalog.get_programmatic_book_by_id(params["bookid"])
			if(PB && print_cooldown <= world.time)
				make_programmatic_book(PB)
				print_cooldown = world.time + PRINTING_COOLDOWN
		//book author actions
		if("delete_book")
			if(params["bookid"])
				var/datum/cachedbook/selectedbook = GLOB.library_catalog.get_book_by_id(params["bookid"])
				if(!selectedbook)
					playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
					atom_say("Deletion Failed!")
					return
				if(selectedbook.ckey != params["user_ckey"])
					message_admins("[params["user_ckey"]] attempted to delete a book that wasn't theirs, this shouldn't happen, please investigate.")
					return
				if(GLOB.library_catalog.remove_book_by_id(params["bookid"])) //this doesn't need to be logged
					playsound(loc, 'sound/machines/ping.ogg', 25, 0)
					atom_say("Deletion Successful!")
					return
				playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
				atom_say("Deletion Failed!")


		//rating acts
		if("set_rating")
			if(params["rating_value"])
				user_data.selected_rating = clamp(text2num(params["rating_value"]), 0, 10)
		if("rate_book")
			if(GLOB.library_catalog.rate_book(params["user_ckey"], params["bookid"], user_data.selected_rating))
				playsound(loc, 'sound/machines/ping.ogg', 25, 0)
				atom_say("Rating Successful!")
			populate_booklist()
		//Report Acts
		if("submit_report")
			if(GLOB.library_catalog.flag_book_by_id(params["user_ckey"], params["bookid"], selected_report))
				playsound(loc, 'sound/machines/ping.ogg', 50, 0)
				atom_say("Report Submitted!")
				return
			playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
			atom_say("Report Submission Failed!")
		if("set_report")
			selected_report =  text2num(params["report_type"])
		//Book Uploader
		if("toggle_upload_category")
			if(text2num(params["category_id"]) in user_data.selected_book.categories)
				user_data.selected_book.categories -= text2num(params["category_id"])
				populate_booklist()
			else
				if(length(user_data.selected_book.categories) >= 3)
					playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
					return
				user_data.selected_book.categories += text2num(params["category_id"])
				populate_booklist()
		if("uploadbook")
			var/choice = tgui_alert(ui.user, "I have ensured that nothing in this book violates this server's game rules and want to upload it to the database.", "Confirm", list("Yes", "No"))
			if(choice != "Yes")
				return
			if(GLOB.library_catalog.upload_book(ui.user.ckey, user_data.selected_book))
				playsound(src, 'sound/machines/ping.ogg', 50, 0)
				atom_say("Book Uploaded!")
				return
			playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
			atom_say("Book Upload Failed!")
			num_pages = getmaxpages()
		if("reportlost")
			inventoryRemove(text2num(params["libraryid"]))
			for(var/datum/borrowbook/book in checkouts)
				if(book.libraryid == text2num(params["libraryid"]))
					checkouts -= book


/obj/machinery/computer/library/proc/ui_act_modal(action, list/params)
	. = TRUE
	var/id = params["id"] // The modal's ID
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("setpagenumber")
					ui_modal_input(src, id, "Please input a page number:", null, arguments, archive_page_num)
				//search inputs
				if("edit_search_title")
					ui_modal_input(src, id, "Please input the new title:", null, arguments, user_data.search_title)
				if("edit_search_author")
					ui_modal_input(src, id, "Please input the new author:", null, arguments, user_data.search_author)
				if("edit_search_ratingmax")
					ui_modal_input(src, id, "Please input the new upper rating bound:", null, arguments,  user_data.search_rating["max"])
				if("edit_search_ratingmin")
					ui_modal_input(src, id, "Please input the new lower rating bound:", null, arguments,  user_data.search_rating["min"])
				//book uploader inputs
				if("edit_selected_title")
					ui_modal_input(src, id, "Please input the new title:", null, arguments, user_data.selected_book.title)
				if("edit_selected_author")
					ui_modal_input(src, id, "Please input the new author:", null, arguments, user_data.selected_book.author)
				if("edit_selected_summary")
					ui_modal_input(src, id, "Please input the new summary:", null, arguments, user_data.selected_book.summary)
				//book list buttons
				if("expand_info")
					var/datum/programmatic_book/PB = GLOB.library_catalog.get_programmatic_book_by_id(arguments["bookid"])
					if(PB)
						ui_modal_message(src, id, "", arguments = list(
							"isProgrammatic" = TRUE,
							"title" = PB.title,
							"author" = PB.author,
							"summary" = PB.summary ? PB.summary : "No Summary Provided",
							"rating" = "N for Nanotrasen",
						))

						return //If we've succesfully opened the modal for our programmatic book, we don't need to do more logic
					var/datum/cachedbook/CB = GLOB.library_catalog.get_book_by_id(arguments["bookid"])
					if(CB)
						var/category_names = list()
						for(var/datum/library_category/category in CB.categories)
							category_names += category.description
						user_data.selected_report = null
						user_data.selected_rating = 0

						ui_modal_message(src, id, "", arguments = list(
							"isProgrammatic" = FALSE,
							"id" = CB.id,
							"ckey" = CB.ckey,
							"title" = CB.title,
							"author" = CB.author,
							"summary" = CB.summary ? CB.summary : "No Summary Provided",
							"rating" = CB.rating ? CB.rating : 0,
							"categories" = category_names,
						))
				if("report_book")
					var/datum/cachedbook/CB = GLOB.library_catalog.get_book_by_id(arguments["bookid"])
					ui_modal_message(src, id, "", arguments = list(
						id = CB.id,
						title = CB.title,
						ckey = CB.ckey,
					))
				if("rate_info")
					var/datum/cachedbook/CB = GLOB.library_catalog.get_book_by_id(arguments["bookid"])
					var/list/book_ratings = GLOB.library_catalog.get_book_ratings(arguments["bookid"])
					ui_modal_message(src, id, "", arguments = list(
						"id" = CB.id,
						"title" = CB.title,
						"author" = CB.author,
						"ckey" = CB.ckey,
						"current_rating" = length(book_ratings) ? book_ratings[1] : 0,
						"total_ratings" = length(book_ratings) ? length(book_ratings[2]) : 0,
					))
				else
					return FALSE
		if(UI_MODAL_ANSWER)
			var/answer = sanitize(params["answer"]) //xss attacks bad
			switch(id)
				if("edit_search_title")
					if(!length(answer))
						user_data.search_title = null
						populate_booklist()
						return
					if(length(answer) >= MAX_NAME_LEN)
						return
					user_data.search_title = answer
					populate_booklist()
				if("edit_search_author")
					if(!length(answer))
						user_data.search_author = null
						populate_booklist()
						return
					if(length(answer) >= MAX_NAME_LEN)
						return
					user_data.search_author = answer
					populate_booklist()
				if("edit_search_ratingmax")
					if(!text2num(answer))
						return
					user_data.search_rating["max"] = clamp(text2num(answer), user_data.search_rating["min"], 10)
					populate_booklist()
				if("edit_search_ratingmin")
					if(isnull(text2num(answer)))
						return
					user_data.search_rating["min"] = clamp(text2num(answer), 0, user_data.search_rating["max"])
					populate_booklist()
				if("edit_selected_title")
					if(length(answer) >= MAX_NAME_LEN)
						return
					user_data.selected_book.title = answer
				if("edit_selected_author")
					if(length(answer) >= MAX_NAME_LEN)
						return
					user_data.selected_book.author = answer
				if("edit_selected_summary")
					if(length(answer) >= MAX_SUMMARY_LEN)
						return
					user_data.selected_book.summary = answer
				if("setpagenumber")
					if(!text2num(answer))
						return
					populate_booklist()
					archive_page_num = clamp(text2num(answer), 1, getmaxpages())
				else
					return FALSE
		else
			return FALSE

/obj/machinery/computer/library/proc/select_book(obj/item/book/B)
	if(B.carved)
		return
	user_data.selected_book.title = B.title ? B.title : "No Title"
	user_data.selected_book.author = B.author ? B.author : "No Author"
	user_data.selected_book.summary = B.summary ? B.summary : "No Summary"
	user_data.selected_book.copyright = B.copyright ? B.copyright : FALSE
	user_data.selected_book.content = B.pages ? B.pages : list()
	user_data.selected_book.categories = B.categories ? B.categories : list()

/obj/machinery/computer/library/proc/inventoryAdd(obj/item/book/B) //add book to library inventory
	for(var/datum/cachedbook/I in inventory)
		if(I.libraryid == B.libraryid)
			return FALSE
	if(!B.libraryid)
		total_books++
		B.libraryid = total_books
	var/datum/cachedbook/CB = new()
	CB.serialize_book(B)
	if(!CB)
		return
	inventory.Add(CB)
	return TRUE

/obj/machinery/computer/library/proc/inventoryRemove(libraryID) //remove book from library inventory
	for(var/datum/cachedbook/O in inventory)
		if(O.libraryid == libraryID)
			inventory.Remove(O)
			return TRUE
	return FALSE

/obj/machinery/computer/library/proc/checkout(obj/item/book/B) //checkout book
	if(!B.libraryid || !user_data.patron_name) //If book isn't a library book or there isn't a selected patron: return
		return FALSE
	for(var/datum/borrowbook/O in checkouts) //is this book already checked out?
		if(O.libraryid == B.libraryid)
			return FALSE
	var/datum/borrowbook/P = new /datum/borrowbook
	P.bookname = sanitize(B.title)
	P.libraryid = B.libraryid
	P.patron_name = sanitize(user_data.patron_name)
	P.patron_account = sanitize(user_data.patron_account)
	P.duedate = world.time + (checkoutperiod)
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

/*
  * # populate_booklist
  *
  * internal proc that will refresh our cached booklist, it needs to be called everytime we are switching parameters
  * that will affect what books will be displayed in our TGUI player book archive.
 */
/obj/machinery/computer/library/proc/populate_booklist()
	cached_booklist = list() //clear old list
	var/starting_book = (archive_page_num - 1) * LIBRARY_BOOKS_PER_PAGE
	var/range = LIBRARY_BOOKS_PER_PAGE
	for(var/datum/cachedbook/CB in GLOB.library_catalog.get_book_by_range(starting_book, range, user_data))
		//instead of just adding the datum to the cached_booklist, we want to make it an assoc list so we can just give it to the TGUI

		var/list/book_data = list(
			"id" = CB.id,
			"title" = CB.title,
			"author" = CB.author,
			"rating" = CB.rating,
			"summary" = CB.summary,
			"ckey" = CB.ckey,
			"reports" = CB.reports,
		)
		book_data["categories"] = list()
		for(var/category in CB.categories)
			var/datum/library_category/book_category = GLOB.library_catalog.get_book_category_by_id(category)
			if(book_category)
				book_data["categories"] += book_category.description //we're displaying the cats onlys, so we don't need the ids

		cached_booklist += list(book_data)
	num_pages = getmaxpages()
	archive_page_num = clamp(archive_page_num, 1, num_pages)

///Returns the amount of pages we will need to hold all the book our DB has found
/obj/machinery/computer/library/proc/getmaxpages()
	//if get_total_books doesn't return anything, just set pages to 1 so we don't break stuff
	var/book_count = max(1, GLOB.library_catalog.get_total_books(user_data))
	var/page_count = round(book_count / LIBRARY_BOOKS_PER_PAGE)
	//Since 'round' gets the floor value it's likely there will be 1 page more than
	//the page count amount (almost guaranteed), we check for a remainder because of this
	if(book_count % LIBRARY_BOOKS_PER_PAGE)
		page_count++
	return page_count

/obj/machinery/computer/library/proc/make_external_book(datum/cachedbook/newbook)
	if(!newbook?.id)
		return
	new /obj/item/book(loc, newbook, TRUE, FALSE)
	visible_message("<span class='notice'>[src]'s printer hums as it produces a completely bound book. How did it do that?</span>")

/obj/machinery/computer/library/proc/make_programmatic_book(datum/programmatic_book/newbook)
	if(!newbook?.book_type)
		return

	new newbook.book_type(loc)
	visible_message("<span class='notice'>[src]'s printer hums as it produces a completely bound book. How did it do that?</span>")

/obj/machinery/computer/library/emag_act(mob/user)
	if(print_cooldown <= world.time)
		new /obj/item/storage/bible/syndi(loc)
		visible_message("<span class='notice'>[src]'s printer ominously hums as it produces a completely bound book. How did it do that?</span>")
		print_cooldown = world.time + PRINTING_COOLDOWN
		return TRUE

/obj/machinery/computer/library/syndie
	req_one_access = list(ACCESS_SYNDICATE)

#undef LIBRARY_BOOKS_PER_PAGE
#undef LOGIN_FULL
#undef LOGIN_PUBLIC
#undef PRINTING_COOLDOWN
