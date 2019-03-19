//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki(query as text)
	set name = "wiki"
	set desc = "Type what you want to know about.  This will open the wiki in your web browser."
	set hidden = 1
	if(config.wikiurl)
		if(query)
			var/output = config.wikiurl + "/index.php?title=Special%3ASearch&profile=default&search=" + query
			src << link(output)
		else
			src << link(config.wikiurl)
	else
		to_chat(src, "<span class='danger'>The wiki URL is not set in the server configuration.</span>")
	return

/client/verb/changes()
	set name = "Changelog"
	set desc = "View the changelog."
	set hidden = 1

	getFiles(
		'html/88x31.png',
		'html/bug-minus.png',
		'html/cross-circle.png',
		'html/hard-hat-exclamation.png',
		'html/image-minus.png',
		'html/image-plus.png',
		'html/music-minus.png',
		'html/music-plus.png',
		'html/tick-circle.png',
		'html/wrench-screwdriver.png',
		'html/spell-check.png',
		'html/burn-exclamation.png',
		'html/chevron.png',
		'html/chevron-expand.png',
		'html/changelog.css',
		'html/changelog.js',
		'html/changelog.html'
		)
	src << browse('html/changelog.html', "window=changes;size=675x650")
	update_changelog_button()
	if(prefs.lastchangelog != changelog_hash) //if it's already opened, no need to tell them they have unread changes
		prefs.SetChangelog(src,changelog_hash)

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	if(config.forumurl)
		if(alert("This will open the forum in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.forumurl)
	else
		to_chat(src, "<span class='danger'>The forum URL is not set in the server configuration.</span>")
	return

/client/verb/rules()
	set name = "Rules"
	set desc = "View the server rules."
	set hidden = 1
	if(config.rulesurl)
		if(alert("This will open the rules in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.rulesurl)
	else
		to_chat(src, "<span class='danger'>The rules URL is not set in the server configuration.</span>")
	return

/client/verb/github()
	set name = "GitHub"
	set desc = "Visit the GitHub page."
	set hidden = 1
	if(config.githuburl)
		if(alert("This will open our GitHub repository in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.githuburl)
	else
		to_chat(src, "<span class='danger'>The GitHub URL is not set in the server configuration.</span>")
	return

/client/verb/discord()
	set name = "Discord"
	set desc = "Join our Discord server."
	set hidden = 1
	if(config.discordurl)
		if(alert("This will invite you to our Discord server. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.discordurl)
	else
		to_chat(src, "<span class='danger'>The Discord URL is not set in the server configuration.</span>")
	return
	
/client/verb/donate()
	set name = "Donate"
	set desc = "Donate to help with hosting costs."
	set hidden = 1
	if(config.donationsurl)
		if(alert("This will open the donation page in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.donationsurl)
	else
		to_chat(src, "<span class='danger'>The rules URL is not set in the server configuration.</span>")
	return

/client/verb/hotkeys_help()
	set name = "Hotkey Help"
	set category = "OOC"

	var/adminhotkeys = {"<font color='purple'>
Admin:
\tF5 = Asay
\tF6 = Admin Ghost
\tF7 = Player Panel
\tF8 = Admin PM
\tF9 = Invisimin

Admin ghost:
\tCtrl+Click = Player Panel
\tCtrl+Shift+Click = View Variables
\tShift+Middle Click = Mob Info
</font>"}

	mob.hotkey_help()

	if(check_rights(R_MOD|R_ADMIN,0))
		to_chat(src, adminhotkeys)

/mob/proc/hotkey_help()
	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = Toggle Hotkey Mode
\ta = Move Left
\ts = Move Down
\td = Move Right
\tw = Move Up
\tq = Drop Item
\te = Equip Item
\tr = Throw Item
\tm = Me
\tt = Say
\to = OOC
\tb = Resist
\tx = Swap Hands
\tz = Activate Held Object (or y)
\tf = Cycle Intents Left
\tg = Cycle Intents Right
\t1 = Help Intent
\t2 = Disarm Intent
\t3 = Grab Intent
\t4 = Harm Intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = Move Left
\tCtrl+s = Move Down
\tCtrl+d = Move Right
\tCtrl+w = Move Up
\tCtrl+q = Drop Item
\tCtrl+e = Equip Item
\tCtrl+r = Throw Item
\tCtrl+b = Resist
\tCtrl+o = OOC
\tCtrl+x = Swap Hands
\tCtrl+z = Activate Held Object (or Ctrl+y)
\tCtrl+f = Cycle Intents Left
\tCtrl+g = Cycle Intents Right
\tCtrl+1 = Help Intent
\tCtrl+2 = Disarm Intent
\tCtrl+3 = Grab Intent
\tCtrl+4 = Harm Intent
\tDEL = Pull
\tINS = Cycle Intents Right
\tHOME = Drop Item
\tPGUP = Swap Hands
\tPGDN = Activate Held Object
\tEND = Throw Item
\tF2 = OOC
\tF3 = Say
\tF4 = Me
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)

/mob/living/silicon/robot/hotkey_help()
	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = Toggle Hotkey Mode
\ta = Move Left
\ts = Move Down
\td = Move Right
\tw = Move Up
\tq = Unequip Active Module
\tm = Me
\tt = Say
\to = OOC
\tx = Cycle Active Modules
\tb = Resist
\tz = Activate Held Object (or y)
\tf = Cycle Intents Left
\tg = Cycle Intents Right
\t1 = Activate Module 1
\t2 = Activate Module 2
\t3 = Activate Module 3
\t4 = Toggle Intents
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = Move Left
\tCtrl+s = Move Down
\tCtrl+d = Move Right
\tCtrl+w = Move Up
\tCtrl+q = Unequip Active Module
\tCtrl+x = Cycle Active Modules
\tCtrl+b = Resist
\tCtrl+o = OOC
\tCtrl+z = Activate Held Object (or Ctrl+y)
\tCtrl+f = Cycle Intents Left
\tCtrl+g = Cycle Intents Right
\tCtrl+1 = Activate Module 1
\tCtrl+2 = Activate Module 2
\tCtrl+3 = Activate Module 3
\tCtrl+4 = Toggle Intents
\tDEL = Pull
\tINS = Toggle Intents
\tPGUP = Cycle Active Modules
\tPGDN = Activate Held Object
\tF2 = OOC
\tF3 = Say
\tF4 = Me
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)

//adv. hotkey mode verbs, vars located in /code/modules/client/client defines.dm
/client/verb/hotkey_toggle()//toggles hotkey mode between on and off, respects selected type
	set name = ".Toggle Hotkey Mode"

	hotkeyon = !hotkeyon//toggle the var
	to_chat(usr, (hotkeyon ? "Hotkey mode enabled." : "Hotkey mode disabled."))//feedback to the user

	if(hotkeyon)//using an if statement because I don't want to clutter winset() with ? operators
		winset(usr, "mainwindow.hotkey_toggle", "is-checked=true")//checks the button
	else
		winset(usr, "mainwindow.hotkey_toggle", "is-checked=false")//unchecks the button
	if(mob)
		mob.update_interface()

/client/verb/hotkey_mode()//asks user for the hotkey type and changes the macro accordingly
	set name = "Set Hotkey Mode"
	set category = "Preferences"

	var/hkt = input("Choose hotkey mode", "Hotkey mode") as null|anything in hotkeylist//ask the user for the hotkey type
	if(!hkt)
		return
	hotkeytype = hkt

	var/hotkeys = hotkeylist[hotkeytype]//get the list containing the hotkey names
	var/hotkeyname = hotkeys[hotkeyon ? "on" : "off"]//get the name of the hotkey, to not clutter winset() to much

	winset(usr, "mainwindow", "macro=[hotkeyname]")//change the hotkey
	to_chat(usr, "Hotkey mode changed to [hotkeytype].")
