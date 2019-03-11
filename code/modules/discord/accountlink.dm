// DONT TOUCH ANYTHING IN HERE UNLESS YOU KNOW WHAT YOU ARE DOING -affected
/client/verb/linkdiscord()
    set category = "Special Verbs"
    set name = "Link Discord Account"
    set desc = "Link your discord account to your BYOND account."
    var/user_ckey = sanitizeSQL(usr.ckey) // Probably not neccassary but better safe than sorry
    if(!config.sql_enabled)
        to_chat(src, "<span class='warning'>This is feature requires the SQL backend</span>")
        return
    var/DBQuery/db_discord_id = dbcon.NewQuery("SELECT discord_id FROM [format_table_name("discord")] WHERE ckey = '[user_ckey]'")
    if(!db_discord_id.Execute())
        var/err = db_discord_id.ErrorMsg()
        log_game("SQL ERROR while selecting discord account. Error : \[[err]\]\n")
        to_chat(src, "<span class='warning'>Error checking Discord account. Please inform an administrator</span>")
        return
    var/stored_id
    while(db_discord_id.NextRow())
        stored_id = db_discord_id.item[1]
    if(!stored_id) // Not linked
        var/know_how = alert("Do you know how to get a discord user ID? This ID is NOT your discord username and numbers!","Question","Yes","No")
        if(know_how == "No") // Opens discord support on how to collect IDs
            src << link("https://support.discordapp.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID")
        var/entered_id = input("Please enter your Discord ID.", "Enter Discord ID", null, null) as text|null
        var/sql_id = sanitizeSQL(entered_id)
        var/DBQuery/store_discord_id = dbcon.NewQuery("INSERT INTO [format_table_name("discord")] (ckey, discord_id, notify) VALUES ('[user_ckey]', [sql_id], 0)")
        if(!store_discord_id.Execute())
            var/err = db_discord_id.ErrorMsg()
            log_game("SQL ERROR while linking discord account. Error : \[[err]\]\n")
            to_chat(src, "<span class='warning'>Error linking Discord account. Please inform an administrator</span>")
            return
        to_chat(src, "<span class='notice'>Successfully linked discord account [entered_id] to [user_ckey]</span>")
    else // Linked
        var/choice = alert("You already have the Discord Account [stored_id] linked to [user_ckey]. Would you like to unlink or replace","Already Linked","Unlink","Replace")
        switch(choice)
            if("Unlink")
                var/DBQuery/unlink_discord_id = dbcon.NewQuery("DELETE FROM [format_table_name("discord")] WHERE ckey = '[user_ckey]'")
                if(!unlink_discord_id.Execute())
                    var/err = unlink_discord_id.ErrorMsg()
                    log_game("SQL ERROR while unlinking discord account. Error : \[[err]\]\n")
                    to_chat(src, "<span class='warning'>Error unlinking Discord account. Please inform an administrator</span>")
                    return
                to_chat(src, "<span class='notice'>Successfully unlinked discord account</span>")
            if("Replace")
                var/entered_id = input("Please enter your Discord ID. Instructions can be found at https://bit.ly/2AfUu40", "Enter Discord ID", null, null) as text|null
                var/sql_id = sanitizeSQL(entered_id)
                var/DBQuery/store_discord_id = dbcon.NewQuery("UPDATE [format_table_name("discord")] SET discord_id = '[sql_id]' WHERE ckey='[user_ckey]'")
                if(!store_discord_id.Execute())
                    var/err = db_discord_id.ErrorMsg()
                    to_chat(src, "<span class='warning'>Error replacing Discord account. Please inform an administrator</span>")
                    log_game("SQL ERROR while linking discord account. Error : \[[err]\]\n")
                    return
                to_chat(src, "<span class='notice'>Successfully linked discord account [entered_id] to [user_ckey]</span>")
