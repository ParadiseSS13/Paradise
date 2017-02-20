/client/proc/delbook()
	set name = "Delete Book"
	set desc = "Permamently deletes a book from the database."
	set category = "Admin"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/isbn = input("ISBN number?", "Delete Book") as num | null
	if(!isbn)
		return

	var/DBQuery/query_delbook = dbcon.NewQuery("DELETE FROM [format_table_name("library")] WHERE id=[isbn]")
	if(!query_delbook.Execute())
		var/err = query_delbook.ErrorMsg()
		log_game("SQL ERROR deleting book. Error : \[[err]\]\n")
		return

	log_admin("[key_name(usr)] has deleted the book [isbn].")
	message_admins("[key_name_admin(usr)] has deleted the book [isbn].")

/client/proc/view_flagged_books()
	set name = "View Flagged Books"
	set desc = "View books flagged for content."
	set category = "Admin"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	holder.view_flagged_books()

/datum/admins/proc/view_flagged_books()
	if(!usr.client.holder)
		return

	var/dat = "<table><tr><th>ISBN</th><th>Title</th><th>Total Flags</th><th>Options</th></tr>"

	var/DBQuery/query = dbcon.NewQuery("SELECT id, title, flagged FROM [format_table_name("library")] WHERE flagged > 0 ORDER BY flagged DESC")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR getting flagged books. Error : \[[err]\]\n")
		return

	var/books = 0
	while(query.NextRow())
		books++
		var/isbn = query.item[1]
		dat += "<tr><td>[add_zero(isbn, 4)]</td><td>[query.item[2]]</td><td>[query.item[3]]</td><td>"
		dat += "<a href='?_src_=holder;library_book_id=[isbn];view_library_book=1;'>View Content</a>"
		dat += "<a href='?_src_=holder;library_book_id=[isbn];unflag_library_book=1;'>Unflag</a>"
		dat += "<a href='?_src_=holder;library_book_id=[isbn];delete_library_book=1;'>Delete</a>"
		dat += "</td>"

	dat += "</table>"

	if(!books)
		dat = "<h1>No flagged books! :)</h1>"

	var/datum/browser/popup = new(usr, "admin_view_flagged_books", "Flagged Books", 700, 400)
	popup.set_content(dat)
	popup.open(0)

