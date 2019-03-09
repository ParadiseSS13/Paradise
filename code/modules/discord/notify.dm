// DONT TOUCH ANYTHING IN HERE UNLESS YOU KNOW WHAT YOU ARE DOING -affected
/client/verb/notify_restart()
    set category = "Special Verbs"
    set name = "Notify Restart"
    set desc = "Notifies you on Discord when the server restarts."
    if(!config.sql_enabled)
        to_chat(src, "<span class='warning'>This is feature requires the SQL backend</span>")
        return
    var/DBQuery/db_discord_id = dbcon.NewQuery("SELECT discord_id FROM [format_table_name("discord")] WHERE ckey = '[ckey]'")
    if(!db_discord_id.Execute())
        var/err = db_discord_id.ErrorMsg()
        log_game("SQL ERROR while selecting discord account. Error : \[[err]\]\n")
        to_chat(src, "<span class='warning'>Error checking Discord account. Please inform an administrator</span>")
        return
    var/stored_id
    while(db_discord_id.NextRow())
        stored_id = db_discord_id.item[1]
    if(!stored_id) // Not linked
        to_chat(src, "<span class='warning'>This requires you to link your Discord account with the \"Link Discord Account\" verb.</span>")
        return
    else // Linked
        var/DBQuery/toggle_status = dbcon.NewQuery("SELECT notify FROM [format_table_name("discord")] WHERE ckey = '[ckey]'")
        if(!toggle_status.Execute())
            var/err = toggle_status.ErrorMsg()
            log_game("SQL ERROR while getting discord account. Error : \[[err]\]\n")
        var/notify_status
        while(toggle_status.NextRow())
            notify_status = toggle_status.item[1]
        if(notify_status) // Data is there
            switch(notify_status)
                if("0")
                    var/DBQuery/update_notify = dbcon.NewQuery("UPDATE [format_table_name("discord")] SET notify = 1 WHERE ckey='[ckey]'")
                    if(!update_notify.Execute())
                        var/err = db_discord_id.ErrorMsg()
                        to_chat(src, "<span class='warning'>Error updating notify status. Please inform an administrator</span>")
                        log_game("SQL ERROR while updating notify status. Error : \[[err]\]\n")
                        return
                    to_chat(src, "<span class='notice'>You will now be notified on discord when the next round is starting</span>")
                if("1")
                    var/DBQuery/update_notify = dbcon.NewQuery("UPDATE [format_table_name("discord")] SET notify = 0 WHERE ckey='[ckey]'")
                    if(!update_notify.Execute())
                        var/err = db_discord_id.ErrorMsg()
                        to_chat(src, "<span class='warning'>Error updating notify status. Please inform an administrator</span>")
                        log_game("SQL ERROR while updating notify status. Error : \[[err]\]\n")
                        return
                    to_chat(src, "<span class='notice'>You will no longer be notified on discord when the next round is starting</span>")
        else // Oh fuck what the hell happened
            to_chat(src, "<span class='danger'>Something has gone VERY wrong, or affected cant code.</span>")
