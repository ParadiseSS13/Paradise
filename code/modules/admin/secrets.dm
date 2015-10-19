/datum/admins
	var/current_tab =0

/datum/admins/proc/Secrets()


	if(!check_rights(0))	return
	var/dat = "<html><body><center>"

	dat += "<a href='?src=\ref[src];secretsmenu=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Debug</a>"
	dat += "<a href='?src=\ref[src];secretsmenu=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>IC Events</a>"
	dat += "<a href='?src=\ref[src];secretsmenu=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>OOC Events</a>"

	dat += "</center>"
	dat += "<HR>"
	switch(current_tab)
		if (0) // Debug
			if(check_rights(R_ADMIN,0))
				dat += {"
						<center><B><h2>Admin Secrets</h2></B>
						<B>Game</b><br>
						<A href='?src=\ref[src];secretsadmin=showailaws'>Show AI Laws</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsadmin=showgm'>Show Game Mode</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsadmin=manifest'>Show Crew Manifest</A><br>
						<A href='?src=\ref[src];secretsadmin=check_antagonist'>Show current traitors and objectives</A><BR>
						<B>Bombs</b><br>
						<A href='?src=\ref[src];secretsadmin=list_bombers'>Bombing List</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsadmin=clear_bombs'>Remove all bombs currently in existence</A>
						[check_rights(R_SERVER, 0) ? "&nbsp;&nbsp;<A href='?src=\ref[src];secretsfun=togglebombcap'>Toggle bomb cap</A><br>" : "<br>"]
						<B>Lists</b><br>
						<A href='?src=\ref[src];secretsadmin=list_signalers'>Show last [length(lastsignalers)] signalers</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsadmin=list_lawchanges'>Show last [length(lawchanges)] law changes</A><BR>
						<A href='?src=\ref[src];secretsadmin=DNA'>List DNA (Blood)</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsadmin=fingerprints'>List Fingerprints</A><BR>
						<B>Power</b><br>
						<A href='?src=\ref[src];secretsfun=blackout'>Break all lights</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsfun=whiteout'>Fix all lights</A><BR>
						<A href='?src=\ref[src];secretsfun=power'>Make all areas powered</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsfun=unpower'>Make all areas unpowered</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsfun=quickpower'>Power all SMES</A><BR>
						<BR>
						<B>Shuttle options</b><br>
						<A href='?src=\ref[src];secretsfun=launchshuttle'>Launch a shuttle</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsfun=forcelaunchshuttle'>Force launch a shuttle</A><BR>
						<A href='?src=\ref[src];secretsfun=jumpshuttle'>Jump a shuttle</A>&nbsp;&nbsp;
						<A href='?src=\ref[src];secretsfun=moveshuttle'>Move a shuttle</A><BR>
						<BR></center>
					"}

			else if(check_rights(R_SERVER,0)) //only add this if admin secrets are unavailiable; otherwise, it's added inline
				dat += "<center><b>Bomb cap: </b><A href='?src=\ref[src];secretsfun=togglebombcap'>Toggle bomb cap</A><BR></center>"
				dat += "<BR>"
			if(check_rights(R_DEBUG,0))
				dat += {"
					<center>
					<B>Security Level Elevated</B><BR>
					<BR>
					<A href='?src=\ref[src];secretscoder=maint_access_engiebrig'>Change all maintenance doors to engie/brig access only</A><BR>
					<A href='?src=\ref[src];secretscoder=maint_access_brig'>Change all maintenance doors to brig access only</A><BR>
					<A href='?src=\ref[src];secretscoder=infinite_sec'>Remove cap on security officers</A>&nbsp;&nbsp;
					<BR>
					<B>Coder Secrets</B><BR>
					<BR>
					<A href='?src=\ref[src];secretsadmin=list_job_debug'>Show Job Debug</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretscoder=spawn_objects'>Admin Log</A><BR>
					<BR>
					</center>
					"}

		if (1)
			if(check_rights((R_EVENT|R_SERVER),0))
				dat += {"
					<center>
					<h2><B>IC Events</B></h2>
					<b>Teams</b><br>
					<A href='?src=\ref[src];secretsfun=striketeam'>Send in a strike team</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=striketeam_syndicate'>Send in a syndicate strike team</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=honksquad'>Send in a HONKsquad</A><BR>
					<b>Change Security Level</b><BR>
					<A href='?src=\ref[src];secretsfun=securitylevel0'>Security Level - Green</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=securitylevel1'>Security Level - Blue</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=securitylevel2'>Security Level - Red</A><br>
					<A href='?src=\ref[src];secretsfun=securitylevel3'>Security Level - Gamma</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=securitylevel4'>Security Level - Epsilon</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=securitylevel5'>Security Level - Delta</A><BR>
					<BR>
					</center>"}

		if (2)
			if(check_rights((R_SERVER|R_EVENT),0))
				dat += {"
					<center>
					<h2><B>OOC Events</B></h2>
					<b>Thunderdome</b><br>
					<A href='?src=\ref[src];secretsfun=tdomestart'>Start a Thunderdome match</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=tdomereset'>Reset Thunderdome to default state</A><BR><br>
					<b>Clothing</b><br>
					<A href='?src=\ref[src];secretsfun=sec_clothes'>Remove 'internal' clothing</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=sec_all_clothes'>Remove ALL clothing</A><BR>
					<b>TDM</b><br>
					<A href='?src=\ref[src];secretsfun=traitor_all'>Everyone is the traitor</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=onlyone'>There can only be one!</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=onlyoneteam'>Dodgeball (TDM)!</A><BR>
					<b>Round-enders</b><br>
					<A href='?src=\ref[src];secretsfun=floorlava'>The floor is lava! (DANGEROUS: extremely lame)</A><BR>
					<A href='?src=\ref[src];secretsfun=monkey'>Turn all humans into monkeys</A><BR>
					<A href='?src=\ref[src];secretsfun=fakeguns'>Make all items look like guns</A><BR>
					<A href='?src=\ref[src];secretsfun=prisonwarp'>Warp all Players to Prison</A><BR>
					<A href='?src=\ref[src];secretsfun=retardify'>Make all players retarded</A><BR>
					<b>Misc</b><br>
					<A href='?src=\ref[src];secretsfun=sec_classic1'>Remove firesuits, grilles, and pods</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=tripleAI'>Triple AI mode (needs to be used in the lobby)</A><BR>
					<A href='?src=\ref[src];secretsfun=flicklights'>Ghost Mode</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=schoolgirl'>Japanese Animes Mode</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=eagles'>Egalitarian Station Mode</A><BR>
					<A href='?src=\ref[src];secretsfun=guns'>Summon Guns</A>&nbsp;&nbsp;
					<A href='?src=\ref[src];secretsfun=magic'>Summon Magic</A>
					<BR>
					<A href='?src=\ref[src];secretsfun=rolldice'>Roll the Dice</A><BR>
					<BR>
					</center>"}
	dat += "</center></body></html>"
	var/datum/browser/popup = new(usr, "secrets", "<div align='center'>Admin Secrets</div>", 630, 670)
	popup.set_content(dat)
	popup.open(0)


