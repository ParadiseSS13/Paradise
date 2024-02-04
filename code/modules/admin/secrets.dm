/datum/admins
	var/current_tab =0

/datum/admins/proc/Secrets()


	if(!check_rights(0))	return
	var/dat = "<html><body><center>"

	dat += "<a href='?src=[UID()];secretsmenu=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Debug</a>"
	dat += "<a href='?src=[UID()];secretsmenu=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>IC Events</a>"
	dat += "<a href='?src=[UID()];secretsmenu=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>OOC Events</a>"

	dat += "</center>"
	dat += "<HR>"
	switch(current_tab)
		if(0) // Debug
			if(check_rights(R_ADMIN,0))
				dat += {"
						<center><B><h2>Admin Secrets</h2></B>
						<B>Game</b><br>
						<A href='?src=[UID()];secretsadmin=showailaws'>Show AI Laws</A>&nbsp;&nbsp;
						<A href='?src=[UID()];secretsadmin=showgm'>Show Game Mode</A>&nbsp;&nbsp;
						<A href='?src=[UID()];secretsadmin=manifest'>Show Crew Manifest</A><br>
						<A href='?src=[UID()];secretsadmin=check_antagonist'>Show current traitors and objectives</A><BR>
						<A href='?src=[UID()];secretsadmin=view_codewords'>Show code phrases and responses</A><BR>
						<a href='?src=[UID()];secretsadmin=night_shift_set'>Set Night Shift Mode</a><br>
						<B>Bombs</b><br>
						[check_rights(R_SERVER, 0) ? "&nbsp;&nbsp;<A href='?src=[UID()];secretsfun=togglebombcap'>Toggle bomb cap</A><br>" : "<br>"]
						<B>Lists</b><br>
						<A href='?src=[UID()];secretsadmin=list_signalers'>Show last [length(GLOB.lastsignalers)] signalers</A>&nbsp;&nbsp;
						<A href='?src=[UID()];secretsadmin=list_lawchanges'>Show last [length(GLOB.lawchanges)] law changes</A><BR>
						<A href='?src=[UID()];secretsadmin=DNA'>List DNA (Blood)</A>&nbsp;&nbsp;
						<A href='?src=[UID()];secretsadmin=fingerprints'>List Fingerprints</A><BR>
						<B>Power</b><br>
						<A href='?src=[UID()];secretsfun=blackout'>Break all lights</A>&nbsp;&nbsp;
						<A href='?src=[UID()];secretsfun=whiteout'>Fix all lights</A><BR>
						<A href='?src=[UID()];secretsfun=power'>Make all areas powered</A>&nbsp;&nbsp;
						<A href='?src=[UID()];secretsfun=unpower'>Make all areas unpowered</A>&nbsp;&nbsp;
						<A href='?src=[UID()];secretsfun=quickpower'>Power all SMES</A><BR>
						</center>
					"}

			else if(check_rights(R_SERVER,0)) //only add this if admin secrets are unavailiable; otherwise, it's added inline
				dat += "<center><b>Bomb cap: </b><A href='?src=[UID()];secretsfun=togglebombcap'>Toggle bomb cap</A><BR></center>"
				dat += "<BR>"
			if(check_rights(R_DEBUG,0))
				dat += {"
					<center>
					<B>Security Level Elevated</B><BR>
					<BR>
					<A href='?src=[UID()];secretscoder=maint_access_engiebrig'>Change all maintenance doors to engie/brig access only</A><BR>
					<A href='?src=[UID()];secretscoder=maint_ACCESS_BRIG'>Change all maintenance doors to brig access only</A><BR>
					<A href='?src=[UID()];secretscoder=infinite_sec'>Remove cap on security officers</A>&nbsp;&nbsp;
					<BR>
					<B>Coder Secrets</B><BR>
					<BR>
					<A href='?src=[UID()];secretsadmin=list_job_debug'>Show Job Debug</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretscoder=spawn_objects'>Admin Log</A><BR>
					<BR>
					</center>
					"}

		if(1)
			if(check_rights((R_EVENT|R_SERVER),0))
				var/security_levels_data = ""
				for(var/level_name in SSsecurity_level.available_levels)
					var/datum/security_level/this_level = SSsecurity_level.available_levels[level_name]
					security_levels_data += "<a href='?src=[UID()];secretsfun=securitylevel;number=[this_level.number_level]'>[this_level.name]</a>"

				dat += {"
					<center>
					<h2><B>IC Events</B></h2>
					<b>Teams</b><br>
					<A href='?src=[UID()];secretsfun=infiltrators_syndicate'>Send SIT - Syndicate Infiltration Team</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=striketeam_syndicate'>Send in a Syndie Strike Team</A>&nbsp;&nbsp;
					<BR><A href='?src=[UID()];secretsfun=deathsquad'>Send in the Deathsquad</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=gimmickteam'>Send in a Gimmick Team</A><BR>
					<b>Change Security Level</b><BR>
					[security_levels_data]<BR>
					<b>Create Weather</b><BR>
					<A href='?src=[UID()];secretsfun=weatherashstorm'>Weather - Ash Storm</A>&nbsp;&nbsp;
					<BR>
					<b>Reinforce Station</b><BR>
					<A href='?src=[UID()];secretsfun=gammashuttle'>Move the Gamma Armory</A>&nbsp;&nbsp;
					<BR>
					</center>"}

		if(2)
			if(check_rights((R_SERVER|R_EVENT),0))
				dat += {"
					<center>
					<h2><B>OOC Events</B></h2>
					<b>Thunderdome</b><br>
					<A href='?src=[UID()];secretsfun=tdomestart'>Start a Thunderdome match</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=tdomereset'>Reset Thunderdome to default state</A><BR><br>
					<b>Clothing</b><br>
					<A href='?src=[UID()];secretsfun=sec_clothes'>Remove 'internal' clothing</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=sec_all_clothes'>Remove ALL clothing</A><BR>
					<b>TDM</b><br>
					<A href='?src=[UID()];secretsfun=traitor_all'>Everyone is the traitor</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=onlyone'>There can only be one!</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=onlyme'>There can only be me!</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=onlyoneteam'>Dodgeball (TDM)!</A><BR>
					<b>Round-enders</b><br>
					<A href='?src=[UID()];secretsfun=floorlava'>The floor is lava! (DANGEROUS: extremely lame)</A><BR>
					<A href='?src=[UID()];secretsfun=fakelava'>The floor is fake-lava! (non-harmful)</A><BR>
					<A href='?src=[UID()];secretsfun=monkey'>Turn all humans into monkeys</A><BR>
					<A href='?src=[UID()];secretsfun=fakeguns'>Make all items look like guns</A><BR>
					<A href='?src=[UID()];secretsfun=prisonwarp'>Warp all Players to Prison</A><BR>
					<A href='?src=[UID()];secretsfun=stupify'>Make all players stupid</A><BR>
					<b>Misc</b><br>
					<A href='?src=[UID()];secretsfun=sec_classic1'>Remove firesuits, grilles, and pods</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=tripleAI'>Triple AI mode (needs to be used in the lobby)</A><BR>
					<A href='?src=[UID()];secretsfun=flicklights'>Ghost Mode</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=schoolgirl'>Japanese Animes Mode</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=eagles'>Egalitarian Station Mode</A><BR>
					<A href='?src=[UID()];secretsfun=guns'>Summon Guns</A>&nbsp;&nbsp;
					<A href='?src=[UID()];secretsfun=magic'>Summon Magic</A>
					<BR>
					<A href='?src=[UID()];secretsfun=rolldice'>Roll the Dice</A><BR>
					<BR>
					<BR>
					<A href='?src=[UID()];secretsfun=moveferry'>Move Ferry</A><BR>
					<A href='?src=[UID()];secretsfun=moveminingshuttle'>Move Mining Shuttle</A><BR>
					<A href='?src=[UID()];secretsfun=movelaborshuttle'>Move Labor Shuttle</A><BR>
					<BR>
					</center>"}
	dat += "</center></body></html>"
	var/datum/browser/popup = new(usr, "secrets", "<div align='center'>Admin Secrets</div>", 630, 670)
	popup.set_content(dat)
	popup.open(0)
