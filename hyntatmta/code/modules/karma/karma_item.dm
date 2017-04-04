/client/proc/DB_item_unlock(var/karma_id,var/cost)
	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM [format_table_name("whitelist")] WHERE ckey='[usr.key]'")
	query.Execute()

	var/dbitems
	var/dbckey
	while(query.NextRow())
		dbckey = query.item[2]
		dbitems = query.item[5]
	if(!dbckey)
		query = dbcon.NewQuery("INSERT INTO [format_table_name("whitelist")] (ckey, item_id) VALUES ('[usr.key]','[karma_id]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			message_admins("SQL ERROR during whitelist logging (adding new key). Error : \[[err]\]\n")
			return
		else
			message_admins("[key_name(usr)] has unlocked item #[karma_id].")
			karmacharge(cost)

	if(dbckey)
		var/list/itemslist = splittext(dbitems,",")
		if(!(karma_id in itemslist))
			itemslist += karma_id
			var/newitemslist = jointext(itemslist ,",")
			query = dbcon.NewQuery("UPDATE [format_table_name("whitelist")] SET item_id='[newitemslist]' WHERE ckey='[dbckey]'")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				message_admins("SQL ERROR during whitelist logging (updating existing entry). Error: \[[err]\]\n")
				return
			else
				to_chat(usr, "You have unlocked item #[karma_id].")
				message_admins("[key_name(usr)] has unlocked [karma_id].")
				karmacharge(cost)
		else
			to_chat(usr, "You already have this item unlocked!")
			return
	return

/proc/is_item_whitelisted(var/ckey,var/item_id)
	if(check_rights(R_ADMIN, 0))
		return 1
	if(!dbcon.IsConnected())
		to_chat(usr, "\red Unable to connect to whitelist database. Please try again later.<br>")
		return 0
	else
		var/DBQuery/query = dbcon.NewQuery("SELECT item_id FROM [format_table_name("whitelist")] WHERE ckey='[ckey]'")
		query.Execute()

		while(query.NextRow())
			var/itemlist = query.item[1]
			if(itemlist!="*")
				var/allowed_items = splittext(itemlist,",")
				if(item_id in allowed_items) return 1
			else return 1
		return 0
