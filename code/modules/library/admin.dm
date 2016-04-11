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

	var/DBQuery/query = dbcon.NewQuery("SELECT id, title, flagged FROM [format_table_name("library")] WHERE flagged > 0 ORDER BY flagged DESC")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR getting flagged books. Error : \[[err]\]\n")
		return

	var/i
	for(i = 0, query.NextRow(), i++)
		to_chat(usr, "[add_zero(query.item[1], 4)] ([query.item[2]]) - flagged [query.item[3]] times.")
	to_chat(usr, "[i] flagged books total.")