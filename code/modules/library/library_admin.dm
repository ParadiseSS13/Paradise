#define LIBRARY_MENU_MAIN     1
#define LIBRARY_MENU_CKEY     2
#define LIBRARY_MENU_REPORTS  3

/client/proc/library_manager()
	set name = "Manage Library"
	set category = "Admin"
	set desc = "Manage Flagged Books and Perform Maintenance on the Library System"

	if(!check_rights(R_ADMIN))
		return

	var/datum/ui_module/library_manager/L = new()
	L.ui_interact(usr)

/datum/ui_module/library_manager
	name = "Library Manager"
	///Where we will store our cachedbook datums
	var/list/cached_books = list()
	///list of assoc lists detailing each invidual reports, can contain multiple reports for same book
	var/list/reports = list()

	///TGUI page we are currently on
	var/page_state = LIBRARY_MENU_MAIN
	///Ckey's books we are viewing
	var/selected_ckey

	///information for the book we are opening in browserui
	var/datum/cachedbook/view_book
	///browserui helper variable for turning pages in book
	var/view_book_page = 0

/datum/ui_module/library_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/library_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LibraryManager", name)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/library_manager/ui_data(mob/user)
	var/list/data = list()
	data["pagestate"] = page_state
	data["booklist"] = cached_books
	data["ckey"] = selected_ckey ? selected_ckey : "ERROR"
	data["reports"] = reports

	data["modal"] = ui_modal_data(src)
	return data

/datum/ui_module/library_manager/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	if(ui_act_modal(action, params))
		return

	switch(action)
		if("view_reported_books")
			reports = list()
			for(var/datum/cachedbook/CB in GLOB.library_catalog.get_flagged_books())
				for(var/datum/flagged_book/report as anything in CB.reports)
					if(!report)
						continue
					var/datum/library_category/report_category =  GLOB.library_catalog.get_report_category_by_id(report.category_id)
					var/report_info = list(
						"reporter_ckey" = report.reporter,
						"uploader_ckey" = CB.ckey,
						"id" = CB.id,
						"title" = CB.title,
						"author" = CB.author,
						"report_description" = report_category.description,
					)
					reports += list(report_info)
			page_state = LIBRARY_MENU_REPORTS
		if("delete_book")
			if(text2num(params["bookid"])) //make sure this is actually a number
				if(GLOB.library_catalog.remove_book_by_id(text2num(params["bookid"])))
					log_and_message_admins("has deleted book [params["bookid"]].")
		if("view_book")
			if(params["bookid"])
				view_book_by_id(text2num(params["bookid"]), ui.user)
		if("unflag_book")
			if(params["bookid"])
				if(GLOB.library_catalog.unflag_book_by_id(text2num(params["bookid"])))
					log_and_message_admins("has unflagged book [params["bookid"]].")
		if("return")
			page_state = LIBRARY_MENU_MAIN


/datum/ui_module/library_manager/proc/ui_act_modal(action, list/params)
	. = TRUE
	var/id = params["id"] // The modal's ID
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("specify_ssid_delete")
					ui_modal_input(src, id, "Please input a book SSID:", null, arguments)
				if("specify_ckey_search")
					ui_modal_input(src, id, "Please input a CKEY:", null, arguments)
				if("specify_ckey_delete")
					ui_modal_input(src, id, "Please input a CKEY:", null, arguments)
				else
					return FALSE
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("specify_ssid_delete")
					if(!answer || !text2num(answer))
						return
					var/confirm = tgui_alert(usr, "You are about to delete book [text2num(answer)]", "Confirm Deletion", list("Yes", "No"))
					if(confirm != "Yes")
						return //we don't need to sanitize b/c removeBookyByID uses id=:id instead of like statemetns
					if(GLOB.library_catalog.remove_book_by_id(text2num(answer)))
						log_and_message_admins("has deleted the book [text2num(answer)].")
				if("specify_ckey_search")
					if(!answer)
						return
					var/datum/library_user_data/search_terms = new()
					search_terms.search_ckey = paranoid_sanitize(answer)
					selected_ckey = paranoid_sanitize(answer)
					cached_books = list()
					for(var/datum/cachedbook/CB in GLOB.library_catalog.get_book_by_range(1, 10, search_terms))
						var/list/book_data = list(
							"id" = CB.id,
							"title" = CB.title,
							"author" = CB.author,
							"rating" = CB.rating,
							"summary" = CB.summary,
							"ckey" = CB.ckey,
							"reports" = CB.reports,
						)
						cached_books += list(book_data)
					page_state = LIBRARY_MENU_CKEY
				if("specify_ckey_delete")
					if(!answer)
						return
					var/sanitized_answer = paranoid_sanitize(answer) //the last thing we want happening is someone deleting every book with "%%"
					var/confirm //We want to be absolutely certain an admin wants to do this
					confirm = tgui_alert(usr, "You are about to mass delete potentially up to 10 books", "Confirm Deletion", list("Yes", "No"))
					if(confirm != "Yes")
						return
					if(GLOB.library_catalog.remove_books_by_ckey(sanitized_answer))
						log_and_message_admins("has deleted all books uploaded by [answer].")
				else
					return FALSE
		else
			return FALSE

/datum/ui_module/library_manager/proc/view_book_by_id(bookid, mob/user)
	if(!view_book || view_book.id != bookid)
		view_book = GLOB.library_catalog.get_book_by_id(bookid)
	view_book_page = 0
	view_book(user)

/*
* #View Book
*
* Internal proc for viewing library books as an admin. This absolutely must stay as BrowserUI even though the rest of
* the library manager is TGUI. This is because of TGUI sanitization issues.
*/
/datum/ui_module/library_manager/proc/view_book(mob/user)
	if(!view_book || !length(view_book.content))
		return

	var/dat = ""
	//First, we're going to choose/generate our header buttons for switching pages and store it in var/dat
	var/header_left = "<div style='float:left; text-align:left; width:49.9%'></div>"
	var/header_right = "<div style ='float;left; text-align:right; width:49.9%'></div>"
	if(length(view_book.content)) //No need to have page switching buttons if there's no pages
		if(view_book_page < length(view_book.content))
			header_right = "<div style='float:left; text-align:right; width:49.9%'><a href='byond://?src=[UID()];next_page=1'>Next Page</a></div><br><hr>"
		if(view_book_page)
			header_left = "<div style='float:left; text-align:left; width:49.9%'><a href='byond://?src=[UID()];prev_page=1'>Previous Page</a></div>"

	dat += header_left + header_right
	//Now we're going to display the header buttons + the current page selected, if it's page 0, we display the cover_page instead
	if(!view_book_page)
		var/cover_page = {"<center><h1>[view_book.title]</h1><br></h2>Written by: [view_book.author]</h2></center><br><hr><b>Summary:</b> [view_book.summary]"}
		user << browse("<body>[dat]<br>" + "[cover_page]", "window=book[UID()];size=400x400")
		return
	else
		user << browse("<body>[dat]<br>" + "[view_book.content[view_book_page]]", "window=book[UID()]")

/datum/ui_module/library_manager/Topic(href, href_list)
	..()
	if(!check_rights(R_ADMIN))
		log_admin("[key_name(usr)] tried to use the library manager without authorization.")
		message_admins("[key_name_admin(usr)] has attempted to override the library manager!")
		return
	if(href_list["next_page"])
		if(view_book_page > length(view_book.content)) //should never be false, but just in-case
			view_book_page = length(view_book.content)
			return
		view_book_page++
		view_book(usr)  //scuffed but this is how you update the UI
	if(href_list["prev_page"])
		if(view_book_page < 0) //should never be false, but just in-case
			view_book_page = 0
			return
		view_book_page--
		view_book(usr) //scuffed but this is how you update the UI

#undef LIBRARY_MENU_MAIN
#undef LIBRARY_MENU_CKEY
#undef LIBRARY_MENU_REPORTS
