// This is in its own file as it has so much stuff to contend with
/client/proc/edit_2fa()
	if(!config._2fa_auth_host)
		alert(usr, "This server does not have 2FA enabled.")
		return
	// Client does not have 2FA enabled. Set it up.
	if(prefs._2fa_status == _2FA_DISABLED)
		// Get us an auth token
		var/datum/http_response/qrcr = wrap_http_get("[config._2fa_auth_host]/generateQR?ckey=[ckey]")
		// If this fails, shits gone bad
		if(qrcr.errored)
			alert(usr, "Something has gone VERY wrong ingame. Please inform the server host.\nError details: [qrcr.error]")
			return

		if(qrcr.status_code != 200)
			alert(usr, "2FA QR code generation returned a non-200 code. Please inform the server host.\nError code: [qrcr.status_code]\nError details: [qrcr.body]")
			return

		var/list/data = json_decode(qrcr.body)
		var/qr_img_src = data["qr_image"]
		var/datum/browser/B = new(usr, "2fa_qrc", "2FA QR Code", 600, 400)
		var/title_text = "<p>Below is a QR code to scan inside your authenticator app to generate 2FA codes. Please verify it before closing this window. (Behind this window is a text box)</p>"
		var/img_data = "<div style=\"text-align:center;\"><img src=\"[qr_img_src]\"></div>"
		B.set_content("[title_text][img_data]")
		B.open(FALSE)

		var/entered_code = input(usr, "Please enter a code from your auth app. Failure to enter the code correctly will abort 2FA setup.", "2FA Validation")
		if(!entered_code)
			// Cleanup so they can start again
			var/datum/db_query/dbq = SSdbcore.NewQuery("DELETE FROM [format_table_name("2fa_secrets")] WHERE ckey=:ckey", list("ckey" = ckey))
			dbq.warn_execute()
			alert(usr, "2FA Setup aborted!")
			B.close()
			return

		var/datum/http_response/vr = wrap_http_get("[config._2fa_auth_host]/validateCode?ckey=[ckey]&code=[entered_code]")
		// If this fails, shits gone bad
		if(vr.errored)
			alert(usr, "Something has gone VERY wrong ingame. Please inform the server host.\nError details: [vr.error]")
			B.close()
			return

		if(vr.status_code != 200)
			// Cleanup so they can start again
			var/datum/db_query/dbq = SSdbcore.NewQuery("DELETE FROM [format_table_name("2fa_secrets")] WHERE ckey=:ckey", list("ckey" = ckey))
			dbq.warn_execute()

			// See if its unauthorised. I used 400 for that dont at me
			if(vr.status_code == 400)
				alert(usr, "Invalid code entered. 2FA Setup aborted!")
				B.close()
			else
				alert(usr, "2FA validation returned a non-200 code. Please inform the server host.\nError code: [vr.status_code]\nError details: [vr.body]")
				B.close()
			return

		// If we are here, they authed successfully
		alert(usr, "Congratulations. 2FA is now setup properly for your account. In preferences, you can change whether you want it to ask for a code on every connection or only when your IP changes")
		B.close()
		// Default to IP change only
		prefs._2fa_status = _2FA_ENABLED_IP
		prefs.save_preferences(src)
		prefs.ShowChoices(usr)
		return


	// If we are here, they just want to change the mode
	var/option = alert(usr, "Would you like to change 2FA mode or disable it entirely?", "2FA Mode", "Enable (Always)", "Enable (On IP Change)", "Deactivate")
	switch(option)
		if("Enable (Always)")
			prefs._2fa_status = _2FA_ENABLED_ALWAYS
			prefs.save_preferences(src)
			prefs.ShowChoices(usr)
		if("Enable (On IP Change)")
			prefs._2fa_status = _2FA_ENABLED_IP
			prefs.save_preferences(src)
			prefs.ShowChoices(usr)
		if("Deactivate")
			var/confirm = alert(usr, "Are you SURE you want to deactivate 2FA?", "WARNING", "Yes", "No")
			if(confirm != "Yes")
				return

			// Prompt them for a code to make sure they know what they are doing
			var/entered_code = input(usr, "Please enter a code from your auth app", "2FA Validation")
			if(!entered_code)
				alert(usr, "2FA deactivation aborted!")
				return

			var/datum/http_response/vr = wrap_http_get("[config._2fa_auth_host]/validateCode?ckey=[ckey]&code=[entered_code]")
			// If this fails, shits gone bad
			if(vr.errored)
				alert(usr, "Something has gone VERY wrong ingame. Please inform the server host.\nError details: [vr.error]")
				return

			if(vr.status_code != 200)
				// See if its unauthorised. I used 400 for that dont at me
				if(vr.status_code == 400)
					alert(usr, "Invalid code entered. 2FA deactivation aborted!")
				else
					alert(usr, "2FA validation returned non-200 code. Please inform the server host.\nError code: [vr.status_code]\nError details: [vr.body]")
				return

			// If we are here, they authed properly
			var/datum/db_query/dbq = SSdbcore.NewQuery("DELETE FROM [format_table_name("2fa_secrets")] WHERE ckey=:ckey", list("ckey" = ckey))
			dbq.warn_execute()
			prefs._2fa_status = _2FA_DISABLED
			prefs.save_preferences(src)
			prefs.ShowChoices(usr)
			alert(usr, "2FA disabled successfully")

/datum/preferences/proc/_2fastatus_to_text()
	switch(_2fa_status)
		if(_2FA_DISABLED)
			return "Disabled"
		if(_2FA_ENABLED_IP)
			return "Enabled (Will prompt on IP changes)"
		if(_2FA_ENABLED_ALWAYS)
			return "Enabled (Will prompt every time)"


// Proc to wrap HTTP requests properly, without needing SShttp firing
/proc/wrap_http_get(url)
	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_GET, url)
	req.begin_async()
	// Check if we are complete
	UNTIL(req.is_complete())
	var/datum/http_response/res = req.into_response()

	return res

