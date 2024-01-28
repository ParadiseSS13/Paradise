///library category datum constructor helper, used to make easier the process of defining new report/book categories
#define DEFINE_CATEGORY(C, D) (new /datum/library_category(_category_id = C, _description = D))
///Maximum number of books that can be uploaded by a single ckey
#define MAX_PLAYER_UPLOADS 5

/*
 * # Library Catalog
 *
 * This datum forms the basis for the entire library system, one is created at roundstart and stored to a global variable
 * It holds lists for all predefined report and book categories, books flagged during the round, and all programmatic
 * books.
 *
 * Additionally, ALL library SQL queries are handled in this datum. This is intentional so that we do not have multiple SQL
 * queries trying to do the same thing but in 4-5 different dm files. This file is split/organized into a specific
 * structure:
 * TOP    - Defining Library Lists
 * MIDDLE - Get Procs that get information from the catalog or DB
 * BOTTOM - Send/Update procs that perform changes to the Database. Don't mix their functionalities together.
 */
/datum/library_catalog
	///Lists of all reported books in the current round
	var/list/flagged_books = list()
	///List of all programmatic books, automatically generated upon New()
	var/list/books = list()
	///List of all report categories, automatically generated upon New()
	var/list/report_types = list()
	///List of all book categories, automatically generated upon New()
	var/list/categories = list()

/datum/library_catalog/New()

	//Building a list of all the reasons that players can report books, used for report menu + logging reports in DB
	//Cat ID needs to be unique to category, description can be changed here without issues anywhere else
	report_types = list(
		DEFINE_CATEGORY(LIB_REPORT_HATESPEECH, "Hatespeech or Slur Usage"),
		DEFINE_CATEGORY(LIB_REPORT_EROTICA, "Erotica or Sexual Content"),
		DEFINE_CATEGORY(LIB_REPORT_OOC, "Out of Character Information"),
		DEFINE_CATEGORY(LIB_REPORT_COPYPASTA, "Copypastas or Spam"),
		DEFINE_CATEGORY(LIB_REPORT_BLANK , "Blank or No Content"),
		DEFINE_CATEGORY(LIB_REPORT_NOEFFORT , "Very Low Effort Content"),
		DEFINE_CATEGORY(LIB_REPORT_OTHER  , "Other Reason not Specified"), //required
	)

	//building a list of all categories, used for searching, Cat ID needs to be unique to category
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

		DEFINE_CATEGORY(LIB_CATEGORY_LAW, "Law"),
		DEFINE_CATEGORY(LIB_CATEGORY_SECURITY, "Security"),
		DEFINE_CATEGORY(LIB_CATEGORY_SUPPLY, "Supply"),
		DEFINE_CATEGORY(LIB_CATEGORY_ENGINEERING, "Engineering"),
		DEFINE_CATEGORY(LIB_CATEGORY_SERVICE , "Service"),
		DEFINE_CATEGORY(LIB_CATEGORY_MEDICAL, "Medical"),
		DEFINE_CATEGORY(LIB_CATEGORY_RESEARCH, "Science"),
		DEFINE_CATEGORY(LIB_CATEGORY_COMMAND , "Command"),
	)

	//Books that we don't want showing up in the programmatic book list
	//Books should go here if they're non-functional, spawners, or are designed for off-station roles to consume
	var/list/forbidden_books = list(
		/obj/item/book/manual/random,
		/obj/item/book/manual/nuclear,
		/obj/item/book/manual/wiki,
		/obj/item/book/manual/hydroponics_pod_people,
	)

	var/newid = 1
	//building a list of all programmatic books
	for(var/typepath in (subtypesof(/obj/item/book/manual) - forbidden_books))
		var/obj/item/book/B = typepath
		var/datum/programmatic_book/PB = new()
		PB.title = initial(B.name)
		PB.author = initial(B.author)
		PB.id = "M[newid]"
		PB.book_type = typepath
		newid++
		books += PB

/*
 * can_vv_delete override
 * Admins should not be deleting this willy nilly, if they think it is neccesary,
 * they can go through the effort of advanced proccall
 */
/datum/library_catalog/can_vv_delete()
	message_admins("An admin attempted to VV delete the global library catalog, this will break the library system for the round, if you know what you are doing please use advanced proccal")
	return FALSE

/*
 * Database Select and Get Procs
 *
 * Each of these procs facilitate finding, taking,
 * and prepping information from the database for use elsewhere
 */

///External proc that Returns a report library_category datum that matches the provided cat_id
/datum/library_catalog/proc/get_report_category_by_id(category_id)
	for(var/datum/library_category/category in report_types)
		if(category.category_id == category_id)
			return category
	//proc shouldn't get this far, but if there's an entry in the DB that we don't have added, just default to other cat
	for(var/datum/library_category/category in report_types)
		if(category.category_id == LIB_REPORT_OTHER)
			return category

///External proc that Returns a book library_category datum that matches the provided cat_id
/datum/library_catalog/proc/get_book_category_by_id(category_id)
	for(var/datum/library_category/category in categories)
		if(category.category_id == category_id)
			return category

///External proc that Returns a report programmaticbook datum that matches the provided bookid
/datum/library_catalog/proc/get_programmatic_book_by_id(id)
	for(var/datum/programmatic_book/PB as anything in books)
		if(PB.id == id)
			return PB

/*
  * # get_book_by_id
  *
  * External proc that takes in an id number and searches the Database for a book with a matching SSID
  * returns a cached book with the data from that row
  *
  * Arguments:
  * * id - integer value that matches as a book SSID
 */
/datum/library_catalog/proc/get_book_by_id(id)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id, author, title, content, summary, rating, raters, primary_category, secondary_category, tertiary_category, ckey, reports FROM library WHERE id=:id", list(
		"id" = id
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
			"content" = query.item[4],
			"summary" = query.item[5],
			"rating" = query.item[6],
			"raters"  = query.item[7],
			"primary_category"   = query.item[8],
			"secondary_category" = query.item[9],
			"tertiary_category"  = query.item[10],
			"ckey"    = query.item[11],
			"reports" = query.item[12],
		))
		results += CB
		qdel(query)
		return CB
	qdel(query)
	return results

/*
  * # build_search_query
  *
  * Internal proc that builds part of an SQL statement using a datum of search terms/parameters. It will then return
  * a list of two objects: 1) the built SQL statement and 2) the assoc list of parameters that will accompany it in the query
  * This should only ever be used to generate WHERE statements
  *
  * Arguments:
  * * datum/library_user_data/search_terms - datum with parameters for what we want to query our DB for
 */
/datum/library_catalog/proc/build_search_query(datum/library_user_data/search_terms)
	var/searchquery = ""
	//We do not want to use WHERE more than once in our query, first usage makes this TRUE and defaults other WHERE's to AND
	var/where = FALSE
	var/list/sql_params = list()
	if(search_terms)
		if(search_terms.search_title)
			searchquery += " WHERE title LIKE :title"
			sql_params["title"] = "%[search_terms.search_title]%"
			where = TRUE
		if(search_terms.search_author)
			searchquery += " [!where ? "WHERE" : "AND"] author LIKE :author"
			sql_params["author"] = "%[search_terms.search_author]%"
			where = TRUE
		if(length(search_terms.search_categories))
			//yes this sql is cursed, but this is how it must be done and we only ever use this once :)
			var/category_vars = list()
			var/category_count = 1
			for(var/c in search_terms.search_categories)
				sql_params["category[category_count]"] = c
				category_vars += ":category[category_count]"
				category_count++
			var/query_insert = "([jointext(category_vars, ", ")])"
			searchquery += " [!where ? "WHERE" : "AND"] (primary_category IN [query_insert] OR secondary_category IN [query_insert] OR tertiary_category IN [query_insert])"
			where = TRUE
		if(search_terms.search_rating["min"] && search_terms.search_rating["max"])
			searchquery += " [!where ? "WHERE" : "AND"] (rating BETWEEN :ratingmin AND :ratingmax)"
			sql_params["ratingmin"] = search_terms.search_rating["min"]
			sql_params["ratingmax"] = search_terms.search_rating["max"]
			where = TRUE
		if(search_terms.search_ckey)
			searchquery += " [!where ? "WHERE" : "AND"] ckey =:ckey"
			sql_params["ckey"] = search_terms.search_ckey
			where = TRUE

	var/list/results = list(searchquery, sql_params)
	return results

/*
  * # get_book_by_range
  *
  * External proc used to get a large amount of books from a specific part of the library DB. Has paremeters to
  * specify range as well as what kind of books to look for. Will return a list of cachedbook datums.
  *
  * Arguments:
  * * initial - Book we want to start grabbing rows at, THIS IS NOT SSID, based on number of rows in DB
  * * range - Amount of books we want to grab at once
  * * datum/library_user_data/search_terms - datum with parameters for what we want to query our DB for
 */
/datum/library_catalog/proc/get_book_by_range(initial = 1, range = 25, datum/library_user_data/search_terms, doAsync = TRUE)
	var/list/search_query = build_search_query(search_terms)
	var/sql = "SELECT id, author, title, content, summary, rating, raters, primary_category, secondary_category, tertiary_category, ckey, reports FROM library" + search_query[1] + " LIMIT :lowerlimit, :upperlimit"
	var/list/sql_params = search_query[2]

	sql_params["lowerlimit"] = initial
	sql_params["upperlimit"] = range

	var/datum/db_query/select_query = SSdbcore.NewQuery(sql, sql_params)

	if(!select_query.warn_execute(async = doAsync))
		qdel(select_query)
		return

	var/list/results = list()
	while(select_query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      = select_query.item[1],
			"author"  = select_query.item[2],
			"title"   = select_query.item[3],
			"content" = select_query.item[4],
			"summary" = select_query.item[5],
			"rating" = select_query.item[6],
			"raters"  = select_query.item[7],
			"primary_category"   = select_query.item[8],
			"secondary_category" = select_query.item[9],
			"tertiary_category"  = select_query.item[10],
			"ckey"    = select_query.item[11],
			"reports" = select_query.item[12],
		))
		results += CB
	qdel(select_query)
	return results

/*
  * # get_flagged_books
  *
  * External proc that finds all books that have reports marked in the Database. Returns these books as a list
  * of cachedbook datums. This proc is not intended to actually handle reports or generate report_book datums
 */
/datum/library_catalog/proc/get_flagged_books()
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id, author, title, content, summary, ckey, reports FROM library WHERE LENGTH(reports) > 5")
	if(!query.warn_execute())
		qdel(query)
		return

	var/list/flagged_books = list()
	while(query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      = query.item[1],
			"author"  = query.item[2],
			"title"   = query.item[3],
			"content" = query.item[4],
			"summary" = query.item[5],
			"ckey"    = query.item[6],
			"reports" = query.item[7],
		))
		flagged_books += CB
	qdel(query)
	return flagged_books

/*
  * # get_total_books
  *
  * External proc that counts the number of books in the DB that match the provided search parameters
  * calling this with no arguments will return the complete count of books in the DB, if the query fails
  * this proc will return null, so usages of this proc will need to account for that
  *
  * Arguments:
  * * datum/library_user_data/search_terms - datum with parameters for what we want to query our DB for
 */
/datum/library_catalog/proc/get_total_books(datum/library_user_data/search_terms)
	var/list/search_query = build_search_query(search_terms)
	var/sql = "SELECT COUNT(id) FROM library" + search_query[1]
	var/list/sql_params = search_query[2]

	var/datum/db_query/count_query = SSdbcore.NewQuery(sql, sql_params)
	if(!count_query.warn_execute())
		qdel(count_query)
		return

	while(count_query.NextRow())
		var/value = text2num(count_query.item[1])
		qdel(count_query)
		return value
	qdel(count_query)

/*
  * # get_book_ratings
  *
  * External proc that gets all of the book ratings for a book. Unless the requested SSID doesn't exist in the
  * database, this proc will return (if the book has ratings) a list with the
  * first element being the books avg ratings and a list of ratings by players ["ckey", rating_int]
  *
  * Arguments:
  * * bookid - SSID of the book you wish to get ratings for
 */
/datum/library_catalog/proc/get_book_ratings(bookid)
	var/list/sql_params = list()
	sql_params["id"] = bookid

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT rating, raters FROM library WHERE id=:id", sql_params)

	if(!query.warn_execute())
		qdel(query)
		return

	var/list/book_ratings = list()
	while(query.NextRow())
		if(!query.item[2] || length(query.item[2]) < 5) //we don't want to decode something that is null or contains no values
			book_ratings = list(query.item[1], list())
			break
		book_ratings = list(query.item[1], json_decode(query.item[2]))

	qdel(query)
	return book_ratings

/*
  * # get_random_books
  *
  * External proc that gets random books from the Database, used by spawners for the most part. RANT: whoever wrote the fucking
  * old library code made this a global proc that accepted a loc and new'd/spawned in books from THIS PROC, take this as a
  * lesson never to do this. Anywho, this proc returns a list of cached books.
  *
  * Arguments:
  * * amount - amount of random books to get
 */
/datum/library_catalog/proc/get_random_book(amount = 1, doAsync = TRUE)
	if(!amount)
		return
	if(!SSdbcore.IsConnected())
		return
	var/num_books = clamp(amount, 1, 50) //you don't need more than 50 random books <3
	var/list/sql_params = list("amount" = num_books )
	var/sql = "SELECT id, author, title, content, summary, rating, primary_category, secondary_category, tertiary_category, ckey, reports FROM library GROUP BY title ORDER BY rand() LIMIT :amount"
	var/datum/db_query/query = SSdbcore.NewQuery(sql, sql_params)
	if(!query.warn_execute(async = doAsync)) //this proc is used in initialize in some objects :)
		qdel(query)
		return

	var/list/results = list()
	while(query.NextRow())
		var/datum/cachedbook/CB = new()
		CB.LoadFromRow(list(
			"id"      = query.item[1],
			"author"  = query.item[2],
			"title"   = query.item[3],
			"content" = query.item[4],
			"summary" = query.item[5],
			"rating" = query.item[6],
			"primary_category"   = query.item[7],
			"secondary_category" = query.item[8],
			"tertiary_category"  = query.item[9],
			"ckey"    = query.item[10],
			"reports" = query.item[11]
		))
		results += CB
	qdel(query)
	return results
/*
 * Database Update Procs
 *
 *  Each of these procs facilitate editing/updating the database
 */

/*
  * # flag_book_by_id
  *
  * External proc that Handles reporting of books. Will first get the existing flags for the book from the DB, if the report is
  * guchi, it will then add it to the list of reports for the book, encode to JSON, and update the DB
  *
  * Arguments:
  * * ckey - ckey of the player who is making the report
  * * bookid - SSID of the book being reported
  * * category_id - ID of the report category that is being used in the report
 */
/datum/library_catalog/proc/flag_book_by_id(ckey, bookid, category_id)
	//we should never flag a book in the DB without having the Book ID, Report Type, or Who reported it
	if(!bookid || !category_id || !ckey)
		return FALSE
	var/datum/library_category/report_type = get_report_category_by_id(category_id) //lets pull our report category datum
	if(!report_type) //is this an existing report type? If not somethings gone terribly wrong
		message_admins("WARNING: a player has attempted to flag book #[bookid] as inappropriate for a reason that does not exist, please investigate further.")
		return FALSE
	var/datum/cachedbook/reportedbook = get_book_by_id(bookid) //and now lets get what's currently on the DB
	if(!reportedbook) //does this book exist in the DB?
		message_admins("WARNING: a player has attempted to flag book #[bookid] as inappropriate for [report_type.description] but it does not exist in the Database, please investigate further.")
		return FALSE
	if(!SSdbcore.IsConnected()) //check our connection to the DB
		message_admins("WARNING: a player has attempted to flag book #[bookid] as inappropriate for [report_type.description] but the flag was not successfully saved to the Database. Please investigate further.")
		alert("Connection to Archive has been severed. Aborting.")
		return FALSE

	//Alright now that we've triple checked that we're ready to do this:
	//Has this player reported this book already this round?
	for(var/datum/flagged_book/book in flagged_books)
		if(book.bookid == bookid && book.reporter == ckey)
			return FALSE
	//If not, have they report this book in a previous round?
	for(var/datum/flagged_book/book in reportedbook.reports)
		if(book.reporter == ckey)
			return FALSE

	//lets add this book to the reported_books list for the round
	var/datum/flagged_book/f = new()
	f.bookid = bookid
	f.reporter = ckey
	f.category_id = category_id
	flagged_books += f //adding to global list
	reportedbook.reports += f //adding to books var for tracking reports
	//Now we will add the report to the DB, we will build the JSON we're going to upload from our books report list
	var/list/flag_json = list()
	//Flagged book json is stored as such: "[[reporter_ckey1, report_id1],[reporter_ckey2, report_id2]]""
	for(var/datum/flagged_book/book in reportedbook.reports)
		flag_json += list(list( //yes this is intentional
			book.reporter,
			book.category_id,
		))
	//uploading our report to the library
	var/datum/db_query/query = SSdbcore.NewQuery("UPDATE library SET reports=:report WHERE id=:id", list(
		"id" = text2num(bookid),
		"report" = json_encode(flag_json),
	))
	if(!query.warn_execute())
		message_admins("WARNING: a player has attempted to flag book #[bookid] as inappropriate for \"[report_type.description]\" but the flag was not successfully saved to the Database. Please investigate further.")
		qdel(query)
		return FALSE
	message_admins("[ckey] has flagged book #[bookid] as inappropriate for \"[report_type.description]\".")
	qdel(query)
	return TRUE

/*
  * # unflag_book_by_id
  *
  * External proc that removes all reports on a book.
  *
  * Arguments:
  * * bookid - SSID of the book being reported
 */
/datum/library_catalog/proc/unflag_book_by_id(bookid)
	//we should never flag a book in the DB without having the Book ID, Report Type, or Who reported it
	if(!bookid)
		return FALSE
	var/datum/cachedbook/reportedbook = get_book_by_id(bookid)
	if(!reportedbook)
		return FALSE //it don't exist

	if(!SSdbcore.IsConnected()) //check our connection to the DB
		message_admins("WARNING: an admin has attempted to unflag book #[bookid] but it was not successfully saved to the Database. Please investigate further.")
		return FALSE

	//uploading our report to the library
	var/datum/db_query/query = SSdbcore.NewQuery("UPDATE library SET reports=:report WHERE id=:id", list(
		"id" = text2num(bookid),
		"report" = json_encode(list()),
	))
	if(!query.warn_execute())
		message_admins("WARNING: an admin has attempted to unflag book #[bookid] but it was not successfully saved to the Database. Please investigate further.")
		qdel(query)
		return FALSE
	qdel(query)
	return TRUE
/*
  * # remove_book_by_id
  *
  * External proc that Handles the deletion of books by SSID
  *
  * Arguments:
  * * bookid - SSID of the book being deleted
 */
/datum/library_catalog/proc/remove_book_by_id(bookid)
	var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM library WHERE id=:id", list(
		"id" = text2num(bookid)
	))
	if(!query.warn_execute())
		qdel(query)
		return FALSE
	qdel(query)
	return TRUE

/*
  * # remove_books_by_ckey
  *
  * External proc that Handles the mass deletion of all books uploaded by a single ckey
  *
  * Arguments:
  * * ckey - ckey we will use to get all the books we want for deletion
 */
/datum/library_catalog/proc/remove_books_by_ckey(ckey)
	var/datum/db_query/query = SSdbcore.NewQuery("DELETE FROM library WHERE ckey=:ckey", list(
		"ckey" = ckey
	))
	if(!query.warn_execute())
		qdel(query)
		return FALSE
	qdel(query)
	return TRUE

/*
  * # upload_book
  *
  * External proc that handles creating new rows/uploading books to the DB
  *
  * Arguments:
  * * ckey - author's ckey that will be tied to the book uploaded
  * * datum/cachedbook/selected_book - cachedbook datum that contains all the book information to added to DB
 */
/datum/library_catalog/proc/upload_book(ckey, datum/cachedbook/selected_book)
	if(!ckey)
		return FALSE
	if(!selected_book.title || !selected_book.author || !length(selected_book.categories) || !length(selected_book.content))
		return FALSE

	if(!SSdbcore.IsConnected())
		return FALSE

	var/datum/library_user_data/search_terms = new()
	search_terms.search_ckey = ckey
	if(length(get_total_books(search_terms)) >= MAX_PLAYER_UPLOADS)
		return FALSE

	var/sql = {"INSERT INTO library (author, title, content, summary, primary_category, secondary_category, tertiary_category, ckey, raters, reports)
	VALUES (:author, :title, :content, :summary, :primarycategory, :secondarycategory, :tertiarycategory, :ckey, :raters, :reports)"}

	var/sql_params = list(
			"author"  = selected_book.author,
			"title"   = selected_book.title,
			"content" = json_encode(selected_book.content),
			"summary" = selected_book.summary ? selected_book.summary : "No Summary",
			"primarycategory"   = length(selected_book.categories) >= 1 ? selected_book.categories[1] : 0,
			"secondarycategory" = length(selected_book.categories) >= 2 ? selected_book.categories[2] : 0,
			"tertiarycategory"  = length(selected_book.categories) >= 3 ? selected_book.categories[3] : 0,
			"ckey"    = ckey,
			"raters"  = " ", //Entry for both of these columns are NOT NULL
			"reports" = " ", //so we need to provide an empty string val
		)

	var/datum/db_query/query = SSdbcore.NewQuery(sql, sql_params)

	if(!query.warn_execute())
		qdel(query)
		return FALSE

	qdel(query)
	log_admin("[ckey] has uploaded the book titled [selected_book.title], [length(selected_book.content)] pages in length")
	message_admins("[ckey] has uploaded the book titled [selected_book.title], [length(selected_book.content)] pages in length")
	return TRUE

/*
  * # rate_book
  *
  * External proc that handles adding ratings to books in the DB. Will first get the ratings for the book from the DB
  * and then rebuild the list/JSON for the ratings. It will also calculate the new average rating for the book.
  * This proc will automatically clean out duplicate entries (2 or more ratings from the same ckey on 1 book), additionally,
  * watch out for any user inputs that are not whole numbers/integers
  *
  * Arguments:
  * * ckey - reviewer's ckey
  * * bookid - SSID of the book being rated
  * * user_rating - integer from 1 to 10
 */
/datum/library_catalog/proc/rate_book(ckey, bookid, user_rating)
	if(!ckey || !bookid || !user_rating || !isnum(user_rating))
		return
	if(!SSdbcore.IsConnected())
		return

	var/list/current_ratings = get_book_ratings(bookid) // = [ratingInt, [[ckey, rating],[ckey, rating],[ckey, rating]]]
	var/list/new_raters_info = list()
	var/new_rating_value = round(user_rating, 1) //should only ever be a whole number

	if(length(current_ratings)) //did get_book_ratings actually return something?
		for(var/rating in current_ratings[2])
			if(rating[1] == ckey)
				continue //if your ckey has an existing rating, throw it out to make room for new one
			new_raters_info += list(rating)
			new_rating_value += rating[2]
	else
		current_ratings = list()

	new_raters_info += list(list(ckey, user_rating)) //intentional
	var/list/sql_params = list()
	sql_params["id"] = bookid
	//aggregate of ratings divided by total ratings to get average
	var/new_calculated_average = new_rating_value / length(new_raters_info)
	new_calculated_average = round(new_calculated_average, 0.1)
	sql_params["newrating"] = new_calculated_average
	sql_params["raters"] = json_encode(new_raters_info)

	var/datum/db_query/query = SSdbcore.NewQuery("UPDATE library SET rating=:newrating, raters=:raters WHERE id=:id", sql_params)

	if(!query.warn_execute())
		qdel(query)
		return
	qdel(query)
	return TRUE

#undef DEFINE_CATEGORY
#undef MAX_PLAYER_UPLOADS

/*     here be dragons~~~
 *                __        _
 *              _/  \    _(\(o
 *             /     \  /  _  ^^^o
 *            /   !   \/  ! '!!!v'
 *           !  !  \ _' ( \____
 *           ! . \ _!\   \===^\)
 *            \ \_!  / __!
 *             \!   /    \
 *       (\_      _/   _\ )
 *        \ ^^--^^ __-^ /(__
 *         ^^----^^    "^--v'
*/
