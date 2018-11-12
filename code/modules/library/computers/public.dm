/obj/machinery/computer/library/public
	name = "visitor computer"

/obj/machinery/computer/library/public/attack_hand(var/mob/user as mob)
	if(..())
		return
	interact(user)

/obj/machinery/computer/library/public/attackby(obj/item/W as obj, mob/user as mob)
	if(default_unfasten_wrench(user, W))
		power_change()
		return

/obj/machinery/computer/library/public/interact(var/mob/user)
	if(interact_check(user))
		return

	var/dat = ""
	switch(screenstate)
		if(0)

			dat += {"<h2>Search Settings</h2><br />
				<A href='?src=[UID()];settitle=1'>Filter by Title: [query.title]</A><br />
				<A href='?src=[UID()];setcategory=1'>Filter by Category: [query.category]</A><br />
				<A href='?src=[UID()];setauthor=1'>Filter by Author: [query.author]</A><br />
				<A href='?src=[UID()];search=1'>\[Start Search\]</A><br />"}
		if(1)
			establish_db_connection()
			if(!dbcon.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font><br />"
			else if(num_results == 0)
				dat += "<em>No results found.</em>"
			else
				var/pagelist = get_pagelist()

				dat += pagelist
				dat += {"<form name='pagenum' action='?src=[UID()]' method='get'>
										<input type='hidden' name='src' value='[UID()]'>
										<input type='text' name='pagenum' value='[page_num]' maxlength="5" size="5">
										<input type='submit' value='Jump To Page'>
							</form>"}
				dat += {"<table border=\"0\">
					<tr>
						<td>Author</td>
						<td>Title</td>
						<td>Category</td>
						<td>SS<sup>13</sup>BN</td>
						<td>Controls</td>
					</tr>"}
				for(var/datum/cachedbook/CB in get_page(page_num))
					dat += {"<tr>
						<td>[CB.author]</td>
						<td>[CB.title]</td>
						<td>[CB.category]</td>
						<td>[CB.id]</td>
						<td><A href="?src=[UID()];flag=[CB.id]">\[Flag[CB.flagged ? "ged" : ""]\]</A></td>
					</tr>"}

				dat += "</table><br />[pagelist]"
			dat += "<A href='?src=[UID()];back=1'>\[Go Back\]</A><br />"
	var/datum/browser/B = new /datum/browser(user, "library", "Library Visitor")
	B.set_content(dat)
	B.open()

/obj/machinery/computer/library/public/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=publiclibrary")
		onclose(usr, "publiclibrary")
		return

	if(href_list["pagenum"])
		if(!num_pages)
			page_num = 1
		else
			var/pn = text2num(href_list["pagenum"])
			if(!isnull(pn))
				page_num = Clamp(pn, 1, num_pages)

	if(href_list["settitle"])
		var/newtitle = input("Enter a title to search for:") as text|null
		if(newtitle)
			query.title = sanitize(newtitle)
		else
			query.title = null
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category to search for:") in (list("Any") + library_section_names)
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

	if(href_list["page"])
		if(num_pages == 0)
			page_num = 1
		else
			page_num = Clamp(text2num(href_list["page"]), 1, num_pages)

	if(href_list["search"])
		num_results = src.get_num_results()
		num_pages = Ceiling(num_results/LIBRARY_BOOKS_PER_PAGE)
		page_num = 1

		screenstate = 1

	if(href_list["back"])
		screenstate = 0

	if(href_list["flag"])
		if(!dbcon.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
			return
		var/id = href_list["flag"]
		if(id)
			var/datum/cachedbook/B = getBookByID(id)
			if(B)
				if((input(usr, "Are you sure you want to flag [B.title] as having inappropriate content?", "Flag Book #[B.id]") in list("Yes", "No")) == "Yes")
					library_catalog.flag_book_by_id(usr, id)

	add_fingerprint(usr)
	updateUsrDialog()
	return