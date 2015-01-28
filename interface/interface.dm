//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki(query as text)
	set name = "wiki"
	set desc = "Type what you want to know about.  This will open the wiki on your web browser."
	set hidden = 1
	if(config.wikiurl)
		if(query)
			var/output = config.wikiurl + "/index.php?title=Special%3ASearch&profile=default&search=" + query
			src << link(output)
		else
			src << link(config.wikiurl)
	else
		src << "<span class='danger'>The wiki URL is not set in the server configuration.</span>"
	return

#define CHANGELOG "http://nanotrasen.se/phpBB3/viewtopic.php?f=10&t=36"
/client/verb/changes()
	set name = "Changelog"
	set desc = "Visit the forum to check out the changelog."
	set hidden = 1

	if(alert("This will open the changelog in your browser. Are you sure?",,"Yes","No")=="No")
		return
	src << link(CHANGELOG)
	return
#undef CHANGELOG

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	if( config.forumurl )
		if(alert("This will open the forum in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.forumurl)
	else
		src << "\red The forum URL is not set in the server configuration."
	return

#define RULES_FILE "config/rules.html"
/client/verb/rules()
	set name = "Rules"
	set desc = "Show Server Rules."
	set hidden = 1
	src << browse(file(RULES_FILE), "window=rules;size=480x320")
#undef RULES_FILE

#define DONATE "http://nanotrasen.se/phpBB3/donate.php"
/client/verb/donate()
	set name = "Donate"
	set desc = "Donate to help with development costs."
	set hidden = 1

	if(alert("This will open the changelog in your browser. Are you sure?",,"Yes","No")=="No")
		return
	src << link(DONATE)
	return
#undef DONATE

/client/verb/hotkeys_help()
	set name = "Hotkeys Help"
	set category = "OOC"

	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = drop
\te = equip
\tr = throw
\tt = say
\tx = swap-hand
\tz = activate held object (or y)
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+x = swap-hand
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tDEL = pull
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
</font>"}

	var/admin = {"<font color='purple'>
Admin:
\tF5 = Aghost (admin-ghost)
\tF6 = player-panel-new
\tF7 = admin-pm
\tF8 = Invisimin
</font>"}

	src << hotkey_mode
	src << other
	if(holder)
		src << admin


//adv. hotkey mode verbs, vars located in /code/modules/client/client defines.dm

/client/verb/hotkey_toggle()//toggles hotkey mode between on and off, respects selected type
	set name = ".Toggle hotkey mode"

	hotkeyon = !hotkeyon//toggle the var

	var/hotkeys = hotkeylist[hotkeytype]//get the list containing the hotkey names
	var/hotkeyname = hotkeys[hotkeyon ? "on" : "off"]//get the name of the hotkey, to not clutter winset() to much

	winset(usr, "mainwindow", "macro=[hotkeyname]")//change the hotkey
	usr << (hotkeyon ? "Hotkey mode enabled." : "Hotkey mode disabled.")//feedback to the user

	if(hotkeyon)//using an if statement because I don't want to clutter winset() with ? operators
		winset(usr, "mainwindow.hotkey_toggle", "is-checked=true")//checks the button
		winset(usr, "mapwindow.map", "focus=true")//sets mapwindow focus
	else
		winset(usr, "mainwindow.hotkey_toggle", "is-checked=false")//unchecks the button
		winset(usr, "mainwindow.input", "focus=true")//sets focus

/client/verb/hotkey_mode()//asks user for the hotkey type and changes the macro accordingly
	set name = "Set hotkey mode"
	set category = "Preferences"

	hotkeytype = input("Choose hotkey mode", "Hotkey mode") as null|anything in hotkeylist//ask the user for the hotkey type

	var/hotkeys = hotkeylist[hotkeytype]//get the list containing the hotkey names
	var/hotkeyname = hotkeys[hotkeyon ? "on" : "off"]//get the name of the hotkey, to not clutter winset() to much

	winset(usr, "mainwindow", "macro=[hotkeyname]")//change the hotkey
	usr << "Hotkey mode changed to [hotkeytype]."
