
/*
 * # Library User Data Datum
 *
 * Because facilitating an entire library system that needs to be able to search a DB + move lots and lots of data
 * the temporary data used for functions has been condensed into a single datum
 */
/datum/library_user_data
	var/search_title
	var/search_author
	var/search_ckey
	var/search_rating = list(
		"min" = 0,
		"max" = 10,
	)
	var/search_categories = list()
	var/selected_rating = 0
	var/patron_name
	var/patron_account
	var/datum/cachedbook/selected_book = new()
	var/datum/library_category/selected_report

/datum/library_user_data/proc/clear_search()
	search_title = null
	search_author = null
	search_ckey = null
	search_rating["min"] = 0
	search_rating["max"] = 10
	search_categories = list()

/*
 * # Borrowbook datum
 *
 * Used for tracking books that have been checked out from the library by players. Created and stored upon a book being
 * checked out and deleted upon the book being succesfully checked back in or the librarian marking a book as "lost"
 */
/// Datum used to keep track of who has borrowed what when and for how long.
/datum/borrowbook
	var/bookname
	var/libraryid
	var/patron_name
	var/patron_account //Patron's Account ID, used for deducting $credits$ from their account
	var/duedate

/*
 * # Cachedbook datum
 *
 * Used for holding book data sourced from the Database in limbo to be used whenever the library computer needs it, these
 * are designed to only temporarily hold book data
 * checked out and deleted upon the book being succesfully checked back in or the librarian marking a book as "lost"
 */
/// Datum used to cache the SQL DB books locally in order to achieve a performance gain.
/datum/cachedbook
	var/id
	var/libraryid
	var/title
	var/list/content = list()
	var/summary
	var/author
	var/rating
	var/copyright
	var/ckey //administrative tracking/tooling purposes
	var/list/categories = list()
	var/reports = list()

///helper proc to turn our returned query rows into a cachedbook datum
/datum/cachedbook/proc/LoadFromRow(list/row)
	id = row["id"]
	author = row["author"]
	title = row["title"]
	content = json_decode(row["content"])
	summary = row["summary"]
	rating = row["rating"]
	if(text2num(row["primary_category"]))
		categories += text2num(row["primary_category"])
	if(text2num(row["primary_category"]))
		categories += text2num(row["secondary_category"])
	if(text2num(row["primary_category"]))
		categories += text2num(row["tertiary_category"])
	ckey = row["ckey"]
	var/list/reports_json = list()
	if(length(row["reports"]) > 5) //do we actually have a string with content??
		reports_json = json_decode(row["reports"])
	for(var/r in reports_json)
		var/datum/library_category/report_category = GLOB.library_catalog.get_report_category_by_id(r[2])
		var/datum/flagged_book/report = new()
		report.bookid = id
		report.category_id = report_category.category_id
		report.reporter = r[1]
		reports += report

/datum/cachedbook/proc/serialize_book(obj/item/book/B)
	title = B.title ? B.title : "Unnamed"
	author = B.author ? B.author : "Anonymous"
	if(length(B.pages)) //just incase we run a book with no pages
		content = B.pages
	else
		content = list()
	summary = B.summary ? B.summary : "No summary provided"
	rating = B.rating ? B.rating : 0
	copyright = B.copyright ? B.copyright : FALSE
	libraryid = B.libraryid

/*
 * # Programmaticbook datum
 *
 * Used for holding book data from books that have been "hardcoded" such as manuals.
 */
/datum/programmatic_book
	var/id
	var/title
	var/author
	var/book_type
	var/summary

/datum/flagged_book
	///book id of the book this flag is attached to
	var/bookid
	///The ckey of the player who reported it
	var/reporter
	///the id of the report category
	var/category_id

/*
 * # library_category datum
 *
 * Used for storing information about library categories. This is used both for "book categories" like genre/purpose
 * and also for defining OOC Report types to facilitate the reporting and deleting of bad books
 */
/datum/library_category
	var/category_id
	var/description //The front-facing text that the user sees

/datum/library_category/New(_category_id, _description)
	category_id = _category_id
	description = _description
