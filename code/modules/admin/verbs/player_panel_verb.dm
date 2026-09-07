USER_CONTEXT_MENU(show_player_panel, R_ADMIN|R_MOD, "\[Admin\] Show Player Panel", mob/M)
	if(!M)
		to_chat(client, "You seem to be selecting a mob that doesn't exist anymore.")
		return

	var/our_key = M.key
	if(M.client && M.client.holder)
		if(M.client.holder.fakekey && M.client.holder.big_brother)
			our_key = M.client.holder.fakekey

	var/mob_uid = M.UID()

	var/body = "<html><meta charset='UTF-8'><head><title>Options for [our_key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		if(check_rights(R_PERMISSIONS, FALSE))
			body += "\[<A href='byond://?_src_=holder;editrights=rank;ckey=[M.ckey]'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\] "
		else if(M.client.holder && M.client.holder.fakekey && M.client.holder.big_brother)
			body += "\[Player\] "
		else
			body += "\[[M.client.holder ? M.client.holder.rank : "Player"]\] "
		body += "\[<A href='byond://?_src_=holder;getplaytimewindow=[mob_uid]'>" + M.client.get_exp_type(EXP_TYPE_CREW) + " as [EXP_TYPE_CREW]</a>\]"
		body += "<br>BYOND account registration date: [M.client.byondacc_date || "ERROR"] [M.client.byondacc_age <= GLOB.configuration.general.byond_account_age_threshold ? "<b>" : ""]([M.client.byondacc_age] days old)[M.client.byondacc_age <= GLOB.configuration.general.byond_account_age_threshold ? "</b>" : ""]"
		body += "<br>BYOND client version: [M.client.byond_version].[M.client.byond_build]"
		body += "<br>Global Ban DB Lookup: [GLOB.configuration.url.centcom_ban_db_url ? "<a href='byond://?_src_=holder;open_ccbdb=[M.client.ckey]'>Lookup</a>" : "<i>Disabled</i>"]"
		body += "<br><a href='byond://?_src_=holder;clientmodcheck=[M.client.UID()]'>Check for client modification</a>"

		body += "<br>"

	if(isnewplayer(M))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='byond://?_src_=holder;revive=[mob_uid]'>Heal</A>\] "


	body += "<br><br>\[ "
	body += "<a href='byond://?_src_=holder;open_logging_view=[mob_uid];'>LOGS</a> - "
	body += "<a href='byond://?_src_=vars;Vars=[mob_uid]'>VV</a> - "
	body += "[ADMIN_TP(M,"TP")] - "
	if(M.client)
		body += "<a href='byond://?src=[usr.UID()];priv_msg=[M.client.ckey]'>PM</a> - "
		body += "[ADMIN_SM(M,"SM")] - "
	if(ishuman(M) && M.mind)
		body += "<a href='byond://?_src_=holder;HeadsetMessage=[mob_uid]'>HM</a> - "
	body += "[admin_jump_link(M)] - "
	body += "<a href='byond://?_src_=holder;adminalert=[mob_uid]'>SEND ALERT</a>\]</b><br>"
	body += "<b>Mob type:</b> [M.type]<br>"
	if(M.client)
		if(length(M.client.related_accounts_cid))
			body += "<b>Related accounts by CID:</b> [jointext(M.client.related_accounts_cid, " - ")]<br>"
		if(length(M.client.related_accounts_ip))
			body += "<b>Related accounts by IP:</b> [jointext(M.client.related_accounts_ip, " - ")]<br><br>"

	if(M.ckey)
		body += "<b>Enabled AntagHUD</b>: [M.has_ahudded() ? "<b><font color='red'>TRUE</font></b>" : "false"]<br>"
		body += "<b>Roundstart observer</b>: [M.is_roundstart_observer() ? "<b>true</b>" : "false"]<br>"
		body += "<A href='byond://?_src_=holder;boot2=[mob_uid]'>Kick</A> | "
		body += "<A href='byond://?_src_=holder;newban=[mob_uid];dbbanaddckey=[M.ckey]'>Ban</A> | "
		body += "<A href='byond://?_src_=holder;jobban2=[mob_uid];dbbanaddckey=[M.ckey]'>Jobban</A> | "
		body += "<A href='byond://?_src_=holder;shownoteckey=[M.ckey]'>Notes</A> | "
		if(GLOB.configuration.url.forum_playerinfo_url)
			body += "<A href='byond://?_src_=holder;webtools=[M.ckey]'>WebInfo</A> | "
	if(M.client)
		if(M.client.watchlisted)
			body += "<A href='byond://?_src_=holder;watchremove=[M.ckey]'>Remove from Watchlist</A> | "
			body += "<A href='byond://?_src_=holder;watchedit=[M.ckey]'>Edit Watchlist Reason</A> "
		else
			body += "<A href='byond://?_src_=holder;watchadd=[M.ckey]'>Add to Watchlist</A> "

		body += "| <A href='byond://?_src_=holder;sendtoprison=[mob_uid]'>Prison</A> | "
		body += "\ <A href='byond://?_src_=holder;sendbacktolobby=[mob_uid]'>Send back to Lobby</A> | "
		body += "\ <A href='byond://?_src_=holder;eraseflavortext=[mob_uid]'>Erase Flavor Text</A> | "
		body += "\ <A href='byond://?_src_=holder;userandomname=[mob_uid]'>Use Random Name</A> | "
		body += {"<br><b>Mute: </b>
			\[<A href='byond://?_src_=holder;mute=[mob_uid];mute_type=[MUTE_IC]'><font color='[check_mute(M.client.ckey, MUTE_IC) ? "red" : "#6685f5"]'>IC</font></a> |
			<A href='byond://?_src_=holder;mute=[mob_uid];mute_type=[MUTE_OOC]'><font color='[check_mute(M.client.ckey, MUTE_OOC) ? "red" : "#6685f5"]'>OOC</font></a> |
			<A href='byond://?_src_=holder;mute=[mob_uid];mute_type=[MUTE_PRAY]'><font color='[check_mute(M.client.ckey, MUTE_PRAY) ? "red" : "#6685f5"]'>PRAY</font></a> |
			<A href='byond://?_src_=holder;mute=[mob_uid];mute_type=[MUTE_ADMINHELP]'><font color='[check_mute(M.client.ckey, MUTE_ADMINHELP) ? "red" : "#6685f5"]'>ADMINHELP</font></a> |
			<A href='byond://?_src_=holder;mute=[mob_uid];mute_type=[MUTE_DEADCHAT]'><font color='[check_mute(M.client.ckey, MUTE_DEADCHAT) ?" red" : "#6685f5"]'>DEADCHAT</font></a> |
			<A href='byond://?_src_=holder;mute=[mob_uid];mute_type=[MUTE_EMOTE]'><font color='[check_mute(M.client.ckey, MUTE_EMOTE) ?" red" : "#6685f5"]'>EMOTE</font></a>]
			(<A href='byond://?_src_=holder;mute=[mob_uid];mute_type=[MUTE_ALL]'><font color='[check_mute(M.client.ckey, MUTE_ALL) ? "red" : "#6685f5"]'>toggle all</font></a>)
		"}

	var/jumptoeye = ""
	if(is_ai(M))
		var/mob/living/silicon/ai/A = M
		if(A.client && A.eyeobj) // No point following clientless AI eyes
			jumptoeye = " <b>(<A href='byond://?_src_=holder;jumpto=[A.eyeobj.UID()]'>Eye</A>)</b>"
	body += {"<br><br>
		<A href='byond://?_src_=holder;jumpto=[mob_uid]'><b>Jump to</b></A>[jumptoeye] |
		<A href='byond://?_src_=holder;getmob=[mob_uid]'>Get</A> |
		<A href='byond://?_src_=holder;sendmob=[mob_uid]'>Send To</A>
		<br><br>
		[check_rights(R_ADMIN,0) ? "[ADMIN_TP(M,"Traitor panel")] | " : "" ]
		<A href='byond://?_src_=holder;narrateto=[mob_uid]'>Narrate to</A> |
		[ADMIN_SM(M,"Subtle message")]
	"}

	if(check_rights(R_EVENT, 0))
		body += {" | <A href='byond://?_src_=holder;Bless=[mob_uid]'>Bless</A> | <A href='byond://?_src_=holder;Smite=[mob_uid]'>Smite</A>"}

	if(isLivingSSD(M))
		if(istype(M.loc, /obj/machinery/cryopod))
			body += {" | <A href='byond://?_src_=holder;cryossd=[mob_uid]'>De-Spawn</A> "}
		else
			body += {" | <A href='byond://?_src_=holder;cryossd=[mob_uid]'>Cryo</A> "}

	if(M.client)
		if(!isnewplayer(M))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Monkey
			if(issmall(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<A href='byond://?_src_=holder;monkeyone=[mob_uid]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='byond://?_src_=holder;corgione=[mob_uid]'>Corgize</A> | "

			//AI / Cyborg
			if(is_ai(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += {"<A href='byond://?_src_=holder;makeai=[mob_uid]'>Make AI</A> |
					<A href='byond://?_src_=holder;makerobot=[mob_uid]'>Make Robot</A> |
					<A href='byond://?_src_=holder;makealien=[mob_uid]'>Make Alien</A> |
					<A href='byond://?_src_=holder;makeslime=[mob_uid]'>Make Slime</A> |
					<A href='byond://?_src_=holder;makesuper=[mob_uid]'>Make Superhero</A> |
				"}

			//Simple Animals
			if(isanimal_or_basicmob(M))
				body += "<A href='byond://?_src_=holder;makeanimal=[mob_uid]'>Re-Animalize</A> | "
			else
				body += "<A href='byond://?_src_=holder;makeanimal=[mob_uid]'>Animalize</A> | "

			if(isobserver(M))
				body += "<A href='byond://?_src_=holder;incarn_ghost=[mob_uid]'>Re-incarnate</a> | "

			if(ispAI(M))
				body += "<B>Is a pAI</B> "
			else
				body += "<A href='byond://?_src_=holder;makePAI=[mob_uid]'>Make pAI</A> | "

			// DNA2 - Admin Hax
			if(M.dna && iscarbon(M))
				body += "<br><br>"
				body += "<b>DNA Blocks:</b><br><table border='0'><tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>"
				var/bname
				for(var/block in 1 to DNA_SE_LENGTH)
					if(((block-1)%5)==0)
						body += "</tr><tr><th>[block-1]</th>"
					bname = GLOB.assigned_blocks[block]
					body += "<td>"
					if(bname)
						var/bstate=M.dna.GetSEState(block)
						var/bcolor="[(bstate)?"#006600":"#ff0000"]"
						body += "<A href='byond://?_src_=holder;togmutate=[mob_uid];block=[block]' style='color:[bcolor];'>[bname]</A><sub>[block]</sub>"
					else
						body += "[block]"
					body+="</td>"
				body += "</tr></table>"

			body += {"<br><br>
				<b>Rudimentary transformation:</b><font size=2><br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</font><br>
				<A href='byond://?_src_=holder;simplemake=observer;mob=[mob_uid]'>Observer</A> |
				\[ Alien: <A href='byond://?_src_=holder;simplemake=drone;mob=[mob_uid]'>Drone</A>,
				<A href='byond://?_src_=holder;simplemake=hunter;mob=[mob_uid]'>Hunter</A>,
				<A href='byond://?_src_=holder;simplemake=queen;mob=[mob_uid]'>Queen</A>,
				<A href='byond://?_src_=holder;simplemake=sentinel;mob=[mob_uid]'>Sentinel</A>,
				<A href='byond://?_src_=holder;simplemake=larva;mob=[mob_uid]'>Larva</A> \]
				<A href='byond://?_src_=holder;simplemake=human;mob=[mob_uid]'>Human</A>
				\[ slime: <A href='byond://?_src_=holder;simplemake=slime;mob=[mob_uid]'>Baby</A>,
				<A href='byond://?_src_=holder;simplemake=adultslime;mob=[mob_uid]'>Adult</A> \]
				<A href='byond://?_src_=holder;simplemake=monkey;mob=[mob_uid]'>Monkey</A> |
				<A href='byond://?_src_=holder;simplemake=robot;mob=[mob_uid]'>Cyborg</A> |
				<A href='byond://?_src_=holder;simplemake=cat;mob=[mob_uid]'>Cat</A> |
				<A href='byond://?_src_=holder;simplemake=runtime;mob=[mob_uid]'>Runtime</A> |
				<A href='byond://?_src_=holder;simplemake=corgi;mob=[mob_uid]'>Corgi</A> |
				<A href='byond://?_src_=holder;simplemake=ian;mob=[mob_uid]'>Ian</A> |
				<A href='byond://?_src_=holder;simplemake=crab;mob=[mob_uid]'>Crab</A> |
				<A href='byond://?_src_=holder;simplemake=coffee;mob=[mob_uid]'>Coffee</A> |
				\[ Construct: <A href='byond://?_src_=holder;simplemake=constructarmoured;mob=[mob_uid]'>Armoured</A> ,
				<A href='byond://?_src_=holder;simplemake=constructbuilder;mob=[mob_uid]'>Builder</A> ,
				<A href='byond://?_src_=holder;simplemake=constructwraith;mob=[mob_uid]'>Wraith</A> \]
				<A href='byond://?_src_=holder;simplemake=shade;mob=[mob_uid]'>Shade</A>
			"}

	if(M.client)
		body += {"<br><br>
			<b>Other actions:</b>
			<br>
			<A href='byond://?_src_=holder;forcespeech=[mob_uid]'>Forcesay</A> |
			<A href='byond://?_src_=holder;aroomwarp=[mob_uid]'>Admin Room</A> |
			<A href='byond://?_src_=holder;tdome1=[mob_uid]'>Thunderdome 1</A> |
			<A href='byond://?_src_=holder;tdome2=[mob_uid]'>Thunderdome 2</A> |
			<A href='byond://?_src_=holder;tdomeadmin=[mob_uid]'>Thunderdome Admin</A> |
			<A href='byond://?_src_=holder;tdomeobserve=[mob_uid]'>Thunderdome Observer</A> |
			<A href='byond://?_src_=holder;contractor_stop=[mob_uid]'>Stop Syndicate Jail Timer</A> |
			<A href='byond://?_src_=holder;contractor_start=[mob_uid]'>Start Syndicate Jail Timer</A> |
			<A href='byond://?_src_=holder;contractor_release=[mob_uid]'>Release now from Syndicate Jail</A> |
		"}

	body += {"<br>
		</body></html>
	"}

	client << browse(body, "window=adminplayeropts;size=550x615")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
