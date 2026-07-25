// This is in its own file as it has so much stuff to contend with
/client/proc/edit_2fa()
	// Client does not have 2FA enabled. Set it up.
	if(prefs._2fa_status == _2FA_DISABLED)
		// Step 1 - Generate a secret
		var/mfa_secret = rustlibs_mfa_generate_secret()

		// Step 2 - Generate QR code
		var/mfa_qr_code = rustlibs_mfa_generate_qr(mfa_secret, ckey)

		var/datum/browser/B = new(usr, "2fa_qrc", "2FA QR Code", 600, 560)
		var/title_text = "<p>Below is a QR code to scan inside your authenticator app to generate 2FA codes. Please verify it before closing this window. (Behind this window is a text box)</p>"
		var/img_data = "<div style=\"text-align:center;\"><img src=\"[mfa_qr_code]\"></div>"
		B.set_content("[title_text][img_data]")
		B.open(FALSE)

		var/entered_code = input(usr, "Please enter a code from your auth app. Failure to enter the code correctly will abort 2FA setup.", "2FA Validation")
		if(!entered_code)
			alert(usr, "2FA Setup aborted!")
			B.close()
			return

		// See if the code entered is corrected
		var/mfa_success = rustlibs_mfa_verify_code(mfa_secret, entered_code)

		if(!mfa_success)
			alert(usr, "Incorrect MFA code entered - check your phone date and time settings.")
			B.close()
			return

		// If we are here, they authed successfully
		B.close()

		// Do our DB update
		var/datum/db_query/insert_qry = SSdbcore.NewQuery("INSERT INTO 2fa_secrets (ckey, secret) VALUES (:ckey, :secret)", list(
			"ckey" = ckey,
			"secret" = mfa_secret
		))

		if(!insert_qry.warn_execute())
			qdel(insert_qry)
			alert(usr, "MFA failed to save to the DB - please inform the server host.")
			return

		// Default to IP change only
		prefs._2fa_status = _2FA_ENABLED_IP
		prefs.save_preferences(src)
		prefs.ShowChoices(usr)
		if(holder && holder.restricted_by_2fa)
			reload_one_admin(ckey, silent = TRUE)
			to_chat(usr, "<span class='notice'>2fa configured, admin verbs enabled.")
		alert(usr, "Congratulations. 2FA is now setup properly for your account. In preferences, you can change whether you want it to ask for a code on every connection or only when your IP changes")
		return


	// If we are here, they just want to change the mode
	var/option = tgui_alert(usr, "Would you like to change 2FA mode or disable it entirely?", "2FA Mode", list("Enable (Always)", "Enable (On IP Change)", "Deactivate"))
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
			var/confirm = tgui_alert(usr, "Are you SURE you want to deactivate 2FA?", "WARNING", list("Yes", "No"))
			if(confirm != "Yes")
				return
			if(holder && holder.needs_2fa())
				confirm = tgui_alert(usr, "This will disable most of your admin permissions. Are you REALLY sure?", "WARNING", list("Yes", "No"))
				if(confirm != "Yes")
					return

			// Prompt them for a code to make sure they know what they are doing
			var/entered_code = input(usr, "Please enter a code from your auth app", "2FA Validation")
			if(!entered_code)
				alert(usr, "2FA deactivation aborted!")
				return

			// Get their secret
			var/datum/db_query/load_qry = SSdbcore.NewQuery("SELECT secret FROM 2fa_secrets WHERE ckey=:ckey", list(
				"ckey" = ckey,
			))

			if(!load_qry.warn_execute())
				qdel(load_qry)
				alert(usr, "Failed to load your existing MFA token - please inform the server host.")
				return

			var/db_secret = null

			if(load_qry.NextRow())
				db_secret = load_qry.item[1]

			qdel(load_qry)

			if(!db_secret)
				alert(usr, "Failed to load your existing MFA token - please inform the server host.")
				return

			var/mfa_result = rustlibs_mfa_verify_code(db_secret, entered_code)

			if(!mfa_result)
				alert(usr, "Invalid code entered. 2FA deactivation aborted. If you have lost your authenticator, please inform the server host.")
				return

			// If we are here, they authed properly
			var/datum/db_query/dbq = SSdbcore.NewQuery("DELETE FROM 2fa_secrets WHERE ckey=:ckey", list("ckey" = ckey))
			dbq.warn_execute()
			prefs._2fa_status = _2FA_DISABLED
			prefs.save_preferences(src)
			prefs.ShowChoices(usr)
			if(holder && holder.needs_2fa())
				reload_one_admin(ckey, silent = TRUE)
			alert(usr, "2FA disabled successfully")

/client/proc/has_2fa()
	return prefs._2fa_status != _2FA_DISABLED

/datum/preferences/proc/_2fastatus_to_text()
	switch(_2fa_status)
		if(_2FA_DISABLED)
			return "Disabled"
		if(_2FA_ENABLED_IP)
			return "Enabled (Will prompt on IP changes)"
		if(_2FA_ENABLED_ALWAYS)
			return "Enabled (Will prompt every time)"
