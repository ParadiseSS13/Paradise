#define DEFINE_CATEGORY(C, D) (new /datum/library_category(category_id = C, description = D))
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

/datum/programmaticbook
	var/id
	var/title
	var/author
	var/path
	var/summary

/datum/library_category
	var/category_id
	var/description //The front-facing text that the user sees
	var/selected = 1 //1 = not-selected ;  2 = selected

/datum/library_category/New(category_id, description)
	src.category_id = category_id
	src.description = description
/*
 * We don't want our hardcoded/programmatic books to mix-in with our player written books in the archive
 * This is because the library computer offers these two types in their own seperate tabs
 */
GLOBAL_DATUM_INIT(library_catalog, /datum/library_catalog, new())

/datum/library_catalog
	var/list/books = list()
	var/list/report_types = list()
	var/list/categories = list()

/datum/library_catalog/New()

	//Building a list of all the reasons that players can report books, used for report menu + logging reports in DB
	report_types = list(
		DEFINE_CATEGORY(LIB_REPORT_HATESPEECH, "Hatespeech or Slur Usage"),
		DEFINE_CATEGORY(LIB_REPORT_EROTICA, "Erotica or Sexual Content"),
		DEFINE_CATEGORY(LIB_REPORT_OOC, "Out of Character Information"),
		DEFINE_CATEGORY(LIB_REPORT_COPYPASTA, "Copypastas or Spam"),
		DEFINE_CATEGORY(LIB_REPORT_BLANK , "Blank or No Content"),
		DEFINE_CATEGORY(LIB_REPORT_NOEFFORT , "Very Low Effort Content"),
		DEFINE_CATEGORY(LIB_REPORT_OTHER  , "Other Reason not Specified"),
	)

	//building a list of all categories, used for searching
	categories = list(
		DEFINE_CATEGORY(LIB_CATEGORY_FICTION, "Fiction"),
		DEFINE_CATEGORY(LIB_CATEGORY_NONFICTION, "Non-Fiction"),
		DEFINE_CATEGORY(LIB_CATEGORY_RELIGION, "Religious"),
		DEFINE_CATEGORY(LIB_CATEGORY_FANTASY, "Fantasy"),
		DEFINE_CATEGORY(LIB_CATEGORY_HORROR, "Horror"),
		DEFINE_CATEGORY(LIB_CATEGORY_ROMANCE, "Romance"),
		DEFINE_CATEGORY(LIB_CATEGORY_MYSTERY, "Mystery"),
		DEFINE_CATEGORY(LIB_CATEGORY_ADVENTURE, "Adventure"),
		DEFINE_CATEGORY(LIB_CATEGORY_HISTORY, "History"),
		DEFINE_CATEGORY(LIB_CATEGORY_PHILOSOPHY, "Philosophy"),
		DEFINE_CATEGORY(LIB_CATEGORY_DRAMA, "Drama and Thriller"),
    	DEFINE_CATEGORY(LIB_CATEGORY_EXPERIMENT, "Experiment Notes"),
		DEFINE_CATEGORY(LIB_CATEGORY_LEGAL, "Legal Document"),
		DEFINE_CATEGORY(LIB_CATEGORY_BIOGRAPHY, "Biography"),
		DEFINE_CATEGORY(LIB_CATEGORY_GUIDE, "Guides and References"),
		DEFINE_CATEGORY(LIB_CATEGORY_PAPERWORK, "Paperwork"),
		DEFINE_CATEGORY(LIB_CATEGORY_COOKING, "Culinary Arts"),
		DEFINE_CATEGORY(LIB_CATEGORY_DESIGN, "Decor and Design"),
		DEFINE_CATEGORY(LIB_CATEGORY_COMBAT, "Martial Arts and Combat"),
		DEFINE_CATEGORY(LIB_CATEGORY_EXPLORATION, "Exploration"),
		DEFINE_CATEGORY(LIB_CATEGORY_THEATRE, "Theatre"),
		DEFINE_CATEGORY(LIB_CATEGORY_POETRY, "Poetry"),
    	DEFINE_CATEGORY(LIB_CATEGORY_LAW, "Law"), //departments
		DEFINE_CATEGORY(LIB_CATEGORY_SECURITY, "Security"),
		DEFINE_CATEGORY(LIB_CATEGORY_SUPPLY, "Supply"),
		DEFINE_CATEGORY(LIB_CATEGORY_ENGINEERING, "Engineering"),
		DEFINE_CATEGORY(LIB_CATEGORY_SERVICE , "Service"),
		DEFINE_CATEGORY(LIB_CATEGORY_MEDICAL, "Medical"),
		DEFINE_CATEGORY(LIB_CATEGORY_RESEARCH, "Science"),
		DEFINE_CATEGORY(LIB_CATEGORY_COMMAND , "Command"),
	)

	var/newid = 1
	for(var/typepath in subtypesof(/obj/item/book/manual)) //building a list of all programmatic books
		var/obj/item/book/B = new typepath(null)
		var/datum/programmaticbook/PB = new()
		PB.title = B.name
		PB.author = B.author
		PB.id = "M[newid]"
		PB.path = typepath
		newid++
		books += PB

// Builds a SQL statement
/datum/library_query
	var/author
	var/categories //need to make into a list
	var/title
	var/rating

/*
 * Yes this is a weird spot for these 3 procs, however, they need to be accessed at anytime by admin tooling seperate
 * from the library computer object so they can't be tied to the computer. Since this is always able to be referenced
 * because its stored in a global variable all round, it is a solid place.
 */

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

	var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM library WHERE id=:id", list(
		"id" = text2num(id)
	))
	if(!query.warn_execute())
		qdel(query)
		return
	qdel(query)

/datum/library_catalog/proc/getProgrammaticBookByID(id)
	for(var/book in GLOB.library_catalog.books)
		var/datum/programmaticbook/PB = book
		if(PB.id == id)
			return PB

/datum/library_catalog/proc/getBookByID(id)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id, author, title, category, content, ckey, flagged FROM library WHERE id=:id", list(
		"id" = text2num(id)
	))
	if(!query.warn_execute())
		qdel(query)
		return

	var/list/results = list()
	while(query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      = query.item[1],
			"author"  = query.item[2],
			"title"   = query.item[3],
			"category"= query.item[4],
			"content" = query.item[5],
			"ckey"    = query.item[6],
			"flagged" = query.item[7]
		))
		results += CB
		qdel(query)
		return CB
	qdel(query)
	return results
