/client/proc/alt_check()
	set category = "Admin"
	set name = "Alt Account Checker"

	var/dat = {"<B>Just to be sure you should try to also look up computer IDs/IPs on the server logs for a second opinion.</B>
				<br>Additionally make an attempt to introduce new players to the server
				<HR>"}

	if(dbcon.IsConnected())
		for(var/client/C in GLOB.clients)
			dat += "<p>[C.ckey] (Player Age: <font color = 'red'>[C.player_age]</font>) - <b>[C.computer_id]</b> / <b>[C.address]</b><br>"
			if(C.related_accounts_cid.len)
				dat += "--Accounts associated with CID: "
				dat += "<b>[jointext(C.related_accounts_cid, " - ")]</b><br>"
			if(C.related_accounts_ip.len)
				dat += "--Accounts associated with IP: "
				dat += "<b>[jointext(C.related_accounts_ip, " - ")]</b> "
	usr << browse(dat, "window=alt_panel;size=640x480")
	return

