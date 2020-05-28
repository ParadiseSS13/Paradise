#define LIBRARY_BOOKS_PER_PAGE 25

GLOBAL_DATUM_INIT(library_catalog, /datum/library_catalog, new())
GLOBAL_LIST_INIT(library_section_names, list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion"))


/hook/startup/proc/load_manuals()
	GLOB.library_catalog.initialize()
	return 1

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate

/*
 * Cachedbook datum
 */
/datum/cachedbook // Datum used to cache the SQL DB books locally in order to achieve a performance gain.
	var/id
	var/title
	var/author
	var/ckey // ADDED 24/2/2015 - N3X
	var/category
	var/content
	var/programmatic=0                // Is the book programmatically added to the catalog?
	var/forbidden=0
	var/path = /obj/item/book // Type path of the book to generate
	var/flagged = 0

/datum/cachedbook/proc/LoadFromRow(var/list/row)
	id = row["id"]
	author = row["author"]
	title = row["title"]
	category = row["category"]
	ckey = row["ckey"]
	flagged = row["flagged"]
	if("content" in row)
		content = row["content"]
	programmatic=0

// Builds a SQL statement
/datum/library_query
	var/author
	var/category
	var/title

/datum/library_query/proc/toSQL()
	var/list/where = list()
	if(author || title || category)
		if(author)
			where.Add("author LIKE '%[sanitizeSQL(author)]%'")
		if(category)
			where.Add("category = '[sanitizeSQL(category)]'")
		if(title)
			where.Add("title LIKE '%[sanitizeSQL(title)]%'")
		return " WHERE " + jointext(where, " AND ")
	return ""

// So we can have catalogs of books that are programmatic, and ones that aren't.
/datum/library_catalog
	var/list/cached_books = list()

/datum/library_catalog/proc/initialize()
	var/newid=1
	for(var/typepath in subtypesof(/obj/item/book/manual))
		var/obj/item/book/B = new typepath(null)
		var/datum/cachedbook/CB = new()
		CB.forbidden = B.forbidden
		CB.title = B.name
		CB.author = B.author
		CB.programmatic=1
		CB.path=typepath
		CB.id = "M[newid]"
		newid++
		cached_books["[CB.id]"]=CB

/datum/library_catalog/proc/flag_book_by_id(mob/user, id)
	var/global/books_flagged_this_round[0]

	if("[id]" in cached_books)
		var/datum/cachedbook/CB = cached_books["[id]"]
		if(CB.programmatic)
			to_chat(user, "<span class='danger'>That book cannot be flagged in the system, as it does not actually exist in the database.</span>")
			return

	if("[id]" in books_flagged_this_round)
		to_chat(user, "<span class='danger'>This book has already been flagged this shift.</span>")
		return

	books_flagged_this_round["[id]"] = 1
	message_admins("[key_name_admin(user)] has flagged book #[id] as inappropriate.")

	var/sqlid = text2num(id)
	if(!sqlid)
		return
	var/DBQuery/query = GLOB.dbcon.NewQuery("UPDATE [format_table_name("library")] SET flagged = flagged + 1 WHERE id=[sqlid]")
	query.Execute()

/datum/library_catalog/proc/rmBookByID(mob/user, id)
	if("[id]" in cached_books)
		var/datum/cachedbook/CB = cached_books["[id]"]
		if(CB.programmatic)
			to_chat(user, "<span class='danger'>That book cannot be removed from the system, as it does not actually exist in the database.</span>")
			return

	var/sqlid = text2num(id)
	if(!sqlid)
		return
	var/DBQuery/query = GLOB.dbcon.NewQuery("DELETE FROM [format_table_name("library")] WHERE id=[sqlid]")
	query.Execute()

/datum/library_catalog/proc/getBookByID(id)
	if("[id]" in cached_books)
		return cached_books["[id]"]

	var/sqlid = text2num(id)
	if(!sqlid)
		return
	var/DBQuery/query = GLOB.dbcon.NewQuery("SELECT id, author, title, category, content, ckey, flagged FROM [format_table_name("library")] WHERE id=[sqlid]")
	query.Execute()

	var/list/results=list()
	while(query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      =query.item[1],
			"author"  =query.item[2],
			"title"   =query.item[3],
			"category"=query.item[4],
			"content" =query.item[5],
			"ckey"    =query.item[6],
			"flagged" =query.item[7]
		))
		results += CB
		cached_books["[id]"]=CB
		return CB
	return results

/** Scanner **/
/obj/machinery/libraryscanner
	name = "scanner"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	var/obj/item/book/cache		// Last scanned book

/obj/machinery/libraryscanner/attackby(obj/item/I, mob/user)
	if(default_unfasten_wrench(user, I))
		power_change()
		return
	if(istype(I, /obj/item/book))
		user.drop_item()
		I.forceMove(src)
		return 1
	else
		return ..()

/obj/machinery/libraryscanner/attack_hand(mob/user)
	if(istype(user,/mob/dead))
		to_chat(user, "<span class='danger'>Nope.</span>")
		return
	usr.set_machine(src)
	var/dat = "<HEAD><TITLE>Scanner Control Interface</TITLE></HEAD><BODY>\n" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=[UID()];scan=1'>\[Scan\]</A>"
	if(cache)
		dat += "       <A href='?src=[UID()];clear=1'>\[Clear Memory\]</A><BR><BR><A href='?src=[UID()];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	user << browse(dat, "window=scanner")
	onclose(user, "scanner")

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=scanner")
		onclose(usr, "scanner")
		return

	if(href_list["scan"])
		for(var/obj/item/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/book/B in contents)
			B.loc = src.loc
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Book Binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1

/obj/machinery/bookbinder/attackby(obj/item/I, mob/user)
	var/obj/item/paper/P = I
	if(default_unfasten_wrench(user, I))
		power_change()
		return
	if(istype(P))
		user.drop_item()
		user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
		src.visible_message("[src] begins to hum as it warms up its printing drums.")
		sleep(rand(200,400))
		src.visible_message("[src] whirs as it prints and binds a new book.")
		var/obj/item/book/b = new(loc)
		b.dat = P.info
		b.name = "Print Job #[rand(100, 999)]"
		b.icon_state = "book[rand(1,16)]"
		qdel(P)
		return 1
	else
		return ..()
