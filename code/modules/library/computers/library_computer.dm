#define MAX_BOOK_FLAGS 3	// maximum number of times a book can be flagged before being removed from results


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
	var/datum/cachedbook/selected_book
	var/datum/library_query/query  //	var/author var/category var/title -- holder object?
	var/patron_name
	var/patron_account

	var/static/list/checkouts = list()
	var/static/list/inventory = list()
	var/checkoutperiod = 5 // In minutes

	var/static/datum/library_catalog/programmatic_books = new()

/obj/machinery/computer/library/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/library/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/library/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/book))
		select_book(O)
	if(istype(O, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/B = O
		B.computer = src
		to_chat(user, "Barcode Scanner Succesfully Connected to Computer")
		audible_message("[src] lets out a low, short blip.", hearing_distance = 2)
		playsound(B, 'sound/machines/terminal_select.ogg', 10, TRUE)
	return ..()

///TGUI SHIT, DONT NEED TO WORRY BOUT
/obj/machinery/computer/library/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "LibraryComputer", name, 1050, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/library/ui_data(mob/user)
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



/*

/obj/machinery/computer/library/checkout/interact(mob/user)
	switch(screenstate)
		if(2)
			// Checked Out
			for(var/datum/borrowbook/b in checkouts)
				var/timetaken = world.time - b.getdate
				//timetaken *= 10
				timetaken /= 600
				timetaken = round(timetaken)
				var/timedue = b.duedate - world.time
				//timedue *= 10
				timedue /= 600
				if(timedue <= 0)
					timedue = "<font color=red><b>(OVERDUE)</b> [timedue]</font>"
				else
					timedue = round(timedue)

				dat += {"\"[b.bookname]\", Checked out to: [b.mobname]<BR>--- Taken: [timetaken] minutes ago, Due: in [timedue] minutes<BR>
					<A href='?src=[UID()];checkin=\ref[b]'>(Check In)</A><BR><BR>"}
			dat += "<A href='?src=[UID()];switchscreen=0'>(Return to main menu)</A><BR>"
		if(3)
			// Check Out a Book

			dat += {"<h3>Check Out a Book</h3><BR>
				Book: [src.buffer_book]
				<A href='?src=[UID()];editbook=1'>\[Edit\]</A><BR>
				Recipient: [src.buffer_mob]
				<A href='?src=[UID()];editmob=1'>\[Edit\]</A><BR>
				Checkout Date : [world.time/600]<BR>
				Due Date: [(world.time + checkoutperiod)/600]<BR>
				(Checkout Period: [checkoutperiod] minutes) (<A href='?src=[UID()];increasetime=1'>+</A>/<A href='?src=[UID()];decreasetime=1'>-</A>)
				<A href='?src=[UID()];checkout=1'>(Commit Entry)</A><BR>
				<A href='?src=[UID()];switchscreen=0'>(Return to main menu)</A><BR>"}
		if(4)
			dat += "<h3>External Archive</h3>"
			if(!SSdbcore.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font>"
			else
				num_results = src.get_num_results()
				num_pages = CEILING(num_results/LIBRARY_BOOKS_PER_PAGE, 1)
				dat += {"<ul>
					<li><A href='?src=[UID()];id=-1'>(Order book by SS<sup>13</sup>BN)</A></li>
				</ul>"}
				var/pagelist = get_pagelist()

				dat += {"<h2>Search Settings</h2><br />
					<A href='?src=[UID()];settitle=1'>Filter by Title: [query.title]</A><br />
					<A href='?src=[UID()];setcategory=1'>Filter by Category: [query.category]</A><br />
					<A href='?src=[UID()];setauthor=1'>Filter by Author: [query.author]</A><br />
					<A href='?src=[UID()];search=1'>\[Start Search\]</A><br />"}
				dat += pagelist

				dat += {"<form name='pagenum' action='?src=[UID()]' method='get'>
										<input type='hidden' name='src' value='[UID()]'>
										<input type='text' name='pagenum' value='[archive_page_num]' maxlength="5" size="5">
										<input type='submit' value='Jump To Page'>
							</form>"}

				dat += {"<table border=\"0\">
					<tr>
						<td>Author</td>
						<td>Title</td>
						<td>Category</td>
						<td>Controls</td>
					</tr>"}

				for(var/datum/cachedbook/CB in get_page(archive_page_num))
					var/author = CB.author
					var/controls =  "<A href='?src=[UID()];id=[CB.id]'>\[Order\]</A>"
					controls += {" <A href="?src=[UID()];flag=[CB.id]">\[Flag[CB.flagged ? "ged" : ""]\]</A>"}
					if(check_rights(R_ADMIN, 0, user = user))
						controls +=  " <A style='color:red' href='?src=[UID()];del=[CB.id]'>\[Delete\]</A>"
						author += " (<A style='color:red' href='?src=[UID()];delbyckey=[ckey(CB.ckey)]'>[ckey(CB.ckey)])</A>)"
					dat += {"<tr>
						<td>[author]</td>
						<td>[CB.title]</td>
						<td>[CB.category]</td>
						<td>[controls]</td>
					</tr>"}

				dat += "</table><br />[pagelist]"

			dat += "<br /><A href='?src=[UID()];switchscreen=0'>(Return to main menu)</A><BR>"
		if(5)
			dat += "<h3>Upload a New Title</h3>"
			if(!scanner)
				for(var/obj/machinery/libraryscanner/S in range(9))
					scanner = S
					break
			if(!scanner)
				dat += "<FONT color=red>No scanner found within wireless network range.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>No data found in scanner memory.</FONT><BR>"
			else

				dat += {"<TT>Data marked for upload...</TT><BR>
					<TT>Title: </TT>[scanner.cache.name]<BR>"}
				if(!scanner.cache.author)
					scanner.cache.author = "Anonymous"

				dat += {"<TT>Author: </TT><A href='?src=[UID()];uploadauthor=1'>[scanner.cache.author]</A><BR>
					<TT>Category: </TT><A href='?src=[UID()];uploadcategory=1'>[upload_category]</A><BR>
					<A href='?src=[UID()];upload=1'>\[Upload\]</A><BR>"}
			dat += "<A href='?src=[UID()];switchscreen=0'>(Return to main menu)</A><BR>"
		if(7)
			dat += "<H3>Print a Manual</H3>"
			dat += "<table>"

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
					dat += "<tr><td><A href='?src=[UID()];manual=[manualcount]'>[M.title]</A></td></tr>"
					QDEL_NULL(M)
				manualcount++
			dat += "</table>"
			dat += "<BR><A href='?src=[UID()];switchscreen=0'>(Return to main menu)</A><BR>"

		if(8)

			dat += {"<h3>Accessing Forbidden Lore Vault v 1.3</h3>
				Are you absolutely sure you want to proceed? EldritchArtifacts Inc. takes no responsibilities for loss of sanity resulting from this action.<p>
				<A href='?src=[UID()];arccheckout=1'>Yes.</A><BR>
				<A href='?src=[UID()];switchscreen=0'>No.</A><BR>"}

	var/datum/browser/B = new /datum/browser(user, "library", "Book Inventory Management")
	B.set_content(dat)
	B.open()

/obj/machinery/computer/library/checkout/Topic(href, href_list)
	if(href_list["settitle"])
		var/newtitle = input("Enter a title to search for:") as text|null
		if(newtitle)
			query.title = sanitize(newtitle)
		else
			query.title = null
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category to search for:") in (list("Any") + GLOB.library_section_names)
		if(newcategory == "Any")
			query.category = null
		else if(newcategory)
			query.category = sanitize(newcategory)
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

		screenstate = 4
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
		switch(href_list["switchscreen"])
			if("0")
				screenstate = 0
			if("1")
				screenstate = 1
			if("2")
				screenstate = 2
			if("3")
				screenstate = 3
			if("4")
				screenstate = 4
			if("5")
				screenstate = 5
			if("6")
				if(!bibledelay)

					var/obj/item/storage/bible/B = new /obj/item/storage/bible(src.loc)
					if(SSticker && ( SSticker.Bible_icon_state && SSticker.Bible_item_state) )
						B.icon_state = SSticker.Bible_icon_state
						B.item_state = SSticker.Bible_item_state
						B.name = SSticker.Bible_name
						B.deity_name = SSticker.Bible_deity_name

					bibledelay = 1
					spawn(60)
						bibledelay = 0

				else
					visible_message("<b>[src]</b>'s monitor flashes, \"Bible printer currently unavailable, please wait a moment.\"")

			if("7")
				screenstate = 7
			if("8")
				screenstate = 8
	if(href_list["arccheckout"])
		if(src.emagged)
			src.arcanecheckout = 1
		src.screenstate = 0
	if(href_list["increasetime"])
		checkoutperiod += 1
	if(href_list["decreasetime"])
		checkoutperiod -= 1
		if(checkoutperiod < 1)
			checkoutperiod = 1
	if(href_list["editbook"])
		buffer_book = copytext(sanitize(input("Enter the book's title:") as text|null),1,MAX_MESSAGE_LEN)
	if(href_list["editmob"])
		buffer_mob = copytext(sanitize(input("Enter the recipient's name:") as text|null),1,MAX_NAME_LEN)
	if(href_list["checkin"])
		var/datum/borrowbook/b = locate(href_list["checkin"])
		checkouts.Remove(b)
	if(href_list["delbook"])
		var/obj/item/book/b = locate(href_list["delbook"])
		inventory.Remove(b)
	if(href_list["uploadauthor"])
		var/newauthor = copytext(sanitize(input("Enter the author's name: ") as text|null),1,MAX_MESSAGE_LEN)
		if(newauthor && scanner)
			scanner.cache.author = newauthor
	if(href_list["uploadcategory"])
		var/newcategory = input("Choose a category: ") in list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			upload_category = newcategory
	if(href_list["upload"])

	if(href_list["id"])
		if(href_list["id"]=="-1")
			href_list["id"] = input("Enter your order:") as null|num
			if(!href_list["id"])
				return

		if(!SSdbcore.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
			return

		var/datum/cachedbook/newbook = getBookByID(href_list["id"]) // Sanitized in getBookByID
		if(!newbook)
			alert("No book found")
			return

		if(bibledelay)
			visible_message("<b>[src]</b>'s monitor flashes, \"Printer unavailable. Please allow a short time before attempting to print.\"")
		else
			bibledelay = 1
			spawn(60)
				bibledelay = 0
			make_external_book(newbook)
	if(href_list["manual"])
		if(!href_list["manual"]) return
		var/bookid = href_list["manual"]

		if(!SSdbcore.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
			return

		var/datum/cachedbook/newbook = getBookByID("M[bookid]")
		if(!newbook)
			alert("No book found")
			return

		if(bibledelay)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"Printer unavailable. Please allow a short time before attempting to print.\"")
		else
			bibledelay = 1
			spawn(60)
				bibledelay = 0
			make_external_book(newbook)

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

*/



/obj/machinery/computer/library/proc/select_book(book)
	var/obj/item/book/B = book
	selected_book.title = B.title
	selected_book.author = B.author
	selected_book.summary = B.summary
	selected_book.copyright = B.copyright

/obj/machinery/computer/library/proc/inventoryAdd(book) //add book to library inventory
	for(var/obj/item/B in inventory)
		if(B == book)
			return FALSE
	inventory.Add(src)
	return TRUE

/obj/machinery/computer/library/proc/inventoryRemove(book) //remove book from library inventory
	for(var/obj/item/B in inventory)
		if(B == book)
			inventory.Remove(src)
			return TRUE
	return FALSE

/obj/machinery/computer/library/proc/checkout(obj/item/book/B) //checkout book
	if(!B.libraryid)
		return FALSE
	for(var/datum/borrowbook/O in checkouts) //is this book already checked out?
		if(O.bookid == B.libraryid)
			return FALSE
	var/datum/borrowbook/P = new /datum/borrowbook
	P.bookname = sanitize(B.title)
	P.bookid = B.libraryid
	P.patron_name = sanitize(patron_name)
	P.patron_account = sanitize(patron_account)
	P.getdate = world.time
	P.duedate = world.time + (checkoutperiod * 600)
	checkouts.Add(P)
	return TRUE

/obj/machinery/computer/library/proc/checkin(obj/item/book/B) //check back in a book
	if(!B.libraryid)
		return FALSE
	var/datum/borrowbook/P
	for(var/datum/borrowbook/O in checkouts) //is this book checked out?
		if(O.bookid == B.libraryid)
			P = O
	if(P)
		checkouts.Remove(P)
		return TRUE
	return FALSE

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

/obj/machinery/computer/library/proc/upload_book()
	var/choice = input("Are you certain you wish to upload this title to the Archive?") in list("Confirm", "Abort")
		if(choice == "Confirm")
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
