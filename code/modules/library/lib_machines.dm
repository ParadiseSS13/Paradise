#define LIBRARY_BOOKS_PER_PAGE 25

GLOBAL_DATUM_INIT(library_catalog, /datum/library_catalog, new())
GLOBAL_LIST_INIT(library_section_names, list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion"))

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/libraryid
	var/patron_name
	var/patron_account
	var/getdate
	var/duedate
	var/fined

/*
 * Cachedbook datum
 */
/datum/cachedbook // Datum used to cache the SQL DB books locally in order to achieve a performance gain.
	var/id
	var/libraryid
	var/title
	var/content
	var/summary
	var/author
	var/rating
	var/copyright
	var/path = /obj/item/book // Type path of the book to generate
	var/programmatic //Hardcoded book?
	var/ckey // ADDED 24/2/2015 - N3X
	var/list/categories = list()
	var/flagged = 0

/datum/cachedbook/proc/LoadFromRow(list/row)
	id = row["id"]
	author = row["author"]
	title = row["title"]
	categories = row["category"]
	ckey = row["ckey"]
	flagged = row["flagged"]
	if("content" in row)
		content = row["content"]

// Builds a SQL statement
/datum/library_query
	var/author
	var/category
	var/title

// So we can have catalogs of books that are programmatic, and ones that aren't.
/datum/library_catalog
	var/list/cached_books = list()

/datum/library_catalog/New()
	var/newid=1
	for(var/typepath in subtypesof(/obj/item/book/manual))
		var/obj/item/book/B = new typepath(null)
		var/datum/cachedbook/CB = new()
		CB.title = B.name
		CB.author = B.author
		CB.path=typepath
		CB.id = "M[newid]"
		newid++
		cached_books["[CB.id]"]=CB

/datum/library_catalog/proc/flag_book_by_id(mob/user, id)
	var/global/books_flagged_this_round[0]

	if("[id]" in books_flagged_this_round)
		to_chat(user, "<span class='danger'>This book has already been flagged this shift.</span>")
		return

	books_flagged_this_round["[id]"] = 1
	message_admins("[key_name_admin(user)] has flagged book #[id] as inappropriate.")

	var/datum/db_query/query = SSdbcore.NewQuery("UPDATE library SET flagged = flagged + 1 WHERE id=:id", list(
		"id" = text2num(id)
	))
	if(!query.warn_execute())
		qdel(query)
		return
	qdel(query)

/datum/library_catalog/proc/rmBookByID(mob/user, id)
	if("[id]" in cached_books)
		var/datum/cachedbook/CB = cached_books["[id]"]

	var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM library WHERE id=:id", list(
		"id" = text2num(id)
	))
	if(!query.warn_execute())
		qdel(query)
		return
	qdel(query)

/datum/library_catalog/proc/getBookByID(id)
	if("[id]" in cached_books)
		return cached_books["[id]"]

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id, author, title, category, content, ckey, flagged FROM library WHERE id=:id", list(
		"id" = text2num(id)
	))
	if(!query.warn_execute())
		qdel(query)
		return

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
		qdel(query)
		return CB
	qdel(query)
	return results

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
